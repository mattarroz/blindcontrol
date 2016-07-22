// menu.h

// mt __flash typedef struct
typedef struct PROGMEM
{
    unsigned char state;
    unsigned char input;
    unsigned char nextstate;
} MENU_NEXTSTATE;


// mt __flash typedef struct
typedef struct PROGMEM
{
    unsigned char state;
    // char __flash *pText;
    PGM_P pText;
    char (*pFunc)(char input);
} MENU_STATE;


// Menu text
// mtA, these where all of the same structure as in the follow. line
const char MT_TIME_CLOCK_ADJUST[] PROGMEM         = "Adjust Clock";
const char MT_MOTOR[] PROGMEM					  = "Motor";
const char MT_MOTOR_JALOUSIE_CLOSE[] PROGMEM	  = "Close Jalousie";
const char MT_MOTOR_JALOUSIE0_OPEN[] PROGMEM	      = "Open Jalousie 0";
const char MT_MOTOR_JALOUSIE1_OPEN[] PROGMEM	      = "Open Jalousie 1";
const char MT_MOTOR_OPERATE[] PROGMEM			  = "Operate Manually";
const char MT_ALARM[] PROGMEM					  = "Alarm";
const char MT_ALARM_SET[] PROGMEM			  = "Set Alarm";
const char MT_ALARM_GET[] PROGMEM			  = "Get Alarm";
const char MT_ALARM_DISABLE[] PROGMEM			  = "Disable Alarm";
// mt - never used: const char MT_OPTIONS_DISPLAY_SEG[] PROGMEM       = "Browse segments";
// mtE

// mt MENU_NEXTSTATE menu_nextstate[] = { 
const MENU_NEXTSTATE menu_nextstate[] PROGMEM = {
//  STATE                       INPUT       NEXT STATE

    {ST_TIME_CLOCK_ADJUST,      KEY_PLUS,   ST_MOTOR}, 
    {ST_TIME_CLOCK_ADJUST,      KEY_ENTER,  ST_TIME_CLOCK_ADJUST_FUNC},
    {ST_TIME_CLOCK_ADJUST,      KEY_PREV,   ST_TIME_CLOCK_ADJUST},    
    {ST_TIME_CLOCK_ADJUST,      KEY_MINUS,  ST_ALARM}, 


    {ST_ALARM,                   KEY_PLUS,   ST_TIME_CLOCK_ADJUST},
    {ST_ALARM,                   KEY_NEXT,   ST_ALARM_SET},
    {ST_ALARM,                   KEY_PREV,   ST_ALARM},
    {ST_ALARM,                   KEY_MINUS,  ST_MOTOR},

    {ST_ALARM_SET,                   KEY_PLUS,   ST_ALARM_GET},
    {ST_ALARM_SET,                   KEY_NEXT,   ST_ALARM_SET_FUNC},
    {ST_ALARM_SET,                   KEY_PREV,   ST_ALARM},
    {ST_ALARM_SET,                   KEY_MINUS,  ST_ALARM_GET},

    {ST_ALARM_GET,                   KEY_PLUS,   ST_ALARM_SET},
    {ST_ALARM_GET,                   KEY_NEXT,   ST_ALARM_GET_FUNC},
    {ST_ALARM_GET,                   KEY_PREV,   ST_ALARM},
    {ST_ALARM_GET,                   KEY_MINUS,  ST_ALARM_DISABLE},

    {ST_ALARM_DISABLE,                   KEY_PLUS,   ST_ALARM_GET},
    {ST_ALARM_DISABLE,                   KEY_NEXT,   ST_ALARM_DISABLE_FUNC},
    {ST_ALARM_DISABLE,                   KEY_PREV,   ST_ALARM},
    {ST_ALARM_DISABLE,                   KEY_MINUS,  ST_ALARM_SET},

	{ST_MOTOR,					KEY_PLUS,	ST_ALARM},
	{ST_MOTOR,                  KEY_NEXT,   ST_MOTOR_OPERATE},
	{ST_MOTOR,                  KEY_PREV,   ST_MOTOR},
	{ST_MOTOR,                  KEY_MINUS,   ST_TIME_CLOCK_ADJUST},

	{ST_MOTOR_JALOUSIE_CLOSE,	KEY_PLUS,	ST_MOTOR_OPERATE},
	{ST_MOTOR_JALOUSIE_CLOSE,   KEY_NEXT,   ST_MOTOR_JALOUSIE_CLOSE_FUNC},
	{ST_MOTOR_JALOUSIE_CLOSE,   KEY_PREV,   ST_MOTOR},
	{ST_MOTOR_JALOUSIE_CLOSE,   KEY_MINUS,   ST_MOTOR_JALOUSIE0_OPEN},

	{ST_MOTOR_JALOUSIE0_OPEN,   KEY_PLUS,	ST_MOTOR_JALOUSIE_CLOSE},
	{ST_MOTOR_JALOUSIE0_OPEN,   KEY_NEXT,   ST_MOTOR_JALOUSIE0_OPEN_FUNC},
	{ST_MOTOR_JALOUSIE0_OPEN,   KEY_PREV,   ST_MOTOR},
	{ST_MOTOR_JALOUSIE0_OPEN,   KEY_MINUS,   ST_MOTOR_JALOUSIE1_OPEN},

	{ST_MOTOR_JALOUSIE1_OPEN,   KEY_PLUS,	ST_MOTOR_JALOUSIE0_OPEN},
	{ST_MOTOR_JALOUSIE1_OPEN,   KEY_NEXT,   ST_MOTOR_JALOUSIE1_OPEN_FUNC},
	{ST_MOTOR_JALOUSIE1_OPEN,   KEY_PREV,   ST_MOTOR},
	{ST_MOTOR_JALOUSIE1_OPEN,   KEY_MINUS,   ST_MOTOR_OPERATE},

	{ST_MOTOR_OPERATE,			KEY_PLUS,	ST_MOTOR_JALOUSIE1_OPEN},
	{ST_MOTOR_OPERATE,          KEY_NEXT,   ST_MOTOR_OPERATE_MANUALLY_FUNC},
	{ST_MOTOR_OPERATE,          KEY_PREV,   ST_MOTOR},
	{ST_MOTOR_OPERATE,          KEY_MINUS,   ST_MOTOR_JALOUSIE_CLOSE},
    {0,                         0,          0}
};


// mt MENU_STATE menu_state[] = {
const MENU_STATE menu_state[] PROGMEM = {
//  STATE                               STATE TEXT                  STATE_FUNC
    {ST_TIME_CLOCK_ADJUST,              MT_TIME_CLOCK_ADJUST,       NULL},
    {ST_TIME_CLOCK_ADJUST_FUNC,         NULL,                       SetClock},
	{ST_ALARM,							MT_ALARM,					NULL},
	{ST_ALARM_GET,				MT_ALARM_GET,			NULL},
	{ST_ALARM_GET_FUNC,			NULL,						AlarmGet},
	{ST_ALARM_SET,				MT_ALARM_SET,			NULL},
	{ST_ALARM_SET_FUNC,			NULL,						AlarmSet},
	{ST_ALARM_DISABLE,				MT_ALARM_DISABLE,			NULL},
	{ST_ALARM_DISABLE_FUNC,			NULL,						AlarmDisable},
    {ST_MOTOR,							MT_MOTOR,					NULL},
	{ST_MOTOR_JALOUSIE_CLOSE,			MT_MOTOR_JALOUSIE_CLOSE,	NULL},
	{ST_MOTOR_JALOUSIE_CLOSE_FUNC,		NULL,				OperateJalousieClose},
	{ST_MOTOR_JALOUSIE0_OPEN,			MT_MOTOR_JALOUSIE0_OPEN,	NULL},
	{ST_MOTOR_JALOUSIE0_OPEN_FUNC,		NULL,				OperateJalousie0Open},
	{ST_MOTOR_JALOUSIE1_OPEN,			MT_MOTOR_JALOUSIE1_OPEN,	NULL},
	{ST_MOTOR_JALOUSIE1_OPEN_FUNC,		NULL,				OperateJalousie1Open},
	{ST_MOTOR_OPERATE,					MT_MOTOR_OPERATE,			NULL},
	{ST_MOTOR_OPERATE_MANUALLY_FUNC,					NULL,			OperateJalousieManuallyFunc},
    {0,                                 NULL,                       NULL},
};
