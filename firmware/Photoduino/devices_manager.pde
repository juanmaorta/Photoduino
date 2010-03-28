/**
 *
 * - Photoduino
 * - http://code.google.com/p/photoduino/
 *
 * This file is part of Photoduino.
 *
 * Photoduino is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Photoduino is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Photoduino.  If not, see <http://www.gnu.org/licenses/>.
 */

// Shoots the flash after wait a delay
void flash_shoot(unsigned int previousDelay, byte pin) {
    delay(previousDelay);
    digitalWrite(pin,HIGH); 
    delayMicroseconds(1);
    digitalWrite(pin,LOW);
 }

// Begins the shutter 
void camera_shutterBegin(unsigned int shutterLag){
    digitalWrite(PINS_SHUTTER,HIGH); 
    delay(shutterLag);
}
 
// Ends the shutter
void camera_shutterEnd(unsigned int preCloseTime){
    delay(preCloseTime);
    digitalWrite(PINS_SHUTTER,LOW); 
}

// Begins the autofocus
void camera_autofocusBegin(unsigned int autofocusTime){
    digitalWrite(PINS_AUTOFOCUS,HIGH); 
    delay(autofocusTime);
}

// Ends the autofocus
void camera_autofocusEnd(){
    digitalWrite(PINS_AUTOFOCUS,LOW);
}

// Turns the laser ON
void laser_turnOn(){
   digitalWrite(PINS_LASER,HIGH);
   delay(1); // waits for laser to anything
}

// Turns the laser OFF
void laser_turnOff(){
   digitalWrite(PINS_LASER,LOW); 
}

// Reads the value of a sensor
byte sensor_read(byte sensorPin) {
  
  byte value = analogRead(sensorPin)>>6;
  
  if (sensorPin == PINS_SENSOR_MIC) {
    if (value > 7) value = (value-7)*2;
    else value = (7-value)*2;
  }
  
  return value;
}

// Waits for sensor cross the limit
void sensor_waitFor(byte pin, byte mode, unsigned int limit){
     
  byte sensorValue = sensor_read(pin);

  for(boolean result = false; !result && !cancelFlag; sensorValue = sensor_read(pin)) {
    if (mode==SENSOR_MODE_HIGHER && sensorValue>=limit) result = true;
    if (mode==SENSOR_MODE_LOWER && sensorValue<=limit) result = true;
  }
}

// Called in interrupt mode when any button is pressed
void keyboard_interrupts(){
  if (!digitalRead(PINS_BTN_A)&&!digitalRead(PINS_BTN_B)) cancelFlag = false; 
  else cancelFlag = true;
}

// Scans keyboard buttons
void keyboard_scan() { 

  unsigned long time = millis();
  lastKey = NO_KEY;
  
  if (flagHoldKey) { 
      buzzer_beep(100);
      while(digitalRead(PINS_BTN_A) || digitalRead(PINS_BTN_B)) {}
      flagHoldKey = false; 
      delay(100);
      
  } else if (digitalRead(PINS_BTN_A)) {
     while(digitalRead(PINS_BTN_A) && (millis()-time) <= KEY_HOLD_TIME){  
        if (millis()-time >= KEY_DEBOUNCE_TIME) lastKey = KEY_A;  
        if (millis()-time >= KEY_HOLD_TIME) { lastKey = KEY_AH; flagHoldKey = true; }
     }
     
  } else if (digitalRead(PINS_BTN_B)) {
     while(digitalRead(PINS_BTN_B) && (millis()-time) <= KEY_HOLD_TIME){  
        if (millis()-time >= KEY_DEBOUNCE_TIME) lastKey = KEY_B;  
        if (millis()-time >= KEY_HOLD_TIME) { lastKey = KEY_BH; flagHoldKey = true; }
     }    
  } 
  
}

// Waits until any key is pressed
void keyboard_waitForAnyKey(){
   do{ keyboard_scan(); } while (lastKey==NO_KEY);
}

// Waits until no key is pressed
void keyboard_waitForNokey(){
   do{ keyboard_scan(); } while (lastKey!=NO_KEY);
}

// Beeps buzzer a time in ms
void buzzer_beep(int time){
  
  if (system_useSpeaker){
     analogWrite(PINS_BUZZER,64); 
     delay(time);
     analogWrite(PINS_BUZZER,0); 
  }
}

// Toggle the backlight status (on/off)
void backlight_toggle(){
  
  system_useBacklight = !system_useBacklight;
  digitalWrite(PINS_LCD_LED, system_useBacklight);
}

// prints screen title
void display_printTitle(char *title){
    lcd.clear();
    lcd.print(">");
    lcd.print(title);
    lcd.setCursor(0,1);
}

void display_printEnumeration(byte num, char *msg){
    lcd.print(num, 10);
    lcd.print(".");
    lcd.print(msg);
}

// prints resetting message
void display_printResetting(){
  lcd.clear();
  lcd.print(MSG_RESETTING);
  delay(500);
}

// prints aborting message
void display_printAborting(){
  lcd.clear();
  lcd.print(MSG_ABORTING);
}

// prints a boolean value
void display_printBoolean(boolean value) {
  lcd.print(" (");
  if (value) lcd.print(MSG_YES); else lcd.print(MSG_NO);
  lcd.print(")");
}

// Print units value
void display_printUnits(byte units){
  lcd.print("(");
  if(units==UNITS_US) lcd.print(MSG_UNITS_US);
  if(units==UNITS_MS) lcd.print(MSG_UNITS_MS);     
  if(units==UNITS_SECS) lcd.print(MSG_UNITS_SECS);
  if(units==UNITS_MINS) lcd.print(MSG_UNITS_MINS);
  if(units==UNITS_HOURS) lcd.print(MSG_UNITS_HOURS);
  if(units==UNITS_DAYS) lcd.print(MSG_UNITS_DAYS);
  if(units==UNITS_CICLES) lcd.print(MSG_UNITS_CICLES);
  lcd.print(")");
}




