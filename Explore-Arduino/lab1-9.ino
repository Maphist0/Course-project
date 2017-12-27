/*
  LiquidCrystal Library - display() and noDisplay()

 Demonstrates the use a 16x2 LCD display.  The LiquidCrystal
 library works with all LCD displays that are compatible with the
 Hitachi HD44780 driver. There are many of them out there, and you
 can usually tell them by the 16-pin interface.

 This sketch prints "Hello World!" to the LCD and uses the
 display() and noDisplay() functions to turn on and off
 the display.

 The circuit:
 * LCD RS pin to digital pin 12
 * LCD Enable pin to digital pin 11
 * LCD D4 pin to digital pin 5
 * LCD D5 pin to digital pin 4
 * LCD D6 pin to digital pin 3
 * LCD D7 pin to digital pin 2
 * LCD R/W pin to ground
 * 10K resistor:
 * ends to +5V and ground
 * wiper to LCD VO pin (pin 3)

 Library originally added 18 Apr 2008
 by David A. Mellis
 library modified 5 Jul 2009
 by Limor Fried (http://www.ladyada.net)
 example added 9 Jul 2009
 by Tom Igoe
 modified 22 Nov 2010
 by Tom Igoe

 This example code is in the public domain.

 http://www.arduino.cc/en/Tutorial/LiquidCrystalDisplay

 */

// ----------------------------------
// Module name:
//     lab1-9.ino
//
// Description:
//     Control the cursor by two buttons.
//     Press down button 1, will move the cursor left by one position
//     Press down button 2, will move the cursor right.
//
// Rev.0 28,June 2017
// ----------------------------------

// include the library code:
#include <LiquidCrystal.h>

// Plug the cable for two buttons in the corresponding socket
// Button 1 in socket 10, button 2 in socket 9
int BUTTON1 = 10;
int BUTTON2 = 9;

// initialize the library with the numbers of the interface pins
LiquidCrystal lcd(2, 3, 4, 5, 6, 7, 8);

// Constants to denote the maximum length and height of the LCD display
int MAX_X = 16;
int MAX_Y = 2;
// Total points, 2 rows and 16 colums
int MAX_LEN = MAX_X * MAX_Y;

// Variable to denote current position of the cursor
// Start from the top-left corner, counting horizontally
int cursor_pos = 0;

// To hold the (x, y) coordinate of the cursor
// Only used by setCursor() function
int x = 0, y = 0;

void setup() {
  // set up the LCD's number of columns and rows:
  lcd.begin(16, 2);
  // Set cursor to the first line
  // Print a uppercased X to denote the cursor
  lcd.setCursor(0, 0);
  lcd.print("X");
  // Set up mode for both buttons
  pinMode(BUTTON1, INPUT);
  pinMode(BUTTON2, INPUT);
}

// -------------------------------
// clearLCD
// 
// Purpose:
//    Clear all outputs on the LCD display (Overriding with blank space)
// 
// Parameters:
//    None
//
// Return:
//    None
//
// Rev.0  28,June 2017
// ------------------------------
void clearLCD()
{
  for (int i = 0; i < MAX_X; i++)
  {
    for (int j = 0; j < MAX_Y; j++)
    { 
      lcd.setCursor(i, j);
      lcd.print(" ");
    }
  }
}

void loop() {
  
  int offset = 0;
  
  // Since button 1 is tested ahead of button 2
  // It means if two buttons are pressed down simultaneously,
  //    the cursor will move to the left
  if (digitalRead(BUTTON1))
  {
    // Move left, decrease the position
    offset = -1;
  }
  else if (digitalRead(BUTTON2))
  {
    // Move right, increase the position
    offset = 1; 
  }
  else
  {
    // Do nothing, keep what it is right now
    return;
  }

  // Only executed if either botton is pressed down
  // Clear the LCD screen
  // You could use "clearLCD();" instead, but the following method
  //    probably have better performance
  lcd.setCursor(x, y);
  lcd.write(" ");

  // Update the position for the cursor
  cursor_pos = (cursor_pos + offset + MAX_LEN) % (MAX_X * MAX_Y);

  // Calculate its (x, y) coordinate
  y = cursor_pos / MAX_X;
  x = cursor_pos % MAX_X;

  // Write an "X" at current cursor's position
  lcd.setCursor(x, y);
  lcd.write("X");

  // Wait for sometime, tunning the delay time 
  //    smaller will make these buttons more responsive
  delay(200);
}
