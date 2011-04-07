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

module dgui.core.exception;

import dgui.core.winapi;
import std.windows.syserror;
import std.string;

class DGuiException: Exception
{
	debug
	{
		public this(string msg, string fileName, int line)
		{
			string err = format("File: %s(%d)\n%s", fileName, line, msg);
			super(err);
		}
	}
	else
	{
		public this(string msg)
		{
			super(msg);
		}
	}
}

class Win32Exception: Exception
{
	debug
	{
		public this(string msg, string fileName, int line)
		{
			string err = format("File: %s(%d)\n%s\n\nWindows Error Message: %s", fileName, line, msg, sysErrorString(GetLastError()));
			super(err);
		}
	}
	else
	{
		public this(string m)
		{
			string err = format("%s\n\nWindows Error Message:\n%s", m, sysErrorString(GetLastError()));
			super(err);
		}
	}
}

class RegistryException: Win32Exception
{
	debug
	{
		public this(string msg, string fileName, int line)
		{
			super(msg, fileName, line);
		}
	}
	else
	{
		public this(string m)
		{
			super(m);
		}
	}
}

class GdiException: Win32Exception
{
	debug
	{
		public this(string msg, string fileName, int line)
		{
			super(msg, fileName, line);
		}
	}
	else
	{
		public this(string m)
		{
			super(m);
		}
	}
}
