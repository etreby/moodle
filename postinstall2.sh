#!/bin/bash
RED_B='\e[1;91m'
GREEN_B='\e[1;92m'
YELLOW_B='\e[1;93m'
BLUE_B='\e[1;94m'
PURPLE_B='\e[1;95m'
CYAN_B='\e[1;96m'
WHITE_B='\e[1;97m'
RESET='\e[0m'
red() { echo -e "${RED_B}${1}${RESET}"; }
green() { echo -e "${GREEN_B}${1}${RESET}"; }
yellow() { echo -e "${YELLOW_B}${1}${RESET}"; }
blue() { echo -e "${BLUE_B}${1}${RESET}"; }
purple() { echo -e "${PURPLE_B}${1}${RESET}"; }
cyan() { echo -e "${CYAN_B}${1}${RESET}"; }
white() { echo -e "${WHITE_B}${1}${RESET}"; }
configFile=/var/www/html/config.php
func_echo_variables()
{
	echo Installing Moodle 
	echo Moodle URl ${MOODLE_URL}
	echo 'config path : ' $configFile
	echo 'SITENAME : ' $SITENAME
	echo 'SHORTNAME : ' $SHORTNAME
	echo 'LANG : ' $LANG
	echo 'wwwroot : ' $MOODLE_URL
	echo 'dataroot : ' $MOODLE_DATA
	echo 'dbtype : ' $DBTYPE
	echo 'dbhost : ' $DBHOST
	echo 'dbname : ' $DBNAME
	echo 'dbuser : ' $DBUSER
	echo 'dbpass : ' $DBPASS
	echo 'prefix : ' $DBPREFIX
	echo 'adminuser : ' $ADMINUSER
	echo 'adminpass : ' $ADMINPASS
	echo 'adminEmail : ' $ADMINEMAIL
	echo 'license auto agree'
	echo 'press 0 to back'
	read -p 'Command: ' option
	if [ $option -eq 0 ]; then
		funcStart
	fi
}
func_unset_all()
{
unset  MOODLE_URL
unset  configFile
unset  SITENAME
unset  SHORTNAME
unset  LANG
unset  MOODLE_DATA
unset  DBTYPE
unset  DBHOST
unset  DBNAME
unset  DBUSER
unset  DBPASS
unset  DBPREFIX
unset  ADMINUSER
unset  ADMINPASS
unset  ADMINEMAIL
unset  RESULT
}
func_checkDatabase()
{
	echo 'checking database connection'
	echo 'checking database connection'
	ping -c4 -W1 $DBHOST && echo 'server is up' || echo 'server is down'
	RESULT=`mysqlshow --host=$DBHOST --user=$DBUSER --password=$DBPASS $DBNAME| grep -v Wildcard | grep -o $DBNAME`
	echo $RESULT
	if [ "$RESULT" = "$DBNAME" ]; then
        echo "DataB found"
	else
        echo "DB not found"
	fi
}
func_InstallMoodle()
{
	if [ -f "$configFile" ]; then
		echo "$configFile exists. moodle installed already"
	else
		echo "$configFile does not exist."
		echo "Start Moodle Installing"
		/usr/bin/php /var/www/html/admin/cli/install.php --lang=${LANG} --fullname=${SITENAME} --shortname=${SHORTNAME} --dbtype=${DBTYPE} --wwwroot=${MOODLE_URL} --dataroot=${MOODLE_DATA} --dbhost=${DBHOST} --dbname=${DBNAME} --dbuser=${DBUSER} --dbpass=${DBPASS} --prefix=${DBPREFIX} --adminuser=${ADMINUSER} --adminpass=${ADMINPASS} --adminemail=${ADMINEMAIL} --dbsocket=1 --dbport=${DBPORT} --non-interactive --agree-license=agree
		cat /var/www/html/config.comprehend.php >> /var/www/html/config.php
		vim /var/www/html/config.php -c "set ff=unix" -c ":wq"
		chown -R www-data:www-data /var/www/html
		chown -R www-data:www-data ${MOODLE_DATA}
		echo "creating quarantine for antivirus"
		mkdir /var/quarantine
		chown -R www-data /var/quarantine
		echo 'doing cleanup!'
		rm /var/www/html/config.comprehend.php
		apt-get clean
		#rm /var/www/html/postinstall.sh
	fi
}
func_phpMemoryModification()
{
    echo "Set Memory Limit to : 1024M"
    phpmemory_limit=1024M #or what ever you want it set to
    sed -i 's/memory_limit = .*/memory_limit = '${phpmemory_limit}'/' /etc/php/7.4/cli/php.ini
}
func_restartApache2()
{
  echo
  /etc/init.d/apache2 reload
}

func_create_cron_jobs()
{
	echo "making cronJob"
	crontab -l www-data | grep '/usr/bin/php  /var/www/html/admin/cli/cron.php' 1> /dev/null 2>&1
	(( $? == 0 )) && exit
	crontab -l www-data > /tmp/crontab.tmp
	echo '* * * * * /usr/bin/php  /var/www/html/admin/cli/cron.php 2>&1 | /usr/bin/logger' >> /tmp/crontab.tmp
	echo '* * * * * /usr/bin/php  /var/www/html/admin/cli/cron.php 2>&1 | /usr/bin/logger' >> /tmp/crontab.tmp
	echo '* * * * * /usr/bin/php  /var/www/html/admin/cli/cron.php 2>&1 | /usr/bin/logger' >> /tmp/crontab.tmp
	echo ' * * * * * /usr/bin/php  /var/www/html/admin/cli/adhoc_task.php --execute --keep-alive=59' >> /tmp/crontab.tmp
	echo ' * * * * * /usr/bin/php  /var/www/html/admin/cli/adhoc_task.php --execute --keep-alive=59' >> /tmp/crontab.tmp
	echo ' * * * * * /usr/bin/php  /var/www/html/admin/cli/adhoc_task.php --execute --keep-alive=59' >> /tmp/crontab.tmp
	crontab -e www-data /tmp/crontab.tmp
	rm /tmp/crontab.tmp
	echo 'check system'
	php /var/www/html/admin/cli/checks.php
}
func_moodleMaintenanceEnabled()
{
  /usr/bin/php /var/www/html/admin/cli/maintenance.php --enable
}
func_MoodleUpgrade()
{
    git pull
    /usr/bin/php /var/www/html/admin/cli/upgrade.php
}
func_moodleMaintenanceDisabled()
{
  /usr/bin/php /var/www/html/admin/cli/maintenance.php --disable
}
func_Install()
{
  if [ -f "$configFile" ]; then
    blue "Moodle installed!"
  else
    func_echo_variables
    func_checkDatabase
    func_InstallMoodle
    func_create_cron_jobs
  fi
}
func_ShowStart()
{
  func_Install
	blue "$(figlet -tcf slant "IBM \n comprehend")"
	echo "1) show Variables						2) check Database			  3) install Moodle"
	echo "4) Cron Tools							  5) Server Tools 				0) Exit"
	read -p 'Command: ' option
	if [ $option -eq  1 ]; then
		func_echo_variables
	elif [ $option -eq 2 ]; then
		func_checkDatabase
	elif [ $option -eq 3 ]; then
		func_InstallMoodle
	elif [ $option -eq 4 ]; then
		func_InstallMoodle
	elif [ $option -eq 5 ]; then
    echo "server tools"
	elif [ $option -eq 0 ]; then
		func_unset_all
		exit 1
	fi
}
func_ShowStart