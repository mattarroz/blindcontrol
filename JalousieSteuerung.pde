/*
  LiquidCrystal Library - Hello World
 
 Demonstrates the use a 16x2 LCD display.  The LiquidCrystal
 library works with all LCD displays that are compatible with the 
 Hitachi HD44780 driver. There are many of them out there, and you
 can usually tell them by the 16-pin interface.
 
 This sketch prints "Hello World!" to the LCD
 and shows the time.
 
 The circuit:
 * LCD RS pin 4 to digital pin A0
 * LCD Enable 6 pin to digital pin A1
 * LCD D4 pin 11 to digital pin A2
 * LCD D5 pin 12 to digital pin A3
 * LCD D6 pin 13 to digital pin A4
 * LCD D7 pin 14 to digital pin A5
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
 
 http://www.arduino.cc/en/Tutorial/LiquidCrystal
 */

// include the library code:
#include <LiquidCrystal.h>
#include <avr/io.h>
#include <avr/pgmspace.h>
#include "Time.h"
#include "main.h"
#include "menu.h"

// initialize the library with the numbers of the interface pins
LiquidCrystal lcd (A0, A1, A2, A3, A4, A5);
uint8_t state;
uint8_t nextstate;
PGM_P statetext;
uint8_t (*pStateFunc)(uint8_t);
uint8_t input;
uint8_t last_buttons;
int8_t motorspeed = 0;
uint8_t motor = 0;


#define MOTOR0_EN1  7
#define MOTOR0_EN2  8
#define MOTOR0_PWM  9
#define MOTOR1_EN1  11
#define MOTOR1_EN2  12
#define MOTOR1_PWM  10

#define PIN_PLUS   0
#define PIN_MINUS  2
#define PIN_NEXT   4
#define PIN_PREV   6

#define JALOUSIE0_DELAY 27
#define JALOUSIE1_DELAY 27

#define HOUR 1
#define MINUTE 2
#define SECOND 3
uint8_t mode = HOUR;

uint8_t alarm_enabled = 0;

time_t alarm_time = 0, alarm_compare = 0;

uint8_t i,j;
char buffer[21];
void
setup ()
{
  // set up the LCD's number of columns and rows: 
  lcd.begin (20, 2);
  /* Motor 1 A,B */
  pinMode (MOTOR0_EN1, OUTPUT);
  pinMode (MOTOR0_EN2, OUTPUT);
  digitalWrite (MOTOR0_EN1, HIGH);
  digitalWrite (MOTOR0_EN2, LOW);
  analogWrite (MOTOR0_PWM, 0);
  /* Motor 2 A,B */
  pinMode (MOTOR1_EN1, OUTPUT);
  pinMode (MOTOR1_EN2, OUTPUT);
  digitalWrite (MOTOR1_EN1, HIGH);
  digitalWrite (MOTOR1_EN2, LOW);
  analogWrite (MOTOR1_PWM, 0);

  /* This sets the PWM frequency to 32.768 kHz */
  //  TCCR1B = TCCR1B & 0b11111000 | 0x01;
  // TCCR1A = _BV(COM2A1) | _BV(COM2B1) | _BV(WGM21) | _BV(WGM20);
  TCCR1B = _BV(CS22);

  /* This sets the PWM frequency to 32.768 kHz */
  //  TCCR1A = TCCR1A & 0b11111000 | 0x01;



  /* Button 1 */

  pinMode(PIN_NEXT, INPUT);
  pinMode(PIN_PREV, INPUT);
  pinMode (PIN_PLUS, INPUT);
  pinMode (PIN_MINUS, INPUT);

  setTime (8, 29, 0, 0, 0, 0);	// set time to Saturday 8:29:00am Jan 1 2011  

  // Initial state variables
  state = ST_MOTOR;
  nextstate = ST_MOTOR;
  statetext = MT_MOTOR;
  pStateFunc = NULL;
}

int freeRam () {
  extern int __heap_start, *__brkval; 
  int v; 
  return (int) &v - (__brkval == 0 ? (int) &__heap_start : (int) __brkval); 
}



void
loop ()
{
  input = !digitalRead(PIN_NEXT);//(digitalRead(5) == LOW ? 1 : 0);
  input |= ((!digitalRead(PIN_PREV)) << 1);
  input |= ((!digitalRead(PIN_PLUS)) << 2);
  input |= ((!digitalRead(PIN_MINUS)) << 3);
  ShowTime (now());
  
  // Plain menu text
  if (statetext)
  {
    lcd.clear();
    lcd.setCursor(0, 0);
    strcpy_P(buffer, statetext);
    lcd.print (buffer);
    statetext = NULL;
  }


  if (pStateFunc)
  {
    // When in this state, we must call the state function
    nextstate = pStateFunc (input);
  }
  else if (input != KEY_NULL)
  {
    // Plain menu, clock the state machine
    nextstate = StateMachine (state, input);
  }

  if (nextstate != state)
  {
    state = nextstate;
    // mt: for (i=0; menu_state[i].state; i++)
    for (i = 0; (j = pgm_read_byte (&menu_state[i].state)); i++)
    {
      //mt: if (menu_state[i].state == state)
      //mt 1/06 if (pgm_read_byte(&menu_state[i].state) == state)
      if (j == state)
      {
        // mtA
        // mt - original: statetext =  menu_state[i].pText;
        // mt - original: pStateFunc = menu_state[i].pFunc;
        /// mt this is like the example from an avr-gcc guru (mailing-list):
        statetext = (PGM_P) pgm_read_word (&menu_state[i].pText);
        // mt - store pointer to function from menu_state[i].pFunc in pStateFunc
        //// pStateFunc = pmttemp;      
        pStateFunc =  (uint8_t (*)(uint8_t)) pgm_read_word (&menu_state[i].pFunc);
        // mtE
        break;
      }
    }
  }
  delay(200);

   alarm_compare = hoursToTime_t(hour()) + minutesToTime_t(minute());
  if ((alarm_compare == alarm_time) && (state != ST_ALARM_SET_FUNC) && alarm_enabled) {
    OperateJalousieOpen(0);
    OperateJalousieOpen(1);
    // this disables the alarm
    alarm_enabled = 0;
  }
}





void
ShowTime (time_t time)
{
  lcd.setCursor(0,1);
  if (hour(time) < 10)
    lcd.print ('0');
  lcd.print(hour (time));
  printDigits (minute (time));
  printDigits (second (time));
}


void
printDigits (int digits)
{
  lcd.print (":");
  if (digits < 10)
    lcd.print ('0');
  lcd.print (digits);
}

char
SetClock (char input)
{
  ShowTime(now());

  switch (mode) {
  case HOUR:
    lcd.setCursor(1,1);

    switch (input) {
    case KEY_PLUS:
      setTime (hour()+1, minute(), second(), 0, 0, 0);
      break;
    case KEY_MINUS:
      setTime (hour()-1, minute(), second(), 0, 0, 0);
      break;
    case KEY_PREV:
      lcd.noBlink();
      return ST_TIME_CLOCK_ADJUST;
      break;
    case KEY_NEXT:
      mode = MINUTE;
      break;
    default:
      break;
    }
    break;

  case MINUTE:
    lcd.setCursor(3,1);
    switch (input) {
    case KEY_PLUS:
      setTime (hour(), minute()+1, second(), 0, 0, 0);
      break;
    case KEY_MINUS:
      setTime (hour(), minute()-1, second(), 0, 0, 0);
      break;
    case KEY_PREV:
      mode = HOUR;
      break;
    case KEY_NEXT:
      mode = HOUR;
      lcd.noBlink();
      return ST_TIME_CLOCK_ADJUST;
      break;
    default:
      break;
    }
    break;
  default: 
    break;
  }  

  lcd.blink();  
  return ST_TIME_CLOCK_ADJUST_FUNC;
}

char
AlarmDisable (char input){
  alarm_enabled = 0;
  return ST_ALARM_DISABLE;
}

char
AlarmGet (char input)
{
  lcd.setCursor (0,1);   
  if (!alarm_enabled) {
    lcd.print("Alarm not set");
    delay(1000);
    return ST_ALARM_GET;
  }

  // digital clock display of the time
  ShowTime(alarm_time);
  if (input)
    return ST_ALARM_GET;
  else
    return ST_ALARM_GET_FUNC;
}

char
AlarmSet(char input)
{
  ShowTime(alarm_time);

  switch (mode) {
  case HOUR:
    lcd.setCursor(1,1);

    switch (input) {
    case KEY_PLUS:
      alarm_time += SECS_PER_HOUR;
      break;
    case KEY_MINUS:
      /* avoid alarm_time underflow, wrap time instead */
      if (alarm_time - SECS_PER_HOUR < 0) 
        alarm_time += 23UL * SECS_PER_HOUR;
      else
        alarm_time -= SECS_PER_HOUR;
      break;
    case KEY_PREV:
      lcd.noBlink();
      alarm_enabled = 1;
      return ST_ALARM_SET;
      break;
    case KEY_NEXT:
      mode = MINUTE;
      break;
    default:
      break;
    }
    break;

  case MINUTE:
    lcd.setCursor(3,1);
    switch (input) {
    case KEY_PLUS:
      alarm_time += SECS_PER_MIN;
      break;
    case KEY_MINUS:
      /* avoid alarm_time underflow, wrap time instead */
      if (alarm_time - SECS_PER_MIN < 0)
        alarm_time = 23UL * SECS_PER_HOUR + 59UL * SECS_PER_MIN;
      else
        alarm_time -= SECS_PER_MIN;
      break;
    case KEY_PREV:
      mode = HOUR;
      break;
    case KEY_NEXT:
      lcd.noBlink();
      mode = HOUR;
      alarm_enabled = 1;
      return ST_ALARM_SET;
      break;    
    default:
      break;
    }
    break;
  default: 
    break;
  }  

  lcd.blink();  

  return ST_ALARM_SET_FUNC;
}


char
OperateJalousieClose (char input)
{
}

char OperateJalousieOpen(char jalousie) {
  uint8_t motor_en1;
  uint8_t motor_en2;
  uint8_t motor_pwm;

  if (jalousie) {
    motor_en1 = MOTOR1_EN1;
    motor_en2 = MOTOR1_EN2;
    motor_pwm = MOTOR1_PWM;
  } 
  else {
    motor_en1 = MOTOR0_EN1;
    motor_en2 = MOTOR0_EN2;
    motor_pwm = MOTOR0_PWM;
  }

  digitalWrite(motor_en1,HIGH);
  digitalWrite(motor_en2,LOW);
  lcd.setCursor (0,1);
  lcd.print("Accelerating...");
  for (i = 0; i < 255; i++) {
    analogWrite(motor_pwm,i);
    delay(25);
  }
  lcd.setCursor(0,1);
  lcd.print("Stopping in     s");
  for (i = (jalousie ? JALOUSIE1_DELAY : JALOUSIE0_DELAY); i > 0; i--) {
    lcd.setCursor(12,1);
    if (i < 10)
      lcd.print ('0');
    lcd.print(i,DEC);
    delay(1000);
  }
  lcd.setCursor(0,1);
  for (i = 0; i < 20; i++)
    lcd.write(' ');
  lcd.setCursor(0,1);
  lcd.print("Breaking...");
  for (i = 255; i > 0; i--) {
    analogWrite(motor_pwm,i);
    delay(25);
  }
  lcd.setCursor(0,1);
  for (i = 0; i < 20; i++)
    lcd.write(' ');
  digitalWrite(motor_en1,HIGH);
  digitalWrite(motor_en2,HIGH);

  return (jalousie ? ST_MOTOR_JALOUSIE1_OPEN : ST_MOTOR_JALOUSIE0_OPEN);
}

char
OperateJalousie0Open (char input)
{
  return OperateJalousieOpen(0);
}

char
OperateJalousie1Open (char input)
{
  return OperateJalousieOpen(1);
}

char
OperateJalousieManuallyFunc (char input)
{
  uint8_t motor_en1;
  uint8_t motor_en2;
  uint8_t motor_pwm;

  lcd.setCursor(10,1);
  for (i = 0; i < 10; i++)
    lcd.write(' ');
  lcd.setCursor(10,1);
  lcd.print("S:");
  lcd.print(motorspeed,DEC);
  lcd.print(" M:");
  lcd.print(motor,DEC);

  switch(input) {
  case KEY_PLUS:
    if (motorspeed < 120)
      motorspeed += 10;
    break;
  case KEY_MINUS:
    if (motorspeed > -120)
      motorspeed -= 10;
    break;
  case KEY_NEXT:
    motor = !motor;
    break;
  case KEY_PREV:
    return ST_MOTOR_OPERATE;
    break;
  default:
    break;
  }
  if (motor) {
    motor_en1 = MOTOR1_EN1;
    motor_en2 = MOTOR1_EN2;
    motor_pwm = MOTOR1_PWM;
  } 
  else {
    motor_en1 = MOTOR0_EN1;
    motor_en2 = MOTOR0_EN2;
    motor_pwm = MOTOR0_PWM;
  }
  if (motorspeed > 3) {
    digitalWrite(motor_en1,HIGH);
    digitalWrite(motor_en2,LOW);
  } 
  else if (motorspeed < -3) {
    digitalWrite(motor_en1,LOW);
    digitalWrite(motor_en2,HIGH);    
  } 
  else {
    digitalWrite(motor_en1,HIGH);
    digitalWrite(motor_en2,HIGH);
  }
  analogWrite(motor_pwm,abs(motorspeed)*2);

  return ST_MOTOR_OPERATE_MANUALLY_FUNC;
}


/*****************************************************************************
 *
 *   Function name : StateMachine
 *
 *   Returns :       nextstate
 *
 *   Parameters :    state, stimuli
 *
 *   Purpose :       Shifts between the different states
 *
 *****************************************************************************/
unsigned char StateMachine(char state, unsigned char stimuli)
{
  unsigned char nextstate = state;    // Default stay in same state
  unsigned char i, j;

  // mt: for (i=0; menu_nextstate[i].state; i++)
  for (i=0; ( j=pgm_read_byte(&menu_nextstate[i].state) ); i++ )
  {
    // mt: if (menu_nextstate[i].state == state && menu_nextstate[i].input == stimuli)
    // mt 1/06 : if (pgm_read_byte(&menu_nextstate[i].state) == state && 
    if ( j == state && 
      pgm_read_byte(&menu_nextstate[i].input) == stimuli)
    {
      // This is the one!
      // mt: nextstate = menu_nextstate[i].nextstate;
      nextstate = pgm_read_byte(&menu_nextstate[i].nextstate);
      break;
    }
  }

  return nextstate;
}










