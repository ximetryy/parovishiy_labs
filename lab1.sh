#/bin/bash


read -p "Enter login: " login

check_login() 
{
	if grep -q "^$login:" /etc/passwd; then
		echo "Login '$login' exist"
	else
		echo "User '$login' dont exist"
		exit 1
	fi
}

check_login

read -s -p "Enter password: " password
echo 

echo "Welcome, $login!"
