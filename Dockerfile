FROM ubuntu:20.04
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

#Update Enviroment
RUN apt-get update && \
 DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata && \
 apt-get -y install locales && \
 locale-gen en_US.UTF-8 && \ 
 localedef -i en_US -f UTF-8 en_US.UTF-8 && \ 
 export LANGUAGE=en_US.UTF-8 && \
 export LANG=en_US.UTF-8 && \
 export LC_ALL=en_US.UTF-8 && \
 dpkg-reconfigure locales && \
 apt-get -y install vim\
 nano\
 figlet\
 curl\
 wget\
 htop\
 iputils-ping\
 unzip\
 apache2\
 mysql-client\
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
 php7.4-soap\
 php7.4-mbstring\
 git\
 git-core && \
 rm -rf /var/www/html/* && \ 
 git clone --depth 1 -b MOODLE_${MOODLE_VERSION}_STABLE https://github.com/moodle/moodle.git /var/www/html/ && \
 mkdir -p ${MOODLE_DATA} && \
 chown -R www-data:www-data /var/www/html && \
 chown -R www-data:www-data ${MOODLE_DATA} && \
 a2enmod ssl && a2ensite default-ssl && \
 ln -sf /dev/stdout /var/log/apache2/access.log && \
 ln -sf /dev/stderr /var/log/apache2/error.log && \
 apt-get clean && \
 echo "opcache.enable = 1" >> /etc/php/7.4/mods-available/opcache.ini && \
 echo "opcache.memory_consumption = 128" >> /etc/php/7.4/mods-available/opcache.ini && \
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
 service apache2 restart

COPY config.comprehend.php postinstall2.sh /opt
RUN vim /opt/postinstall2.sh -c "set ff=unix" -c ":wq" && \
 mv /opt/config.comprehend.php /var/www/html/config.comprehend.php && \
 mv /opt/postinstall2.sh /var/www/html/postinstall.sh
#CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]