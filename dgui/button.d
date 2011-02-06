module dgui.button;

/*
 * Stili: BS_LEFT, BS_TOP, BS_RIGHT, BS_BOTTOM, BS_CENTER
 */

public import dgui.control;

private const string WC_BUTTON = "Button";
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

	protected override void preCreateWindow(inout PreCreateWindow pcw)
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
	private CheckState _checkState;

	public CheckState checkState()
	{
		if(this.created)
		{
			return cast(CheckState)this.sendMessage(BM_GETCHECK, 0, 0);
		}

		return this._checkState;
	}

	public void checkState(CheckState cs)
	{
		this._checkState = cs;

		if(this.created)
		{
			this.sendMessage(BM_SETCHECK, cs, 0);
		}
	}
}

class Button: AbstractButton
{
	public this()
	{
		super();

		this.setStyle(BS_DEFPUSHBUTTON, true);
	}

	public DialogResult dialogResult()
	{
		return this._dr;
	}

	public void dialogResult(DialogResult dr)
	{
		this._dr = dr;
	}

	protected override void preCreateWindow(inout PreCreateWindow pcw)
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

	protected override void preCreateWindow(inout PreCreateWindow pcw)
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

	protected override void preCreateWindow(inout PreCreateWindow pcw)
	{
		pcw.ClassName = WC_DRADIOBUTTON;

		super.preCreateWindow(pcw);
	}
}
