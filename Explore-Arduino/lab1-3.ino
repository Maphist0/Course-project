// ----------------------------------
// Module name:
//     lab1-3.ino
//
// Description:
//     Turn on the LED module for 2 seconds and turn off for 1 second
//
// Rev.0 28,June 2017
// ----------------------------------

// Plug the jump line from "SIN" to "2" in "DIGITAL" region
int LED_ONE = 2;

// -------------------------------
// blinkBultinLED
// 
// Purpose:
//    Blink certain LED for certain time
// 
// Parameters:
//    [in] int port    - certain port for control signal
//    [in] int onTime  - how long does the light turn on
//    [in] int offTime - how long does the light go off
//
// Return:
//    None
//
// Rev.0  28,June 2017
// ------------------------------
void blinkLED(int port, int onTime, int offTime)
{
  digitalWrite(port, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(onTime);              // wait for certain seconds
  digitalWrite(port, LOW);    // turn the LED off by making the voltage LOW
  delay(offTime);             // wait for certain seconds
}

void setup() 
{
  // initialize digital pin LED_ONE as an output.
  pinMode(LED_ONE, OUTPUT);
}

// the loop function runs over and over again forever
void loop() 
{
  // 2 seconds on and 1 second off
  blinkLED(LED_ONE, 2000, 1000);
}
