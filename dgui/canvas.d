module dgui.canvas;

public import std.string;
public import std.utf;
public import std.gc;

public import dgui.core.winapi;
public import dgui.core.exception;
public import dgui.core.gdiplus;
public import dgui.core.handle;
public import dgui.core.utils;

debug
{
	public import std.stdio;
}

alias string EncoderFormat;

struct EncoderType
{
	public static EncoderFormat bmp()
	{
		return "{B96B3CAB-0728-11D3-9D7B-0000F81EF32E}";
	}

	public static EncoderFormat jpeg()
	{
		return "{B96B3CAE-0728-11D3-9D7B-0000F81EF32E}";
	}

	public static EncoderFormat gif()
	{
		return "{B96B3CB0-0728-11D3-9D7B-0000F81EF32E}";
	}

	public static EncoderFormat tiff()
	{
		return "{B96B3CB1-0728-11D3-9D7B-0000F81EF32E}";
	}

	public static EncoderFormat png()
	{
		return "{B96B3CAF-0728-11D3-9D7B-0000F81EF32E}";
	}
}

public ARGB makeARGB(ubyte a, ubyte r, ubyte g, ubyte b)
{
	return ((cast(ARGB)(b) << BLUE_SHIFT) | (cast(ARGB)(g) << GREEN_SHIFT) | (cast(ARGB)(r) << RED_SHIFT) | (cast(ARGB)(a) << ALPHA_SHIFT));
}

public COLORREF ARGBtoCOLORREF(ARGB argb)
{
	ubyte r = cast(ubyte)(argb >> RED_SHIFT);
	ubyte g = cast(ubyte)(argb >> GREEN_SHIFT);
	ubyte b = cast(ubyte)(argb >> BLUE_SHIFT);

	return RGB(r, g, b);
}

public ARGB COLORREFtoARGB(COLORREF cref)
{
	return makeARGB(0xFF, GetRValue(cref), GetGValue(cref), GetBValue(cref));
}

alias ARGB Color;

enum Colors: Color
{
	ALICE_BLUE              = 0xFFF0F8FF,
	ANTIQUE_WHITE           = 0xFFFAEBD7,
	AQUA                    = 0xFF00FFFF,
	AQUAMARINE              = 0xFF7FFFD4,
	AZURE                   = 0xFFF0FFFF,
	BEIGE                   = 0xFFF5F5DC,
	BISQUE                  = 0xFFFFE4C4,
	BLACK                   = 0xFF000000,
	BLANCHED_ALMOND         = 0xFFFFEBCD,
	BLUE                    = 0xFF0000FF,
	BLUE_VIOLET             = 0xFF8A2BE2,
	BROWN                   = 0xFFA52A2A,
	BURLY_WOOD              = 0xFFDEB887,
	CADET_BLUE              = 0xFF5F9EA0,
	CHART_REUSE             = 0xFF7FFF00,
    CHOCOLATE               = 0xFFD2691E,
    CORAL                   = 0xFFFF7F50,
    CORN_FLOWER_BLUE        = 0xFF6495ED,
    CORNSILK                = 0xFFFFF8DC,
    CRIMSON                 = 0xFFDC143C,
    CYAN                    = 0xFF00FFFF,
    DARK_BLUE               = 0xFF00008B,
    DARK_CYAN               = 0xFF008B8B,
    DARK_GOLDENROD          = 0xFFB8860B,
    DARK_GRAY               = 0xFFA9A9A9,
    DARK_GREEN              = 0xFF006400,
    DARK_KHAKI              = 0xFFBDB76B,
    DARK_MAGENTA            = 0xFF8B008B,
    DARK_OLIVE_GREEN        = 0xFF556B2F,
	DARK_ORANGE             = 0xFFFF8C00,
	DARK_ORCHID             = 0xFF9932CC,
	DARK_RED                = 0xFF8B0000,
	DARK_SALMON             = 0xFFE9967A,
	DARK_SEA_GREEN          = 0xFF8FBC8B,
	DARK_SLATE_BLUE         = 0xFF483D8B,
	DARK_SLATE_GRAY         = 0xFF2F4F4F,
	DARK_TURQUOISE          = 0xFF00CED1,
	DARK_VIOLET             = 0xFF9400D3,
	DEEP_PINK               = 0xFFFF1493,
	DEEP_SKY_BLUE           = 0xFF00BFFF,
	DIM_GRAY                = 0xFF696969,
	DODGER_BLUE             = 0xFF1E90FF,
	FIRE_BRICK              = 0xFFB22222,
    FLORAL_WHITE            = 0xFFFFFAF0,
	FOREST_GREEN            = 0xFF228B22,
    FUCHSIA                 = 0xFFFF00FF,
	GAINSBORO               = 0xFFDCDCDC,
	GHOST_WHITE             = 0xFFF8F8FF,
    GOLD                    = 0xFFFFD700,
	GOLDEN_ROD              = 0xFFDAA520,
	GRAY                    = 0xFF808080,
	GREEN                   = 0xFF008000,
	GREEN_YELLOW            = 0xFFADFF2F,
	HONEY_DEW               = 0xFFF0FFF0,
    HOT_PINK                = 0xFFFF69B4,
    INDIAN_RED              = 0xFFCD5C5C,
    INDIGO                  = 0xFF4B0082,
	INVALID					= 0x00000000,
	IVORY                   = 0xFFFFFFF0,
	KHAKI                   = 0xFFF0E68C,
    LAVENDER                = 0xFFE6E6FA,
    LAVENDER_BLUSH          = 0xFFFFF0F5,
    LAWN_GREEN              = 0xFF7CFC00,
    LEMON_CHIFFON           = 0xFFFFFACD,
    LIGHT_BLUE              = 0xFFADD8E6,
    LIGHT_CORAL             = 0xFFF08080,
    LIGHTCYAN               = 0xFFE0FFFF,
    LIGHT_GOLDEN_ROD_YELLOW = 0xFFFAFAD2,
    LIGHT_GRAY              = 0xFFD3D3D3,
    LIGHT_GREEN             = 0xFF90EE90,
    LIGHT_PINK              = 0xFFFFB6C1,
    LIGHT_SALMON            = 0xFFFFA07A,
    LIGHT_SEA_GREEN         = 0xFF20B2AA,
    LIGHT_SKY_BLUE          = 0xFF87CEFA,
	LIGHT_SLATE_GRAY        = 0xFF778899,
    LIGHT_STEEL_BLUE        = 0xFFB0C4DE,
    LIGHT_YELLOW            = 0xFFFFFFE0,
    LIME                    = 0xFF00FF00,
	LIME_GREEN              = 0xFF32CD32,
    LINEN                   = 0xFFFAF0E6,
    MAGENTA                 = 0xFFFF00FF,
    MAROON                  = 0xFF800000,
    MEDIUM_AQUAMARINE       = 0xFF66CDAA,
    MEDIUM_BLUE             = 0xFF0000CD,
    MEDIUM_ORCHID           = 0xFFBA55D3,
    MEDIUM_PURPLE           = 0xFF9370DB,
    MEDIUM_SEA_GREEN        = 0xFF3CB371,
    MEDIUM_SLATE_BLUE       = 0xFF7B68EE,
    MEDIUM_SPRING_GREEN     = 0xFF00FA9A,
    MEDIUM_TURQUOISE        = 0xFF48D1CC,
    MEDIUM_VIOLET_RED       = 0xFFC71585,
	MIDNIGHT_BLUE           = 0xFF191970,
	MINT_CREAM              = 0xFFF5FFFA,
    MISTY_ROSE              = 0xFFFFE4E1,
    MOCCASIN                = 0xFFFFE4B5,
    NAVAJO_WHITE            = 0xFFFFDEAD,
    NAVY                    = 0xFF000080,
    OLD_LACE                = 0xFFFDF5E6,
    OLIVE                   = 0xFF808000,
    OLIVE_DRAB              = 0xFF6B8E23,
    ORANGE                  = 0xFFFFA500,
    ORANGE_RED              = 0xFFFF4500,
    ORCHID                  = 0xFFDA70D6,
    PALE_GOLDENROD          = 0xFFEEE8AA,
    PALE_GREEN              = 0xFF98FB98,
    PALE_TURQUOISE          = 0xFFAFEEEE,
    PALE_VIOLET_RED         = 0xFFDB7093,
    PAPAYA_WHIP             = 0xFFFFEFD5,
    PEACH_PUFF              = 0xFFFFDAB9,
    PERU                    = 0xFFCD853F,
    PINK                    = 0xFFFFC0CB,
	PLUM                    = 0xFFDDA0DD,
	POWDER_BLUE             = 0xFFB0E0E6,
	PURPLE                  = 0xFF800080,
	RED                     = 0xFFFF0000,
	ROSY_BROWN              = 0xFFBC8F8F,
	ROYAL_BLUE              = 0xFF4169E1,
	SADDLEBROWN             = 0xFF8B4513,
	SALMON                  = 0xFFFA8072,
	SANDY_BROWN             = 0xFFF4A460,
	SEA_GREEN               = 0xFF2E8B57,
	SEA_SHELL               = 0xFFFFF5EE,
	SIENNA                  = 0xFFA0522D,
	SILVER                  = 0xFFC0C0C0,
	SKY_BLUE                = 0xFF87CEEB,
	SLATE_BLUE              = 0xFF6A5ACD,
	SLATE_GRAY              = 0xFF708090,
	SNOW                    = 0xFFFFFAFA,
	SPRING_GREEN            = 0xFF00FF7F,
	STEEL_BLUE              = 0xFF4682B4,
	TAN                     = 0xFFD2B48C,
	TEAL                    = 0xFF008080,
	THISTLE                 = 0xFFD8BFD8,
	TOMATO                  = 0xFFFF6347,
	TRANSPARENT             = 0x00FFFFFF,
	TURQUOISE               = 0xFF40E0D0,
	VIOLET                  = 0xFFEE82EE,
	WHEAT                   = 0xFFF5DEB3,
	WHITE                   = 0xFFFFFFFF,
	WHITE_SMOKE             = 0xFFF5F5F5,
	YELLOW                  = 0xFFFFFF00,
	YELLOW_GREEN            = 0xFF9ACD32,
}


enum PixelUnit: int
{
    WORLD,      // 0 -- World coordinate (non-physical unit)
    DISPLAY,    // 1 -- Variable -- for PageTransform only
    PIXEL,      // 2 -- Each unit is one device pixel.
    POINT,      // 3 -- Each unit is a printer's point, or 1/72 inch.
    INCH,       // 4 -- Each unit is 1 inch.
    DOCUMENT,   // 5 -- Each unit is 1/300 inch.
    MILLIMETER, // 6 -- Each unit is 1 millimeter.
}

enum PenStyle: int
{
    SOLID,          // 0
    DASH,           // 1
    DOT,            // 2
    DASH_DOT,       // 3
    DASH_DOT_DOT,   // 4
    CUSTOM,         // 5
}

enum HatchStyle
{
    HORIZONTAL,                    // 0
    VERTICAL,                      // 1
    FORWARD_DIAGONAL,              // 2
    BACKWARD_DIAGONAL,             // 3
    CROSS,                         // 4
    DIAGONAL_CROSS,                // 5
    PERCENT_05,                    // 6
    PERCENT_10,                    // 7
    PERCENT_20,                    // 8
    PERCENT_25,                    // 9
    PERCENT_30,                    // 10
    PERCENT_40,                    // 11
    PERCENT_50,                    // 12
    PERCENT_60,                    // 13
    PERCENT_70,                    // 14
    PERCENT_75,                    // 15
    PERCENT_80,                    // 16
    PERCENT_90,                    // 17
    LIGHT_DOWNWARD_DIAGONAL,       // 18
    LIGHT_UPWARD_DIAGONAL,         // 19
    DARK_DOWNWARD_DIAGONAL,        // 20
    DARK_UPWARD_DIAGONAL,          // 21
    WIDE_DOWNWARD_DIAGONAL,        // 22
    WIDE_UPWARD_DIAGONAL,          // 23
    LIGHT_VERTICAL,                // 24
    LIGHT_HORIZONTAL,              // 25
    NARROW_VERTICAL,               // 26
    NARROW_HORIZONTAL,             // 27
    DARK_VERTICAL,                 // 28
    DARK_HORIZONTAL,               // 29
    DASHED_DOWNWARD_DIAGONAL,      // 30
    DASHED_UPWARD_DIAGONAL,        // 31
    DASHED_HORIZONTAL,             // 32
    DASHED_VERTICAL,               // 33
    SMALL_CONFETTI,                // 34
    LARGE_CONFETTI,                // 35
    ZIGZAG,                        // 36
    WAVE,                          // 37
    DIAGONAL_BRICK,                // 38
    HORIZONTAL_BRICK,              // 39
    WEAVE,                         // 40
    PLAID,                         // 41
    DIVOT,                         // 42
    DOTTED_GRID,                   // 43
    DOTTED_DIAMOND,                // 44
    SHINGLE,                       // 45
    TRELLIS,                       // 46
    SPHERE,                        // 47
    SMALL_GRID,                    // 48
    SMALL_CHECKER_BOARD,           // 49
    LARGE_CHECKER_BOARD,           // 50
    OUTLINED_DIAMOND,              // 51
    SOLID_DIAMOND,                 // 52
}

enum StringFormatFlags
{
	NONE 						   = 0x00000000,
    DIRECTION_RIGHT_TO_LEFT        = 0x00000001,
    DIRECTION_VERTICAL             = 0x00000002,
    NO_FIT_BLACK_BOX               = 0x00000004,
    DISPLAY_FORMAT_CONTROL         = 0x00000020,
    NO_FONT_FALLBACK               = 0x00000400,
    MEASURE_TRAILING_SPACES        = 0x00000800,
    NO_WRAP                        = 0x00001000,
    LINE_LIMIT                     = 0x00002000,
    NO_CLIP                        = 0x00004000,
}

enum StringAlignment: int
{
    NEAR   = 0,
    CENTER = 1,
    FAR    = 2,
}

enum StringTrimming: int
{
    NONE               = 0,
    CHARACTER          = 1,
    WORD               = 2,
    ELLIPSIS_CHARACTER = 3,
    ELLIPSIS_WORD      = 4,
    ELLIPSIS_PATH      = 5,
}

enum FontStyle
{
    REGULAR     = 0,
    BOLD        = 1,
    ITALIC      = 2,
    BOLD_ITALIC = 3,
    UNDERLINE   = 4,
    STRIKEOUT   = 8,
}

enum BorderType: uint
{
	RAISED_OUTER = BDR_RAISEDOUTER,
	RAISED_INNER = BDR_RAISEDINNER,

	SUNKEN_OUTER = BDR_SUNKENOUTER,
	SUNKEN_INNER = BDR_SUNKENINNER,

	BUMP = EDGE_BUMP,
	ETCHED = EDGE_ETCHED,
	EDGE_RAISED = EDGE_RAISED,
	SUNKEN = EDGE_SUNKEN,
}

enum BorderMode: uint
{
	ADJUST = BF_ADJUST,
	DIAGONAL = BF_DIAGONAL,
	FLAT = BF_FLAT,
	LEFT = BF_LEFT,
	TOP = BF_TOP,
	RIGHT = BF_RIGHT,
	BOTTOM = BF_BOTTOM,
	MIDDLE = BF_MIDDLE,
	MONO = BF_MONO,
	RECT = BF_RECT,
	SOFT = BF_SOFT,
}

enum: ubyte
{
	ALPHA_SHIFT = 24,
	RED_SHIFT   = 16,
	GREEN_SHIFT = 8,
	BLUE_SHIFT  = 0,
}

enum
{
	ALPHA_MASK = 0xFF000000,
	RED_MASK   = 0x00FF0000,
	GREEN_MASK = 0x0000FF00,
	BLUE_MASK  = 0x000000FF,
}

final class SystemColors
{
	public static Color color3DdarkShadow()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_3DDKSHADOW));
	}

	public static Color color3Dface()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_3DFACE));
	}

	public static Color colorBtnFace()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_BTNFACE));
	}

	public static Color color3DLight()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_3DLIGHT));
	}

	public static Color color3DShadow()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_3DSHADOW));
	}

	public static Color colorActiveBorder()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_ACTIVEBORDER));
	}

	public static Color colorActiveCaption()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_3DLIGHT));
	}

	public static Color colorAppWorkspace()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_APPWORKSPACE));
	}

	public static Color colorBackground()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_BACKGROUND));
	}

	public static Color colorBtnText()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_BTNTEXT));
	}

	public static Color colorCaptionText()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_CAPTIONTEXT));
	}

	public static Color colorGrayText()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_GRAYTEXT));
	}

	public static Color colorHighLight()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_HIGHLIGHT));
	}

	public static Color colorHighLightText()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_HIGHLIGHTTEXT));
	}

	public static Color colorInactiveBorder()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_INACTIVEBORDER));
	}

	public static Color colorInactiveCaption()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_INACTIVECAPTION));
	}

	public static Color colorInactiveCaptionText()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_INACTIVECAPTIONTEXT));
	}

	public static Color colorInfoBk()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_INFOBK));
	}

	public static Color colorInfoText()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_INFOTEXT));
	}

	public static Color colorMenu()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_MENU));
	}

	public static Color colorMenuText()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_MENUTEXT));
	}

	public static Color colorScrollBar()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_SCROLLBAR));
	}

	public static Color colorWindow()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_WINDOW));
	}

	public static Color colorWindowFrame()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_WINDOW));
	}

	public static Color colorWindowText()
	{
		return COLORREFtoARGB(GetSysColor(COLOR_WINDOWTEXT));
	}
}

final class SystemFonts
{
	public static Font windowsFont()
	{
		static Font f;

		if(!f)
		{
			NONCLIENTMETRICSA ncm = void; //La inizializza sotto.
			ncm.cbSize = NONCLIENTMETRICSA.sizeof;

			if(SystemParametersInfoA(SPI_GETNONCLIENTMETRICS, NONCLIENTMETRICSA.sizeof, &ncm, 0))
			{
				f = Font.fromLOGFONT(&ncm.lfMessageFont);
			}
			else
			{
				f = SystemFonts.ansiVarFont;
			}
		}

		return f;
	}

	public static Font ansiFixedFont()
	{
		static Font f;

		if(!f)
		{
			f = Font.fromHFONT(GetStockObject(ANSI_FIXED_FONT));
		}

		return f;
	}

	public static Font ansiVarFont()
	{
		static Font f;

		if(!f)
		{
			f = Font.fromHFONT(GetStockObject(ANSI_VAR_FONT));
		}

		return f;
	}

	public static Font deviceDefaultFont()
	{
		static Font f;

		if(!f)
		{
			f = Font.fromHFONT(GetStockObject(DEVICE_DEFAULT_FONT));
		}

		return f;
	}

	public static Font oemFixedFont()
	{
		static Font f;

		if(!f)
		{
			f = Font.fromHFONT(GetStockObject(OEM_FIXED_FONT));
		}

		return f;
	}

	public static Font systemFont()
	{
		static Font f;

		if(!f)
		{
			f = Font.fromHFONT(GetStockObject(SYSTEM_FONT));
		}

		return f;
	}

	public static Font systemFixedFont()
	{
		static Font f;

		if(!f)
		{
			f = Font.fromHFONT(GetStockObject(SYSTEM_FIXED_FONT));
		}

		return f;
	}
}

final class SystemCursors
{
	public static Cursor appStarting()
	{
		static Cursor c;

		if(!c)
		{
			 c = Cursor.fromHCURSOR(LoadImageA(null, IDC_APPSTARTING, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	public static Cursor arrow()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(LoadImageA(null, IDC_ARROW, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	public static Cursor cross()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(LoadImageA(null, IDC_CROSS, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	public static Cursor ibeam()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(LoadImageA(null, IDC_IBEAM, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	public static Cursor icon()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(LoadImageA(null, IDC_ICON, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	public static Cursor no()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(LoadImageA(null, IDC_NO, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	public static Cursor sizeALL()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(LoadImageA(null, IDC_SIZEALL, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	public static Cursor sizeNESW()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(LoadImageA(null, IDC_SIZENESW, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	public static Cursor sizeNS()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(LoadImageA(null, IDC_SIZENS, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	public static Cursor sizeNWSE()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(LoadImageA(null, IDC_SIZENWSE, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	public static Cursor sizeWE()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(LoadImageA(null, IDC_SIZEWE, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	public static Cursor upArrow()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(LoadImageA(null, IDC_UPARROW, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	public static Cursor wait()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(LoadImageA(null, IDC_WAIT, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}
}

abstract class GraphicObject: IDisposable
{
	protected GpObject _native;

	public ~this()
	{
		if(this._native)
		{
			this.dispose();
			this._native = null;
		}
	}

	new(size_t sz)
	{
		void* ptr = GdipAlloc(sz);

		if(!ptr)
		{
			debug
			{
				throw new GdiException("Cannot allocate GDI+ Object", __FILE__, __LINE__);
			}
			else
			{
				throw new GdiException("Cannot allocate GDI+ Object");
			}
		}

		addRoot(ptr);
		return ptr;
	}

	delete(void* p)
	{
		removeRoot(p);
		GdipFree(p);
	}

	protected static void checkException(Status s)
	{
		if(!s)
		{
			return;
		}

		switch(s)
		{
			case Status.GENERIC_ERROR:
			{
				debug
				{
					throw new GdiException("GDI+ Generic Error", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("GDI+ Generic Error");
				}
			}

			case Status.INVALID_PARAMETER:
			{
				debug
				{
					throw new GdiException("GDI+ Invalid Parameter", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("GDI+ Invalid Parameter");
				}
			}

			case Status.OUT_OF_MEMORY:
			{
				debug
				{
					throw new GdiException("GDI+ Out Of Memory", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("GDI+ Out Of Memory");
				}
			}

			case Status.OBJECT_BUSY:
			{
				debug
				{
					throw new GdiException("GDI+ Object Busy", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("GDI+ Object Busy");
				}
			}

			case Status.INSUFFICIENT_BUFFER:
			{
				debug
				{
					throw new GdiException("GDI+ Insufficient Buffer", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("GDI+ Insufficient Buffer");
				}
			}

			case Status.NOT_IMPLEMENTED:
			{
				debug
				{
					throw new GdiException("GDI+ Not Implemented", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("GDI+ Not Implemented");
				}
			}

			case Status.WIN32_ERROR:
			{
				debug
				{
					throw new GdiException("GDI+ Win32 Error", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("GDI+ Win32 Error");
				}
			}

			case Status.WRONG_STATE:
			{
				debug
				{
					throw new GdiException("GDI+ Wrong State", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("GDI+ Wrong State");
				}
			}

			case Status.ABORTED:
			{
				debug
				{
					throw new GdiException("GDI+ Aborted", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("GDI+ Aborted");
				}
			}

			case Status.FILE_NOT_FOUND:
			{
				debug
				{
					throw new GdiException("GDI+ File Not Found", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("GDI+ File Not Found");
				}
			}

			case Status.VALUE_OVERFLOW:
			{
				debug
				{
					throw new GdiException("GDI+ Value Overflow", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("GDI+ Value Overflow");
				}
			}

			case Status.ACCESS_DENIED:
			{
				debug
				{
					throw new GdiException("GDI+ Access Denied", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("GDI+ Access Denied");
				}
			}

			case Status.UNKNOWN_IMAGE_FORMAT:
			{
				debug
				{
					throw new GdiException("GDI+ Unknown Image Format", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("GDI+ Unknown Image Format");
				}
			}

			case Status.FONT_FAMILY_NOT_FOUND:
			{
				debug
				{
					throw new GdiException("GDI+ Font Family Not Found", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("GDI+ Font Family Not Found");
				}
			}

			case Status.FONT_STYLE_NOT_FOUND:
			{
				debug
				{
					throw new GdiException("GDI+ Font Style Not Found", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("GDI+ Font Style Not Found");
				}
			}

			case Status.NOT_TRUETYPE_FONT:
			{
				debug
				{
					throw new GdiException("GDI+ Not TrueType Font", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("GDI+ Not TrueType Font");
				}
			}

			case Status.UNSUPPORTED_GDIPLUS_VERSION:
			{
				debug
				{
					throw new GdiException("GDI+ Unsupported Version", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("GDI+ Unsupported Version");
				}
			}

			case Status.GDI_PLUS_NOT_INITIALIZED:
			{
				debug
				{
					throw new GdiException("GDI+ Not Initialized", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("GDI+ Not Initialized");
				}
			}

			case Status.PROPERTY_NOT_FOUND:
			{
				debug
				{
					throw new GdiException("GDI+ Property Not Found", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("GDI+ Property Not Found");
				}
			}

			case Status.PROPERTY_NOT_SUPPORTED:
			{
				debug
				{
					throw new GdiException("GDI+ Property Not Supported", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("GDI+ Property Not Supported");
				}
			}

			default:
			{
				debug
				{
					throw new GdiException("GDI+ Unknown Error", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("GDI+ Unknown Error");
				}
			}
		}
	}

	public abstract void dispose();

	public final bool created()
	{
		return this._native !is null;
	}

	public final GpObject native()
	{
		return this._native;
	}
}

abstract class Brush: GraphicObject
{
	public void dispose()
	{
		checkException(GdipDeleteBrush(this._native));
	}
}

final class StringFormat: GraphicObject
{
	private static StringFormat _dsf;

	public this(StringFormatFlags sff = StringFormatFlags.NONE)
	{
		checkException(GdipCreateStringFormat(sff, LANG_NEUTRAL, &this._native));
	}

	public void dispose()
	{
		if(this !is _dsf)
		{
			checkException(GdipDeleteStringFormat(this._native));
		}
	}

	public void horizontalAlignment(StringAlignment sa)
	{
		checkException(GdipSetStringFormatAlign(this._native, sa));
	}

	public void verticalAlignment(StringAlignment sa)
	{
		checkException(GdipSetStringFormatLineAlign(this._native, sa));
	}

	public void trimming(StringTrimming st)
	{
		checkException(GdipSetStringFormatTrimming(this._native, cast(GpStringTrimming)st));
	}

	public static StringFormat genericDefault()
	{
		if(!this._dsf)
		{
			GpStringFormat nsf;
			checkException(GdipStringFormatGetGenericDefault(&nsf));

			this._dsf = new StringFormat();
			this._dsf._native = nsf;
		}

		return this._dsf;
	}
}

class SolidBrush: Brush
{
	public this(Color c)
	{
		checkException(GdipCreateSolidFill(c, &this._native));
	}
}

class HatchBrush: Brush
{
	public this(Color fc, Color bc, HatchStyle hs)
	{
		checkException(GdipCreateHatchBrush(cast(GpHatchStyle)hs, fc, bc, &this._native));
	}
}

class Image: GraphicObject
{
	public abstract HGDIOBJ handle();

	public void dispose()
	{
		checkException(GdipDisposeImage(this._native));
	}

	public final PixelFormat pixelFormat()
	{
		PixelFormat pf;

 		checkException(GdipGetImagePixelFormat(this._native, cast(GpPixelFormat*)&pf));
		return pf;
	}

	public final Rect bounds()
	{
		GpRectF rf = void;  //Inizializzato sotto
		GpUnit unit = void; //Inizializzato sotto

		checkException(GdipGetImageBounds(this._native, &rf, &unit));
		return convertRect(rf);
	}

	public final void save(string fileName, EncoderFormat ef)
	{
		CLSID fClsid;
		uint numEncoders, encoderSize;

		CLSIDFromString(toUTF16z(ef), &fClsid);
		GdipGetImageEncodersSize(&numEncoders, &encoderSize);
		ImageCodecInfo* ici = cast(ImageCodecInfo*)malloc(encoderSize);
		GdipGetImageEncoders(numEncoders, encoderSize, cast(GpImageCodecInfo)ici);

		for(int i = 0; i < numEncoders; i++)
		{
			if(compareGUID(&fClsid, &ici[i].FormatID))
			{
				checkException(GdipSaveImageToFile(this._native, toUTF16z(fileName), &ici[i].Clsid, null));
				return;
			}
		}

		debug
		{
			throw new GdiException("Encoder Not Found", __FILE__, __LINE__);
		}
		else
		{
			throw new GdiException("Encoder Not Found");
		}
	}

	public static Image fromFile(string fileName)
	{
		GpImage gImg;
		GpImageType gImgType;

		checkException(GdipLoadImageFromFile(toUTF16z(fileName), &gImg));
		checkException(GdipGetImageType(gImg, &gImgType));

		switch(gImgType)
		{
			case ImageType.BITMAP:
				return Bitmap.fromImage(gImg);

			case ImageType.METAFILE:
				assert(false, "Metafile Not Implemented");

			default:
			{
				debug
				{
					throw new GdiException("Unknown Image Type", __FILE__, __LINE__);
				}
				else
				{
					throw new GdiException("Unknown Image Type");
				}
			}
		}
	}
}

	class Bitmap: Image
{
	private HBITMAP _hBitmap;

	public this()
	{

	}

	public this(Size sz)
	{
		checkException(GdipCreateBitmapFromScan0(sz.width, sz.height, 0, PixelFormat.ARGB_32_BPP, null, &this._native));
	}

	public override void dispose()
	{
		if(this._hBitmap)
		{
			DeleteObject(this._hBitmap);
		}

		super.dispose();
	}

	public final HGDIOBJ handle()
	{
		if(!this._hBitmap)
		{
			checkException(GdipCreateHBITMAPFromBitmap(this._native, &this._hBitmap, Colors.TRANSPARENT));
		}

		return this._hBitmap;
	}

	public final BitmapData lockBits(ImageLockMode lockMode)
	{
		return this.lockBits(lockMode, this.pixelFormat);
	}

	public final BitmapData lockBits(ImageLockMode lockMode, PixelFormat pformat)
	{
		return this.lockBits(this.bounds, lockMode, pformat);
	}

	public final BitmapData lockBits(Rect r, ImageLockMode lockMode, PixelFormat pformat)
	{
		BitmapData bd = void; //Inizializzata sotto.
		checkException(GdipBitmapLockBits(this._native, &r.rect, lockMode, pformat, &bd));
		return bd;
	}

	public final void unlockBits(BitmapData bd)
	{
		checkException(GdipBitmapUnlockBits(this._native, &bd));
	}

	package static Bitmap fromImage(GpImage gImg)
	{
		Bitmap bmp = new Bitmap();
		bmp._native = gImg;
		return bmp;
	}

	public static Bitmap fromHBITMAP(HBITMAP hBmp)
	{
		GpBitmap gBmp;
		checkException(GdipCreateBitmapFromHBITMAP(hBmp, null, &gBmp));

		Bitmap bmp = new Bitmap();
		bmp._native = gBmp;

		return bmp;
	}
}

class Icon: Handle!(HICON), IDisposable
{
	public this()
	{

	}

	public ~this()
	{
		this.dispose();
	}

	public void dispose()
	{
		if(this._handle)
		{
			DestroyIcon(this._handle);
		}

		this._handle = null;
	}

	public static Icon fromFile(string fileName)
	{
		HICON hIcon = LoadImageA(getHInstance(), toStringz(fileName), IMAGE_ICON, 0, 0, LR_LOADFROMFILE | LR_DEFAULTSIZE);

		if(!hIcon)
		{
			debug
			{
				throw new GdiException("Cannot Load Icon from File", __FILE__, __LINE__);
			}
			else
			{
				throw new GdiException("Cannot Load Icon from File");
			}
		}

		return Icon.fromHICON(hIcon);
	}

	public static Icon fromHICON(HICON hIcon)
	{
		Icon ico = new Icon();
		ico._handle = hIcon;

		return ico;
	}
}

final class Cursor: IDisposable
{
	private HCURSOR _handle;
	private bool _owned;

	public ~this()
	{
		this.dispose();
	}

	public void dispose()
	{
		if(this._owned && this._handle)
		{
			DestroyCursor(this._handle);
			this._handle = null;
		}
	}

	public HCURSOR handle()
	{
		return this._handle;
	}

	public static Point location()
	{
		Point pt = void;

		GetCursorPos(&pt.point);
		return pt;
	}

	public static Cursor fromHCURSOR(HCURSOR hCursor, bool owned = true)
	{
		Cursor c = new Cursor();
		c._handle = hCursor;
		c._owned = owned;

		return c;
	}
}

final class Font: GraphicObject
{
	private GpFontFamily _ff;
	private HFONT _hFont;

	private this()
	{

	}

	public this(Font f, FontStyle fs)
	{
		float fsize;
		GpUnit unit;

		checkException(GdipGetFamily(f.native, &this._ff));
		checkException(GdipGetFontSize(f.native, &fsize));
		checkException(GdipGetFontUnit(f.native, &unit));
		checkException(GdipCreateFont(this._ff, fsize, cast(int)fs, unit, &this._native));
	}

	public this(string fontName, uint h, FontStyle fs = FontStyle.REGULAR, PixelUnit pu = PixelUnit.PIXEL)
	{
		checkException(GdipCreateFontFamilyFromName(toUTF16z(fontName), null, &this._ff));
		checkException(GdipCreateFont(this._ff, h, cast(int)fs, cast(GpUnit)pu, &this._native));
	}

	public void dispose()
	{
		this.destroyHFont();
		checkException(GdipDeleteFont(this._native));
		checkException(GdipDeleteFontFamily(this._ff));
	}

	package void destroyHFont()
	{
		if(this._hFont)
		{
			DeleteObject(this._hFont);
			this._hFont = null;
		}
	}

	private void getTextMetrics(TEXTMETRICA* tm)
	{
		HDC hdc = GetDC(null);
		HFONT hOldFont = SelectObject(hdc, this.handle);

		GetTextMetricsA(hdc, tm);
		SelectObject(hdc, hOldFont);
		this.destroyHFont();
		ReleaseDC(null, hdc);
	}

	public HFONT handle()
	{
		if(!this._hFont)
		{
			LOGFONTA lf = void;  //Inizializzato sotto.
			GpGraphics g = void; //Inizializzato sotto.

			HDC hdc = GetWindowDC(null);
			checkException(GdipCreateFromHDC(hdc, &g));
			checkException(GdipGetLogFontA(this._native, g, &lf));

			this._hFont = CreateFontIndirectA(&lf);
			ReleaseDC(null, hdc);
		}

		return this._hFont;
	}

	public Size size()
	{
		Size sz;
		TEXTMETRICA	tm;

		this.getTextMetrics(&tm);
		sz.height = tm.tmHeight + tm.tmExternalLeading;
		sz.width = tm.tmMaxCharWidth;
		return sz;
	}

	public string name()
	{
		wchar[LF_FACESIZE] name;

		GpFontFamily ff;
		GdipGetFamily(this._native, &ff);
		GdipGetFamilyName(ff, name.ptr, LANG_NEUTRAL);
		return recalcString(toUTF8(name));
	}

	package static Font fromLOGFONT(LOGFONTA* lf)
	{
		GpFont gFont;
		HDC hdc = GetWindowDC(null);
		checkException(GdipCreateFontFromLogfontA(hdc, lf, &gFont));

		Font f = new Font();
		f._native = gFont;

		ReleaseDC(null, hdc);
		return f;
	}

	public static Font fromHFONT(HFONT hFont)
	{
		LOGFONTA lf = void;

		if(GetObjectA(hFont, LOGFONTA.sizeof, &lf))
		{
            return Font.fromLOGFONT(&lf);
		}
		else
		{
			debug
			{
				throw new GdiException("Cannot Create Font (HFONT not valid)", __FILE__, __LINE__);
			}
			else
			{
				throw new GdiException("Cannot Create Font (HFONT not valid)");
			}
		}
	}
}

final class Pen: GraphicObject
{
	public this(Color c, uint w = 1, PenStyle ps = PenStyle.SOLID)
	{
		checkException(GdipCreatePen1(c, w, cast(GpUnit)PixelUnit.WORLD, &this._native));
		checkException(GdipSetPenDashStyle(this._native, cast(GpDashStyle)ps));
	}

	public final void dispose()
	{
		checkException(GdipDeletePen(this._native));
	}
}

final class Canvas: GraphicObject
{
	private HDC _nativeDC;

	private this()
	{

	}

	public void dispose()
	{
		if(this._nativeDC)
		{
			this.releaseDC();
		}

		checkException(GdipDeleteGraphics(this._native));
	}

	public Size measureText(string s, Font f)
	{
		static GpRectF r1 = NullRectF;
		GpRectF r2;

		checkException(GdipMeasureString(this._native, toUTF16z(s), s.length, f.native, &r1, null, &r2, null, null));
		Rect r3 = convertRect(r2);
		return r3.size;
	}

	public void drawArc(Pen p, int x, int y, int width, int height, float startAngle, float sweepAngle)
	{
		checkException(GdipDrawArcI(this._native, p.native, x, y, width, height, startAngle, sweepAngle));
	}

	public void drawArc(Pen p, Rect r, float startAngle, float sweepAngle)
	{
		this.drawArc(p, r.x, r.y, r.width, r.height, startAngle, sweepAngle);
	}

	public void drawBeizer(Pen p, Point p1, Point p2, Point p3, Point p4)
	{
		this.drawBeizer(p, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y);
	}

	public void drawBeizer(Pen p, int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4)
	{
		checkException(GdipDrawBezierI(this._native, p.native, x1, y1, x2, y2, x3, y3, x4, y4));
	}

	public void drawPie(Pen p, Rect r, float startAngle, float sweepAngle)
	{
		this.drawPie(p, r.x, r.y, r.width, r.height, startAngle, sweepAngle);
	}

	public void drawPie(Pen p, int x, int y, int width, int height, float startAngle, float sweepAngle)
	{
		checkException(GdipDrawPieI(this._native, p.native, x, y, width, height, startAngle, sweepAngle));
	}

	public void fillPie(Brush b, Rect r, float startAngle, float sweepAngle)
	{
		this.fillPie(b, r.x, r.y, r.width, r.height, startAngle, sweepAngle);
	}

	public void fillPie(Brush b, int x, int y, int width, int height, float startAngle, float sweepAngle)
	{
		checkException(GdipFillPieI(this._native, b.native, x, y, width, height, startAngle, sweepAngle));
	}

	public void drawImage(Image img, int x, int y)
	{
		checkException(GdipDrawImageI(this._native, img.native, x, y));
	}

	public void drawImage(Image img, Rect r)
	{
		checkException(GdipDrawImageRectI(this._native, img.native, r.x, r.y, r.width, r.height));
	}

	public void drawImage(Image img, Point pt)
	{
		this.drawImage(img, pt.x, pt.y);
	}

	public void drawLine(Pen pen, int x1, int y1, int x2, int y2)
	{
		checkException(GdipDrawLineI(this._native, pen.native, x1, y1, x2, y2));
	}

	public void drawLine(Pen pen, Point from, Point to)
	{
		this.drawLine(pen, from.x, from.y, to.x, to.y);
	}

	public void drawLines(Pen pen, Point[] points)
	{
		POINT[] pts = new POINT[points.length];

		foreach(int i, Point p; points)
		{
			pts[i] = p.point;
		}

		checkException(GdipDrawLinesI(this._native, pen.native, pts.ptr, pts.length)); //VERY SLOW!!!
	}

	public void drawString(string text, Rect r, Brush b, Font f, StringFormat sf)
	{
		GpRectF rf = convertRect(r);
		checkException(GdipDrawString(this._native, toUTF16z(text), -1, f.native, &rf, sf.native, b.native));
	}

	public void drawString(string text, Point pt, Brush b, Font f, StringFormat sf)
	{
		Rect r = Rect(pt, NullSize);
		this.drawString(text, r, b, f, sf);
	}

	public void drawString(string text, Rect r, Brush b, Font f)
	{
		this.drawString(text, r, b, f, StringFormat.genericDefault);
	}

	public void drawString(string text, Point pt, Brush b, Font f)
	{
		Rect r = Rect(pt, NullSize);
		this.drawString(text, r, b, f, StringFormat.genericDefault);
	}

	public void drawBorder(Rect r, BorderType edgeType, BorderMode edgeMode)
	{
		HDC hdc = this.getHDC();
		DrawEdge(hdc, &r.rect, edgeType, edgeMode);
		this.releaseDC();
	}

	public void fillRectangle(Brush b, Rect r)
	{
		checkException(GdipFillRectangleI(this._native, b.native, r.x, r.y, r.width, r.height));
	}

	public void drawRectangle(Pen p, Rect r)
	{
		checkException(GdipDrawRectangleI(this._native, p.native, r.x, r.y, r.width, r.height));
	}

	public void fillEllipse(Brush b, Rect r)
	{
		checkException(GdipFillEllipseI(this._native, b.native, r.x, r.y, r.width, r.height));
	}

	public void drawEllipse(Pen p, Rect r)
	{
		checkException(GdipDrawEllipseI(this._native, p.native, r.x, r.y, r.width, r.height));
	}

	public HDC getHDC()
	{
		if(!this._nativeDC)
		{
			checkException(GdipGetDC(this._native, &this._nativeDC));
		}

		return this._nativeDC;
	}

	public void releaseDC()
	{
		if(this._nativeDC)
		{
			checkException(GdipReleaseDC(this._native, this._nativeDC));
			this._nativeDC = null;
		}
	}

	public static Canvas fromHDC(HDC hdc)
	{
		GpGraphics pGraph;
		checkException(GdipCreateFromHDC(hdc, &pGraph));

		Canvas c = new Canvas();
		c._native = pGraph;
		return c;
	}

	public static Canvas fromImage(Image img)
	{
		GpGraphics graph;
		checkException(GdipGetImageGraphicsContext(img.native, &graph));

		Canvas c = new Canvas();
		c._native = graph;

		return c;
	}

	public static Canvas fromHWND(HWND hWnd)
	{
		GpGraphics pGraph;
		checkException(GdipCreateFromHWND(hWnd, &pGraph));

		Canvas c = new Canvas();
		c._native = pGraph;
		return c;
	}
}

final class Screen
{
	public static Size size()
	{
		Size sz = void; //Inizializzata sotto

		sz.width = GetSystemMetrics(SM_CXSCREEN);
		sz.height = GetSystemMetrics(SM_CYSCREEN);

		return sz;
	}
}

final class Desktop
{
	public static Rect workArea()
	{
		Rect r = void; //Inizializzata sotto

		SystemParametersInfoA(SPI_GETWORKAREA, 0, &r.rect, 0);
		return r;
	}

	public static HWND handle()
	{
		return GetDesktopWindow();
	}
}
