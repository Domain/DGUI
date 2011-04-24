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

module dgui.messagebox;

import std.utf;
import std.string;
import dgui.core.enums;
import dgui.core.winapi;

enum MsgBoxButtons: uint
{
	OK = MB_OK,
	YES_NO = MB_YESNO,
	OK_CANCEL = MB_OKCANCEL,
	RETRY_CANCEL = MB_RETRYCANCEL,
	YES_NO_CANCEL = MB_YESNOCANCEL,
	ABORT_RETRY_IGNORE = MB_ABORTRETRYIGNORE,
}

enum MsgBoxIcons: uint
{
	NONE = 0,
	WARNING = MB_ICONWARNING,
	INFORMATION = MB_ICONINFORMATION,
	QUESTION = MB_ICONQUESTION,
	ERROR = MB_ICONERROR,
}

final class MsgBox
{
	private this()
	{

	}

	public static DialogResult show(string text, string title, MsgBoxButtons button, MsgBoxIcons icon)
	{
		return cast(DialogResult)MessageBoxW(GetActiveWindow(), toUTF16z(text), toUTF16z(title), button | icon);
	}

	public static DialogResult show(string text, string title, MsgBoxButtons button)
	{
		return MsgBox.show(text, title, button, MsgBoxIcons.NONE);
	}

	public static DialogResult show(string text, string title, MsgBoxIcons icon)
	{
		return MsgBox.show(text, title, MsgBoxButtons.OK, icon);
	}

	public static DialogResult show(string text, string title)
	{
		return MsgBox.show(text, title, MsgBoxButtons.OK, MsgBoxIcons.NONE);
	}
}
