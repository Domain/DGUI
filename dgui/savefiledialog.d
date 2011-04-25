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

module dgui.savefiledialog;

import std.utf: toUTF16z, toUTF8;
import dgui.core.utils;
public import dgui.core.commondialog;

class SaveFileDialog: CommonDialog!(OPENFILENAMEW, string)
{
	private string _filter;

	@property public string filter()
	{
		return this._filter;
	}

	@property public void filter(string f)
	{
		this._filter = makeFilter(f);
	}

	public override bool showDialog()
	{
		wchar[MAX_PATH] buffer = void;
		buffer[] = '\0';

		this._dlgStruct.lStructSize = OPENFILENAMEA.sizeof;
		this._dlgStruct.hwndOwner = GetActiveWindow();
		this._dlgStruct.lpstrFilter = toUTF16z(this._filter);
		this._dlgStruct.lpstrTitle = toUTF16z(this._title);
		this._dlgStruct.lpstrFile = buffer.ptr;
		this._dlgStruct.nMaxFile = MAX_PATH;
		this._dlgStruct.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST | OFN_CREATEPROMPT | OFN_OVERWRITEPROMPT;

		if(GetSaveFileNameW(&this._dlgStruct))
		{
			this._dlgRes = toUTF8(buffer);
			return true;
		}

		return false;
	}
}
