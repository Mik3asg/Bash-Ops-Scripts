#!/bin/bash

#################################################################################
# Script Name: ping-check-prod-status
# Description: This script pings a predefined list of server IP addresses to check
#              their network connectivity. If any servers fail to respond after
#              a specified number of attempts and interval, an email notification
#              is sent.
#
# Pre-requisites:
#   - Install the 'mailx' package to enable email notifications.
#       For Debian/Ubuntu: sudo apt-get install mailx
#       For RHEL/CentOS: sudo yum install mailx
#       For Fedora: sudo dnf install mailx
#   - Ensure ICMP (Internet Control Message Protocol) is allowed through the
#     firewall on both this server (for outgoing pings) and on the target servers
#     (for incoming pings). This typically involves adjusting firewall settings
#     to allow ICMP traffic.
#   - SMTP Configuration: Configure the SMTP settings in '/etc/mail.rc' to use Gmail's SMTP server:
#       # Set SMTP to use Gmail's SMTP server
#       set smtp=smtps://smtp.gmail.com:465
#       set smtp-auth=login
#       set smtp-auth-user=<your_email_id>@gmail.com
#       set smtp-auth-password=<app_password_from_gmail_security>
#       set ssl-verify=ignore
#       set nss-config-dir=/etc/pki/nssdb
#       (Replace <your_email_id> and <app_password_from_gmail_security> with your Gmail credentials)
#   - Update the recipient email addresses and target/client IP addresses in the
#     script to match your specific requirements.
#   - Before running this script, test that each target server is reachable via
#     the ping command to confirm that ICMP is enabled on the target servers.
#       Example: ping -c 1 192.168.1.202
#
# Usage:
#   - Simply execute this script from a bash shell: ./ping-check-prod-status
#
# Author: Mickael Asghar
# Created on: 07/06/2024
# Updated on: 07/06/2024
#################################################################################

# Associative array of server IP addresses and their hostnames
declare -A ping_targets=(
    ["192.168.1.202"]="Server 01"
    ["192.168.1.203"]="Server 02"
    ["192.168.1.204"]="Server 03"
)

# Retry settings
retry_count=3       # Number of retry attempts
retry_interval=10   # Interval in seconds between retries

# List of CC recipients
cc_recipients=("mickael@carebeans.co.uk" "mickael.asghar@gmail.com" "mik3asg@gmail.com")

# Convert CC recipients array to a comma-separated string
cc_list=$(IFS=','; echo "${cc_recipients[*]}")

# Initialize a variable to store failed hosts
failed_hosts=""

# Function to ping a host
ping_host() {
    local ip=$1
    ping -c 1 $ip > /dev/null 2>&1
    return $?
}

# Loop through each target and attempt to ping
for ip in "${!ping_targets[@]}"  # Loop over keys of the associative array
do
    hostname=${ping_targets[$ip]}  # Assign hostname from the associative array
    success=false

    for attempt in $(seq 1 $retry_count)
    do
        echo "Pinging $hostname ($ip) (Attempt $attempt of $retry_count)..."
        if ping_host $ip; then
            echo "$hostname ($ip) is reachable."
            success=true
            break
        else
            echo "$hostname ($ip) is not reachable. Waiting $retry_interval seconds before retrying..."
            sleep $retry_interval
        fi
    done

    if ! $success; then
        current_datetime=$(date "+%d/%m/%Y %H:%M:%S")  # Get the current date and time
        echo "$hostname ($ip) failed to respond after $retry_count attempts."
        failed_hosts+="Date: $current_datetime - $hostname ($ip).\n"  # Append formatted string
    fi
done

# Check if any host failed to respond and send an email if so
if [ ! -z "$failed_hosts" ]; then
    message="The following hosts failed to respond after $retry_count attempts with a $retry_interval second interval between attempts:\n$failed_hosts"
    echo -e "$message" | mailx -s "[ALERT] - Ping Failure Notification" -c "$cc_list" mickael.asghar@gmail.com
else
    echo "All hosts responded successfully after $retry_count attempts."
fi