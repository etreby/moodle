FROM debian
# Default values appear here.
# You can override them using "docker run" option like "-e MOODLE_VERSION=39"
ARG TZ=Etc/UTC
ARG MOODLE_VERSION=39
ARG SITENAME=comprehendDemo
ARG SHORTNAME=demo
ARG LANG=en
ARG DBTYPE=mariadb
ARG DBHOST=mariadb
ARG DBUSER=root
ARG DBPASS=moodle
ARG DBNAME=moodle
ARG DBPREFIX=mdl_
ARG DBPORT=3306
ARG ADMINUSER=adminuser
ARG ADMINPASS=adminpass
ARG ADMINEMAIL=admin@comprehend.ibm.com
ARG MOODLE_DATA=/var/www/moodledata
ARG MOODLE_URL=http://localhost:8433
SHELL ["/bin/bash", "-c"]

VOLUME ["${MOODLE_DATA}"]
VOLUME ["/var/www/html"]
EXPOSE 80 443
# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive
ENV MOODLE_URL ${MOODLE_URL}
ENV MOODLE_VERSION ${MOODLE_VERSION}
ENV SITENAME ${SITENAME}
ENV SHORTNAME ${SHORTNAME}
ENV MOODLE_DATA ${MOODLE_DATA}
ENV DBTYPE ${DBTYPE}
ENV LANG ${LANG}
ENV DBHOST ${DBHOST}
ENV DBUSER ${DBUSER}
ENV DBPASS ${DBPASS}
ENV DBNAME ${DBNAME}
ENV DBPREFIX ${DBPREFIX}
ENV DBPORT ${DBPORT}
ENV ADMINUSER ${ADMINUSER}
ENV ADMINPASS ${ADMINPASS}
ENV ADMINEMAIL ${ADMINEMAIL}
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
#Update Enviroment
RUN apt-get update && \
apt-get -y install locales && \
sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen && \
DEBIAN_FRONTEND=noninteractive TZ=${TZ} apt-get -y install tzdata\
libmemcached11 libmemcachedutil2.2 libmemcachedprotocol1.1 libldap-2.4-2 && \

 vim\
 nano\
 figlet\
 curl\
 wget\
 htop\
 iputils-ping\
 unzip\
 apache2\
 libmariadb3\
 php\
 libapache2-mod-php\
 graphviz\
 aspell\
 ghostscript\
 clamav\
 php7.4-pspell\
 php7.4-curl\
 php7.4-gd\
 php7.4-intl\
 php7.4-mysql\
 php7.4-xml\
 php7.4-xmlrpc\
 php7.4-ldap\
 php7.4-zip\
 php-apcu\
 php7.4-soap\
 php7.4-mbstring\
 php-pear\
 git\
 git-core && \
 mkdir -p /opt/moodlesrc && \
 git clone --depth 1 -b MOODLE_${MOODLE_VERSION}_STABLE https://github.com/moodle/moodle.git /opt/moodlesrc && \
 cd /opt/moodlesrc && tar -czf ../MOODLE_${MOODLE_VERSION}.tar.gz . && cd .. && \
 rm -rf /opt/moodlesrc && \
 mkdir -p ${MOODLE_DATA} && \
 chown -R www-data:www-data /var/www/html && \
 chown -R www-data:www-data ${MOODLE_DATA} && \
 a2enmod ssl && a2ensite default-ssl && \
 ln -sf /dev/stdout /var/log/apache2/access.log && \
 ln -sf /dev/stderr /var/log/apache2/error.log && \
 apt-get clean && \
 echo 'apc.enable_cli = On' >> /etc/php/7.4/mods-available/apcu.ini && \
 echo "opcache.enable = 1" >> /etc/php/7.4/mods-available/opcache.ini && \
 echo "opcache.memory_consumption = 512" >> /etc/php/7.4/mods-available/opcache.ini && \
 echo "opcache.max_accelerated_files = 10000" >> /etc/php/7.4/mods-available/opcache.ini && \
 echo "opcache.revalidate_freq = 60" >> /etc/php/7.4/mods-available/opcache.ini && \
 echo "; Required for Moodle" >> /etc/php/7.4/mods-available/opcache.ini && \
 echo "opcache.use_cwd = 1" >> /etc/php/7.4/mods-available/opcache.ini && \
 echo "opcache.validate_timestamps = 1" >> /etc/php/7.4/mods-available/opcache.ini && \
 echo "opcache.save_comments = 1" >> /etc/php/7.4/mods-available/opcache.ini && \
 echo "opcache.enable_file_override = 0" >> /etc/php/7.4/mods-available/opcache.ini && \
 echo "; If something does not work in Moodle" >> /etc/php/7.4/mods-available/opcache.ini && \
 echo ";opcache.revalidate_path = 1 ; May fix problems with include paths" >> /etc/php/7.4/mods-available/opcache.ini && \
 echo ";opcache.mmap_base = 0x20000000 ; (Windows only) fix OPcache crashes with event id 487" >> /etc/php/7.4/mods-available/opcache.ini && \
 echo "; Experimental for Moodle 2.6 and later" >> /etc/php/7.4/mods-available/opcache.ini && \
 echo ";opcache.fast_shutdown = 1" >> /etc/php/7.4/mods-available/opcache.ini && \
 echo ";opcache.enable_cli = 1 ; Speeds up CLI cron" >> /etc/php/7.4/mods-available/opcache.ini && \
 echo ";opcache.load_comments = 0 ; May lower memory use, might not be compatible with add-ons and other apps." >> /etc/php/7.4/mods-available/opcache.ini && \
 sed -i 's/memory_limit = .*/memory_limit = 512M/' /etc/php/7.4/cli/php.ini && \
 sed -i 's/max_execution_time = .*/max_execution_time = 1800/' /etc/php/7.4/cli/php.ini && \
 sed -i 's/max_input_time = .*/max_input_time = 120/' /etc/php/7.4/cli/php.ini && \
 sed -i 's/max_input_vars = .*/max_input_vars = 3000/' /etc/php/7.4/cli/php.ini && \
 sed -i 's/post_max_size = .*/post_max_size = 500M/' /etc/php/7.4/cli/php.ini && \
 sed -i 's/upload_max_filesize = .*/upload_max_filesize = 500M/' /etc/php/7.4/cli/php.ini && \
 sed -i 's/memory_limit = .*/memory_limit = 512M/' /etc/php/7.4/apache2/php.ini && \
 sed -i 's/max_execution_time = .*/max_execution_time = 1800/' /etc/php/7.4/apache2/php.ini && \
 sed -i 's/max_input_time = .*/max_input_time = 120/' /etc/php/7.4/apache2/php.ini && \
 sed -i 's/max_input_vars = .*/max_input_vars = 3000/' /etc/php/7.4/apache2/php.ini && \
 sed -i 's/post_max_size = .*/post_max_size = 500M/' /etc/php/7.4/apache2/php.ini && \
 sed -i 's/upload_max_filesize = .*/upload_max_filesize = 500M/' /etc/php/7.4/apache2/php.ini && \
 /etc/init.d/apache2 restart

COPY config.comprehend.php postinstall2.sh /opt/
RUN vim /opt/postinstall2.sh -c "set ff=unix" -c ":wq" && \
mkdir -p ${MOODLE_DATA} && \
 		chown -R www-data:www-data /var/www/html && \
 		chown -R www-data:www-data ${MOODLE_DATA} && \
 cp /opt/postinstall2.sh /root/postinstall.sh && \
 touch /root/.bashrc \
  && echo "source /root/postinstall.sh" >> /root/.bashrc && \
  echo "alias ls='ls --color=auto'" >> /root/.bashrc && \
  echo "alias ll='ls -alF'" >> /root/.bashrc && \
  echo "alias comprehend='bash /root/postinstall.sh'" >> /root/.bashrc && \
  source /root/.bashrc

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]