<div dir="rtl" align="right">

# زنجیر - پیام‌رسان امن و خصوصی بر پایه Matrix

<div align="center">

![زنجیر](https://img.shields.io/badge/زنجیر-v1.0.0-blue?style=for-the-badge)
![Matrix](https://img.shields.io/badge/Matrix-Protocol-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-Apache%202.0-orange?style=for-the-badge)

**سرور پیام‌رسان شخصی، مخصوص VPS های ایران**

</div>

---
[![zanjir-screens-copy.webp](https://i.postimg.cc/yYjVzZzN/zanjir-screens-copy.webp)](https://postimg.cc/9r43dz03)
## آموزش ویدئویی

[![معرفی پروژه زنجیر](https://i.postimg.cc/0Qq8qTFm/zanjir-copy.webp)](https://youtu.be/ZKTOs9y6rpw)


## معرفی

زنجیر یک بسته‌بندی آماده از پروتکل Matrix هست که برای شرایط ایران بهینه شده. هدف اینه که بتونی روی یه VPS اوبونتوی ایرانی، سرور پیام‌رسان شخصی خودت رو زیر ۵ دقیقه بالا بیاری.

این پروژه از Synapse (سرور رسمی Matrix) استفاده میکنه که برای پایداری و سازگاری با کلاینت‌های جدید مناسبه.

### چی داره؟

- **کاملا فارسی** - رابط کاربری ۱۰۰٪ فارسی و راست‌چین
- **رمزنگاری سرتاسری** - پیام‌ها E2E رمزنگاری میشن
- **مستقل** - Federation غیرفعاله، به سرور خارجی وصل نمیشه
- **سبک** - روی VPSهای ارزون ایرانی هم خوب کار میکنه
- **نصب ساده** - اسکریپت اینتراکتیو، فقط سوالات رو جواب بده
- **بدون وابستگی خارجی** - نیازی به سرویس‌های matrix.org نداره

### برای کی مناسبه؟

- تیم‌ها و شرکت‌هایی که پیام‌رسان داخلی میخوان
- گروه‌های دوستانه که چت امن میخوان
- هر کسی که میخواد دیتاش پیش خودش باشه

---

## پیش‌نیازها

### سخت‌افزار

| منبع | حداقل | پیشنهادی |
|------|-------|----------|
| CPU | 1 هسته | 2 هسته |
| RAM | 1 گیگابایت | 2 گیگابایت |
| دیسک | 10 گیگابایت | 20 گیگابایت |

### نرم‌افزار

- سیستم عامل: Ubuntu 22.04 یا 24.04
- یک دامنه با A Record به IP سرور (یا فقط IP برای تست)
- دسترسی root به سرور

### درباره دامنه

میتونی از هر دامنه‌ای استفاده کنی. اگه دامنه نداری، با IP خالی هم کار میکنه ولی SSL نخواهی داشت.

---

## نصب

وارد سرور شو و این دستورات رو بزن:

```bash
git clone https://github.com/MatinSenPai/zanjir.git
cd zanjir
sudo bash install.sh
```

اسکریپت ازت میپرسه:
1. آدرس سرور (دامنه یا IP)
2. ایمیل (فقط برای SSL، اگه IP زدی لازم نیست)

بقیه کارا اتوماتیک انجام میشه.

---

## ساخت کاربر

ثبت‌نام باز نیست (که سرور اسپم نشه). یوزر رو دستی میسازی:

```bash
bash scripts/create-user.sh --admin
```

پسورد رو وارد کن و تمام. برای ساخت یوزر معمولی، بدون `--admin` اجرا کن.

---

## استفاده

### وب

مرورگر رو باز کن، آدرس سرور رو بزن. لاگین کن.

### موبایل (Element)

1. اپ Element رو از کافه‌بازار یا مایکت بگیر (یا APK دانلود کن)
2. گزینه ورود رو بزن
3. حتما آدرس سرور رو Edit کن و آدرس خودت رو بذار
4. لاگین کن

### ساخت گروه

دکمه + رو بزن، اتاق جدید، اسم بذار و تنظیمات پرایوسی رو انتخاب کن.

---

## کلاینت‌های مدرن و Sliding Sync

پروکسی قدیمی Sliding Sync (MSC3575) آرشیو شده و جای خودش رو به Simplified Sliding Sync (MSC4186) داده. زنجیر از پشتیبانی بومی Synapse برای MSC4186 استفاده می‌کنه و نیازی به پروکسی جداگانه نداره.

منابع:
- آرشیو شدن پروکسی: https://github.com/matrix-org/sliding-sync
- خبر رسمی مهاجرت: https://matrix.org/blog/2024/11/14/moving-to-native-sliding-sync/
- سینک ساده (MSC4186) در Synapse: https://2024.matrix.org/documents/talk_slides/LAB4%202024-09-21%2010_00%20Ivan%20Enderlin%20-%20Simplified%20Sliding%20Sync.pdf
- اشاره کلاینت‌ها به قابلیت `org.matrix.simplified_msc3575`: https://matrix-org.github.io/matrix-rust-sdk/src/matrix_sdk/sliding_sync/client.rs.html

برای بررسی پشتیبانی:

```bash
curl -sS https://<دامنه_یا_IP>/_matrix/client/versions | jq .
```

باید توی خروجی `unstable_features` مقدار `org.matrix.simplified_msc3575` رو ببینی.

---

## دستورات مفید

```bash
# وضعیت سرویس‌ها
docker compose ps

# لاگ‌ها
docker compose logs -f

# ریستارت
docker compose restart

# خاموش کردن
docker compose down

# آپدیت
docker compose pull
docker compose up -d
```

---

## مشکلات رایج

### خطای 403 موقع نصب Docker

اگه این خطا رو دیدی:
```
curl: (22) The requested URL returned error: 403
https://download.docker.com/...
```

**دلیل:** سرور نمیتونه به `download.docker.com` وصل بشه (تحریم یا بلاک)

**راه‌حل:** Docker رو از ریپوی اوبونتو نصب کن (تحریم‌خور نیست):

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
```

بعد اسکریپت نصب رو دوباره اجرا کن.

---

### مشکل Docker Compose (نسخه قدیمی)

اگه این خطا رو دیدی:
```
docker-compose: command not found
```

یا:
```
docker compose version
# Docker Compose version v1.x.x (قدیمی)
```

**راه‌حل:** نسخه جدید (v2) رو نصب کن:

```bash
# حذف نسخه قدیمی (اگه هست)
sudo apt remove docker-compose -y
sudo rm -f /usr/local/bin/docker-compose

# نصب نسخه جدید
sudo apt update
sudo apt install docker-compose-plugin -y
```

تست:

```bash
docker compose version
# باید نشون بده: Docker Compose version v2.x.x
```

**نکته:** دستور جدید `docker compose` هست (با فاصله)، نه `docker-compose` (با خط تیره).

---

### کندی Pull کردن ایمیج‌ها

اگه دانلود ایمیج‌های Docker کنده:

**۱. تنظیم Docker Mirror ایرانی:**

```bash
sudo nano /etc/docker/daemon.json
```

این محتوا رو بذار:

```json
{
  "registry-mirrors": [
    "https://docker.arvancloud.ir"
  ]
}
```

بعد:

```bash
sudo systemctl restart docker
```

---

### مشکل DNS

اگه به اینترنت وصل نمیشی:

```bash
sudo nano /etc/resolv.conf
```

این رو بذار:

```
nameserver 8.8.8.8
nameserver 1.1.1.1
```

بعد:

```bash
sudo systemctl restart systemd-resolved
ping google.com
```

---

### SSL نگرفت

دامنه رو چک کن. `dig +short yourdomain.com` باید IP سرور رو بده. اگه تازه ست کردی صبر کن.

### صفحه باز نمیشه

فایروال رو چک کن:

```bash
sudo ufw allow 80
sudo ufw allow 443
```

### لاگین نمیشه

یوزر نساختی. بخش ساخت کاربر رو بخون.

### کندی یا قطعی

- مطمئن شو سرور ایرانیه و فیلتر نیست
- اینترنت سرور رو چک کن

---

## ساختار پروژه

```
zanjir/
├── install.sh              # اسکریپت نصب
├── docker-compose.yml      # داکر
├── Caddyfile               # وب‌سرور (دامنه)
├── Caddyfile.ip-mode       # وب‌سرور (IP)
├── config/
│   ├── element-config.json # کانفیگ کلاینت
│   └── welcome.html        # صفحه اول
├── synapse/
│   ├── homeserver.yaml     # کانفیگ Synapse
│   └── log.config          # لاگ Synapse
└── scripts/
    └── create-user.sh      # ساخت کاربر
```

---

## امنیت

- پسورد قوی بذار
- فایل `.env` رو جایی آپلود نکن
- سرور رو آپدیت نگه دار

### بکاپ

```bash
# دیتابیس
docker exec zanjir-postgres pg_dump -U synapse synapse > backup.sql

# فایل‌ها
tar -czvf zanjir-backup.tar.gz synapse/ config/ .env
```

---

## نکات فنی

- **Federation غیرفعاله** - این سرور به سرورهای Matrix دیگه وصل نمیشه. دلیلش اینه که سرورهای matrix.org از ایران فیلتر هستن.
- **Identity Server نداره** - سرویس‌های تایید ایمیل و شماره تلفن matrix.org هم فیلتر هستن، پس غیرفعال شدن.
- **کاملا مستقل** - همه چیز روی سرور خودت اجرا میشه.
- **بدون وابستگی به matrix.org** - توی Synapse گزینه `trusted_key_servers: []` ست شده تا هیچ Key Server خارجی استفاده نشه. (مستندات: https://matrix-org.github.io/synapse/latest/usage/configuration/config_documentation.html و توضیح رفتار: https://github.com/matrix-org/synapse/issues/7047)

اگه بعدا خواستی Federation رو فعال کنی (مثلا سرور رو به خارج بردی)، باید `federation_enabled: true` رو داخل `synapse/homeserver.yaml` ست کنی و بعد سرویس‌ها رو ریستارت کنی.

---

## لایسنس

Apache 2.0

---

## کردیت

- [Matrix.org](https://matrix.org)
- [Synapse](https://github.com/matrix-org/synapse)
- [Element](https://element.io)
- [Caddy](https://caddyserver.com)

---

مشکلی دیدی توی Issues بگو.

<div align="center">

**تقدیم به بچه‌های خوب ایران**

</div>

</div>
