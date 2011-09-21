﻿/*
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

/* ANSI <-> UNICODE bridge module */

module dgui.core.charset;

import std.array;
import std.conv: to;
import std.utf: toUTFz;
import dgui.core.winapi;
import dgui.core.utils;

/**
  * $(B) Unicode Wrapper of CreateWindowEx API $(B)
  */
public HWND createWindowEx(DWORD exStyle, string className, string windowName, DWORD style,
					       int x, int y, int nWidth, int nHeight, HWND hWndParent, LPVOID lpParam)
{
	return CreateWindowExW(exStyle, toUTFz!(wchar*)(className), toUTFz!(wchar*)(windowName), style, x, y,
						   nWidth, nHeight, hWndParent, null, getHInstance(), lpParam);
}

public BOOL getClassInfoEx(string className, WNDCLASSEXW* pWndClassEx)
{
	return GetClassInfoExW(getHInstance(), toUTFz!(wchar*)(className), pWndClassEx);
}

public string getModuleFileName(HMODULE hModule)
{
	wchar[MAX_PATH + 1] path = void;

	int len = GetModuleFileNameW(hModule, path.ptr, path.length);
	return to!(string)(path[0..len]);
}

public HICON extractAssociatedIcon(string s, WORD* pIcon)
{
	return ExtractAssociatedIconW(getHInstance(), toUTFz!(wchar*)(s), pIcon);
}

public HANDLE loadImage(HINSTANCE hInstance, string s, UINT uType, int cxDesired, int cyDesired, UINT fuLoad)
{
	return LoadImageW(hInstance, toUTFz!(wchar*)(s), uType, cxDesired, cyDesired, fuLoad);
}

public HANDLE loadImage(HINSTANCE hInstance, wchar* pResID, UINT uType, int cxDesired, int cyDesired, UINT fuLoad)
{
	return LoadImageW(hInstance, pResID, uType, cxDesired, cyDesired, fuLoad);
}

public int drawTextEx(HDC hdc, string s, RECT* lprc, UINT dwDTFormat, DRAWTEXTPARAMS* lpDTParams)
{
	return DrawTextExW(hdc, toUTFz!(wchar*)(s), -1, lprc, dwDTFormat, lpDTParams);
}

public HMODULE loadLibrary(string s)
{
	return LoadLibraryW(toUTFz!(wchar*)(s));
}

public HMODULE getModuleHandle(string s)
{
	return GetModuleHandleW(toUTFz!(wchar*)(s));
}

public void getTempPath(ref string s)
{
	wchar[MAX_PATH + 1] path = void;

	int len = GetTempPathW(MAX_PATH, path.ptr);
	s = to!(string)(path[0..len]);
}

public int getWindowTextLength(HWND hWnd)
{
	return GetWindowTextLengthW(hWnd);
}

public string getWindowText(HWND hWnd)
{
	int len = getWindowTextLength(hWnd);

	if(!len)
	{
		return null;
	}

	len++;

	wchar[] t = new wchar[len];
	len = GetWindowTextW(hWnd, t.ptr, len);
	return to!(string)(t[0..len]);
}

public BOOL setWindowText(HWND hWnd, string s)
{
	return SetWindowTextW(hWnd, toUTFz!(wchar*)(s));
}

public HFONT createFontIndirect(LOGFONTW* lf)
{
	return CreateFontIndirectW(lf);
}

public HFONT createFontIndirect(string s, LOGFONTW* lf)
{
	if(s.length >= LF_FACESIZE)
	{
		s = s[0..LF_FACESIZE - 1];
	}

	wstring ws = to!(wstring)(s);

	foreach(int i, wchar wch; ws)
	{
		lf.lfFaceName[i] = wch;
	}

	lf.lfFaceName[ws.length] = '\0';

	return CreateFontIndirectW(lf);
}

public DWORD getClassLong(HWND hWnd, int nIndex)
{
	return GetClassLongW(hWnd, nIndex);
}

public DWORD setWindowLong(HWND hWnd, int nIndex, LONG dwNewLong)
{
	return SetWindowLongW(hWnd, nIndex, dwNewLong);
}

public LONG getWindowLong(HWND hWnd, int nIndex)
{
	return GetWindowLongW(hWnd, nIndex);
}

public ATOM registerClassEx(string className, HCURSOR hCursor, HBRUSH hBackground, WNDPROC wndProc, uint style)
{
	WNDCLASSEXW wc;

	wc.cbSize = WNDCLASSEXW.sizeof;
	wc.lpszClassName = toUTFz!(wchar*)(className);
	wc.hCursor = hCursor;
	wc.hInstance = getHInstance();
	wc.hbrBackground = hBackground;
	wc.lpfnWndProc = wndProc;
	wc.style = style;

	return RegisterClassExW(&wc);
}

public ATOM registerClassEx(WNDCLASSEXW* wc)
{
	return RegisterClassExW(wc);
}
