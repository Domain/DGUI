/** DGui project file.

Copyright: Trogu Antonio Davide 2011-2013

License: $(HTTP boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Trogu Antonio Davide
*/
module dgui.core.events.focuseventargs;

public import dgui.core.events.eventargs;

class FocusEventArgs: EventArgs
{
	private bool _focused;

	public this(bool fcs)
	{
		this._focused = fcs;
	}

	@property bool focused()
	{
		return this._focused;
	}
}
