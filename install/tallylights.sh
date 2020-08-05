#!/bin/bash

cd INSTDIR

sleep 120

CLASSPATH=.:/opt/pi4j/lib:INSTDIR/AUMCTallyLights_Lib:$CLASSPATH

# A -DDEBUG="TRUE" can be added to the JAVA startup for tracing

java -DDEBUG="FALSE" -Dobsaddress="ws://server_ip" -Dobspassword=server_password  -Dpi4j.linking=dynamic -jar AumcTallyLights.jar


echo "triggering shutdown, you will need to restart the pi"

sudo shutdown -h 
