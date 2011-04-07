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

module dgui.colordialog;

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
			this._dlgRes = Color.fromCOLORREF(this._dlgStruct.rgbResult);
			return true;
		}

		return false;
	}
}
