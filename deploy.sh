#!/bin/bash
set -e

# 1. Update system & install dependencies
echo "==> Installing package dependencies..."
sudo apt-get update && sudo apt-get install -y curl unzip ca-certificates

# 2. Install Docker if not already present
if ! command -v docker &> /dev/null; then
  echo "==> Installing Docker..."
  curl -fsSL https://get.docker.com | sh
fi

# 3. Create project directory
WORKDIR="/opt/librenms-poc"
echo "==> Setting up workspace at $WORKDIR..."
sudo mkdir -p "$WORKDIR"
sudo chown -R $USER:$USER "$WORKDIR"
cd "$WORKDIR"

# 4. Fetch official LibreNMS Compose files
echo "==> Downloading LibreNMS Compose templates..."
curl -sSL https://github.com/librenms/docker/archive/refs/heads/master.zip -o master.zip
unzip -q master.zip
cp -r docker-master/examples/compose/* .
rm -rf master.zip docker-master

# 5. Populate default environment configuration
echo "==> Generating .env configuration..."
cat << 'EOF' > .env
TZ=Etc/UTC
PUID=1000
PGID=1000
MEMORY_LIMIT=256M
UPLOAD_MAX_SIZE=16M
OPCACHE_MEM_SIZE=128

MYSQL_DATABASE=librenms
MYSQL_USER=librenms
MYSQL_PASSWORD=librenms_db_pass
MYSQL_ROOT_PASSWORD=librenms_root_pass

LIBRENMS_SNMP_COMMUNITY=public
EOF

# 6. Launch container stack
echo "==> Launching LibreNMS containers..."
docker compose up -d

echo "==> Deployment initiated successfully!"
