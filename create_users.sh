#!/bin/bash

# Paths for logging and password storage
LOGFILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.csv"

# Check if the input file is provided as expected
if [ -z "$1" ]; then
  echo "Error: No file was provided"
  echo "Usage: $0 <name-of-text-file>"
  exit 1
fi

# Ensure log and password directories exist
mkdir -p /var/secure
touch $LOGFILE $PASSWORD_FILE
chmod 600 $PASSWORD_FILE

generate_random_password() {
    local length=${1:-10} # Default length is 10 if no argument is provided
    tr -dc 'A-Za-z0-9!?%+=' < /dev/urandom | head -c $length
}

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOGFILE
}

# Function to create a user
create_user() {
  local username=$1
  local groups=$2

  if getent passwd "$username" > /dev/null; then
    log_message "User $username already exists"
  else
    useradd -m $username
    log_message "Created user $username"
  fi

  # Add user to specified groupsgroup
  groups_array=($(echo $groups | tr "," "\n"))

  for group in "${groups_array[@]}"; do
    if ! getent group "$group" >/dev/null; then
      groupadd "$group"
      log_message "Created group $group"   
    fi
    usermod -aG "$group" "$username"
    log_message "Added user $username to group $group"
  done

  # Set up home directory permissions
  chmod 700 /home/$username
  chown $username:$username /home/$username
  log_message "Set up home directory for user $username" 

  # Generate a random password
  password=$(generate_random_password 12) 
  echo "$username:$password" | chpasswd
  echo "$username,$password" >> $PASSWORD_FILE
  log_message "Set password for user $username"
}

# Read the input file and create users
while IFS=';' read -r username groups; do
  create_user "$username" "$groups"
  echo $username
done < "$1"

log_message "User creation process completed."
