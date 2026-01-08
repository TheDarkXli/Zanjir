#!/usr/bin/env bash
set -euo pipefail

wait_for_synapse() {
  local attempts=30
  while [ "$attempts" -gt 0 ]; do
    if docker exec zanjir-synapse python - <<'PY' >/dev/null 2>&1
import urllib.request
urllib.request.urlopen("http://localhost:8008/_matrix/client/versions", timeout=2).read()
PY
    then
      return 0
    fi
    sleep 2
    attempts=$((attempts - 1))
  done
  return 1
}

if ! docker ps --format '{{.Names}}' | grep -q '^zanjir-synapse$'; then
  echo "Synapse container is not running. Start it with: docker compose up -d synapse"
  exit 1
fi

if ! wait_for_synapse; then
  echo "Synapse is not responding yet. Check logs with: docker compose logs -f synapse"
  exit 1
fi

docker exec -it zanjir-synapse \
  register_new_matrix_user \
  -c /data/homeserver.yaml \
  http://localhost:8008 "$@"
