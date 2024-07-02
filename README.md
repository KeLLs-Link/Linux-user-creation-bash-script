## HNG11 Internship

# Linux-user-creation-bash-script

- **DevOps Stage 1: Linux User Creation Bash Script
Task**

Your company has employed many new developers. As a SysOps engineer, write a bash script called **`create_users.sh`** that reads a text file containing the employee’s ***usernames and group names,*** where each line is formatted as user;groups.

The script should create users and groups as
specified, set up home directories with appropriate permissions and ownership, generate random passwords for the users, and log all actions to /**`var/log/user_management.log`**. Additionally, store the generated passwords securely in **`/var/secure/user_passwords.txt`**.

Ensure error handling for scenarios like existing users and provide clear documentation and comments within the script.

Also write a **`technical article`** explaining your script, linking back to HNG

- **Requirements:**

Each User must have a personal group with the same group name as the username, this group name will not be written in the text file.

A user can have multiple groups, each group delimited by comma `","`

Usernames and user groups are separated by semicolon `";"`- Ignore whitespace

e.g.
```
light; sudo,dev,www-data
idimma; sudo
mayowa; dev,www-data
```
For the first line, `light is username` and groups are `sudo, dev, www-data`

- **Technical Article:**

The article should be well-structured.

It MUST include at least two links to the HNG Internship websites; choose from any of 
```
https://hng.tech/internship
```
```
 https://hng.tech/hire
 ```
or 
```
https://hng.tech/premium
```
so others can learn more about the program.

The report should be concise.

The article should be public and accessible by anyone on the internet.

- **Acceptance Criteria:**

**Successful Run:** 

The mentors will test your script by supplying the name of the text file containing usernames and groups as the first argument to your script `(i.e bash create_user.sh <name-of-text-file> )` in an Ubuntu machine.

All users should be created and assigned to their groups appropriately.

The file `/var/log/user_management.log` should be created and contain a log of all actions performed by your script.

The file `/var/secure/user_passwords.csv` should be created and contain a list of all users and their passwords delimited by comma, and only the file owner should be able to read it.

The technical article is clear, concise and captures the reasoning behind each step in your script.

- **Submission Mode:**

Submit your task through the designated submission form. Ensure you’ve:

- Double-checked all requirements and acceptance criteria.

- Provided a link to your GitHub repository containing your file in the submission form.

- Thoroughly reviewed your work to ensure accuracy, functionality, and adherence to the specified guidelines before you submit it.

Provided a link to your technical article containing the reasoning behind your specific implementation.

**PS:**

Use a new repository for this task and your script should be in the root directory.
Your repo should contain only 2 files - README.md, create_users.sh

**Submission Deadline:**

The deadline for submissions is `Wed 3rd July, at 11:59 PM GMT. Late submissions will not be entertained. (edited)` 






The goal of this project is to automate the process of creating new user accounts and groups on a Linux system using a bash script.

## Steps

- 1. **Provission your virtual sever and ssh into it from your remote machine terminal**

![image](./Screenshots/aws.png)

- 2. **Create the script file:**
```
touch create_users.sh
chmod +x create_users.sh
```
![image](./Screenshots/userfilecreated.png)

- Open the `create_user.sh` script file with your prefered command line text editor (e.g., nano, vi):
and paste the bash script below.

```
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

```
![image](./Screenshots/nanouserscript.png)

- 3.  **Create the User List File**

Create a file named `user_list.txt`

```
touch user_list.txt
```
![image](./Screenshots/userlisttxt.png)
Open the user_list.txt with your preffered command line text editor:

Add the user and group information
```
light; sudo,dev,www-data
idimma; sudo
mayowa; dev,www-data
```
![image](./Screenshots/userlisttxt.png)

- 4. **Run the Script**

Execute the script with the user list file as an argument:

```
sudo bash create_users.sh user_list.txt
```
***The above script will create users, groups, and set up home directories. It will also log actions to /var/log/user_management.log and store passwords in /var/secure/user_passwords.csv.***

- **Verify the outcome of the script to ensure it is performing it's intended task.**

Check the log file:
```
sudo cat /var/log/user_management.log
```
![image](./Screenshots/created.png)

Check the password file:
```
sudo cat /var/secure/user_passwords.csv
```
![image](./Screenshots/pswrdfile.png)

- Check user and group creation:

```
getent passwd light
getent group light
getent group sudo
```


Visit the [HNG Internship website](https://hng.tech/internship) to learn more about the HNG Internship Program.
