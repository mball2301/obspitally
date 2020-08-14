#!/bin/bash
#obs pi tally install script

osrelease=`grep PRETTY_NAME /etc/os-release|awk -F= '{print $2}'| awk '{print $1}'`
osversion=`grep VERSION /etc/os-release|awk -F= '{print $2}'|tail -2 | head -n1`
if [ ${osrelease:-NA} = "NA" ]
then
    echo "OS not recognized aborting"
    exit 1
fi
echo "found OS-$osrelease VERSION-$osversion"
osshort=`echo $osrelease| cut -b2-5`
     
if [ $osshort = "Rasp" ]
then
    raspos=yes
else
    echo "installing on a none Raspian OS. Use at your own discression"
fi

set_tallypi_location()
{
echo "install in /home/pi/tallypi? (y/n)"
read response
if [ $response = "y" ]
then
    export INSTDIR="/home/pi/tallypi/"
else 
    echo "enter install location"
    read response
    export INSTDIR=$response
fi
}
 
install_java()
{
if [ ${INSTDIR:-X} = "X" ]
then
    echo "Somehow install location is not set"
    set_tallypi_location
fi
mkdir -p $INSTDIR
 
if type -p java; then
    echo found java executable in PATH
    _java=java
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
    echo found java executable in JAVA_HOME     
    _java="$JAVA_HOME/bin/java"
else
    echo "no java, installing"
    sudo apt install defalt-jdk
fi
}

test_wiringpi()
{
piver=`gpio -v | grep version | awk '{print $3}'`
if [ ${piver:-X} = "X" ]
then
    echo "wiringpi version is not installed, please install wiring pi with sudo apt-get install wiringpi"
    exit 9
fi
}

install_pi4j()
{

curl -SSL https://pi4j.com/install | sudo bash
}

install_talllypi()
{
jvers=`java -version 2>&1 | head -1 | cut -d\" -f2 | sed '/^1\./s///' | cut -d'.' -f1`
echo $jvers

case $jvers in
    8)
       curl --output /tmp/tallypi.tar https://raw.githubusercontent.com/mball2301/obspitally/master/java8/obstally8.tar
       ;;
    11)
       curl --output /tmp/tallypi.tar https://raw.githubusercontent.com/mball2301/obspitally/master/java11/obstally11.tar
       ;;
    *)
       echo "unsupported version of JAVA.  Needs to be JAVA 8 or 11."
       exit 9
       ;;
esac      

cd $INSTDIR
echo "installing tally pi application"
tar -xvf /tmp/tallypi.tar   

echo "installing tally pi shell script"
echo "enter your obs websocket server ip address:"
read obswebip
if [ ${obswebip:-X} = "X" ]
then
    obswebip="192.168.0.0"
fi

echo "enter your obs Websocket server password"
read obswebpwd
if [ ${obswebpwd:-X} = "X" ]
then
    obswebpwd="NULL"
fi 
#set -x
sed -i "s/server_ip/"$obswebip"/" tallylights.sh
sed -i "s/server_password/"$obswebpwd"/" tallylights.sh
sed -i "s@INSTDIR@$INSTDIR@" tallylights.sh

}

config_xml()
{
mkdir -p $INSTDIR/xml
editexit="y"

echo '<?xml version="1.0" encoding="UTF-8"?>'>> $INSTDIR/xml/Camera_defs.xml
echo "<cameras>" >> $INSTDIR/xml/Camera_defs.xml


while [ $editexit = "y" ]
do
    echo "     <camera>">> $INSTDIR/xml/Camera_defs.xml
    echo "enter the source name from OBS"
    read obssource
    echo " 	     <cameraName>$obssource</cameraName>">> $INSTDIR/xml/Camera_defs.xml

    echo "enter the GPIO pin to relate to this source"
    read raspgpio

    echo "to ente another relationship enter 'y'"
    read editexit
    echo "	     <cameraAddr>5</cameraAddr>">> $INSTDIR/xml/Camera_defs.xml 

    echo "     </camera>">> $INSTDIR/xml/Camera_defs.xml
done 
echo "</cameras>">> $INSTDIR/xml/Camera_defs.xml

echo "Please review your xml file and exit if everything is okay"
echo " if you make changes please exit with save to write changes"
sleep 10
mousepad $INSTDIR/xml/Camera_defs.xml

}

setup_tally_service()
{
cd $INSTDIR

echo "setting up starup services"
sed "s@INSTDIR@$INSTDIR@" ${INSTDIR}tallylights > /tmp/tallylights
sudo mv /tmp/tallylights /etc/init.d/tallylights

sudo mv ${INSTDIR}tallylights.service /lib/systemd/system/

sudo systemctl enable tallylights
sudo systemctl daemon-reload
}

cleanup()
{
rm -f /tmp/tallypi.tar
# rm -f ~/obspitally

}

#main
echo "Please make sure you have a JAVA JRE installed to run talllypi"

set_tallypi_location

install_java
     
test_wiringpi

install_pi4j

install_talllypi 

config_xml
 
setup_tally_service
	 
cleanup

exit 0 
