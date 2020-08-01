#!/bin/bash

osrelease=(grep PRETTY_NAME /etc/os-release|awk -F= '{print $2})
osversion=(grep VERSION /etc/os-release|awk -F= '{print $2} )
if [ ${osrelease:-NA} = "NA" ]
then
    echo "OS not recognized aborting"
    exit 1
 fi
 echo "found OS-$osrelease VERSION-$osversion"
 osshort=(echo $osversion | cut -b1-4)
      
 if [ $osshort = "Rasp"
 then
     raspos=yes
 else
     echo "installing on a none Raspian OS. Use at your own discression"
 fi


test_Pi4J()
{
echo "pi4j"
# test to see if pi4j and wiring pi are installed if not ask if you can install

}


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
 
 install_talllypi()
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
    echo "no java"
    exit 5
fi

jvers=(java -version 2>&1 | head -1 | cut -d'"' -f2 | sed '/^1\./s///' | cut -d'.' -f1)

case in $jvers
    8)
       curl -output /tmp/tallypi.tar https://github.com/mball2301/obspitally/java8/obstally8.tar
       ;;
    11)
       curl -output /tmp/tallypi.tar https://github.com/mball2301/obspitally/java8/obstally11.tar
       ;;
    *)
       echo "unsupported version of JAVA.  Needs to be JAVA 8 or 11."
       exit 9
       ;;
esac      
       
cd $INSTDIR
echo "installing tally pi application"
tar -xv /tmp/tallypi.tar   

echo "installing tally pi shell script"
echo "enter your obs websocket server ip address:"
read obswebip
if ${obswebip:-X} = "X" ]
then
    obswebip=192.168.0.0
fi

echo "enter your obs Websocket server password"
read obswebpwd
if [ ${obswebpwd:-X} = "X" ]
then
    obswebpwd="NULL"
fi 
sed -e tallylights.sh "s/{server_ip}/$obswebip/"
sed -e tallylights.sh "s/{server_password}/$obswebpwd/"
sed -e tallylights.sh "s/{INSTDIR}/$INSTDIR/"

}

setup_tally_service()
{
cd $INSTDIR

echo "setting up starup services"
sed tallylights "s/{INSTDIR}/$INSTDIR}/" > /etc/init.d/tallylights

mv tallylights.service /usr/lib/systemd/shared/

systemctl enable tallylights
systemctl reload
}

cleanup()
}
rm -f $INSTDIR/tallylights
rm -f /tmp/tallypi.tar

}

#main
echo "Please make sure you have a JAVA JRE installed to run talllypi"



set_tallypi_location
     
install_talllypi 
 
setup_tally_service
	 
cleanup

exit 0 