#!/bin/bash
# زنجیر - اسکریپت نصب خودکار
# پیام‌رسان امن و غیرمتمرکز بر پایه Matrix
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_banner() {
    echo ""
    echo -e "${CYAN}=================================================${NC}"
    echo -e "${CYAN}       زنجیر - نصب‌کننده خودکار Matrix           ${NC}"
    echo -e "${CYAN}=================================================${NC}"
    echo ""
}

log_info() { echo -e "${BLUE}[*]${NC} $1"; }
log_success() { echo -e "${GREEN}[+]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[-]${NC} $1"; }

check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "لطفا با sudo اجرا کنید."
        exit 1
    fi
}

is_ip_address() {
    local ip=$1
    [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
}

get_user_input() {
    echo ""
    log_info "چند تا سوال ازت میپرسم..."
    echo ""
    
    # Get server address
    while true; do
        read -p "آدرس سرور (دامنه یا IP): " SERVER_ADDRESS
        if [ -n "$SERVER_ADDRESS" ]; then
            break
        fi
        log_error "آدرس نمیتونه خالی باشه!"
    done
    
    # Detect IP mode
    if is_ip_address "$SERVER_ADDRESS"; then
        IP_MODE=true
        PROTOCOL="http"
        log_warning "حالت IP تشخیص داده شد. بدون SSL اجرا میشه."
    else
        IP_MODE=false
        PROTOCOL="https"
        log_success "حالت دامنه. SSL از Let's Encrypt گرفته میشه."
    fi
    
    # Get admin email (only for domain mode)
    if [ "$IP_MODE" = false ]; then
        read -p "ایمیل ادمین (برای SSL): " ADMIN_EMAIL
        if [ -z "$ADMIN_EMAIL" ]; then
            ADMIN_EMAIL="admin@${SERVER_ADDRESS}"
        fi
    else
        ADMIN_EMAIL=""
    fi
    
    echo ""
    log_info "تنظیمات:"
    echo "   آدرس: ${SERVER_ADDRESS}"
    echo "   پروتکل: ${PROTOCOL}"
    if [ "$IP_MODE" = false ]; then
        echo "   ایمیل: ${ADMIN_EMAIL}"
    fi
    echo ""
    
    read -p "درسته؟ (Y/n): " confirm
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        log_error "لغو شد."
        exit 1
    fi
}

install_docker() {
    if command -v docker &> /dev/null; then
        log_success "Docker نصبه."
        return
    fi
    log_info "نصب Docker..."
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker
    systemctl start docker
    log_success "Docker نصب شد."
}

install_docker_compose() {
    if command -v docker compose &> /dev/null; then
        log_success "Docker Compose نصبه."
        return
    fi
    log_info "نصب Docker Compose..."
    apt-get update -qq && apt-get install -y -qq docker-compose-plugin
    log_success "Docker Compose نصب شد."
}

generate_secrets() {
    log_info "تولید کلیدهای امنیتی..."
    POSTGRES_PASSWORD=$(openssl rand -base64 24 | tr -d '/+=')
    REGISTRATION_SECRET=$(openssl rand -base64 32 | tr -d '/+=')
    log_success "کلیدها ساخته شدن."
}

create_env_file() {
    log_info "ساخت فایل .env..."
    cat > .env <<EOF
DOMAIN=${SERVER_ADDRESS}
SERVER_ADDRESS=${SERVER_ADDRESS}
PROTOCOL=${PROTOCOL}
IP_MODE=${IP_MODE}
REGISTRATION_SHARED_SECRET=${REGISTRATION_SECRET}
POSTGRES_USER=dendrite
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=dendrite
LETSENCRYPT_EMAIL=${ADMIN_EMAIL}
EOF
    chmod 600 .env
    log_success "فایل .env ساخته شد."
}

setup_caddyfile() {
    log_info "تنظیم Caddy..."
    if [ "$IP_MODE" = true ]; then
        cp Caddyfile.ip-mode Caddyfile.active
    else
        cp Caddyfile Caddyfile.active
    fi
}

update_element_config() {
    log_info "تنظیم Element..."
    
    if [ "$IP_MODE" = true ]; then
        sed -i "s|https://\${DOMAIN}|http://${SERVER_ADDRESS}|g" config/element-config.json
        sed -i "s|\${DOMAIN}|${SERVER_ADDRESS}|g" config/element-config.json
    else
        sed -i "s|\${DOMAIN}|${SERVER_ADDRESS}|g" config/element-config.json
    fi
}

update_dendrite_config() {
    log_info "تنظیم Dendrite..."
    
    sed -i "s/\${DOMAIN}/${SERVER_ADDRESS}/g" dendrite/dendrite.yaml
    sed -i "s/\${POSTGRES_USER}/dendrite/g" dendrite/dendrite.yaml
    sed -i "s/\${POSTGRES_PASSWORD}/${POSTGRES_PASSWORD}/g" dendrite/dendrite.yaml
    sed -i "s/\${POSTGRES_DB}/dendrite/g" dendrite/dendrite.yaml
    sed -i "s/\${REGISTRATION_SHARED_SECRET}/${REGISTRATION_SECRET}/g" dendrite/dendrite.yaml
    
    if [ "$IP_MODE" = true ]; then
        sed -i "s|:443|:80|g" dendrite/dendrite.yaml
        sed -i "s|https://|http://|g" dendrite/dendrite.yaml
    fi
}

generate_matrix_key() {
    log_info "تولید کلید Matrix..."
    if [ ! -f "dendrite/matrix_key.pem" ]; then
        docker run --rm -v "$(pwd)/dendrite:/etc/dendrite" \
            matrixdotorg/dendrite-monolith:latest \
            /usr/bin/generate-keys --private-key /etc/dendrite/matrix_key.pem 2>/dev/null
        chmod 600 dendrite/matrix_key.pem
        log_success "کلید Matrix ساخته شد."
    else
        log_warning "کلید Matrix از قبل هست."
    fi
}

start_services() {
    log_info "راه‌اندازی سرویس‌ها..."
    
    docker compose run --rm element-copy 2>/dev/null
    docker compose up -d postgres dendrite element caddy 2>/dev/null
    
    log_success "سرویس‌ها بالا اومدن."
}

print_success() {
    echo ""
    echo -e "${GREEN}=================================================${NC}"
    echo -e "${GREEN}            نصب تموم شد!                        ${NC}"
    echo -e "${GREEN}=================================================${NC}"
    echo ""
    echo "آدرس: ${PROTOCOL}://${SERVER_ADDRESS}"
    
    if [ "$IP_MODE" = true ]; then
        echo ""
        echo -e "${YELLOW}توجه: بدون SSL داره کار میکنه. فقط برای تست مناسبه.${NC}"
    fi
    
    echo ""
    echo "برای ساخت یوزر ادمین:"
    echo ""
    echo "docker exec -it zanjir-dendrite /usr/bin/create-account \\"
    echo "    --config /etc/dendrite/dendrite.yaml \\"
    echo "    --username YOUR_USERNAME \\"
    echo "    --admin"
    echo ""
    echo "رمز ثبت‌نام (برای استفاده از API): ${REGISTRATION_SECRET}"
    echo ""
    echo "اطلاعات توی فایل .env ذخیره شدن."
    echo ""
}

# Main
print_banner
check_root
get_user_input
install_docker
install_docker_compose
generate_secrets
create_env_file
setup_caddyfile
update_element_config
update_dendrite_config
generate_matrix_key
start_services
print_success
