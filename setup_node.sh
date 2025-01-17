#!/bin/bash

current_directory="$(dirname "$(readlink -f "$0")")"
IFS="/" read -ra dir_array <<< "${current_directory#/}"  # Remove leading slash
parsed_dir="/${dir_array[0]}/${dir_array[1]}/${dir_array[2]}"

# 1) Load the environment variables
source "${parsed_dir}/scripts/load_variables.sh"

# 2) Source the script that returns OS and CPU architecture variables
source "${parsed_dir}/scripts/get_os_arch.sh"

# 3) Execute the setup scripts

# Define color and formatting variables
GREEN='\033[1;32m'
NC='\033[0m' # No Color
BOLD='\033[1m'
NORMAL='\033[0m'
BLUE='\033[1;34m'
ORANGE='\033[1;33m'

echo -e "${GREEN}OS:${NC} ${BLUE}$OS${NC}"
echo -e "${GREEN}CPU architecture:${NC} ${BLUE}$ARCH ($ARCH_RAW)${NC}"

# Setup UFW
echo -e "${ORANGE}${BOLD}Setting up UFW...${NORMAL}"
sudo "${parsed_dir}/scripts/setup_ufw.sh"
echo -e "${GREEN}UFW setup completed.${NC}"

# Setup Nginx
echo -e "${ORANGE}${BOLD}Setting up Nginx...${NORMAL}"
sudo "${parsed_dir}/scripts/setup_nginx.sh"
echo -e "${GREEN}Nginx setup completed.${NC}"


# Setup Prometheus
echo -e "${ORANGE}${BOLD}Setting up Prometheus...${NORMAL}"
sudo "${parsed_dir}/scripts/setup_prometheus.sh"
echo -e "${GREEN}Prometheus setup completed.${NC}"

# Setup Grafana
echo -e "${ORANGE}${BOLD}Setting up Grafana...${NORMAL}"
sudo "${parsed_dir}/scripts/setup_grafana.sh"
echo -e "${GREEN}Grafana setup completed.${NC}"

# Download the snapshots if specified
if [[ $SYNC_FROM == "public" || $SYNC_FROM == "private" ]]; then
  # Setup S3
  echo -e "${ORANGE}${BOLD}Setting up S3...${NORMAL}"
  sudo "${parsed_dir}/scripts/setup_s3.sh"
  echo -e "${GREEN}S3 setup completed.${NC}"

  echo -e "${ORANGE}${BOLD}Sync mode:${NC} ${BLUE}${SYNC_FROM}${NC}."
  echo -e "${ORANGE}${BOLD}Downloading snapshots...${NORMAL}"
  sudo "${parsed_dir}/scripts/restore.sh"
  echo -e "${GREEN}${BOLD}Snapshots Downloaded!${NORMAL}"
elif [[ $SYNC_FROM == "chain" ]]; then
  # we don't actually need to do anything here, but we can print a message since reth and lighthouse will start syncing on launch
  echo -e "${ORANGE}${BOLD}Sync mode:${NC} ${RED}${SYNC_FROM}${NC}."
fi

# Setup Siren
echo -e "${ORANGE}${BOLD}Setting up Siren...${NORMAL}"
#screen -dmS siren sudo "${parsed_dir}/scripts/setup_siren.sh"
echo -e "${GREEN}Siren setup completed.${NC}"

# Commented out for now, do it manually.
echo -e "${ORANGE}${BOLD}Starting rETH & Lighthouse...${NORMAL}"
screen -dmS reth sudo "${parsed_dir}/scripts/setup_services.sh"
echo -e "${GREEN}rETH & Lighthouse started.${NC}"

echo -e "${GREEN}${BOLD}Script execution completed.${NORMAL}"

# Finish
sudo "${parsed_dir}/scripts/finish.sh"