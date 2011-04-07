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

module dgui.core.windowclass;

import std.string;
import dgui.core.winapi;
import dgui.core.exception;
import dgui.core.utils;
import dgui.core.enums;
import dgui.canvas;

private alias WNDPROC[string] ClassMap; //Tiene traccia delle window procedure originali: [OrgClassName | OrgWndProc]

public void registerWindowClass(string className, ClassStyles classStyle, Cursor cursor, WNDPROC wndProc)
{
	static HINSTANCE hInst;
	WNDCLASSEXA wc;

	if(!hInst)
	{
		hInst = getHInstance();
	}

	bool found = cast(bool)GetClassInfoExA(hInst, toStringz(className), &wc);

	if(!found)
	{
		wc.cbSize = WNDCLASSEXA.sizeof;
		wc.lpszClassName = toStringz(className);
		wc.hCursor = cursor ? cursor.handle : SystemCursors.arrow.handle;
		wc.hInstance = hInst;
		wc.hbrBackground = SystemBrushes.brushBtnFace.handle;
		wc.lpfnWndProc = wndProc;
		wc.style = classStyle;

		if(!RegisterClassExA(&wc))
		{
			debug
			{
				throw new Win32Exception(format("Windows Class \"%s\" not created", className), __FILE__, __LINE__);
			}
			else
			{
				throw new Win32Exception(format("Windows Class \"%s\" not created", className));
			}
		}
	}
}

public WNDPROC superClassWindowClass(string oldClassName, string newClassName, WNDPROC newWndProc)
{
	static HINSTANCE hInst;
	static ClassMap classMap;
	WNDCLASSEXA oldWc = void, newWc = void; //Non serve inizializzarli

	if(!hInst)
	{
		hInst = getHInstance();
	}

	oldWc.cbSize = WNDCLASSEXA.sizeof;
	newWc.cbSize = WNDCLASSEXA.sizeof;

	immutable(char)* pOldClassName = toStringz(oldClassName);
	immutable(char)* pNewClassName = toStringz(newClassName);

	if(!GetClassInfoExA(hInst, pNewClassName, &newWc)) // IF Classe Non Trovata THEN
	{
		// Super Classing
		GetClassInfoExA(hInst, pOldClassName, &oldWc);

		//Salvo la window procedure originale nella ClassMap
		classMap[oldClassName] = oldWc.lpfnWndProc;

		newWc = oldWc;
		newWc.style &= ClassStyles.PARENTDC | (~ClassStyles.GLOBALCLASS);
		newWc.lpfnWndProc = newWndProc;
		newWc.lpszClassName = pNewClassName;
		newWc.hInstance = hInst;
		//newWc.hbrBackground = null; //Lo disegno io (se serve).

		if(!RegisterClassExA(&newWc))
		{
			debug
			{
				throw new Win32Exception(format("Windows Class \"%s\" not created", newClassName), __FILE__, __LINE__);
			}
			else
			{
				throw new Win32Exception(format("Windows Class \"%s\" not created", newClassName));
			}
		}
	}

	return classMap[oldClassName]; //Ritorno la Window Procedure Originale
}
