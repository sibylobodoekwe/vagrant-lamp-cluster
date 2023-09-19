FROM httpd:latest
EXPOSE 80
RUN apt update && apt install -y apache2 mysql-server php libapache2-mod-php
RUN systemctl enable apache2 && systemctl enable mysql && mysql_secure_installation
