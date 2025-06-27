#!/bin/bash

# Update system
sudo apt update && sudo apt upgrade -y && sudo apt dist-upgrade -y
sudo apt install aptitude && aptitude safe-upgrade -y


# Declare variables
fqdn =
hostname =
user =
hashPasswd =
sshPubKey =

# Initialize firewall and allow SSH
ufw allow OpenSSH
ufw enable

# Set hostname
echo "127.0.1.1 $fqdn and $hostname" | tee /etc/hosts.new
cat /etc/hosts.new /etc/hosts > /etc/hosts.tmp
mv /etc/hosts.tmp /etc/hosts


hostnamectl set-hostname {fqdn}

#Create a user with Sudo access
create_user_with_hash() {
    local username="$1"
    local password_hash="$2"
    
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root"
        exit 1
    fi
    
    if [[ -z "$username" ]] || [[ -z "$password_hash" ]]; then
        echo "Usage: $0 <username> <password_hash>"
        exit 1
    fi
    
    # Create user with pre-generated password hash
    useradd -m -s /bin/bash -p "$password_hash" "$username"
    
    if [[ $? -eq 0 ]]; then
        echo "User $username created successfully"
    else
        echo "Failed to create user $username"
        exit 1
    fi
}

# Declare username and password
# Hash password to avoid entering plaintext password
create_user_with_hash "$user" "$hashPasswd"

# Grant user sudo access
adduser $user sudo


# SSH
# Generate ssh keys on your computer and copy public key

mkdir /home/$user/.ssh
echo "$sshPubKey" >> /home/$user/.ssh/authorized_keys
chown $user:$user /home/$user/.ssh/ -R
chmod 700 /home/$user/.ssh
chmod 600 /home/$user/.ssh/authorized_keys


