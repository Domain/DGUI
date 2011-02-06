module dgui.colordialog;

public import std.string;
public import dgui.core.commondialog;

class ColorDialog: CommonDialog!(CHOOSECOLORA, Color)
{
	public bool showDialog()
	{
		this._dlgStruct.lStructSize = CHOOSECOLORA.sizeof;
		this._dlgStruct.hwndOwner = GetActiveWindow();
		this._dlgStruct.Flags = CC_FULLOPEN;

		if(ChooseColorA(&this._dlgStruct))
		{
			this._dlgRes = COLORREFtoARGB(this._dlgStruct.rgbResult);
			return true;
		}

		return false;
	}
}
