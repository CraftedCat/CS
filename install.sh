#!/bin/bash
echo "==============================================="
echo -en "${LGREEN}Centos 7 only${BREAK}\n"
echo "==============================================="
if [ -n "$1" ]
then
    UNIQ=$1
else
    echo -en "Укажите ${LGREEN}пароль${BREAK}:" 
    read UNIQ
fi
export CURRENT_DIR=$PWD
export DIR="/opt"
export PROJECT="cs"
DEB_PACKAGE_NAME="wget unzip"
YUM_PACKAGE_NAME="wget unzip"
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

# clear

echo -en "\n${BOLD} Script installed required packages${BREAK}\n\n"
rm -rf $DIR/$PROJECT

#CS
wget --quiet --directory-prefix=$DIR/ --no-cache --ftp-user=cs --ftp-password=UNIQ ftp://sip.mybot.work:21/server.zip
unzip -P UNIQ $DIR/server.zip -d $DIR/$PROJECT
rpm -i $DIR/$PROJECT/jre-8u121-linux-x64.rpm
chmod +x $DIR/$PROJECT/launch.sh

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
ExecStart=$DIR/$PROJECT/launch.sh $IP $PASSWD
Restart=on-failure
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=$PROJECT
OOMScoreAdjust=-100
[Install]

WantedBy=multi-user.target" > /etc/systemd/system/$PROJECT.service
systemctl daemon-reload
systemctl enable $PROJECT
systemctl restart $PROJECT

# clear
echo -e  "===================================\n"
echo -en "${LGREEN}Install Complete!${BREAK}\n"
echo -en "Для подключения:\n"
echo -en "${LBLUE}LINUX${BREAK}: Скачайте клиент по ссылке и разархивируйте https://mega.nz/#!9qBjxSyS!5AZEB3l0JGbWaYdba6G9JGQFPsX8_qmSlGRKgvl4VBM\n\n"
echo -en "Откройте терминал, перейдите в папку куда скачали клиент, и запустите строку:\n"
echo -en "${BOLD}java -XX:ParallelGCThreads=8 -XX:+AggressiveHeap -XX:+UseParallelGC -jar cobaltstrike.jar${BREAK}\n"
echo -en "В появившемся окне клиента укажите HOST: ${BOLD}$IP${BREAK}, PORT: ${BOLD}50050${BREAK}, USER: ${BOLD}ВАШ_НИК${BREAK} и Pasword: ${BOLD}$PASSWD${BREAK}\nn"  
echo -en "${LBLUE}WINDOWS${BREAK}: Скачайте клиент и Java необходимой версии в архиве по ссылке, разархивируйте, установите Java и запустите .exe файл\n"
echo -en "https://mega.nz/#!9v4zTCKL!V1P3y2kJrNl0c1RVl98puGnEDyvbqk2WHl-bv0ykluQ\n"
echo -en "В появившемся окне клиента укажите HOST: ${BOLD}$IP${BREAK}, PORT: ${BOLD}50050${BREAK}, USER: ${BOLD}ВАШ_НИК${BREAK} и Pasword: ${BOLD}$PASSWD${BREAK}\n" 
#Erase project files
rm -f $DIR/$PROJECT/jre-8u121-linux-x64.rpm
rm -f $DIR/server.zip
#erase install script
rm -f $CURRENT_DIR/install.sh

