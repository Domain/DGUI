/** DGui project file.

Copyright: Trogu Antonio Davide 2011-2013

License: $(HTTP boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Trogu Antonio Davide
*/
module dgui.core.dialogs.dialogresult;

private import dgui.core.winapi;

enum DialogResult: int
{
	NONE,
	OK = IDOK,
	YES = IDYES,
	NO = IDNO,
	CANCEL = IDCANCEL,
	RETRY = IDRETRY,
	ABORT = IDABORT,
	IGNORE = IDIGNORE,
	CLOSE = CANCEL, //Same as 'CANCEL'
}
