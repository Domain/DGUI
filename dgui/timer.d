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

module dgui.timer;

import std.string;
import dgui.core.winapi;
import dgui.core.idisposable;
import dgui.core.signal;
import dgui.core.events;
import dgui.core.exception;

final class Timer: IDisposable
{
	private alias Timer[uint] TimerMap;

	public Signal!(Timer, EventArgs) tick;

	private static TimerMap _timers;
	private uint _timerId = 0;
	private uint _time = 0;

	public ~this()
	{
		this.dispose();
	}

	extern(Windows) private static void timerProc(HWND hwnd, uint msg, uint idEvent, uint t)
	{
		if(idEvent in _timers)
		{
			_timers[idEvent].onTick(EventArgs.empty);
		}
		else
		{
			debug
			{
				throw new Win32Exception(format("Unknown Timer: %08X", idEvent), __FILE__, __LINE__);
			}
			else
			{
				throw new Win32Exception(format("Unknown Timer: %08X", idEvent));
			}
		}
	}

	public void dispose()
	{
		if(this._timerId)
		{
			if(!KillTimer(null, this._timerId))
			{
				debug
				{
					throw new Win32Exception("Cannot Dispose Timer", __FILE__, __LINE__);
				}
				else
				{
					throw new Win32Exception("Cannot Dispose Timer");
				}
			}

			_timers.remove(this._timerId);
			this._timerId = 0;
		}
	}

	@property public uint time()
	{
		return this._time;
	}

	@property public void time(uint t)
	{
		this._time = t >= 0 ? t : t * (-1); //Take the absolute value.
	}

	public void start()
	{
		if(!this._timerId)
		{
			this._timerId = SetTimer(null, 0, this._time, &Timer.timerProc);

			if(!this._timerId)
			{
				debug
				{
					throw new Win32Exception("Cannot Start Timer", __FILE__, __LINE__);
				}
				else
				{
					throw new Win32Exception("Cannot Start Timer");
				}
			}

			this._timers[this._timerId] = this;
		}
	}

	public void stop()
	{
		this.dispose();
	}

	private void onTick(EventArgs e)
	{
		this.tick(this, e);
	}
}
