module dgui.core.utils;

public import dgui.core.winapi;
public import dgui.canvas;
import std.string;
import std.stdio;
import std.path;

public bool compareGUID(GUID* g1, GUID* g2)
{
	if(g1.Data1 != g2.Data1)
	{
		return false;
	}

	if(g1.Data2 != g2.Data2)
	{
		return false;
	}

	if(g1.Data3 != g2.Data3)
	{
		return false;
	}

	for(int i = 0; i < g1.Data4.length; i++)
	{
		if(g1.Data4[i] != g2.Data4[i])
		{
			return false;
		}
	}

	return true;
}

T winCast(T)(Object o)
{
	return cast(T)(cast(void*)o);
}

T winCast(T)(size_t st)
{
	return cast(T)(cast(void*)st);
}

void copyBitmap(Canvas dest, Canvas src, Bitmap bmp, Size sz)
{
	HDC destDc = dest.getHDC();
	HDC srcDc = src.getHDC();

	HBITMAP hOldBmp = SelectObject(srcDc, bmp.handle);
	BitBlt(destDc, 0, 0, sz.width, sz.height, srcDc, 0, 0, SRCCOPY);
	SelectObject(srcDc, hOldBmp);

	src.releaseDC();
	dest.releaseDC();
}

void fastFillBlack(Canvas c, Size sz)
{
	HDC hdc = c.getHDC();

	BitBlt(hdc, 0, 0, sz.width, sz.height, null, 0, 0, BLACKNESS);
	c.releaseDC();
}

HINSTANCE getHInstance()
{
	static HINSTANCE hInst = null;

	if(!hInst)
	{
		hInst = GetModuleHandleA(null);
	}

	return hInst;
}

string getExecutablePath()
{
	static string exePath;

	if(!exePath.length)
	{
		char[] path = new char[MAX_PATH];

		GetModuleFileNameA(null, path.ptr, path.length);
		exePath = toString(path.ptr);
	}

	return exePath;
}

string getStartupPath()
{
	static string startPath;

	if(!startPath.length)
	{
		startPath = getDirName(getExecutablePath());
	}

	return startPath;
}

string getTempPath()
{
	static string tempPath;

	if(!tempPath.length)
	{
		char[] path = new char[MAX_PATH];

		GetTempPathA(MAX_PATH, path.ptr);
		tempPath = toString(path.ptr);
	}

	return tempPath;
}

string makeFilter(string userFilter)
{
	char[] newFilter = userFilter;

	foreach(ref char ch; newFilter)
	{
		if(ch == '|')
		{
			ch = '\0';
		}
	}

	newFilter ~= '\0';
	return newFilter;
}

string recalcString(string s)
{
	return std.string.toString(s.ptr);
}

class ObjectContainer(T)
{
	private T _t;

	public this(T t)
	{
		this._t = t;
	}

	public final T get()
	{
		return this._t;
	}

	static if(is(T: string))
	{
		public override string toString()
		{
			return this._t;
		}
	}
}
