// ----------------------------------
// Module name:
//     lab1-5.ino
//
// Description:
//     Let the button control the LED module
//     Press down the button, lighten the LED
//
// Rev.0 28,June 2017
// ----------------------------------

// Plug the jump line for LED module from "SIN" to "2" in "DIGITAL" region
int LED = 2;
// Plug the jump line for button from "SIN" to "4" in "DIGITAL" region
int BUTTON = 4;

void setup() {
  // initialize digital pin LED_ONE as an output.
  pinMode(LED, OUTPUT);
  pinMode(BUTTON, INPUT);
}

// the loop function runs over and over again forever
void loop() {
  if (digitalRead(BUTTON))
  {
    digitalWrite(LED, HIGH);
  }
  else
  {
    digitalWrite(LED, LOW);
  }
}
