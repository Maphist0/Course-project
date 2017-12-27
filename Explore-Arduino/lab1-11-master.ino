// ----------------------------------
// Module name:
//     lab1-11-master.ino
//
// Description:
//     Enable button attached on master board to control LED module
//        attached on slave board.
//     This script set up a master.
//
// Rev.0 28,June 2017
// ----------------------------------

#include <Wire.h>

// Plug in cable for button module into socket 4
int BUTTON = 4;

void setup()
{
  Wire.begin(); 				      // join i2c bus (address optional for master)
  Serial.begin(9600); 			  // start serial for output
  pinMode(BUTTON, INPUT);
}

// The data to be sent
byte x = 0;

void loop()
{
  Wire.beginTransmission(4); 	// transmit to device #4

  // If the button pressed, send 1.
  // Otherwise send 0.
  if (digitalRead(BUTTON))
  {
    Wire.write("1");
    Serial.println("Button pressed");
  }
  else
  {
    Wire.write("0");
    Serial.println("Button not pressed");
  }

  Wire.endTransmission(); 		// stop transmitting
  delay(50);                  // refresh rate
}
