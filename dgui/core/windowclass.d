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

import std.utf;
import std.string;
import dgui.core.charset;
import dgui.core.winapi;
import dgui.core.exception;
import dgui.core.utils;
import dgui.core.enums;
import dgui.canvas;

private alias WNDPROC[string] ClassMap; //Keeps original window procedure addresses: [OrgClassName | OrgWndProc]

public void registerWindowClass(string className, ClassStyles classStyle, Cursor cursor, WNDPROC wndProc)
{
	WNDCLASSEXW wc;

	wc.cbSize = WNDCLASSEXW.sizeof;
	bool found = cast(bool)getClassInfoEx(className, &wc);

	if(!found)
	{
		if(!registerClassEx(className, cursor ? cursor.handle : SystemCursors.arrow.handle,
						    SystemBrushes.brushBtnFace.handle, wndProc, classStyle))
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
	static ClassMap classMap;
	WNDCLASSEXW oldWc = void, newWc = void;

	oldWc.cbSize = WNDCLASSEXW.sizeof;
	newWc.cbSize = WNDCLASSEXW.sizeof;

	//const(char)* pOldClassName = toUTF16z(oldClassName);
	const(wchar)* pNewClassName = toUTF16z(newClassName);

	if(!getClassInfoEx(newClassName, &newWc)) // IF Class Non Found THEN
	{
		// Super Classing
		getClassInfoEx(oldClassName, &oldWc);

		//Keep the original window procedure in a map
		classMap[oldClassName] = oldWc.lpfnWndProc;

		newWc = oldWc;
		newWc.style &= ClassStyles.PARENTDC | (~ClassStyles.GLOBALCLASS);
		newWc.lpfnWndProc = newWndProc;
		newWc.lpszClassName = pNewClassName;
		newWc.hInstance = getHInstance();
		//newWc.hbrBackground = null;

		if(!RegisterClassExW(&newWc))
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

	return classMap[oldClassName]; //Back to the original window procedure
}
