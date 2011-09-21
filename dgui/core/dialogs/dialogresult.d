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
