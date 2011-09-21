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

module dgui.core.events.mouseeventargs;

public import dgui.core.events.eventargs;
import dgui.core.geometry;
import dgui.core.winapi;

enum MouseWheel: ubyte
{
	UP,
	DOWN,
}

enum MouseKeys: uint
{
	NONE   = 0, // No mouse buttons specified.

	// Standard mouse keys
	LEFT   = MK_LBUTTON,
	RIGHT  = MK_RBUTTON,
	MIDDLE = MK_MBUTTON,

	// Windows 2000+
	//XBUTTON1 = 0x0800000,
	//XBUTTON2 = 0x1000000,
}

class MouseEventArgs: EventArgs
{
	private MouseKeys _mKeys;
	private Point _cursorPos;

	public this(Point cursorPos, MouseKeys mk)
	{
		this._cursorPos = cursorPos;
		this._mKeys = mk;
	}

	@property public Point location()
	{
		return this._cursorPos;
	}

	@property public MouseKeys keys()
	{
		return this._mKeys;
	}
}

class MouseWheelEventArgs: MouseEventArgs
{
	private MouseWheel _mw;

	public this(Point cursorPos, MouseKeys mk, MouseWheel mw)
	{
		this._mw = mw;

		super(cursorPos, mk);
	}

	@property public MouseWheel wheel()
	{
		return this._mw;
	}
}
