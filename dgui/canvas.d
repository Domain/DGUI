/*
	Copyright (c) 2011 Trogu Antonio Davide

	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

module dgui.canvas;

import std.path;
import std.string;
import std.c.string;
import core.memory;
import dgui.core.charset;
import dgui.core.winapi;
import dgui.core.idisposable;
import dgui.core.exception;
import dgui.core.handle;
import dgui.core.utils;
public import dgui.core.geometry;

enum FontStyle: ubyte
{
	NORMAL = 0,
	BOLD = 1,
	ITALIC = 2,
	UNDERLINE = 4,
	STRIKEOUT = 8,
}

enum ImageType
{
	BITMAP 		   = 0,
	ICON_OR_CURSOR = 1,
}

enum GradientFillRectMode
{
	HORIZONTAL = 0,
	VERTICAL   = 1,
}

enum EdgeType: uint
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

enum EdgeMode: uint
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

enum HatchStyle: int
{
	HORIZONTAL = HS_HORIZONTAL,
	VERTICAL = HS_VERTICAL,
	BACKWARD_DIAGONAL = HS_BDIAGONAL,
	FORWARD_DIAGONAL = HS_FDIAGONAL,
	CROSS = HS_CROSS,
	DIAGONAL_CROSS = HS_DIAGCROSS,
}

enum PenStyle: uint
{
	SOLID = PS_SOLID,
	DASH = PS_DASH,
	DOT = PS_DOT,
	DASH_DOT = PS_DASHDOT,
	DASH_DOT_DOT = PS_DASHDOTDOT,
	NULL = PS_NULL,
	INSIDE_FRAME = PS_INSIDEFRAME,
}

enum TextFormatFlags: uint
{
	NO_PREFIX = DT_NOPREFIX,
	DIRECTION_RIGHT_TO_LEFT = DT_RTLREADING,
	WORD_BREAK = DT_WORDBREAK,
	SINGLE_LINE = DT_SINGLELINE,
	NO_CLIP = DT_NOCLIP,
	LINE_LIMIT = DT_EDITCONTROL,
}

enum TextAlignment: uint
{
	LEFT = DT_LEFT,
	RIGHT = DT_RIGHT,
	CENTER = DT_CENTER,

	TOP = DT_TOP,
	BOTTOM = DT_BOTTOM,
	MIDDLE = DT_VCENTER,
}

enum TextTrimming: uint
{
	NONE = 0,
	ELLIPSIS = DT_END_ELLIPSIS,
	ELLIPSIS_PATH = DT_PATH_ELLIPSIS,
}

enum BitmapCopyMode
{
	NORMAL 	= SRCCOPY,
	INVERT	= SRCINVERT,
	AND   	= SRCAND,
	OR      = SRCPAINT,
}

struct BitmapBit
{
	union
	{
		ubyte rgbBlue;
		ubyte Blue;
	}

	union
	{
		ubyte rgbGreen;
		ubyte Green;
	}

	union
	{
		ubyte rgbRed;
		ubyte Red;
	}

	union
	{
		ubyte rgbReserved;
		ubyte Alpha;
	}
}

struct BitmapData
{
	BITMAPINFO* Info;
	uint ImageSize;
	uint BitsCount;
	BitmapBit* Bits;
}

struct Color
{
	private bool _valid = false; // Check if it was assigned a value

	public union
	{
		align(1) struct
		{
			ubyte red   = 0x00;
			ubyte green = 0x00;
			ubyte blue  = 0x00;
			ubyte alpha = 0xFF; //0x00: Transparent, 0xFF: Opaque
		}

		COLORREF colorref;
	}

	@property public final bool valid()
	{
		return this._valid;
	}

	public static Color opCall(ubyte r, ubyte g, ubyte b)
	{
		return Color(0xFF, r, g, b);
	}

	public static Color opCall(ubyte a, ubyte r, ubyte g, ubyte b)
	{
		Color color = void; //Inializzata sotto;

		color._valid = true;

		color.alpha = a;
		color.red = r;
		color.green = g;
		color.blue = b;
		color.blue = b;

		return color;
	}

	public static Color fromCOLORREF(COLORREF cref)
	{
		Color color = void; //Inializzata sotto;

		color._valid = true;
		color.colorref = cref;
		return color;
	}
}

class Canvas: Handle!(HDC), IDisposable
{
	private enum CanvasType: ubyte
	{
		NORMAL = 0,
		FROM_CONTROL = 1,
		IN_MEMORY = 2,
	}

	private CanvasType _canvasType = CanvasType.NORMAL;
	private HBITMAP _hBitmap;
	private bool _owned;

	protected this(HDC hdc, bool owned, CanvasType type)
	{
		this._handle = hdc;
		this._owned = owned;
		this._canvasType = type;
	}

	public ~this()
	{
		if(this._handle && this._owned)
		{
			this.dispose();
			this._handle = null;
		}
	}

	public void copyTo(Canvas c, BitmapCopyMode bcm)
	{
		BITMAP bmp;
		GetObjectW(GetCurrentObject(this._handle, OBJ_BITMAP), BITMAP.sizeof, &bmp);

		BitBlt(c.handle, 0, 0, bmp.bmWidth, bmp.bmHeight, this._handle, 0, 0, bcm);
	}

	public void copyTo(Canvas c)
	{
		this.copyTo(c, BitmapCopyMode.NORMAL);
	}

	public void copyTransparent(Canvas c, Color transpColor)
	{
		BITMAP bmp;
		HBITMAP hBitmap = GetCurrentObject(this._handle, OBJ_BITMAP);

		GetObjectW(hBitmap, BITMAP.sizeof, &bmp);
		GdiTransparentBlt(c.handle, 0, 0, bmp.bmWidth, bmp.bmHeight, this._handle, 0, 0, bmp.bmWidth, bmp.bmHeight, transpColor.colorref);
	}

	public void dispose()
	{
		switch(this._canvasType)
		{
			case CanvasType.FROM_CONTROL:
				ReleaseDC(WindowFromDC(this._handle), this._handle);
				break;

			case CanvasType.IN_MEMORY:
				DeleteObject(this._hBitmap);
				DeleteDC(this._handle);
				break;

			default:
				break;
		}
	}

	public static Size measureString(string s, Canvas c, Font f)
	{
		Size sz;

		HFONT hOldFont = f ? SelectObject(c.handle, f.handle) : null;
		GetTextExtentPoint32W(c.handle, toUTF16z(s), s.length, &sz.size);

		if(f)
		{
			SelectObject(c.handle, hOldFont);
		}

		return sz;
	}

	public static Size measureString(string s, Canvas c)
	{
		return Canvas.measureString(s, c, null);
	}

	public static Size measureString(string s, Font f)
	{
		scope Canvas c = Screen.canvas;
		return Canvas.measureString(s, c, f);
	}

	public static Size measureString(string s)
	{
		scope Canvas c = Screen.canvas;
		return Canvas.measureString(s, c, SystemFonts.windowsFont);
	}

	public final void fillRectGradient(Rect r, Color startColor, Color endColor, GradientFillRectMode gfrm)
	{
		TRIVERTEX[2] tv;
		static GRADIENT_RECT gr = {UpperLeft: 0, LowerRight: 1};

		tv[0].x = r.left;
		tv[0].y = r.top;
		tv[0].Red = startColor.red << 8;
		tv[0].Green = startColor.green << 8;
		tv[0].Blue = startColor.blue << 8;
		tv[0].Alpha = startColor.alpha << 8;

		tv[1].x = r.right;
		tv[1].y = r.bottom;
		tv[1].Red = endColor.red << 8;
		tv[1].Green = endColor.green  << 8;
		tv[1].Blue =  endColor.blue << 8;
		tv[1].Alpha = endColor.alpha << 8;

		GdiGradientFill(this._handle, tv.ptr, 2, &gr, 1, gfrm);
	}

	public final void fillTriangleGradient(int x1, int y1, int x2, int y2, int x3, int y3, Color color1, Color color2, Color color3)
	{
		this.fillTriangleGradient(Point(x1, y1), Point(x2, y2), Point(x3, y3), color1, color2, color3);
	}

	public final void fillTriangleGradient(Point pt1, Point pt2, Point pt3, Color color1, Color color2, Color color3)
	{
		TRIVERTEX[3] tv;
		static GRADIENT_TRIANGLE gt = {Vertex1: 0, Vertex2: 1, Vertex3: 2};

		tv[0].x = pt1.x;
		tv[0].y = pt1.y;
		tv[0].Red = color1.red << 8;
		tv[0].Green = color1.green << 8;
		tv[0].Blue = color1.blue << 8;
		tv[0].Alpha = color1.alpha << 8;

		tv[1].x = pt2.x;
		tv[1].y = pt2.y;
		tv[1].Red = color2.red << 8;
		tv[1].Green = color2.green  << 8;
		tv[1].Blue = color2.blue << 8;
		tv[1].Alpha = color2.alpha << 8;

		tv[2].x = pt3.x;
		tv[2].y = pt3.y;
		tv[2].Red = color3.red << 8;
		tv[2].Green = color3.green  << 8;
		tv[2].Blue = color3.blue << 8;
		tv[2].Alpha = color3.alpha << 8;

		GdiGradientFill(this._handle, tv.ptr, 3, &gt, 1, 2 /* GRADIENT_FILL_TRIANGLE */);
	}

	public final void drawImage(Image img, Point upLeft, Point upRight, Point lowLeft)
	{
		this.drawImage(img, 0, 0, upLeft, upRight, lowLeft);
	}
	public final void drawImage(Image img, int x, int y, Point upLeft, Point upRight, Point lowLeft)
	{
		POINT[3] pts;

		pts[0] = upLeft.point;
		pts[1] = upRight.point;
		pts[2] = lowLeft.point;

		Size sz = img.size;
		HDC hdc = CreateCompatibleDC(this._handle);
		HBITMAP hOldBitmap = SelectObject(hdc, img.handle);

		PlgBlt(this._handle, pts.ptr, hdc, x, y, sz.width, sz.height, null, 0, 0);

		SelectObject(hdc, hOldBitmap);
		DeleteDC(hdc);
	}

	public final void drawImage(Image img, int x, int y)
	{
		Size sz = img.size;

		switch(img.type)
		{
			case ImageType.BITMAP:
				HDC hdc = CreateCompatibleDC(this._handle);
				HBITMAP hOldBitmap = SelectObject(hdc, img.handle);
				BitBlt(this._handle, x, y, sz.width, sz.height, hdc, 0, 0, SRCCOPY);
				SelectObject(hdc, hOldBitmap);
				DeleteDC(hdc);
				break;

			case ImageType.ICON_OR_CURSOR:
				DrawIconEx(this._handle, x, y, img.handle, sz.width, sz.height, 0, null, DI_NORMAL);
				break;

			default:
				break;
		}
	}

	public final void drawImage(Image img, Rect r)
	{
		Size sz = img.size;

		switch(img.type)
		{
			case ImageType.BITMAP:
				HDC hdc = CreateCompatibleDC(this._handle);
				HBITMAP hOldBitmap = SelectObject(hdc, img.handle);
				StretchBlt(this._handle, r.x, r.y, r.width, r.height, hdc, 0, 0, sz.width, sz.height, SRCCOPY);
				SelectObject(hdc, hOldBitmap);
				DeleteDC(hdc);
				break;

			case ImageType.ICON_OR_CURSOR:
				DrawIconEx(this._handle, r.x, r.y, img.handle, r.width, r.height, 0, null, DI_NORMAL);
				break;

			default:
				break;
		}
	}

	public final void drawEdge(Rect r, EdgeType edgeType, EdgeMode edgeMode)
	{
		DrawEdge(this._handle, &r.rect, edgeType, edgeMode);
	}

	public final void drawText(string text, Rect r, Color foreColor, Font font, TextFormat textFormat)
	{
		DRAWTEXTPARAMS dtp;

		dtp.cbSize = DRAWTEXTPARAMS.sizeof;
		dtp.iLeftMargin = textFormat.leftMargin;
		dtp.iRightMargin = textFormat.rightMargin;
		dtp.iTabLength = textFormat.tabLength;

		HFONT hOldFont = SelectObject(this._handle, font.handle);
		COLORREF oldColorRef = SetTextColor(this._handle, foreColor.colorref);
		int oldBkMode = SetBkMode(this._handle, TRANSPARENT);

		drawTextEx(this._handle, text, &r.rect,
				   DT_EXPANDTABS | DT_TABSTOP | textFormat.formatFlags | textFormat.alignment | textFormat.trimming,
				   &dtp);

		SetBkMode(this._handle, oldBkMode);
		SetTextColor(this._handle, oldColorRef);
		SelectObject(this._handle, hOldFont);
	}

	public final void drawText(string text, Rect r, Color foreColor, Font font)
	{
		scope TextFormat tf = new TextFormat(TextFormatFlags.NO_PREFIX | TextFormatFlags.WORD_BREAK |
											 TextFormatFlags.NO_CLIP | TextFormatFlags.LINE_LIMIT);

		tf.trimming = TextTrimming.NONE;

		this.drawText(text, r, foreColor, font, tf);
	}

	public final void drawText(string text, Rect r, Color foreColor)
	{
		scope Font f = Font.fromHFONT(GetCurrentObject(this._handle, OBJ_FONT), false);
		this.drawText(text, r, foreColor, f);
	}

	public final void drawText(string text, Rect r, Font f, TextFormat tf)
	{
		this.drawText(text, r, Color.fromCOLORREF(GetTextColor(this._handle)), f, tf);
	}

	public final void drawText(string text, Rect r, TextFormat tf)
	{
		scope Font f = Font.fromHFONT(GetCurrentObject(this._handle, OBJ_FONT), false);
		this.drawText(text, r, Color.fromCOLORREF(GetTextColor(this._handle)), f, tf);
	}

	public final void drawText(string text, Rect r, Font f)
	{
		this.drawText(text, r, Color.fromCOLORREF(GetTextColor(this._handle)), f);
	}

	public final void drawText(string text, Rect r)
	{
		scope Font f = Font.fromHFONT(GetCurrentObject(this._handle, OBJ_FONT), false);
		this.drawText(text, r, Color.fromCOLORREF(GetTextColor(this._handle)), f);
	}

	public final void drawLine(Pen p, int x1, int y1, int x2, int y2)
	{
		HPEN hOldPen = SelectObject(this._handle, p.handle);

		MoveToEx(this._handle, x1, y1, null);
		LineTo(this._handle, x2, y2);

		SelectObject(this._handle, hOldPen);
	}

	public final void drawEllipse(Pen pen, Brush fill, Rect r)
	{
		HPEN hOldPen;
		HBRUSH hOldBrush;

		if(pen)
		{
			hOldPen = SelectObject(this._handle, pen.handle);
		}

		if(fill)
		{
			hOldBrush = SelectObject(this._handle, fill.handle);
		}

		Ellipse(this._handle, r.left, r.top, r.right, r.bottom);

		if(hOldBrush)
		{
			SelectObject(this._handle, hOldBrush);
		}

		if(hOldPen)
		{
			SelectObject(this._handle, hOldPen);
		}
	}

	public final void drawEllipse(Pen pen, Rect r)
	{
		this.drawEllipse(pen, SystemBrushes.nullBrush, r);
	}

	public final void drawRectangle(Pen pen, Brush fill, Rect r)
	{
		HPEN hOldPen;
		HBRUSH hOldBrush;

		if(pen)
		{
			hOldPen = SelectObject(this._handle, pen.handle);
		}

		if(fill)
		{
			hOldBrush = SelectObject(this._handle, fill.handle);
		}

		Rectangle(this._handle, r.left, r.top, r.right, r.bottom);

		if(hOldBrush)
		{
			SelectObject(this._handle, hOldBrush);
		}

		if(hOldPen)
		{
			SelectObject(this._handle, hOldPen);
		}
	}

	public final void drawRectangle(Pen pen, Rect r)
	{
		this.drawRectangle(pen, SystemBrushes.nullBrush, r);
	}

	public final void fillRectangle(Brush b, Rect r)
	{
		FillRect(this._handle, &r.rect, b.handle);
	}

	public final void fillEllipse(Brush b, Rect r)
	{
		this.drawEllipse(SystemPens.nullPen, b, r);
	}

	public final Canvas createInMemory(Bitmap b)
	{
		HBITMAP hBitmap;
		HDC hdc = CreateCompatibleDC(this._handle);
		Canvas c = new Canvas(hdc, true, CanvasType.IN_MEMORY);

		if(!b)
		{
			BITMAP bmp;

			GetObjectW(GetCurrentObject(this._handle, OBJ_BITMAP), BITMAP.sizeof, &bmp);
			hBitmap = CreateCompatibleBitmap(this._handle, bmp.bmWidth, bmp.bmHeight);
			c._hBitmap = hBitmap;
			SelectObject(hdc, hBitmap);  // La seleziona e la distrugge quando ha finito.
		}
		else
		{
			SelectObject(hdc, b.handle); // La prende 'in prestito', ma non la distrugge.
		}


		return c;
	}

	public final Canvas createInMemory()
	{
		return this.createInMemory(null);
	}

	public static Canvas fromHDC(HDC hdc, bool owned = true)
	{
		return new Canvas(hdc, owned, CanvasType.FROM_CONTROL);
	}
}

abstract class GraphicObject: Handle!(HGDIOBJ), IDisposable
{
	protected bool _owned;

	protected this()
	{

	}

	protected this(HGDIOBJ hGdiObj, bool owned)
	{
		this._handle = hGdiObj;
		this._owned = owned;
	}

	public ~this()
	{
		if(this._owned && this._handle)
		{
			this.dispose();
			this._handle = null;
		}
	}

	protected static int getInfo(T)(HGDIOBJ hGdiObj, ref T t)
	{
		return GetObjectW(hGdiObj, T.sizeof, &t);
	}

	public void dispose()
	{
		DeleteObject(this._handle);
	}
}

abstract class Image: GraphicObject
{
	protected this()
	{

	}

	@property public abstract Size size();
	@property public abstract ImageType type();

	protected this(HGDIOBJ hGdiObj, bool owned)
	{
		super(hGdiObj, owned);
	}
}

class Bitmap: Image
{
	public this(Size sz)
	{
		HBITMAP hBitmap = this.createBitmap(sz.width, sz.height, RGB(0xFF, 0xFF, 0xFF));
		super(hBitmap, true);
	}

	public this(Size sz, Color bc)
	{
		HBITMAP hBitmap = this.createBitmap(sz.width, sz.height, bc.colorref);
		super(hBitmap, true);
	}

	public this(int w, int h)
	{
		HBITMAP hBitmap = this.createBitmap(w, h, RGB(0xFF, 0xFF, 0xFF));
		super(hBitmap, true);
	}

	public this(int w, int h, Color bc)
	{
		HBITMAP hBitmap = this.createBitmap(w, h, bc.colorref);
		super(hBitmap, true);
	}

	protected this(HBITMAP hBitmap, bool owned)
	{
		super(hBitmap, owned);
	}

	protected this(string fileName)
	{
		HBITMAP hBitmap = loadImage(null, fileName, IMAGE_BITMAP, 0, 0, LR_DEFAULTCOLOR | LR_DEFAULTSIZE | LR_LOADFROMFILE);

		if(!hBitmap)
		{
			throwException!(Win32Exception)("Cannot load Bitmap From File: '%s'", fileName);
		}

		super(hBitmap, true);
	}

	private static HBITMAP createBitmap(int w, int h, COLORREF backColor)
	{
		Rect r = Rect(0, 0, w, h);

		HDC hdc = GetWindowDC(null);
		HDC hcdc = CreateCompatibleDC(hdc);
		HBITMAP hBitmap = CreateCompatibleBitmap(hdc, w, h);
		HBITMAP hOldBitmap = SelectObject(hcdc, hBitmap);

		COLORREF oldColor = SetBkColor(hcdc, backColor);
		extTextOut(hcdc, 0, 0, ETO_OPAQUE, &r.rect, "", 0, null);
		SetBkColor(hcdc, oldColor);

		SelectObject(hcdc, hOldBitmap);
		DeleteDC(hcdc);
		ReleaseDC(null, hdc);

		return hBitmap;
	}

	public Bitmap alphaBlend(ubyte alpha)
	{
		BITMAP b;
		getInfo!(BITMAP)(this._handle, b);

		HDC hdc = GetWindowDC(null);
		HDC hdc1 = CreateCompatibleDC(hdc);
		HDC hdc2 = CreateCompatibleDC(hdc);
		HBITMAP hBitmap = CreateCompatibleBitmap(hdc, b.bmWidth, b.bmHeight);
		HBITMAP hOldBitmap1 = SelectObject(hdc1, hBitmap);
		HBITMAP hOldBitmap2 = SelectObject(hdc2, this._handle);

		BLENDFUNCTION bf;
		bf.BlendOp = 0; // AC_SRC_OVER
		bf.SourceConstantAlpha = alpha;

		if(b.bmBitsPixel == 32) // Premultiply bits if Bitmap's bpp = 32bpp
		{
			BitmapData bd;
			Bitmap.getData(hBitmap, bd);

			for(int i = 0; i < bd.BitsCount; i++)
			{
				bd.Bits[i].Red = cast(ubyte)(bd.Bits[i].Red * (alpha / 0xFF));
				bd.Bits[i].Green = cast(ubyte)(bd.Bits[i].Green * (alpha / 0xFF));
				bd.Bits[i].Blue = cast(ubyte)(bd.Bits[i].Blue * (alpha / 0xFF));
			}

			Bitmap.setData(hBitmap, bd);

			bf.AlphaFormat = 1; // AC_SRC_ALPHA
		}

		GdiAlphaBlend(hdc1, 0, 0, b.bmWidth, b.bmHeight, hdc2, 0, 0, b.bmWidth, b.bmHeight, bf);

		SelectObject(hdc2, hOldBitmap2);
		SelectObject(hdc1, hOldBitmap1);
		DeleteDC(hdc2);
		DeleteDC(hdc1);
		ReleaseDC(null, hdc);

		return Bitmap.fromHBITMAP(hBitmap);
	}

	public Bitmap clone()
	{
		BITMAP b;
		getInfo!(BITMAP)(this._handle, b);

		HDC hdc = GetDC(null);
		HDC hcdc1 = CreateCompatibleDC(hdc); // Contains this bitmap
		HDC hcdc2 = CreateCompatibleDC(hdc); // The Bitmap will be copied here
		HBITMAP hBitmap = CreateCompatibleBitmap(hdc, b.bmWidth, b.bmHeight); //Don't delete it, it will be deleted by the class Bitmap

		HBITMAP hOldBitmap1 = SelectObject(hcdc1, this._handle);
		HBITMAP hOldBitmap2 = SelectObject(hcdc2, hBitmap);

		BitBlt(hcdc2, 0, 0, b.bmWidth, b.bmHeight, hcdc1, 0, 0, SRCCOPY);
		SelectObject(hcdc2, hOldBitmap2);
		SelectObject(hcdc1, hOldBitmap1);

		DeleteDC(hcdc2);
		DeleteDC(hcdc1);
		ReleaseDC(null, hdc);

		Bitmap bmp = new Bitmap(hBitmap, true);
		return bmp;
	}

	public static void getData(HBITMAP hBitmap, ref BitmapData bd)
	{
		BITMAPINFO bi;
		bi.bmiHeader.biSize = BITMAPINFOHEADER.sizeof;
		bi.bmiHeader.biBitCount = 0;

		HDC hdc = GetWindowDC(null);
		GetDIBits(hdc, hBitmap, 0, 0, null, &bi, DIB_RGB_COLORS); // Get Bitmap Info

		bd.ImageSize = bi.bmiHeader.biSizeImage;
		bd.BitsCount = bi.bmiHeader.biSizeImage / RGBQUAD.sizeof;
		bd.Bits = cast(BitmapBit*)GC.malloc(bi.bmiHeader.biSizeImage);

		switch(bi.bmiHeader.biBitCount) // Calculate color table size (if needed)
		{
			case 24:
				bd.Info = cast(BITMAPINFO*)GC.malloc(bi.bmiHeader.biSize);
				break;

			case 16, 32:
				bd.Info = cast(BITMAPINFO*)GC.malloc(bi.bmiHeader.biSize + uint.sizeof * 3); // Needs Investigation
				break;

			default:
				bd.Info = cast(BITMAPINFO*)GC.malloc(bi.bmiHeader.biSize + RGBQUAD.sizeof * (1 << bi.bmiHeader.biBitCount));
				break;
		}

		bd.Info.bmiHeader = bi.bmiHeader;
		GetDIBits(hdc, hBitmap, 0, bd.Info.bmiHeader.biHeight, cast(RGBQUAD*)bd.Bits, bd.Info, DIB_RGB_COLORS);
		ReleaseDC(null, hdc);
	}


	public void getData(ref BitmapData bd)
	{
		return Bitmap.getData(this._handle, bd);
	}

	private static void setData(HBITMAP hBitmap, ref BitmapData bd)
	{
		HDC hdc = GetWindowDC(null);
		SetDIBits(hdc, hBitmap, 0, bd.Info.bmiHeader.biHeight, cast(RGBQUAD*)bd.Bits, bd.Info, DIB_RGB_COLORS);

		ReleaseDC(null, hdc);
		Bitmap.freeData(bd);
	}

	public void setData(ref BitmapData bd)
	{
		Bitmap.setData(this._handle, bd);
	}

	public static void freeData(ref BitmapData bd)
	{
		GC.free(bd.Bits);
		GC.free(bd.Info);
	}

	@property public override Size size()
	{
		BITMAP bmp = void; //Inizializzata da getInfo()

		getInfo!(BITMAP)(this._handle, bmp);
		return Size(bmp.bmWidth, bmp.bmHeight);
	}

	@property public override ImageType type()
	{
		return ImageType.BITMAP;
	}

	public static Bitmap fromHBITMAP(HBITMAP hBitmap, bool owned = true)
	{
		return new Bitmap(hBitmap, owned);
	}

	public static Bitmap fromFile(string fileName)
	{
		return new Bitmap(fileName);
	}
}

class Icon: Image
{
	protected this(HICON hIcon, bool owned)
	{
		super(hIcon, owned);
	}

	protected this(string fileName)
	{
		HICON hIcon;

		if(!icmp(getExt(fileName), "ico"))
		{
			hIcon = loadImage(null, fileName, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR | LR_DEFAULTSIZE | LR_LOADFROMFILE);
		}
		else
		{
			ushort dummy = 0;
			hIcon = extractAssociatedIcon(fileName, &dummy);
		}

		if(!hIcon)
		{
			throwException!(Win32Exception)("Cannot load Icon From File: '%s'", fileName);
		}

		super(hIcon, true);
	}

	public override void dispose()
	{
		DestroyIcon(this._handle);
	}

	@property public override Size size()
	{
		ICONINFO ii = void; //Inizializzata da GetIconInfo()
		BITMAP bmp = void; //Inizializzata da getInfo()
		Size sz = void; //Inizializzata sotto.

		if(!GetIconInfo(this._handle, &ii))
		{
			throwException!(Win32Exception)("Unable to get information from Icon");
		}

		if(ii.hbmColor) //Exists: Icon Color Bitmap
		{
			if(!getInfo!(BITMAP)(ii.hbmColor, bmp))
			{
				throwException!(Win32Exception)("Unable to get Icon Color Bitmap");
			}

			sz.width = bmp.bmWidth;
			sz.height = bmp.bmHeight;
			DeleteObject(ii.hbmColor);
		}
		else
		{
			if(!getInfo!(BITMAP)(ii.hbmMask, bmp))
			{
				throwException!(Win32Exception)("Unable to get Icon Mask");
			}

			sz.width = bmp.bmWidth;
			sz.height = bmp.bmHeight / 2;
		}

		DeleteObject(ii.hbmMask);
		return sz;
	}

	@property public override ImageType type()
	{
		return ImageType.ICON_OR_CURSOR;
	}

	public Bitmap toBitmap(Size sz)
	{
		HDC hwdc = GetWindowDC(null);
		HDC hdc1 = CreateCompatibleDC(hwdc);

		HBITMAP hBitmap = CreateCompatibleBitmap(hwdc, sz.width, sz.height);
		HBITMAP hOldBitmap = SelectObject(hdc1, hBitmap);

		Rect r = Rect(0, 0, sz.width, sz.height);

		SetBkColor(hdc1, RGB(255, 255, 255));
		extTextOut(hdc1, 0, 0, ETO_OPAQUE,  &r.rect, null, 0, null);

		DrawIconEx(hdc1, 0, 0, this._handle, sz.width, sz.height, 0, null, DI_NORMAL);
		SelectObject(hdc1, hOldBitmap);
		DeleteDC(hdc1);
		ReleaseDC(null, hwdc);

		return Bitmap.fromHBITMAP(hBitmap);
	}

	public Bitmap toBitmap()
	{
		Size sz = this.size;
		return this.toBitmap(sz);
	}

	public static Icon fromHICON(HICON hIcon, bool owned = true)
	{
		return new Icon(hIcon, owned);
	}

	public static Icon fromFile(string fileName)
	{
		return new Icon(fileName);
	}
}

final class Cursor: Icon
{
	protected this(HCURSOR hCursor, bool owned)
	{
		super(hCursor, owned);
	}

	public override void dispose()
	{
		DestroyCursor(this._handle);
	}

	@property public static Point location()
	{
		Point pt;

		GetCursorPos(&pt.point);
		return pt;
	}

	public static Cursor fromHCURSOR(HCURSOR hCursor, bool owned = true)
	{
		return new Cursor(hCursor, owned);
	}
}

final class Font: GraphicObject
{
	private FontStyle _style;
	private int _height;
	private string _name;

	private this(HFONT hFont, bool owned)
	{
		super(hFont, owned);
	}

	public this(string name, int h, FontStyle style = FontStyle.NORMAL)
	in
	{
		assert(h > 0, "Font height must be > 0");
	}
	body
	{
		HDC hdc = GetWindowDC(null);

		this._name = name;
		this._height = MulDiv(cast(int)(h * 100), GetDeviceCaps(hdc, LOGPIXELSY), 72 * 100);
		this._style = style;

		LOGFONTW lf;
		lf.lfHeight = this._height;

		doStyle(style, lf);
		this._handle = createFontIndirect(name, &lf);

		ReleaseDC(null, hdc);
	}

	public this(Font f, FontStyle fs)
	{
		LOGFONTW lf;

		getInfo!(LOGFONTW)(f.handle, lf);
		doStyle(fs, lf);
		this._handle = createFontIndirect(&lf);
	}

	private static void doStyle(FontStyle style, ref LOGFONTW lf)
	{
		lf.lfCharSet = DEFAULT_CHARSET;
		lf.lfWeight = FW_NORMAL;
		//lf.lfItalic = FALSE;    Inizializzata dal compilatore
		//lf.lfStrikeOut = FALSE; Inizializzata dal compilatore
		//lf.lfUnderline = FALSE; Inizializzata dal compilatore

		if(style & FontStyle.BOLD)
		{
			lf.lfWeight = FW_BOLD;
		}

		if(style & FontStyle.ITALIC)
		{
			lf.lfItalic = 1;
		}

		if(style & FontStyle.STRIKEOUT)
		{
			lf.lfStrikeOut = 1;
		}

		if(style & FontStyle.UNDERLINE)
		{
			lf.lfUnderline = 1;
		}
	}

	public static Font fromHFONT(HFONT hFont, bool owned = true)
	{
		return new Font(hFont, owned);
	}
}

abstract class Brush: GraphicObject
{
	protected this(HBRUSH hBrush, bool owned)
	{
		super(hBrush, owned);
	}
}

class SolidBrush: Brush
{
	private Color _color;

	protected this(HBRUSH hBrush, bool owned)
	{
		super(hBrush, owned);
	}

	public this(Color color)
	{
		this._color = color;
		super(CreateSolidBrush(color.colorref), true);
	}

	@property public final Color color()
	{
		return this._color;
	}

	public static SolidBrush fromHBRUSH(HBRUSH hBrush, bool owned = true)
	{
		return new SolidBrush(hBrush, owned);
	}
}

class HatchBrush: Brush
{
	private Color _color;
	private HatchStyle _style;

	protected this(HBRUSH hBrush, bool owned)
	{
		super(hBrush, owned);
	}

	public this(Color color, HatchStyle style)
	{
		this._color = color;
		this._style = style;

		super(CreateHatchBrush(style, color.colorref), true);
	}

	@property public final Color color()
	{
		return this._color;
	}

	@property public final HatchStyle style()
	{
		return this._style;
	}

	public static HatchBrush fromHBRUSH(HBRUSH hBrush, bool owned = true)
	{
		return new HatchBrush(hBrush, owned);
	}
}

class PatternBrush: Brush
{
	private Bitmap _bmp;

	protected this(HBRUSH hBrush, bool owned)
	{
		super(hBrush, owned);
	}

	public this(Bitmap bmp)
	{
		this._bmp = bmp;
		super(CreatePatternBrush(bmp.handle), true);
	}

	@property public final Bitmap bitmap()
	{
		return this._bmp;
	}

	public static PatternBrush fromHBRUSH(HBRUSH hBrush, bool owned = true)
	{
		return new PatternBrush(hBrush, owned);
	}
}

final class Pen: GraphicObject
{
	private PenStyle _style;
	private Color _color;
	private int _width;

	protected this(HPEN hPen, bool owned)
	{
		super(hPen, owned);
	}

	public this(Color color, int width = 1, PenStyle style = PenStyle.SOLID)
	{
		this._color = color;
		this._width = width;
		this._style = style;

		this._handle = CreatePen(style, width, color.colorref);

		super(this._handle, true);
	}

	@property public PenStyle style()
	{
		return this._style;
	}

	@property public int width()
	{
		return this._width;
	}

	@property public Color color()
	{
		return this._color;
	}

	public static Pen fromHPEN(HPEN hPen, bool owned = true)
	{
		return new Pen(hPen, owned);
	}
}

final class SystemPens
{
	@property public static Pen nullPen()
	{
		return Pen.fromHPEN(GetStockObject(NULL_PEN), false);
	}

	@property public static Pen blackPen()
	{
		return Pen.fromHPEN(GetStockObject(BLACK_PEN), false);
	}

	@property public static Pen whitePen()
	{
		return Pen.fromHPEN(GetStockObject(WHITE_PEN), false);
	}
}

final class SystemIcons
{
	@property public static Icon application()
	{
		static Icon ico;

		if(!ico)
		{
			HICON hIco = loadImage(null, cast(wchar*)IDI_APPLICATION, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR | LR_DEFAULTSIZE);
			ico = Icon.fromHICON(hIco);
		}

		return ico;
	}

	@property public static Icon asterisk()
	{
		static Icon ico;

		if(!ico)
		{
			HICON hIco = loadImage(null, IDI_ASTERISK, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR | LR_DEFAULTSIZE);
			ico = Icon.fromHICON(hIco);
		}

		return ico;
	}

	@property public static Icon error()
	{
		static Icon ico;

		if(!ico)
		{
			HICON hIco = loadImage(null, IDI_ERROR, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR | LR_DEFAULTSIZE);
			ico = Icon.fromHICON(hIco);
		}

		return ico;
	}

	@property public static Icon question()
	{
		static Icon ico;

		if(!ico)
		{
			HICON hIco = loadImage(null, IDI_QUESTION, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR | LR_DEFAULTSIZE);
			ico = Icon.fromHICON(hIco);
		}

		return ico;
	}

	@property public static Icon warning()
	{
		static Icon ico;

		if(!ico)
		{
			HICON hIco = loadImage(null, IDI_WARNING, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR | LR_DEFAULTSIZE);
			ico = Icon.fromHICON(hIco);
		}

		return ico;
	}
}

final class SystemBrushes
{
	@property public static SolidBrush blackBrush()
	{
		return SolidBrush.fromHBRUSH(GetStockObject(BLACK_BRUSH), false);
	}

	@property public static SolidBrush darkGrayBrush()
	{
		return SolidBrush.fromHBRUSH(GetStockObject(DKGRAY_BRUSH), false);
	}

	@property public static SolidBrush grayBrush()
	{
		return SolidBrush.fromHBRUSH(GetStockObject(GRAY_BRUSH), false);
	}

	@property public static SolidBrush lightGrayBrush()
	{
		return SolidBrush.fromHBRUSH(GetStockObject(LTGRAY_BRUSH), false);
	}

	@property public static SolidBrush nullBrush()
	{
		return SolidBrush.fromHBRUSH(GetStockObject(NULL_BRUSH), false);
	}

	@property public static SolidBrush whiteBrush()
	{
		return SolidBrush.fromHBRUSH(GetStockObject(WHITE_BRUSH), false);
	}

	@property public static SolidBrush brush3DdarkShadow()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_3DDKSHADOW), false);
	}

	@property public static SolidBrush brush3Dface()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_3DFACE), false);
	}

	@property public static SolidBrush brushBtnFace()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_BTNFACE), false);
	}

	@property public static SolidBrush brush3DLight()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_3DLIGHT), false);
	}

	@property public static SolidBrush brush3DShadow()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_3DSHADOW), false);
	}

	@property public static SolidBrush brushActiveBorder()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_ACTIVEBORDER), false);
	}

	@property public static SolidBrush brushActiveCaption()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_3DLIGHT), false);
	}

	@property public static SolidBrush brushAppWorkspace()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_APPWORKSPACE), false);
	}

	@property public static SolidBrush brushBackground()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_BACKGROUND), false);
	}

	@property public static SolidBrush brushBtnText()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_BTNTEXT), false);
	}

	@property public static SolidBrush brushCaptionText()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_CAPTIONTEXT), false);
	}

	@property public static SolidBrush brushGrayText()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_GRAYTEXT), false);
	}

	@property public static SolidBrush brushHighLight()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_HIGHLIGHT), false);
	}

	@property public static SolidBrush brushHighLightText()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_HIGHLIGHTTEXT), false);
	}

	@property public static SolidBrush brushInactiveBorder()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_INACTIVEBORDER), false);
	}

	@property public static SolidBrush brushInactiveCaption()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_INACTIVECAPTION), false);
	}

	@property public static SolidBrush brushInactiveCaptionText()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_INACTIVECAPTIONTEXT), false);
	}

	@property public static SolidBrush brushInfoBk()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_INFOBK), false);
	}

	@property public static SolidBrush brushInfoText()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_INFOTEXT), false);
	}

	@property public static SolidBrush brushMenu()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_MENU), false);
	}

	@property public static SolidBrush brushMenuText()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_MENUTEXT), false);
	}

	@property public static SolidBrush brushScrollBar()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_SCROLLBAR), false);
	}

	@property public static SolidBrush brushWindow()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_WINDOW), false);
	}

	@property public static SolidBrush brushWindowFrame()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_WINDOW), false);
	}

	@property public static SolidBrush brushWindowText()
	{
		return SolidBrush.fromHBRUSH(GetSysColorBrush(COLOR_WINDOWTEXT), false);
	}
}

final class SystemFonts
{
	@property public static Font windowsFont()
	{
		static Font f;

		if(!f)
		{
			NONCLIENTMETRICSW ncm = void; //La inizializza sotto.
			ncm.cbSize = NONCLIENTMETRICSW.sizeof;

			if(SystemParametersInfoW(SPI_GETNONCLIENTMETRICS, NONCLIENTMETRICSW.sizeof, &ncm, 0))
			{
				f = Font.fromHFONT(createFontIndirect(&ncm.lfMessageFont));
			}
			else
			{
				f = SystemFonts.ansiVarFont;
			}
		}

		return f;
	}

	@property public static Font ansiFixedFont()
	{
		static Font f;

		if(!f)
		{
			f = Font.fromHFONT(GetStockObject(ANSI_FIXED_FONT));
		}

		return f;
	}

	@property public static Font ansiVarFont()
	{
		static Font f;

		if(!f)
		{
			f = Font.fromHFONT(GetStockObject(ANSI_VAR_FONT));
		}

		return f;
	}

	@property public static Font deviceDefaultFont()
	{
		static Font f;

		if(!f)
		{
			f = Font.fromHFONT(GetStockObject(DEVICE_DEFAULT_FONT));
		}

		return f;
	}

	@property public static Font oemFixedFont()
	{
		static Font f;

		if(!f)
		{
			f = Font.fromHFONT(GetStockObject(OEM_FIXED_FONT));
		}

		return f;
	}

	@property public static Font systemFont()
	{
		static Font f;

		if(!f)
		{
			f = Font.fromHFONT(GetStockObject(SYSTEM_FONT));
		}

		return f;
	}

	@property public static Font systemFixedFont()
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
	@property public static Cursor appStarting()
	{
		static Cursor c;

		if(!c)
		{
			 c = Cursor.fromHCURSOR(loadImage(getHInstance(), IDC_APPSTARTING, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	@property public static Cursor arrow()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(loadImage(null, IDC_ARROW, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	@property public static Cursor cross()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(loadImage(null, cast(wchar*)IDC_CROSS, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	@property public static Cursor ibeam()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(loadImage(null, IDC_IBEAM, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	@property public static Cursor icon()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(loadImage(null, IDC_ICON, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	@property public static Cursor no()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(loadImage(null, IDC_NO, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	@property public static Cursor sizeALL()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(loadImage(null, IDC_SIZEALL, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	@property public static Cursor sizeNESW()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(loadImage(null, IDC_SIZENESW, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	@property public static Cursor sizeNS()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(loadImage(null, IDC_SIZENS, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	@property public static Cursor sizeNWSE()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(loadImage(null, IDC_SIZENWSE, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	@property public static Cursor sizeWE()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(loadImage(null, IDC_SIZEWE, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	@property public static Cursor upArrow()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(loadImage(null, IDC_UPARROW, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}

	@property public static Cursor wait()
	{
		static Cursor c;

		if(!c)
		{
			c = Cursor.fromHCURSOR(loadImage(null, IDC_WAIT, IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE | LR_DEFAULTCOLOR | LR_SHARED), false);
		}

		return c;
	}
}

final class SystemColors
{
	@property public static Color red()
	{
		return Color(0xFF, 0x00, 0x00);
	}

	@property public static Color green()
	{
		return Color(0x00, 0xFF, 0x00);
	}

	@property public static Color blue()
	{
		return Color(0x00, 0x00, 0xFF);
	}

	@property public static Color black()
	{
		return Color(0x00, 0x00, 0x00);
	}

	@property public static Color white()
	{
		return Color(0xFF, 0xFF, 0xFF);
	}

	@property public static Color yellow()
	{
		return Color(0xFF, 0xFF, 0x00);
	}

	@property public static Color magenta()
	{
		return Color(0xFF, 0x00, 0xFF);
	}

	@property public static Color magicPink()
	{
		return SystemColors.magenta; //Is 'Magic Pink'
	}

	@property public static Color cyan()
	{
		return Color(0x00, 0xFF, 0xFF);
	}

	@property public static Color darkGray()
	{
		return Color(0xA9, 0xA9, 0xA9);
	}

	@property public static Color lightGray()
	{
		return Color(0xD3, 0xD3, 0xD3);
	}

	@property public static Color darkRed()
	{
		return Color(0x8B, 0x00, 0x00);
	}

	@property public static Color darkGreen()
	{
		return Color(0x00, 0x64, 0x00);
	}

	@property public static Color darkBlue()
	{
		return Color(0x00, 0x00, 0x8B);
	}

	@property public static Color darkYellow()
	{
		return Color(0x00, 0x80, 0x80);
	}

	@property public static Color darkMagenta()
	{
		return Color(0x80, 0x00, 0x80);
	}

	@property public static Color darkCyan()
	{
		return Color(0x80, 0x80, 0x00);
	}

	@property public static Color transparent()
	{
		return Color(0x00, 0x00, 0x00, 0x00);
	}

	@property public static Color color3DdarkShadow()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_3DDKSHADOW));
	}

	@property public static Color color3Dface()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_3DFACE));
	}

	@property public static Color colorBtnFace()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_BTNFACE));
	}

	@property public static Color color3DLight()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_3DLIGHT));
	}

	@property public static Color color3DShadow()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_3DSHADOW));
	}

	@property public static Color colorActiveBorder()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_ACTIVEBORDER));
	}

	@property public static Color colorActiveCaption()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_3DLIGHT));
	}

	@property public static Color colorAppWorkspace()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_APPWORKSPACE));
	}

	@property public static Color colorBackground()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_BACKGROUND));
	}

	@property public static Color colorBtnText()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_BTNTEXT));
	}

	@property public static Color colorCaptionText()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_CAPTIONTEXT));
	}

	@property public static Color colorGrayText()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_GRAYTEXT));
	}

	@property public static Color colorHighLight()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_HIGHLIGHT));
	}

	@property public static Color colorHighLightText()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_HIGHLIGHTTEXT));
	}

	@property public static Color colorInactiveBorder()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_INACTIVEBORDER));
	}

	@property public static Color colorInactiveCaption()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_INACTIVECAPTION));
	}

	@property public static Color colorInactiveCaptionText()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_INACTIVECAPTIONTEXT));
	}

	@property public static Color colorInfoBk()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_INFOBK));
	}

	@property public static Color colorInfoText()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_INFOTEXT));
	}

	@property public static Color colorMenu()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_MENU));
	}

	@property public static Color colorMenuText()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_MENUTEXT));
	}

	@property public static Color colorScrollBar()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_SCROLLBAR));
	}

	@property public static Color colorWindow()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_WINDOW));
	}

	@property public static Color colorWindowFrame()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_WINDOW));
	}

	@property public static Color colorWindowText()
	{
		return Color.fromCOLORREF(GetSysColor(COLOR_WINDOWTEXT));
	}
}

final class TextFormat
{
	private TextTrimming _trim = TextTrimming.NONE; // TextTrimming.CHARACTER.
	private TextFormatFlags _flags = TextFormatFlags.NO_PREFIX | TextFormatFlags.WORD_BREAK;
	private TextAlignment _align = TextAlignment.LEFT;
	private DRAWTEXTPARAMS _params = {DRAWTEXTPARAMS.sizeof, 8, 0, 0};

	public this()
	{

	}

	public this(TextFormat tf)
	{
		this._trim = tf._trim;
		this._flags = tf._flags;
		this._align = tf._align;
		this._params = tf._params;
	}

	public this(TextFormatFlags tff)
	{
		this._flags = tff;
	}

	@property public TextAlignment alignment()
	{
		return this._align;
	}

	@property public void alignment(TextAlignment ta)
	{
		this._align = ta;
	}

	@property public void formatFlags(TextFormatFlags tff)
	{
		this._flags = tff;
	}

	@property public TextFormatFlags formatFlags()
	{
		return this._flags;
	}

	@property public void trimming(TextTrimming tt)
	{
		this._trim = tt;
	}

	@property public TextTrimming trimming()
	{
		return this._trim;
	}

	@property public int tabLength()
	{
		return _params.iTabLength;
	}

	@property public void tabLength(int tablen)
	{
		this._params.iTabLength = tablen;
	}

	@property public int leftMargin()
	{
		return this._params.iLeftMargin;
	}

	@property public void leftMargin(int sz)
	{
		this._params.iLeftMargin = sz;
	}

	@property public int rightMargin()
	{
		return this._params.iRightMargin;
	}

	@property public void rightMargin(int sz)
	{
		this._params.iRightMargin = sz;
	}
}

final class Screen
{
	@property public static Size size()
	{
		Size sz = void; //Inizializzata sotto

		sz.width = GetSystemMetrics(SM_CXSCREEN);
		sz.height = GetSystemMetrics(SM_CYSCREEN);

		return sz;
	}

	@property public static Rect workArea()
	{
		Rect r = void; //Inizializzata sotto

		SystemParametersInfoW(SPI_GETWORKAREA, 0, &r.rect, 0);
		return r;
	}

	@property public static Canvas canvas()
	{
		return Canvas.fromHDC(GetWindowDC(null));
	}
}
