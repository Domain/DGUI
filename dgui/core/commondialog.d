module dgui.core.commondialog;

public import dgui.core.winapi;
public import dgui.canvas;

class CommonDialog(T1, T2)
{
	protected T1 _dlgStruct;
	protected T2 _dlgRes;
	protected string _title;

	public string text()
	{
		return this._title;
	}

	public T2 result()
	{
		return this._dlgRes;
	}

	public void text(string s)
	{
		this._title = s;
	}

	public abstract bool showDialog();
}
