/** DGui project file.

Copyright: Trogu Antonio Davide 2011-2013

License: $(HTTP boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Trogu Antonio Davide
*/
module dgui.core.events.scrolleventargs;

public import dgui.core.events.eventargs;
import dgui.core.winapi;

enum ScrollMode: uint
{
	BOTTOM 		  = SB_BOTTOM,
	ENDSCROLL 	  = SB_ENDSCROLL,
	LINEDOWN  	  = SB_LINEDOWN,
	LINEUP 		  = SB_LINEUP,
	PAGEDOWN	  = SB_PAGEDOWN,
	PAGEUP 		  = SB_PAGEUP,
	THUMBPOSITION = SB_THUMBPOSITION,
	THUMBTRACK 	  = SB_THUMBTRACK,
	TOP 		  = SB_TOP,
	LEFT  		  = SB_LEFT,
	RIGHT 		  = SB_RIGHT,
	LINELEFT      = SB_LINELEFT,
	LINERIGHT 	  = SB_LINERIGHT,
	PAGELEFT 	  = SB_PAGELEFT,
	PAGERIGHT 	  = SB_PAGERIGHT,
}

enum ScrollWindowDirection: ubyte
{
	LEFT  = 0,
	UP    = 1,
	RIGHT = 2,
	DOWN  = 4,
}

enum ScrollDirection: ubyte
{
	VERTICAL,
	HORIZONTAL,
}

class ScrollEventArgs: EventArgs
{
	private ScrollDirection _dir;
	private ScrollMode _mode;

	public this(ScrollDirection sd, ScrollMode sm)
	{
		this._dir = sd;
		this._mode = sm;
	}

	@property public ScrollDirection direction()
	{
		return this._dir;
	}

	@property public ScrollMode mode()
	{
		return this._mode;
	}
}
