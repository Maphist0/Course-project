// ----------------------------------
// Module name:
//     lab1-4.ino
//
// Description:
//     Turn on the LED module for 1 second twice and 2 seconds twice
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
  delay(onTime);                     // wait for certain seconds
  digitalWrite(port, LOW);    // turn the LED off by making the voltage LOW
  delay(offTime);                    // wait for certain seconds
}

// the setup function runs once when you press reset or power the board
void setup() 
{
  // initialize digital pin LED_BUILTIN as an output.
  pinMode(LED_BUILTIN, OUTPUT);
}

// the loop function runs over and over again forever
void loop() 
{
  // 1 second blink twice
  blinkLED(LED_ONE, 1000, 1000);
  blinkLED(LED_ONE, 1000, 1000);
  // 2 seconds blink twice
  blinkLED(LED_ONE, 2000, 2000);
  blinkLED(LED_ONE, 2000, 2000);
}
