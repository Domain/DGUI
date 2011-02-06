module dgui.core.exception;

public import dgui.core.winapi;
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
