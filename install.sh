#!/bin/bash
export CURRENT_DIR=$PWD
export DIR="/opt"
export PROJECT="cs"
DEB_PACKAGE_NAME="wget git unzip"
YUM_PACKAGE_NAME="wget git unzip"
BOLD='\033[1m'       #  ${BOLD}
LGREEN='\033[1;32m'     #  ${LGREEN}
LBLUE='\033[1;34m'     #  ${LBLUE}
BGGREEN='\033[42m'     #  ${BGGREEN}
BGGRAY='\033[47m'     #  ${BGGRAY}
BREAK='\033[m'       #  ${BREAK}
regex='^[0-9]+$'
if cat /etc/*release | grep ^NAME | grep CentOS; then
    echo "==============================================="
    echo "Installing packages $YUM_PACKAGE_NAME on CentOS"
    echo "==============================================="
    yum install -y $YUM_PACKAGE_NAME
 elif cat /etc/*release | grep ^NAME | grep Red; then
    echo "==============================================="
    echo "Installing packages $YUM_PACKAGE_NAME on RedHat"
    echo "==============================================="
    yum install -y $YUM_PACKAGE_NAME
 elif cat /etc/*release | grep ^NAME | grep Fedora; then
    echo "================================================"
    echo "Installing packages $YUM_PACKAGE_NAME on Fedora"
    echo "================================================"
    yum install -y $YUM_PACKAGE_NAME
 elif cat /etc/*release | grep ^CentOS; then
    echo "================================================"
    echo "Installing packages $YUM_PACKAGE_NAME on Fedora"
    echo "================================================"
    OS="CentOS6"
    yum install -y $YUM_PACKAGE_NAME
 elif cat /etc/*release | grep ^NAME | grep Ubuntu; then
    echo "==============================================="
    echo "Installing packages $DEB_PACKAGE_NAME on Ubuntu"
    echo "==============================================="
    apt-get update
    apt-get install -y $DEB_PACKAGE_NAME
 elif cat /etc/*release | grep ^NAME | grep Debian ; then
    echo "==============================================="
    echo "Installing packages $DEB_PACKAGE_NAME on Debian"
    echo "==============================================="
    apt-get update
    apt-get install -y $DEB_PACKAGE_NAME
 elif cat /etc/*release | grep ^NAME | grep Mint ; then
    echo "============================================="
    echo "Installing packages $DEB_PACKAGE_NAME on Mint"
    echo "============================================="
    apt-get update
    apt-get install -y $DEB_PACKAGE_NAME
 elif cat /etc/*release | grep ^NAME | grep Knoppix ; then
    echo "================================================="
    echo "Installing packages $DEB_PACKAGE_NAME on Kanoppix"
    echo "================================================="
    apt-get update
    apt-get install -y $DEB_PACKAGE_NAME
 else
    echo "OS NOT DETECTED, couldn't install package $PACKAGE"
    exit 1;
 fi

 clear
echo -en "\n${BOLD} Script install required packages${BREAK}\n\n"
cd $DIR && rm -rf $PROJECT

#CS
wget https://fs01n1.sendspace.com/dl/737d05da507f07bc5a3df332e8362007/5e021c4c4b64bfc1/w7hsep/server.zip
unzip -P DBF8EC3DB1D4B93B848197591827939C server.zip -d $DIR
rpm -i $DIR/$PROJECT/jre-8u121-linux-x64.rpm

#Generate Password
PASSWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)

#Obtain IP
IP=$(wget --timeout=1 --tries=1 -qO- ipinfo.io/ip)
if [[ "${IP}" = "" ]]; then
    IP=$(wget --timeout=1 --tries=1 -qO- ipecho.net/plain)
fi
if [[ "${IP}" = "" ]]; then
    IP=$(wget --timeout=1 --tries=1 -qO- icanhazip.com)
fi
if [[ "${IP}" = "" ]]; then
    IP=$(wget --timeout=1 --tries=1 -qO- ident.me)
fi

echo "[Unit]
Description=$PROJECT
After=network.target
[Service]
WorkingDirectory=/opt/$PROJECT
ExecStart=/opt/$PROJECT/launch.sh $IP $PASSWORD
Restart=on-failure
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=$PROJECT
OOMScoreAdjust=-100
[Install]

WantedBy=multi-user.target" > /etc/systemd/system/$PROJECT.service
systemctl daemon-reload
systemctl enable $PROJECT
systemctl start $PROJECT

clear
echo -e  "===================================\n"
echo -en "${LGREEN}Install Complete!${BREAK}\n"
echo -en "Для подключения:\n"
echo -en "LINUX: Скачайте клиент по ссылке, разархивируйте https://mega.nz/#!9qBjxSyS!5AZEB3l0JGbWaYdba6G9JGQFPsX8_qmSlGRKgvl4VBM"
echo -en "Откройте терминал, перейдите в папку куда скачали клиент, и вставьте строку:${BOLD}java -XX:ParallelGCThreads=8 -XX:+AggressiveHeap -XX:+UseParallelGC -jar cobaltstrike.jar${BREAK}\n"
echo -en "В появившемся окне укажите HOST: $IP, PORT: 50050, USER: любой ник и Pasword: $PASSWORD"  
echo -en "\n\n"
echo -en "WINDOWS: Скачайте клиент и Java необходимой версии в архиве по ссылке, разархивируйте, установите Java и запустите .exe файл https://mega.nz/#!9v4zTCKL!V1P3y2kJrNl0c1RVl98puGnEDyvbqk2WHl-bv0ykluQ\n"
echo -en "В появившемся окне укажите HOST: $IP, PORT: 50050, USER: любой ник и Pasword: $PASSWORD"  
rm -f install.sh
rm -f $DIR/$PROJECT/jre-8u121-linux-x64.rpm


