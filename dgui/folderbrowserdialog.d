﻿/*
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

module dgui.folderbrowserdialog;

pragma(lib, "shell32.lib");

import std.utf;
import std.conv;
import std.string;
public import dgui.core.commondialog;

class FolderBrowserDialog: CommonDialog!(BROWSEINFOW, string)
{
	public override bool showDialog()
	{
		wchar[MAX_PATH] buffer = void;
		buffer[0] = '\0';

		this._dlgStruct.hwndOwner = GetActiveWindow();
		this._dlgStruct.pszDisplayName = buffer.ptr;
		this._dlgStruct.ulFlags = BIF_RETURNONLYFSDIRS;
		this._dlgStruct.lpszTitle = toUTF16z(this._title);

		ITEMIDLIST* pidl = SHBrowseForFolderW(&this._dlgStruct);

		if(pidl)
		{
			SHGetPathFromIDListW(pidl, buffer.ptr); //Get Full Path.
			this._dlgRes = toUTF8(buffer);
			return true;
		}

		return false;
	}
}
