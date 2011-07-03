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

import dgui.control;

/**
  Enums that contain the check state of a _CheckBox or similar component
  */
enum CheckState: uint
{
	CHECKED = BST_CHECKED, 				///Checked State
	UNCHECKED = BST_UNCHECKED,			///Unchecked State
	INDETERMINATE = BST_INDETERMINATE,	///Indeterminate State
}

/// Abstract class of a _Button/_CheckBox/_RadioButton
abstract class AbstractButton: SubclassedControl
{
	private DialogResult _dr = DialogResult.NONE;

	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		pcw.Style |= WS_TABSTOP;
		pcw.OldClassName = WC_BUTTON;

		super.preCreateWindow(pcw);
	}

	@property protected override bool ownClickMsg()
	{
		return true;
	}

	protected override int onReflectedMessage(uint msg, WPARAM wParam, LPARAM lParam)
	{
		switch(msg)
		{
			case WM_COMMAND:
			{
				switch(HIWORD(wParam))
				{
					 case BN_CLICKED:
					 {
						MouseKeys mk = MouseKeys.NONE;

						if(GetAsyncKeyState(MK_LBUTTON))
						{
							mk |= MouseKeys.LEFT;
						}

						if(GetAsyncKeyState(MK_MBUTTON))
						{
							mk |= MouseKeys.MIDDLE;
						}

						if(GetAsyncKeyState(MK_RBUTTON))
						{
							mk |= MouseKeys.RIGHT;
						}

						Point p = Point(LOWORD(lParam), HIWORD(lParam));
						scope MouseEventArgs e = new MouseEventArgs(p, mk);
						this.onClick(EventArgs.empty);

						if(this._dr !is DialogResult.NONE)
						{
							IDialogResult iresult = cast(IDialogResult)this.topLevelControl;
							iresult.dialogResult = this._dr;
						}
					 }
					 break;

					default:
						break;
				}
			}
			break;

			default:
				break;
		}

		return super.onReflectedMessage(msg, wParam, lParam);
	}

	protected override int wndProc(uint msg, WPARAM wParam, LPARAM lParam)
	{
		switch(msg)
		{
			case WM_ERASEBKGND:
				return this.originalWndProc(msg, wParam, lParam);

			default:
				return super.wndProc(msg, wParam, lParam);
		}
	}
}

/// Abstract class of a checkable button (_CheckBox, _RadioButton, ...)
abstract class CheckedButton: AbstractButton
{
	public Signal!(Control, EventArgs) checkChanged; ///Checked Changed Event of a Checkable _Button

	private CheckState _checkState = CheckState.UNCHECKED;

	/**
	 Returns:
		True if the _Button is _checked otherwise False.

	 See_Also:
		checkState() property below.
	 */
	@property public bool checked()
	{
		return this.checkState is CheckState.CHECKED;
	}

	/**
	  Sets the checked state of a checkable _button

	  Params:
		True checks the _button, False unchecks it.
	  */
	@property public void checked(bool b)
	{
		this.checkState = b ? CheckState.CHECKED : CheckState.UNCHECKED;
	}

	/**
	  Returns:
		A CheckState enum that returns the state of the checkable button (it includes the indeterminate state too)
	  */
	@property public CheckState checkState()
	{
		if(this.created)
		{
			return cast(CheckState)this.sendMessage(BM_GETCHECK, 0, 0);
		}

		return this._checkState;
	}

	/**
	  Sets the check state of a checkable button
	  */
	@property public void checkState(CheckState cs)
	{
		this._checkState = cs;

		if(this.created)
		{
			this.sendMessage(BM_SETCHECK, cs, 0);
		}
	}

	protected override void onHandleCreated(EventArgs e)
	{
		this.sendMessage(BM_SETCHECK, this._checkState, 0);
		super.onHandleCreated(e);
	}

	protected override int onReflectedMessage(uint msg, WPARAM wParam, LPARAM lParam)
	{
		switch(msg)
		{
			case WM_COMMAND:
			{
				switch(HIWORD(wParam))
				{
					 case BN_CLICKED:
					 {
						if(this._checkState !is this.checkState) //Is Check State Changed?
						{
							this._checkState = this.checkState;
							this.onCheckChanged(EventArgs.empty);
						}
					 }
					 break;

					default:
						break;
				}
			}
			break;

			default:
				break;
		}

		return super.onReflectedMessage(msg, wParam, lParam);
	}

	protected void onCheckChanged(EventArgs e)
	{
		this.checkChanged(this, e);
	}
}

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

	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		pcw.Style |= BS_DEFPUSHBUTTON;
		pcw.ClassName = WC_DBUTTON;

		super.preCreateWindow(pcw);
	}
}

/// Standard windows _CheckBox
class CheckBox: CheckedButton
{
	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		pcw.Style |= BS_AUTOCHECKBOX;
		pcw.ClassName = WC_DCHECKBOX;

		super.preCreateWindow(pcw);
	}
}

/// Standard windows _RadioButton
class RadioButton: CheckedButton
{
	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		pcw.Style |= BS_AUTORADIOBUTTON;
		pcw.ClassName = WC_DRADIOBUTTON;

		super.preCreateWindow(pcw);
	}
}
