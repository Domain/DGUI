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

module dgui.core.utils;

import std.path;
import dgui.core.winapi;
import dgui.core.charset;

T winCast(T)(Object o)
{
	return cast(T)(cast(void*)o);
}

T winCast(T)(size_t st)
{
	return cast(T)(cast(void*)st);
}

HINSTANCE getHInstance()
{
	static HINSTANCE hInst = null;

	if(!hInst)
	{
		hInst = GetModuleHandleW(null);
	}

	return hInst;
}

string getExecutablePath()
{
	static string exePath;

	if(!exePath.length)
	{
		exePath = getModuleFileName(null);
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
		dgui.core.charset.getTempPath(tempPath);
	}

	return tempPath;
}

string makeFilter(string userFilter)
{
	char[] newFilter = cast(char[])userFilter;

	foreach(ref char ch; newFilter)
	{
		if(ch == '|')
		{
			ch = '\0';
		}
	}

	newFilter ~= '\0';
	return newFilter.idup;
}

/*
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
*/
