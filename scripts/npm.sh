#!/usr/bin/env bash
set -euo pipefail

# npm.sh - Install Nginx Proxy Manager (NPM) on Ubuntu using Docker
# Usage: sudo ./npm.sh

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root. Try: sudo $0"
  exit 1
fi

info() { echo -e "[INFO] $*"; }
err() { echo -e "[ERROR] $*" >&2; }

apt_update() {
  info "Updating apt repositories"
  apt-get update -y
}

install_packages() {
  info "Installing required packages"
  apt-get install -y ca-certificates curl gnupg lsb-release
}

install_docker() {
  if command -v docker >/dev/null 2>&1; then
    info "Docker already installed. Skipping"
    return
  fi

  info "Installing Docker Engine"
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  info "Enabling and starting Docker"
  systemctl enable --now docker
}

install_docker_compose_v2() {
  # On newer Ubuntu with docker-compose-plugin installed, docker compose is available as 'docker compose'
  if docker compose version >/dev/null 2>&1; then
    info "Docker Compose (v2) available via docker plugin. Skipping standalone install"
    return
  fi

  # Fallback: install docker-compose standalone binary
  if command -v docker-compose >/dev/null 2>&1; then
    info "docker-compose already installed. Skipping"
    return
  fi

  info "Installing docker-compose (standalone)"
  COMPOSE_VER="2.20.2"
  curl -L "https://github.com/docker/compose/releases/download/v${COMPOSE_VER}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
}

setup_directories() {
  info "Creating Nginx Proxy Manager directories under /opt/npm"
  mkdir -p /opt/npm/data /opt/npm/letsencrypt /opt/npm/ssl
  chown -R root:root /opt/npm
  chmod -R 755 /opt/npm
}

write_compose_file() {
  local file=/opt/npm/docker-compose.yml
  if [[ -f "$file" ]]; then
    info "docker-compose.yml already exists at $file. Backing up to ${file}.bak"
    cp -a "$file" "${file}.bak"
  fi

  info "Writing docker-compose.yml"
  cat > "$file" <<'EOF'
version: '3'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: always
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    environment:
      DB_SQLITE_FILE: '/data/database.sqlite'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt

# Uncomment and configure the db section below to use external Postgres instead of the default sqlite
#  db:
#    image: postgres:13-alpine
#    environment:
#      POSTGRES_USER: npm
#      POSTGRES_PASSWORD: npm
#      POSTGRES_DB: npm
#    volumes:
#      - ./pgdata:/var/lib/postgresql/data
EOF
}

start_compose() {
  info "Starting Nginx Proxy Manager with docker compose"
  (cd /opt/npm && docker compose up -d) || (cd /opt/npm && docker-compose up -d)
}

open_firewall() {
  if command -v ufw >/dev/null 2>&1; then
    info "Allowing ports 80, 81, 443 through ufw"
    ufw allow 80/tcp
    ufw allow 81/tcp
    ufw allow 443/tcp
  else
    info "ufw not found. Skipping firewall configuration"
  fi
}

print_next_steps() {
  cat <<EOF

Nginx Proxy Manager installation finished.

Default web UI:
  URL: http://<server-ip>:81
  Default credentials: admin@example.com / changeme

Data and config are stored in /opt/npm
To view logs:  cd /opt/npm && docker compose logs -f

If you need to use a custom email, TLS, or external DB, edit /opt/npm/docker-compose.yml and restart the stack:
  cd /opt/npm && docker compose down && docker compose up -d

EOF
}

main() {
  apt_update
  install_packages
  install_docker
  install_docker_compose_v2
  setup_directories
  write_compose_file
  open_firewall
  start_compose
  print_next_steps
}

main "$@"
