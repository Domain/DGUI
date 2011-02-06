module dgui.folderbrowserdialog;

pragma(lib, "shell32.lib");

public import dgui.core.winapi;
public import std.string;

public import dgui.core.commondialog;

class FolderBrowserDialog: CommonDialog!(BROWSEINFOA, string)
{
	public bool showDialog()
	{
		char[MAX_PATH] buffer = void;
		buffer[0] = '\0';

		this._dlgStruct.hwndOwner = GetActiveWindow();
		this._dlgStruct.pszDisplayName = buffer.ptr;
		this._dlgStruct.ulFlags = BIF_RETURNONLYFSDIRS;
		this._dlgStruct.lpszTitle = toStringz(this._title);

		ITEMIDLIST* pidl = SHBrowseForFolderA(&this._dlgStruct);

		if(pidl)
		{
			SHGetPathFromIDListA(pidl, buffer.ptr); //Ricava il path intero.
			this._dlgRes = std.string.toString(buffer.ptr).dup;
			return true;
		}

		return false;
	}
}
