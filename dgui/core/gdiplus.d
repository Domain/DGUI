module dgui.core.gdiplus;

import std.math;
public import dgui.core.winapi;
public import dgui.core.idisposable;
public import dgui.core.geometry;

alias uint ARGB;

alias int GpImageType;
alias int GpHatchStyle;
alias int GpPixelFormat;
alias int GpStringAlignment;

alias void* GpPen;
alias void* GpIcon;
alias void* GpFont;
alias void* GpPath;
alias void* GpUnit;
alias void* GpBrush;
alias void* GpImage;
alias void* GpObject; //Base GDI+ Object
alias void* GpBitmap;
alias void* GpMatrix;
alias void* GpRegion;
alias void* GpGraphics;
alias void* GpDashStyle;
alias void* GpSolidFill;
alias void* GpHatchBrush;
alias void* GpFontFamily;
alias void* GpGraphicsPath;
alias void* GpStringFormat;
alias void* GpTextureBrush;
alias void* GpFontCollection;
alias void* GpStringTrimming;
alias void* GpImageCodecInfo;
alias void* GpImageAttributes;
alias void* GpEncoderParameters;
alias void* GpLinearGradientBrush;

enum DebugEventLevel
{
	FATAL,
	WARNING,
}

enum Status
{
	OK,								// 0
	GENERIC_ERROR,					// 1
	INVALID_PARAMETER,				// 2
	OUT_OF_MEMORY,					// 3
	OBJECT_BUSY,					// 4
	INSUFFICIENT_BUFFER,			// 5
	NOT_IMPLEMENTED,				// 6
	WIN32_ERROR,					// 7
	WRONG_STATE,					// 8
	ABORTED,						// 9
	FILE_NOT_FOUND,					// 10
	VALUE_OVERFLOW,					// 11
	ACCESS_DENIED,					// 12
	UNKNOWN_IMAGE_FORMAT,			// 13
	FONT_FAMILY_NOT_FOUND,			// 14
	FONT_STYLE_NOT_FOUND,			// 15
	NOT_TRUETYPE_FONT,				// 16
	UNSUPPORTED_GDIPLUS_VERSION,	// 17
	GDI_PLUS_NOT_INITIALIZED,		// 18
	PROPERTY_NOT_FOUND,				// 19
	PROPERTY_NOT_SUPPORTED,			// 20
}

enum PixelFormat: int
{
	UNDEFINED			= 0x00000000,
	MAX					= 0x0000000F,
	INDEXED				= 0x00010000,
	GDI					= 0x00020000,
	DONT_CARE			= UNDEFINED,

	ALPHA				= 0x00040000,
	PALPHA				= 0x00080000,
	EXTENDED			= 0x00100000,
	CANONICAL			= 0x00200000,

	INDEXED_1_BPP		= 0x00030101,
	INDEXED_4_BPP		= 0x00030402,
	INDEXED_8_BPP		= 0x00030803,

	GRAY_SCALE_16_BPP	= 0x00101004,

	RGB_555_16_BPP		= 0x00021005,
	RGB_565_16_BPP		= 0x00021006,
	RGB_24_BPP			= 0x00021808,
	RGB_32_BPP			= 0x00022009,
	RGB_48_BPP			= 0x0010300C,

	ARGB_1555_16_BPP	= 0x00061007,
	PARGB_32_BPP		= 0x000E200B,
	ARGB_32_BPP			= 0x0026200A,
	ARGB_64_BPP			= 0x0034400D,

	PARGB_64_BPP		= 0x001C400E,
}

enum ImageLockMode
{
    READ 	   = 0x0001,
    WRITE 	   = 0x0002,
    USER_INPUT = 0x0004,

	READ_WRITE = READ | WRITE,
}


enum ImageType
{
    BITMAP = 1,
    METAFILE = 2,
}

struct GdiplusStartupInput
{
  uint GdiplusVersion;
  DebugEventProc DebugEventCallback;
  int SuppressBackgroundThread;
  int SuppressExternalCodecs;
}

struct GdiplusStartupOutput
{
  NotificationHookProc NotificationHook;
  NotificationUnhookProc NotificationUnhook;
}

/* *** Interoperabilita' *** */

struct GpRectF
{
    float x;
    float y;
    float width;
    float height;
}

package const GpRectF NullRectF = GpRectF.init;

Rect convertRect(GpRectF r)
{
	return Rect(cast(uint)floor(r.x), cast(uint)floor(r.y), cast(uint)floor(r.width), cast(uint)floor(r.height))	;
}

GpRectF convertRect(Rect r)
{
	GpRectF rf = void; //Inizializzata sotto

	rf.x = r.x;
	rf.y = r.y;
	rf.width = r.width;
	rf.height = r.height;

	return rf;
}

/* *** **************** *** */

struct BitmapData
{
    uint Width;
    uint Height;
    int Stride;
    PixelFormat Format;
    void* Scan0;
    uint Reserved;
}

align(1) struct ImageCodecInfo
{
    GUID Clsid;
    GUID FormatID;
    wchar* CodecName;
    wchar* DllName;
    wchar* FormatDescription;
    wchar* FilenameExtension;
    wchar* MimeType;
    int Flags;
    int Version;
    int SigCount;
    int SigSize;
    ubyte* SigPattern;
    ubyte* SigMask;
}

alias extern(Windows) void function(DebugEventLevel level, char* message) DebugEventProc;
alias extern(Windows) void function(uint token) NotificationUnhookProc;
alias extern(Windows) int function(out uint token) NotificationHookProc;

extern(Windows) void GdiplusShutdown(uint token);
extern(Windows) void GdipFree(void* ptr);
extern(Windows) void* GdipAlloc(size_t size);
extern(Windows) Status GdiplusStartup(uint* token, GdiplusStartupInput* input, GdiplusStartupOutput* output);
extern(Windows) Status GdipCreateFromHDC(HDC hdc, GpGraphics* graphics);
extern(Windows) Status GdipCreateFromHWND(HWND hwnd, GpGraphics* graphics);
extern(Windows) Status GdipCreateFontFamilyFromName(wchar* name, GpFontCollection fontCollection, GpFontFamily* fontFamily);
extern(Windows) Status GdipDeleteFontFamily(GpFontFamily fontFamily);
extern(Windows) Status GdipGetFamily(GpFont font, GpFontFamily* family);
extern(Windows) Status GdipGetFontSize(GpFont font, float* size);
extern(Windows) Status GdipGetFontUnit(GpFont font, GpUnit unit);
extern(Windows) Status GdipDeleteGraphics(GpGraphics graphics);
extern(Windows) Status GdipGetDC(GpGraphics graphics, HDC* hdc);
extern(Windows) Status GdipReleaseDC(GpGraphics graphics, HDC hdc);
extern(Windows) Status GdipCreatePen1(ARGB color, float width, GpUnit unit, GpPen* pen);
extern(Windows) Status GdipDrawImageI(GpGraphics graphics, GpImage image, int x, int y);
extern(Windows) Status GdipCreateBitmapFromScan0(int width, int height, int stride, GpPixelFormat format, ubyte* scan0, GpBitmap* bitmap);
extern(Windows) Status GdipDeletePen(GpPen pen);
extern(Windows) Status GdipDrawLineI(GpGraphics graphics, GpPen pen, int x1, int y1, int x2, int y2);
extern(Windows) Status GdipDrawLinesI(GpGraphics graphics, GpPen pen, POINT* points, int count);
extern(Windows) Status GdipSetPenWidth(GpPen pen, float width);
extern(Windows) Status GdipSetPenColor(GpPen pen, ARGB argb);
extern(Windows) Status GdipSetPenDashStyle(GpPen pen, GpDashStyle dashstyle);
extern(Windows) Status GdipGetPenDashStyle(GpPen pen, GpDashStyle* dashstyle);
extern(Windows) Status GdipCreateSolidFill(ARGB color, GpSolidFill* brush);
extern(Windows) Status GdipSetSolidFillColor(GpSolidFill brush, ARGB color);
extern(Windows) Status GdipDeleteBrush(GpBrush brush);
extern(Windows) Status GdipCreateHatchBrush(GpHatchStyle hatchStyle, ARGB forecol, ARGB backcol, GpHatchBrush* brush);
extern(Windows) Status GdipFillRectangleI(GpGraphics graphics, GpBrush brush, int x, int y, int width, int height);
extern(Windows) Status GdipDrawRectangleI(GpGraphics graphics, GpPen pen, int x, int y, int width, int height);
extern(Windows) Status GdipDrawEllipseI(GpGraphics graphics, GpPen pen, int x, int y, int width, int height);
extern(Windows) Status GdipDrawArcI(GpGraphics graphics, GpPen pen, int x, int y, int width, int height, float startAngle, float sweepAngle);
extern(Windows) Status GdipDrawBezierI(GpGraphics graphics, GpPen pen, int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4);
extern(Windows) Status GdipDrawPieI(GpGraphics graphics, GpPen pen, int x, int y, int width, int height, float startAngle, float sweepAngle);
extern(Windows) Status GdipFillPieI(GpGraphics graphics, GpBrush brush, int x, int y, int width, int height, float startAngle, float sweepAngle);
extern(Windows) Status GdipFillEllipseI(GpGraphics graphics, GpBrush brush, int x, int y, int width, int height);
extern(Windows) Status GdipDrawString(GpGraphics graphics, wchar* string, int length, GpFont font, GpRectF* layoutRect, GpStringFormat stringFormat, GpBrush brush);
extern(Windows) Status GdipCreateStringFormat(int formatAttributes, LANGID language, GpStringFormat* format);
extern(Windows) Status GdipDeleteStringFormat(GpStringFormat format);
extern(Windows) Status GdipSetStringFormatAlign(GpStringFormat format, GpStringAlignment sa);
extern(Windows) Status GdipSetStringFormatTrimming(GpStringFormat format, GpStringTrimming trimming);
extern(Windows) Status GdipSetStringFormatLineAlign(GpStringFormat format, GpStringAlignment sa);
extern(Windows) Status GdipStringFormatGetGenericDefault(GpStringFormat* format);
extern(Windows) Status GdipCreateFontFromDC(HDC hdc, GpFont* font);
extern(Windows) Status GdipCreateFontFromLogfontA(HDC hdc, LOGFONTA* logfont, GpFont* font);
extern(Windows) Status GdipCreateFont(GpFontFamily fontFamily, float emSize, int style, GpUnit unit, GpFont* font);
extern(Windows) Status GdipCreateBitmapFromHBITMAP(HBITMAP hbm, HPALETTE hpal, GpBitmap* bitmap);
extern(Windows) Status GdipDeleteFont(GpFont font);
extern(Windows) Status GdipCreateBitmapFromHICON(HICON hicon, GpBitmap* bitmap);
extern(Windows) Status GdipCreateHICONFromBitmap(GpBitmap bitmap, HICON* hbmReturn);
extern(Windows) Status GdipCreateHBITMAPFromBitmap(GpBitmap bitmap, HBITMAP* hbmReturn, ARGB background);
extern(Windows) Status GdipDisposeImage(GpImage image);
extern(Windows) Status GdipGetLogFontA(GpFont font, GpGraphics graphics, LOGFONTA* logfontW);
extern(Windows) Status GdipBitmapLockBits(GpBitmap bitmap, RECT* rect, uint flags, GpPixelFormat format, BitmapData* lockedBitmapData);
extern(Windows) Status GdipBitmapUnlockBits(GpBitmap bitmap, BitmapData* lockedBitmapData);
extern(Windows) Status GdipGetImagePixelFormat(GpImage image, GpPixelFormat* format);
extern(Windows) Status GdipGetImageBounds(GpImage image, GpRectF* srcRect, GpUnit srcUnit);
extern(Windows) Status GdipDrawImageRectI(GpGraphics graphics, GpImage image, int x, int y, int width, int height);
extern(Windows) Status GdipLoadImageFromFile(wchar* filename, GpImage* image);
extern(Windows) Status GdipGetImageType(GpImage image, GpImageType* type);
extern(Windows) Status GdipSaveImageToFile(GpImage image, wchar* filename, CLSID* clsidEncoder, GpEncoderParameters encoderParams);
extern(Windows) Status GdipGetImageEncodersSize(uint* numEncoders, uint* size);
extern(Windows) Status GdipGetImageEncoders(uint numEncoders, uint size, GpImageCodecInfo encoders);
extern(Windows) Status GdipGetImageGraphicsContext(GpImage image, GpGraphics* graphics);
extern(Windows) Status GdipGetFontHeight(GpFont font, GpGraphics graphics, float* height);
extern(Windows) Status GdipMeasureString(GpGraphics graphics, wchar* string, int len,  GpFont font, GpRectF* layoutRect, GpStringFormat stringFormat, GpRectF *boundingBox, int* codepointsFitted, int* linesFilled);
extern(Windows) Status GdipGetFamilyName(GpFontFamily family, wchar* name, LANGID language);
