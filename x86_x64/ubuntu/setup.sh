#!/bin/bash

# Variable definitions
DOCKER_DIR="/docker"
DOCKER_REPO_DIR="${DOCKER_DIR}/wordpress-caddy-docker"
DOCKER_ENV_FILE="${DOCKER_REPO_DIR}/.env"
DOCKER_REPO_URL="https://github.com/healme-dev/wordpress-caddy-docker.git"
DOCKER_CE_REPO_URL="https://download.docker.com/linux/ubuntu/gpg"
PACKAGES="docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin git zip unzip vim openssl"

# Default passwords
DEFAULT_WORDPRESS_DB_PASSWORD="70c2dda1641a6f9e7357b0ad8b19dac3"
DEFAULT_MYSQL_ROOT_PASSWORD="d55309c79ed27f0ee9dc715661c3e8ec"

# Set timezone
sudo ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# Set locale
sudo localectl set-locale LANG=ko_KR.UTF-8

# Add docker user and set permissions
sudo useradd -m -d ${DOCKER_DIR} -s /bin/bash docker
sudo chmod 755 ${DOCKER_DIR}

# Install necessary packages
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y 

export DEBIAN_FRONTEND=noninteractive
sudo apt upgrade -yq
sudo apt install -y needrestart
sudo needrestart -r a

#sudo apt-get update && sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && sudo apt-get update
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-get install -y ${PACKAGES}

# Start and enable Docker service
sudo service docker start
sudo service docker enable

# Exit the script if the first argument is "docker-daemon"
if [ "$1" == "docker-daemon" ]; then
    echo "complete"
    exit 0
fi

# Clone the Git repository
sudo -u docker -i git clone ${DOCKER_REPO_URL} ${DOCKER_REPO_DIR}

# Function to check if a password is set to its default value or not set at all in .env
is_password_default_or_unset() {
    local key=$1
    local default_value=$2
    ! grep -q "^export ${key}=" ${DOCKER_ENV_FILE} || grep -q "^export ${key}=${default_value}" ${DOCKER_ENV_FILE}
}

# Function to generate MySQL password
generate_password() {
    local suffix=$1
    echo "$(date +%s)${suffix}" | openssl dgst -sha1 | cut -d" " -f2
}

# Update MySQL passwords in the .env file if they are unset or set to their default values
if is_password_default_or_unset "WORDPRESS_DB_PASSWORD" ${DEFAULT_WORDPRESS_DB_PASSWORD}; then
    mysql_pw=$(generate_password "mysql_password")
    sudo -u docker sed -i "/^export WORDPRESS_DB_PASSWORD=/c\export WORDPRESS_DB_PASSWORD=${mysql_pw}" ${DOCKER_ENV_FILE}
fi

if is_password_default_or_unset "MYSQL_ROOT_PASSWORD" ${DEFAULT_MYSQL_ROOT_PASSWORD}; then
    mysql_root_pw=$(generate_password "mysql_root_password")
    sudo -u docker sed -i "/^export MYSQL_ROOT_PASSWORD=/c\export MYSQL_ROOT_PASSWORD=${mysql_root_pw}" ${DOCKER_ENV_FILE}
fi

# Execute Docker Compose
sudo -u docker -i docker compose -f ${DOCKER_REPO_DIR}/docker-compose.yml pull