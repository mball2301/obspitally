#obspitally

OBS PI Tally is a project that uses an executable java jar to interface the OBS web-socket server with a Raspberry PI GPIO interfaces to allow tally lights to be controlled (off/on) through the Raspberry PI.   I created this application for my church as we were struggling along with every one else to quickly create livestream church services while the building is closed down.  This install project should allow you to get the OBSPITally project up and running quickly.

The pre-requisites for the project are OBS websocket server plugin is running on your OBS machine, a Raspberry Pi with some form of Raspian (or other linux OS) and a basic knowledge of electronics and relays.  The install script will check for and install any other prerequisites needed to run the software (java, pi4j, wiringpi).

You will be asked a number of configuration questions during the install.  The tallypi home is the only one that would require a re-install.  The rest would require you to modify the startup script and/or the camera_defs.xml file. If you need to make any changes to the installation files or the xml file you will need to kill the tally pi process (AumcTallyLights) within about three minutes of startup, or be able to ssh in from another server while the websocket server on the OBS machine is up and running. If the Tallypi service cannot find the websocket server it will halt the system within three minutes of startup. 

To use the system you use an XML file to relate the source (camera) name in OBS to a GPIO Pin on the Raspberry PI.  When the correct source is found as the active source, the GPIO pin is energized.  This can be used to turn on and off tally (on-air) lights for you.   Below is a rough diagram of my current setup. I use a 4 bank 5 volt relay to control the tally lights of three cameras and a test light. 

```
                              _____________________
                             |                    |
                             |  aumctallypi.jar   |
                             |____________________|
                                |    |     |     |
                     GPIO PIN 3 |  6 |   5 |   4 |
                                |    |     |     |
                             _____ _____ _____ _____ 
Pin 2 - DC 5 Volt            |   | |   | |   | |   |  Pin 2 and 6 energize the relays
Pin 6 - ground               | 4 | | 3 | | 2 | | 1 |
              _______________|___|_|___|_|___|_|___|  12 volt is the output side of the relay (normally open)
             |                 |     |     |     |
             |                 |     |     |     |
12 volt DC +                   |     |     |     |
           -                   |     |     |     |  
             |                Test Tally Tally Tally
             |               Light Light Light Light
             |                 |     1     2     3
             |                 |     |     |     |
             |_________________|_____|_____|_____|
             
```             