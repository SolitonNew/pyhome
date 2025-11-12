**PyHome** is a flexible and scalable open-source home automation system designed to control household devices, monitor system status, and collect operational statistics.

It supports a wide range of controllers, including **PyBoard** and **1-Wire**, allowing easy integration of sensors, relays, and control modules. The **web interface** provides convenient remote management and monitoring in real time, along with event history and performance statistics.

In addition to web access, **desktop control panels for Windows and Linux** and a **mobile application** are available, enabling full control of the home from anywhere. The system’s architecture is built for reliability and easy expansion — adding new devices or modules requires minimal code changes.

The repository also includes **PCB schematics and firmware for peripheral devices**, enabling hobbyists to build and program peripheral hardware at home.

**PyHome** has been in active operation for over **10 years**, proving its stability, reliability, and practical value in real-world use.

**License:** MIT

INSTALL ON ORANGE PI LIGHT

python 3.6

```
apt update
apt install mysql-server
apt install mysql-client
apt install apache2
apt install php libapache2-mod-php
apt install php-mysql php-curl php-gd php-xml php-mbstring php-zip
```
```
mkdir /var/www/pyhome
chown wisehouse:wisehouse /var/www/pyhome
cd /var/www/pyhome
git clone https://github.com/SolitonNew/pyhome.git .
cd server
cp .env.example .env
nano .env
```
```
cd /var/www/html
rm index.html
git clone https://github.com/SolitonNew/wh_http.git .
```
```
scp 2025_11_02_wisehouse.sql wisehouse@192.168.40.2:~
mysql -u root -p wisehouse < /home/wisehouse/2025_11_02_wisehouse.sql
```
```
CREATE USER 'wisehouse'@'localhost' IDENTIFIED BY 'wisehousepass';
GRANT ALL PRIVILEGES ON wisehouse.* TO 'wisehouse'@'localhost';
FLUSH PRIVILEGES;
```
```
apt install python3-setuptools
apt install python3-pip
pip3 install pyserial
apt install libcairo2-dev pkg-config python3-dev
pip3 install pycairo num2words dotenv requests
apt install python-cairocffi python3-cairocffi
apt install python3-flask
apt install python3-mysql.connector
```
```
nano /etc/mysql/my.cnf
```
```
[mysqld]
innodb_flush_log_at_trx_commit = 2
sync_binlog = 0
```
```
nano /etc/rc.local
```
```
/usr/bin/screen -dmS pyhome /var/www/pyhome/server/start.sh
```
```
echo 'vm.swappiness=1' | sudo tee -a /etc/sysctl.conf
```
