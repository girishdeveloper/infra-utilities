#!/bin/bash
if [ $EUID -ne 0 ]; then
	echo "Only root user can run this script."
	exit 1
fi
os_name=$(grep -w 'NAME' /etc/os-release | cut -d'=' -f2 | sed -s s/\"//g | cut -d' ' -f1)
case $os_name in
"CentOS")
	yum update
	version_id=$(grep -w 'VERSION_ID' /etc/os-release | cut -d'=' -f2 | sed -s s/\"//g | cut -d' ' -f1)
	case $version_id in
	"7")
		yum localinstall https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
		yum install mysql-community-server
		systemctl start mysqld.service
		systemctl enable mysqld.service
	;;
	"6")
		yum localinstall https://dev.mysql.com/get/mysql80-community-release-el6-1.noarch.rpm
		yum install mysql-community-server
		/etc/init.d/mysql start
		chkconfig --levels 235 mysqld on
	;;
	*)
		echo "Please check the version or update this script for your use. version="$version_id
		exit 1
	esac
;;
*)
	echo "Please check the os build and version or update this script for your use. OS name ="$os_name
	exit 1
esac
#get random password for root user in mysql
root_password=$(grep 'A temporary password is generated for root@localhost' /var/log/mysqld.log | tail -1 | cut -d' ' -f13)
echo -e "Your password for the root user of MySQL is: "
echo $root_password

echo "Change root password plus secure MySQL 8"
/usr/bin/mysql_secure_installation

echo "Use your root password to login into mysql client shell."
mysql -u root -p
exit 0
