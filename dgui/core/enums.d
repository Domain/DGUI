module dgui.core.enums;

public import dgui.core.winapi;

enum ClassStyles: uint
{
	NONE 			= 0x00000000,
	VREDRAW			= 0x00000001,
	HREDRAW			= 0x00000002,
	KEYCVTWINDOW	= 0x00000004,
	DBLCLKS			= 0x00000008,
	OWNDC			= 0x00000020,
	CLASSDC			= 0x00000040,
	PARENTDC		= 0x00000080,
	NOKEYCVT		= 0x00000100,
	NOCLOSE			= 0x00000200,
	SAVEBITS		= 0x00000800,
	BYTEALIGNCLIENT	= 0x00001000,
	BYTEALIGNWINDOW	= 0x00002000,
	GLOBALCLASS		= 0x00004000,
	IME				= 0x00010000,
}

enum PositionSpecified
{
	NONE     = 0,
	X        = 1,
	Y        = 2,
	WIDTH    = 4,
	HEIGHT   = 8,
	POSITION = X | Y,
	SIZE     = WIDTH | HEIGHT,
	ALL      = POSITION | SIZE,
}

enum ControlStyle: ubyte
{
	NONE       = 0,
	NO_ERASE   = 1,
	USER_PAINT = 2,
	DOCKING    = 4,
}

enum BorderStyle: ubyte
{
	MANUAL = 0, //Usato internamente
	NONE = 1,
	FIXED_SINGLE = 2,
	FIXED_3D = 4,
}

enum FormBorderStyle: ubyte
{
	MANUAL = 0, //Usato internamente
	NONE = 1,
	FIXED_SINGLE = 2,
	FIXED_3D = 4,
	FIXED_DIALOG = 8,
	SIZEABLE = 16,
	FIXED_TOOLWINDOW = 32,
	SIZEABLE_TOOLWINDOW = 64,
}

enum FormStartPosition: ubyte
{
	MANUAL = 0,
	CENTER_PARENT = 1,
	CENTER_SCREEN = 2,
	DEFAULT_LOCATION = 4,
}

enum DialogResult: int
{
	NONE,
	OK = IDOK,
	YES = IDYES,
	NO = IDNO,
	CANCEL = IDCANCEL,
	RETRY = IDRETRY,
	ABORT = IDABORT,
	IGNORE = IDIGNORE,
	CLOSE = CANCEL, //Uguale a 'CANCEL'
}

enum DockStyle: ubyte
{
	NONE 	= 0,
	LEFT 	= 1,
	TOP 	= 2,
	RIGHT 	= 4,
	BOTTOM 	= 8,
	FILL 	= 16,
}

enum ItemDrawMode: ubyte
{
	NORMAL = 0,
	OWNER_DRAW_FIXED = 1,
	OWNER_DRAW_VARIABLE = 2,
}

enum MouseKeys: uint
{
	NONE   = 0, // No mouse buttons specified.

	// Standard mouse keys
	LEFT   = MK_LBUTTON,
	RIGHT  = MK_RBUTTON,
	MIDDLE = MK_MBUTTON,

	// Windows 2000+
	//XBUTTON1 = 0x0800000,
	//XBUTTON2 = 0x1000000,
}

enum MouseWheel: ubyte
{
	UP,
	DOWN,
}

enum ScrollMode: uint
{
	BOTTOM 		  = SB_BOTTOM,
	ENDSCROLL 	  = SB_ENDSCROLL,
	LINEDOWN  	  = SB_LINEDOWN,
	LINEUP 		  = SB_LINEUP,
	PAGEDOWN	  = SB_PAGEDOWN,
	PAGEUP 		  = SB_PAGEUP,
	THUMBPOSITION = SB_THUMBPOSITION,
	THUMBTRACK 	  = SB_THUMBTRACK,
	TOP 		  = SB_TOP,
	LEFT  		  = SB_LEFT,
	RIGHT 		  = SB_RIGHT,
	LINELEFT      = SB_LINELEFT,
	LINERIGHT 	  = SB_LINERIGHT,
	PAGELEFT 	  = SB_PAGELEFT,
	PAGERIGHT 	  = SB_PAGERIGHT,
}

enum ScrollDir: ubyte
{
	VERTICAL,
	HORIZONTAL,
}

enum Keys: uint // docmain
{
	NONE =     0, /// No keys specified.

	///
	SHIFT =    0x10000, /// Modifier keys.
	CONTROL =  0x20000,
	ALT =      0x40000,

	A = 'A', /// Letters.
	B = 'B',
	C = 'C',
	D = 'D',
	E = 'E',
	F = 'F',
	G = 'G',
	H = 'H',
	I = 'I',
	J = 'J',
	K = 'K',
	L = 'L',
	M = 'M',
	N = 'N',
	O = 'O',
	P = 'P',
	Q = 'Q',
	R = 'R',
	S = 'S',
	T = 'T',
	U = 'U',
	V = 'V',
	W = 'W',
	X = 'X',
	Y = 'Y',
	Z = 'Z',

	D0 = '0', /// Digits.
	D1 = '1',
	D2 = '2',
	D3 = '3',
	D4 = '4',
	D5 = '5',
	D6 = '6',
	D7 = '7',
	D8 = '8',
	D9 = '9',

	F1 = 112, /// F - function keys.
	F2 = 113,
	F3 = 114,
	F4 = 115,
	F5 = 116,
	F6 = 117,
	F7 = 118,
	F8 = 119,
	F9 = 120,
	F10 = 121,
	F11 = 122,
	F12 = 123,
	F13 = 124,
	F14 = 125,
	F15 = 126,
	F16 = 127,
	F17 = 128,
	F18 = 129,
	F19 = 130,
	F20 = 131,
	F21 = 132,
	F22 = 133,
	F23 = 134,
	F24 = 135,

	NUM_PAD0 = 96, /// Numbers on keypad.
	NUM_PAD1 = 97,
	NUM_PAD2 = 98,
	NUM_PAD3 = 99,
	NUM_PAD4 = 100,
	NUM_PAD5 = 101,
	NUM_PAD6 = 102,
	NUM_PAD7 = 103,
	NUM_PAD8 = 104,
	NUM_PAD9 = 105,

	ADD = 107, ///
	APPS = 93, /// Application.
	ATTN = 246, ///
	BACK = 8, /// Backspace.
	CANCEL = 3, ///
	CAPITAL = 20, ///
	CAPS_LOCK = 20,
	CLEAR = 12, ///
	CONTROL_KEY = 17, ///
	CRSEL = 247, ///
	DECIMAL = 110, ///
	DEL = 46, ///
	DELETE = DEL, ///
	PERIOD = 190, ///
	DOT = PERIOD,
	DIVIDE = 111, ///
	DOWN = 40, /// Down arrow.
	END = 35, ///
	ENTER = 13, ///
	ERASE_EOF = 249, ///
	ESCAPE = 27, ///
	EXECUTE = 43, ///
	EXSEL = 248, ///
	FINAL_MODE = 4, /// IME final mode.
	HANGUL_MODE = 21, /// IME Hangul mode.
	HANGUEL_MODE = 21,
	HANJA_MODE = 25, /// IME Hanja mode.
	HELP = 47, ///
	HOME = 36, ///
	IME_ACCEPT = 30, ///
	IME_CONVERT = 28, ///
	IME_MODE_CHANGE = 31, ///
	IME_NONCONVERT = 29, ///
	INSERT = 45, ///
	JUNJA_MODE = 23, ///
	KANA_MODE = 21, ///
	KANJI_MODE = 25, ///
	LEFT_CONTROL = 162, /// Left Ctrl.
	LEFT = 37, /// Left arrow.
	LINE_FEED = 10, ///
	LEFT_MENU = 164, /// Left Alt.
	LEFT_SHIFT = 160, ///
	LEFT_WIN = 91, /// Left Windows logo.
	MENU = 18, /// Alt.
	MULTIPLY = 106, ///
	NEXT = 34, /// Page down.
	NO_NAME = 252, // Reserved for future use.
	NUM_LOCK = 144, ///
	OEM8 = 223, // OEM specific.
	OEM_CLEAR = 254,
	PA1 = 253,
	PAGE_DOWN = 34, ///
	PAGE_UP = 33, ///
	PAUSE = 19, ///
	PLAY = 250, ///
	PRINT = 42, ///
	PRINT_SCREEN = 44, ///
	PROCESS_KEY = 229, ///
	RIGHT_CONTROL = 163, /// Right Ctrl.
	RETURN = 13, ///
	RIGHT = 39, /// Right arrow.
	RIGHT_MENU = 165, /// Right Alt.
	RIGHT_SHIFT = 161, ///
	RIGHT_WIN = 92, /// Right Windows logo.
	SCROLL = 145, /// Scroll lock.
	SELECT = 41, ///
	SEPARATOR = 108, ///
	SHIFT_KEY = 16, ///
	SNAPSHOT = 44, /// Print screen.
	SPACE = 32, ///
	SPACEBAR = SPACE, // Extra.
	SUBTRACT = 109, ///
	TAB = 9, ///
	UP = 38, /// Up arrow.
	ZOOM = 251, ///

	// Windows 2000+
	BROWSER_BACK = 166, ///
	BROWSER_FAVORITES = 171,
	BROWSER_FORWARD = 167,
	BROWSER_HOME = 172,
	BROWSER_REFRESH = 168,
	BROWSER_SEARCH = 170,
	BROWSER_STOP = 169,
	LAUNCH_APPLICATION1 = 182, ///
	LAUNCH_APPLICATION2 = 183,
	LAUNCH_MAIL = 180,
	MEDIA_NEXT_TRACK = 176, ///
	MEDIA_PLAY_PAUSE = 179,
	MEDIA_PREVIOUS_TRACK = 177,
	MEDIA_STOP = 178,
	OEM_BACKSLASH = 226, // OEM angle bracket or backslash.
	OEM_CLOSE_BRACKETS = 221,
	OEM_COMMA = 188,
	OEM_MINUS = 189,
	OEM_OPEN_BRACKETS = 219,
	OEM_PERIOD = 190,
	OEM_PIPE = 220,
	OEM_PLUS = 187,
	OEM_QUESTION = 191,
	OEM_QUOTES = 222,
	OEM_SEMICOLON = 186,
	OEM_TILDE = 192,
	SELECT_MEDIA = 181, ///
	VOLUME_DOWN = 174, ///
	VOLUME_MUTE = 173,
	VOLUME_UP = 175,

	/// Bit mask to extract key code from key value.
	KEY_CODE = 0xFFFF,

	/// Bit mask to extract modifiers from key value.
	MODIFIERS = 0xFFFF0000,
}

enum DrawItemState: uint
{
	DEFAULT = ODS_DEFAULT,
	CHECKED = ODS_CHECKED,
	DISABLED = ODS_DISABLED,
	FOCUSED = ODS_FOCUS,
	GRAYED = ODS_GRAYED,
	SELECTED = ODS_SELECTED,
}
