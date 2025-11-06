The system of "wise house" created in Python.

The project was continued in the new system. Repository by link: https://github.com/SolitonNew/wh


INSTALL

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
pip3 install pycairo
apt install python-cairocffi python3-cairocffi
apt install python3-flask
apt install python3-mysql.connector
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