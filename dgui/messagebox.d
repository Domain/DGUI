/** DGui project file.

Copyright: Trogu Antonio Davide 2011-2013

License: $(HTTP boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Trogu Antonio Davide
*/
module dgui.messagebox;

import std.utf: toUTFz;
private import dgui.core.winapi;
public import dgui.core.dialogs.dialogresult;

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

	public static DialogResult show(string title, string text, MsgBoxButtons button, MsgBoxIcons icon)
	{
		return cast(DialogResult)MessageBoxW(GetActiveWindow(), toUTFz!(wchar*)(text), toUTFz!(wchar*)(title), button | icon);
	}

	public static DialogResult show(string title, string text, MsgBoxButtons button)
	{
		return MsgBox.show(title, text, button, MsgBoxIcons.NONE);
	}

	public static DialogResult show(string title, string text, MsgBoxIcons icon)
	{
		return MsgBox.show(title, text, MsgBoxButtons.OK, icon);
	}

	public static DialogResult show(string title, string text)
	{
		return MsgBox.show(title, text, MsgBoxButtons.OK, MsgBoxIcons.NONE);
	}
}
