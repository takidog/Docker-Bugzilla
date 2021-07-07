FROM ubuntu:16.04

LABEL Author Takidog

ARG DB_DRIVER
ARG DB_HOST
ARG DB_NAME
ARG DB_USER
ARG DB_PASS
ARG DB_PORT
ARG ADMIN_EMAIL
ARG ADMIN_PASSWORD
ARG ADMIN_REALNAME

ENV DB_DRIVER $DB_DRIVER
ENV DB_HOST $DB_HOST
ENV DB_NAME $DB_NAME
ENV DB_USER $DB_USER
ENV DB_PASS $DB_PASS
ENV DB_PORT $DB_PORT
ENV ADMIN_EMAIL $ADMIN_EMAIL
ENV ADMIN_PASSWORD $ADMIN_PASSWORD
ENV ADMIN_REALNAME $ADMIN_REALNAME


RUN apt-get update -y

RUN apt-get install -y git nano

RUN apt-get install -y apache2 libappconfig-perl libdate-calc-perl libtemplate-perl libmime-perl build-essential libdatetime-timezone-perl libdatetime-perl libemail-sender-perl libemail-mime-perl libemail-mime-modifier-perl libdbi-perl libdbd-mysql-perl libcgi-pm-perl libmath-random-isaac-perl libmath-random-isaac-xs-perl libapache2-mod-perl2 libapache2-mod-perl2-dev libchart-perl libxml-perl libxml-twig-perl perlmagick libgd-graph-perl libtemplate-plugin-gd-perl libsoap-lite-perl libhtml-scrubber-perl libjson-rpc-perl libdaemon-generic-perl libtheschwartz-perl libtest-taint-perl libauthen-radius-perl libfile-slurp-perl libencode-detect-perl libmodule-build-perl libnet-ldap-perl libfile-which-perl libauthen-sasl-perl libtemplate-perl-doc libfile-mimeinfo-perl libhtml-formattext-withlinks-perl libgd-dev libmysqlclient-dev lynx-cur graphviz python-sphinx rst2pdf

RUN apt-get install -y openssh-server supervisor

RUN mkdir -p /var/run/sshd

RUN mkdir -p /var/log/supervisor

RUN mkdir -p /home

WORKDIR /home

RUN git clone --depth 1 --branch release-5.0-stable https://github.com/bugzilla/bugzilla bugzilla

COPY supervisord.conf /etc/supervisord.conf

RUN chmod 700 /etc/supervisord.conf

RUN mkdir -p /var/www/html/

RUN cp -r bugzilla /var/www/html/

WORKDIR /var/www/html/bugzilla/

RUN ./install-module.pl -all

RUN a2enmod cgi
RUN a2enmod cgid
RUN a2enmod expires 
RUN a2enmod headers 
RUN a2enmod rewrite 

# Run first time to create localconfig

RUN ./checksetup.pl

# replace localconfig 
COPY config.py /var/www/html/bugzilla/
RUN python config.py

# Second config
RUN ./checksetup.pl adminconfig

# Add apache config

COPY apache_bugzilla.conf /etc/apache2/sites-enabled/

RUN rm adminconfig

RUN service apache2 restart

WORKDIR /home

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
