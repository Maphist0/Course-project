// ----------------------------------
// Module name:
//     lab1-11-slave.ino
//
// Description:
//     Enable button attached on master board to control LED module
//        attached on slave board.
//     This script set up a slave.
//
// Rev.0 28,June 2017
// ----------------------------------

#include <Wire.h>

// Plug in cable for LED module into socket 2
int LED = 2;

void setup()
{
  Wire.begin(4); 				        // join i2c bus with address #4
  Wire.onReceive(receiveEvent); // register event
  Serial.begin(9600); 			    // start serial for output
  pinMode(LED, OUTPUT);         // set up LED output mode
}

void loop()
{
  delay(100);
}

// function that executes whenever data is received from master
// this function is registered as an event, see setup()
void receiveEvent(int howMany)
{
  while(1 < Wire.available()) // loop through all but the last
  {
    char c = Wire.read(); 		// receive byte as a character
    Serial.print(c); 			    // print the character
    if (c == '1')
    {
      digitalWrite(LED, HIGH);
    }
    else
    {
      digitalWrite(LED, LOW);
    }
  }
  
  int x = Wire.read(); 			  // receive byte as an integer
  Serial.println(x); 			    // print the integer
  if (x == '1')
  {
    digitalWrite(LED, HIGH);
  }
  else
  {
    digitalWrite(LED, LOW);
  }
}
