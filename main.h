//Revisions number
#define SWHIGH  0
#define SWLOW   7
// mt
#define SWLOWLOW 6

#define KEY_NULL    0
#define KEY_ENTER   1
#define KEY_NEXT    1
#define KEY_PREV    2
#define KEY_PLUS    4
#define KEY_MINUS   8

// main.h

void Initialization(void);
unsigned char StateMachine(char state, unsigned char stimuli);
void
ShowTime (time_t time);
char
SetClock (char input);


char
AlarmGet (char input);
char
AlarmSet(char input);
char
AlarmDisable(char input);

char
OperateJalousieClose (char input);
char
OperateJalousie0Open (char input);
char
OperateJalousie1Open (char input);
char
OperateJalousieOpen(char jalousie);
char
OperateJalousieManuallyFunc (char input);

#define AUTO    3

// Macro definitions
//mtA - 
// sbi and cbi are not longer supported by the avr-libc
// to avoid version-conflicts the macro-names have been 
// changed to sbiBF/cbiBF "everywhere"
#define sbiBF(port,bit)  (port |= (1<<bit))   //set bit in port
#define cbiBF(port,bit)  (port &= ~(1<<bit))  //clear bit in port
//mtE

// Menu state machine states
#define ST_AVRBF                        10
#define ST_AVRBF_REV                    11
#define ST_TIME_CLOCK_ADJUST            23
#define ST_TIME_CLOCK_ADJUST_FUNC       24
#define ST_MOTOR						40
#define ST_MOTOR_OPERATE				41
#define ST_MOTOR_OPERATE_MANUALLY_FUNC				42
#define ST_MOTOR_OPERATE_DOWN  			43
#define ST_MOTOR_OPERATE_BREAK 			44
#define ST_MOTOR_OPERATE_UP_FUNC		45
#define ST_MOTOR_OPERATE_DOWN_FUNC 		46
#define ST_MOTOR_OPERATE_BREAK_FUNC 	47
#define ST_MOTOR_JALOUSIE0_OPEN		    48
#define ST_MOTOR_JALOUSIE0_OPEN_FUNC	    49
#define ST_MOTOR_JALOUSIE_CLOSE		    50
#define ST_MOTOR_JALOUSIE_CLOSE_FUNC    51
#define ST_MOTOR_INVERT_JALOUSIE		52
#define ST_MOTOR_INVERT_JALOUSIE_FUNC   53
#define ST_MOTOR_JALOUSIE1_OPEN		    54
#define ST_MOTOR_JALOUSIE1_OPEN_FUNC	    55
#define ST_ALARM						60
#define ST_ALARM_SET				63
#define ST_ALARM_SET_FUNC			64
#define ST_ALARM_GET				65
#define ST_ALARM_GET_FUNC			66
#define ST_ALARM_DISABLE                        67
#define ST_ALARM_DISABLE_FUNC                   68

