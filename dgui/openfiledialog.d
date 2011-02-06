module dgui.openfiledialog;

public import std.string;

public import dgui.core.commondialog;

class OpenFileDialog: CommonDialog!(OPENFILENAMEA, string)
{
	private string _filter;

	public string filter()
	{
		return this._filter;
	}

	public void filter(string f)
	{
		this._filter = makeFilter(f);
	}

	public bool showDialog()
	{
		char[MAX_PATH] buffer = void;
		buffer[] = '\0';

		this._dlgStruct.lStructSize = OPENFILENAMEA.sizeof;
		this._dlgStruct.hwndOwner = GetActiveWindow();
		this._dlgStruct.lpstrFilter = toStringz(this._filter);
		this._dlgStruct.lpstrTitle = toStringz(this._title);
		this._dlgStruct.lpstrFile = buffer.ptr;
		this._dlgStruct.nMaxFile = MAX_PATH;
		this._dlgStruct.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST | OFN_CREATEPROMPT | OFN_OVERWRITEPROMPT;

		if(GetOpenFileNameA(&this._dlgStruct))
		{
			this._dlgRes = std.string.toString(buffer.ptr).dup; //Dup local buffer
			return true;
		}

		return false;
	}
}
