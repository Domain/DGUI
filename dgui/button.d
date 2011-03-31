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

public import dgui.control;

package const string WC_BUTTON = "Button";
private const string WC_DBUTTON = "DButton";
private const string WC_DCHECKBOX = "DCheckBox";
private const string WC_DRADIOBUTTON = "DRadioButton";

enum CheckState: uint
{
	CHECKED = BST_CHECKED,
	UNCHECKED = BST_UNCHECKED,
	INDETERMINATE = BST_INDETERMINATE,
}

abstract class AbstractButton: SubclassedControl
{
	private DialogResult _dr = DialogResult.NONE;

	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		pcw.OldClassName = WC_BUTTON;

		super.preCreateWindow(pcw);
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

abstract class CheckedButton: AbstractButton
{
	public Signal!(Control, EventArgs) checkChanged;

	private CheckState _checkState = CheckState.UNCHECKED;

	@property public bool checked()
	{
		return this.checkState is CheckState.CHECKED;
	}

	@property public void checked(bool b)
	{
		this.checkState = b ? CheckState.CHECKED : CheckState.UNCHECKED;
	}

	@property public CheckState checkState()
	{
		if(this.created)
		{
			return cast(CheckState)this.sendMessage(BM_GETCHECK, 0, 0);
		}

		return this._checkState;
	}

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

class Button: AbstractButton
{
	public this()
	{
		super();

		this.setStyle(BS_DEFPUSHBUTTON, true);
	}

	@property public DialogResult dialogResult()
	{
		return this._dr;
	}

	@property public void dialogResult(DialogResult dr)
	{
		this._dr = dr;
	}

	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		pcw.ClassName = WC_DBUTTON;

		super.preCreateWindow(pcw);
	}
}

class CheckBox: CheckedButton
{
	public this()
	{
		super();

		this.setStyle(BS_AUTOCHECKBOX, true);
	}

	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		pcw.ClassName = WC_DCHECKBOX;

		super.preCreateWindow(pcw);
	}
}

class RadioButton: CheckedButton
{
	public this()
	{
		super();

		this.setStyle(BS_AUTORADIOBUTTON, true);
	}

	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		pcw.ClassName = WC_DRADIOBUTTON;

		super.preCreateWindow(pcw);
	}
}
