# TTP229-TouchSensor_Papilio

This project aims to use a touch keypad sensor with the papilio boards. The TTP229 is generally not very well documented . I got this one on http://www.ebay.com/itm/4x4-Keyboard-TTP229-Digital-Touch-Sensor-Capacitive-Touch-Switch-Module-/371062592514 .
The 8 pins can directl be used without using any specific protocol. Each pin is conneted to a button. However to use the entire 16 set of pins 2 steps needs to be taken:
- Need to connect the two traces which are broken out  on the PCB as shown in the picture below. This post explains it well.http://itimewaste.blogspot.in/2014/12/arduino-code-for-ttp229-touch-16-button.html
- Generate the clocks on the papilio.

The python script is also attached in the same repository.
