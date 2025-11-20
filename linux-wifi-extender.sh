#!/bin/bash

# Copyright 2025 Devin B. Royal.
# All Rights Reserved.

# Set the physical WiFi interface
PHY_IFACE="wlan0"

# Set the virtual WiFi interface
VIRT_IFACE="wlan1"

# Set the WiFi network settings
SSID=""
CHANNEL="36"
HW_MODE="a"
HT_MODE="HT40-"

# Logging function
log() {
  echo "$(date) - $1" >> /var/log/wifi_extender.log
}

# User input validation
while true; do
  read -p "Enter SSID: " SSID
  if [ -n "$SSID" ]; then
    break
  else
    echo "SSID cannot be empty. Please try again."
  fi
done

while true; do
  read -sp "Enter WiFi password: " PASSWORD
  echo
  if [ ${#PASSWORD} -ge 8 ]; then
    break
  else
    echo "Password must be at least 8 characters long. Please try again."
  fi
done

# Function to check if a package is installed
check_package() {
  if ! dpkg -s "$1" &> /dev/null; then
    log "Package $1 is not installed. Installing..."
    install_package "$1"
  fi
}

# Function to install a package
install_package() {
  apt-get update
  apt-get install -y "$1"
  if [ $? -ne 0 ]; then
    log "Failed to install package $1."
    exit 1
  fi
}

# Function to load the batman-adv kernel module
load_batman_adv() {
  if ! lsmod | grep -q batman_adv; then
    log "Loading batman-adv kernel module..."
    modprobe batman-adv
    if [ $? -ne 0 ]; then
      log "Failed to load batman-adv kernel module."
      exit 1
    fi
  fi
}

# Function to create the virtual WiFi interface
create_virtual_iface() {
  if ! ip link show "$VIRT_IFACE" &> /dev/null; then
    log "Creating virtual WiFi interface $VIRT_IFACE..."
    iw dev "$PHY_IFACE" interface add "$VIRT_IFACE" type __ap
    if [ $? -ne 0 ]; then
      log "Failed to create virtual WiFi interface $VIRT_IFACE."
      exit 1
    fi
  fi
}

# Function to configure the WiFi settings for the virtual interface
configure_wifi() {
  log "Configuring WiFi settings for $VIRT_IFACE..."
  iw dev "$VIRT_IFACE" set channel "$CHANNEL" "$HT_MODE"
  if [ $? -ne 0 ]; then
    log "Failed to configure WiFi settings for $VIRT_IFACE."
    exit 1
  fi
}

# Function to configure the hostapd settings
configure_hostapd() {
  log "Configuring hostapd settings..."
  cat << EOF > /etc/hostapd/hostapd.conf
interface=$VIRT_IFACE
driver=nl80211
ssid=$SSID
hw_mode=$HW_MODE
channel=$CHANNEL
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$PASSWORD
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF
  if [ $? -ne 0 ]; then
    log "Failed to configure hostapd settings."
    exit 1
  fi
}

# Function to restart the hostapd service
restart_hostapd() {
  log "Restarting hostapd service..."
  service hostapd restart
  if [ $? -ne 0 ]; then
    log "Failed to restart hostapd service."
    exit 1
  fi
}

# Function to configure the network bridge
configure_bridge() {
  log "Configuring network bridge..."
  brctl addbr br0
  brctl addif br0 "$PHY_IFACE"
  brctl addif br0 "$VIRT_IFACE"
  ip link set br0 up
  if [ $? -ne 0 ]; then
    log "Failed to configure network bridge."
    exit 1
  fi
}

# Function to configure the IP settings for the bridge
configure_ip() {
  log "Configuring IP settings for br0..."
  dhclient br0
  if [ $? -ne 0 ]; then
    log "Failed to configure IP settings for br0."
    exit 1
  fi
}

# Function to create a batman-adv interface
create_batman_adv() {
  log "Creating batman-adv interface..."
  batctl if add "$PHY_IFACE"
  batctl if add "$VIRT_IFACE"
  ip link set bat0 up
  if [ $? -ne 0 ]; then
    log "Failed to create batman-adv interface."
    exit 1
  fi
}

# Function to configure the IP settings for the batman-adv interface
configure_batman_adv_ip() {
  log "Configuring IP settings for bat0..."
  dhclient bat0
  if [ $? -ne 0 ]; then
    log "Failed to configure IP settings for bat0."
    exit 1
  fi
}

# Check if the script is run with root privileges
if [ $(id -u) -ne 0 ]; then
  log "Please run the script with root privileges."
  exit 1
fi

# Check and install required packages
check_package hostapd
check_package batctl

# Load the batman-adv kernel module
load_batman_adv

# Create the virtual WiFi interface
create_virtual_iface

# Bring up the virtual WiFi interface
ip link set "$VIRT_IFACE" up

# Configure the WiFi settings for the virtual interface
configure_wifi

# Configure the hostapd settings
configure_hostapd

# Restart the hostapd service
restart_hostapd

# Configure the network bridge
configure_bridge

# Configure the IP settings for the bridge
configure_ip

# Create a batman-adv interface
create_batman_adv

# Configure the IP settings for the batman-adv interface
configure_batman_adv_ip

log "WiFi extender and mesh network system configured successfully."

echo "WiFi extender and mesh network system configured successfully."
/*
 * Copyright 2025 Devin B. Royal.
 * All Rights Reserved.
 */
