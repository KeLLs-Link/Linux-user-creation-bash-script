#!/bin/bash

# Paths for logging and password storage
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.csv"

# Ensure log and password directories exist
sudo mkdir -p /var/log /var/secure
sudo touch "$LOG_FILE" "$PASSWORD_FILE"
sudo chmod 600 "$PASSWORD_FILE"

# Function to generate random password
generate_password() {
  tr -dc 'A-Za-z0-9!@#$%&*' < /dev/urandom | head -c 16
}

# Read user list from file
while IFS=";" read -r username groups; do
  username=$(echo "$username" | xargs) # Trim whitespace
  groups=$(echo "$groups" | xargs) # Trim whitespace

  # Create user group with the same name as the username
  if ! getent group "$username" > /dev/null; then
    sudo groupadd "$username"
    echo "$(date): Group $username created" | sudo tee -a "$LOG_FILE"
  else
    echo "$(date): Group $username already exists" | sudo tee -a "$LOG_FILE"
  fi

  # Create user if it doesn't exist
  if ! id -u "$username" > /dev/null 2>&1; then
    sudo useradd -m -g "$username" -G "$groups" "$username"
    password=$(generate_password)
    echo "$username:$password" | sudo chpasswd
    echo "$(date): User $username created with groups $groups" | sudo tee -a "$LOG_FILE"
    echo "$username,$password" | sudo tee -a "$PASSWORD_FILE"
    sudo chown root:root "$PASSWORD_FILE"
  else
    echo "$(date): User $username already exists" | sudo tee -a "$LOG_FILE"
  fi

  # Assign user to additional groups
  IFS=',' read -ra GROUP_ARRAY <<< "$groups"
  for group in "${GROUP_ARRAY[@]}"; do
    if ! getent group "$group" > /dev/null; then
      sudo groupadd "$group"
      echo "$(date): Group $group created" | sudo tee -a "$LOG_FILE"
    fi
    sudo usermod -aG "$group" "$username"
    echo "$(date): User $username added to group $group" | sudo tee -a "$LOG_FILE"
  done

  # Set appropriate permissions for home directory
  sudo chmod 700 "/home/$username"
  sudo chown "$username:$username" "/home/$username"

done < "$1"

echo "User creation process completed."
