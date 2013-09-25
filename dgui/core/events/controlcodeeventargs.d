/** DGui project file.

Copyright: Trogu Antonio Davide 2011-2013

License: $(HTTP boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Trogu Antonio Davide
*/
module dgui.core.events.controlcodeeventargs;

public import dgui.core.events.eventargs;
public import dgui.core.winapi;

enum ControlCode: uint
{
	IGNORE					= 0,
	BUTTON 			    	= DLGC_BUTTON,
	DEFAULT_PUSH_BUTTON 	= DLGC_DEFPUSHBUTTON,
	HAS_SETSEL				= DLGC_HASSETSEL,
	RADIO_BUTTON			= DLGC_RADIOBUTTON,
	STATIC					= DLGC_STATIC,
	NO_DEFAULT_PUSH_BUTTON  = DLGC_UNDEFPUSHBUTTON,
	WANT_ALL_KEYS			= DLGC_WANTALLKEYS,
	WANT_ARROWS				= DLGC_WANTARROWS,
	WANT_CHARS				= DLGC_WANTCHARS,
	WANT_TAB				= DLGC_WANTTAB,
}

class ControlCodeEventArgs: EventArgs
{
	private ControlCode _ctrlCode = ControlCode.IGNORE;

	@property public ControlCode controlCode()
	{
		return this._ctrlCode;
	}

	@property public void controlCode(ControlCode cc)
	{
		this._ctrlCode = cc;
	}
}
