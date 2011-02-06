module dgui.fontdialog;

public import dgui.core.winapi;
public import std.string;

public import dgui.core.commondialog;

class FontDialog: CommonDialog!(CHOOSEFONTA, Font)
{
	public bool showDialog()
	{
		LOGFONTA lf = void;

		this._dlgStruct.lStructSize = CHOOSEFONTA.sizeof;
		this._dlgStruct.hwndOwner = GetActiveWindow();
		this._dlgStruct.Flags = CF_INITTOLOGFONTSTRUCT | CF_EFFECTS | CF_SCREENFONTS;
		this._dlgStruct.lpLogFont = &lf;

		if(ChooseFontA(&this._dlgStruct))
		{
			this._dlgRes = Font.fromHFONT(CreateFontIndirectA(&lf));
			return true;
		}

		return false;
	}
}
