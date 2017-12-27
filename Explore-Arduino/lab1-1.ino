// ----------------------------------
// Module name:
//     lab1-1.ino
//
// Description:
//     Turn on the builtin LED for 2 seconds and turn off for 1 second
//
// Rev.0 28,June 2017
// ----------------------------------

// -------------------------------
// blinkBultinLED
// 
// Purpose:
//    Blink the builtin LED for certain time
// 
// Parameters:
//    [in] int onTime  - how long does the light turn on
//    [in] int offTime - how long does the light go off
//
// Return:
//    None
//
// Rev.0  28,June 2017
// ------------------------------
void blinkBuiltinLED(int onTime, int offTime)
{
  digitalWrite(LED_BUILTIN, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(onTime);                     // wait for certain seconds
  digitalWrite(LED_BUILTIN, LOW);    // turn the LED off by making the voltage LOW
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
  // 2 seconds on and 1 second off
  blinkBuiltinLED(2000, 1000);
}
