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

/* ANSI <-> UNICODE bridge module */

module dgui.core.charset;

import std.utf: toUTF16z, toUTF8;
import std.c.wcharh: wcscpy;
import dgui.core.winapi;
import dgui.core.utils;

/**
  * $(B) Unicode Wrapper of CreateWindowEx API $(B)
  */
public HWND createWindowEx(DWORD exStyle, string className, string windowName, DWORD style,
					       int x, int y, int nWidth, int nHeight, HWND hWndParent, LPVOID lpParam)
{
	return CreateWindowExW(exStyle, toUTF16z(className), toUTF16z(windowName), style, x, y,
						   nWidth, nHeight, hWndParent, null, getHInstance(), lpParam);
}

public BOOL getClassInfoEx(string className, WNDCLASSEXW* pWndClassEx)
{
	return GetClassInfoExW(getHInstance(), toUTF16z(className), pWndClassEx);
}

public string getModuleFileName(HMODULE hModule)
{
	wchar[] path = new wchar[MAX_PATH];

	int res = GetModuleFileNameW(hModule, path.ptr, path.length);
	return toUTF8(path);
}

public BOOL extTextOut(HDC hdc, int x, int y, UINT fuOptions, RECT* lprc, string s, uint cbCount, int* lpDx)
{
	return ExtTextOutW(hdc, x, y, fuOptions, lprc, toUTF16z(s), cbCount, lpDx);
}

public HICON extractAssociatedIcon(string s, WORD* pIcon)
{
	return ExtractAssociatedIconW(getHInstance(), toUTF16z(s), pIcon);
}

public HANDLE loadImage(HINSTANCE hInstance, string s, UINT uType, int cxDesired, int cyDesired, UINT fuLoad)
{
	return LoadImageW(hInstance, toUTF16z(s), uType, cxDesired, cyDesired, fuLoad);
}

public HANDLE loadImage(HINSTANCE hInstance, wchar* pResID, UINT uType, int cxDesired, int cyDesired, UINT fuLoad)
{
	return LoadImageW(hInstance, pResID, uType, cxDesired, cyDesired, fuLoad);
}

public int drawTextEx(HDC hdc, string s, RECT* lprc, UINT dwDTFormat, DRAWTEXTPARAMS* lpDTParams)
{
	return DrawTextExW(hdc, toUTF16z(s), -1, lprc, dwDTFormat, lpDTParams);
}

public HMODULE loadLibrary(string s)
{
	return LoadLibraryW(toUTF16z(s));
}

public HMODULE getModuleHandle(string s)
{
	return GetModuleHandleW(toUTF16z(s));
}

public void getTempPath(ref string s)
{
	wchar[] path = new wchar[MAX_PATH];

	int len = GetTempPathW(MAX_PATH, path.ptr);
	s = toUTF8(path[0..len]);
}

public int getWindowTextLength(HWND hWnd)
{
	return GetWindowTextLengthW(hWnd);
}

public string getWindowText(HWND hWnd)
{
	int len = getWindowTextLength(hWnd) + 1;
	wchar[] t = new wchar[len];

	GetWindowTextW(hWnd, t.ptr, len);
	return toUTF8(t);
}

public BOOL setWindowText(HWND hWnd, string s)
{
	return SetWindowTextW(hWnd, toUTF16z(s));
}

public HFONT createFontIndirect(LOGFONTW* lf)
{
	return CreateFontIndirectW(lf);
}

public HFONT createFontIndirect(string s, LOGFONTW* lf)
{
	wcscpy(lf.lfFaceName.ptr, toUTF16z(s));
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
	wc.lpszClassName = toUTF16z(className);
	wc.hCursor = hCursor;
	wc.hInstance = getHInstance();
	wc.hbrBackground = hBackground;
	wc.lpfnWndProc = wndProc;
	wc.style = style;

	return RegisterClassExW(&wc);
}
