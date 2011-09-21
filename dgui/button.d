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

module dgui.button;

import dgui.core.controls.abstractbutton;

/// Standarde windows _Button
class Button: AbstractButton
{
	/**
	  Returns:
		A DialogResult enum (OK, IGNORE, CLOSE, YES, NO, CANCEL, ...)

	See_Also:
		Form.showDialog()
	  */
	@property public DialogResult dialogResult()
	{
		return this._dr;
	}

	/**
	  Sets DialogResult for a button

	  Params:
		dr = DialogResult of the button.

	  See_Also:
		Form.showDialog()
	  */
	@property public void dialogResult(DialogResult dr)
	{
		this._dr = dr;
	}

	protected override void createControlParams(ref CreateControlParams ccp)
	{
		ccp.Style |= BS_DEFPUSHBUTTON;
		ccp.ClassName = WC_DBUTTON;

		super.createControlParams(ccp);
	}
}

/// Standard windows _CheckBox
class CheckBox: CheckedButton
{
	protected override void createControlParams(ref CreateControlParams ccp)
	{
		ccp.Style |= BS_AUTOCHECKBOX;
		ccp.ClassName = WC_DCHECKBOX;

		super.createControlParams(ccp);
	}
}

/// Standard windows _RadioButton
class RadioButton: CheckedButton
{
	protected override void createControlParams(ref CreateControlParams ccp)
	{
		ccp.Style |= BS_AUTORADIOBUTTON;
		ccp.ClassName = WC_DRADIOBUTTON;

		super.createControlParams(ccp);
	}
}
