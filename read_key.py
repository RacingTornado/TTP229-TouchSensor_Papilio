import time
import serial

# configure the serial connections (the parameters differs on the device you are connecting to)
ser = serial.Serial(
    port='COM5',
    baudrate=3000000,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS
)

num1='7FFEFFFE'
num2='BFFEFFFE'
num3='DFFEFFFE'
num4='EFFEFFFE'
num5='F7FEFFFE'
num6='FBFEFFFE'
num7='FDFEFFFE'
num8='FEFEFFFE'
num9='FF7EFFFE'
num10='FFBEFFFE'
num11='FFDEFFFE'
num12='FFEEFFFE'
num13='FFF6FFFE'
num14='FFFAFFFE'
num15='FFFCFFFE'
num16='FFFEFFFE';



while (1 ):
    x = ser.read(4);
    a=x.encode('hex');
    a=a.split();
    a=''.join(a);
    a=a.upper();
    print num1;
    print a;
    if(a == num1):
        print "Num1";
    if(a == num2):
        print "Num2";
    if(a == num3):
        print "Num3";
    if(a == num4):
        print "Num4";
    if(a == num5):
        print "Num5";
    if(a == num6):
        print "Num6";
    if(a == num7):
        print "Num7";
    if(a == num8):
        print "Num8";
    if(a == num9):
        print "Num9";
    if(a == num10):
        print "Num10";
    if(a == num11):
        print "Num11";
    if (a == num12):
        print "Num12";
    if (a == num13):
        print "Num13";
    if (a == num14):
        print "Num14";
    if (a == num15):
        print "Num15";
        a=ser.read(6);
        print a;
    if (a == num16):
        print "Num16";

