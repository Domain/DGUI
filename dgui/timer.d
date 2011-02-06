module dgui.timer;

import dgui.core.idisposable;
import dgui.core.signal;
import dgui.core.events;
import dgui.core.winapi;

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
			_timers.remove(this._timerId);
			this._timerId = 0;
		}
	}

	public uint time()
	{
		return this._time;
	}

	public void time(uint t)
	{
		this._time = t >= 0 ? t : t * (-1); //Se e' < 0 moltiplica per -1 cosi' torna positivo.
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
