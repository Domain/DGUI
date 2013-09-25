/** DGui project file.

Copyright: Trogu Antonio Davide 2011-2013

License: $(HTTP boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Trogu Antonio Davide
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
		switch(this._drawMode)
		{
			case OwnerDrawMode.NORMAL:
				this.setStyle(BS_DEFPUSHBUTTON, true);
				break;

			case OwnerDrawMode.FIXED, OwnerDrawMode.VARIABLE:
				this.setStyle(BS_OWNERDRAW, true);
				break;

			default:
				break;
		}

		ccp.ClassName = WC_DBUTTON;

		super.createControlParams(ccp);
	}
}

/// Standard windows _CheckBox
class CheckBox: CheckedButton
{
	protected override void createControlParams(ref CreateControlParams ccp)
	{
		switch(this._drawMode)
		{
			case OwnerDrawMode.NORMAL:
				this.setStyle(BS_AUTOCHECKBOX, true);
				break;

			case OwnerDrawMode.FIXED, OwnerDrawMode.VARIABLE:
				this.setStyle(BS_OWNERDRAW, true);
				break;

			default:
				break;
		}

		ccp.ClassName = WC_DCHECKBOX;

		super.createControlParams(ccp);
	}
}

/// Standard windows _RadioButton
class RadioButton: CheckedButton
{
	protected override void createControlParams(ref CreateControlParams ccp)
	{
		switch(this._drawMode)
		{
			case OwnerDrawMode.NORMAL:
				this.setStyle(BS_AUTORADIOBUTTON, true);
				break;

			case OwnerDrawMode.FIXED, OwnerDrawMode.VARIABLE:
				this.setStyle(BS_OWNERDRAW, true);
				break;

			default:
				break;
		}

		ccp.ClassName = WC_DRADIOBUTTON;

		super.createControlParams(ccp);
	}
}
