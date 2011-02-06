module dgui.statusbar;

public import dgui.control;

private const string WC_STATUSBAR = "msctls_statusbar32";
private const string WC_DSTATUSBAR = "DStatusBar";

final class StatusPart
{
	private StatusBar _owner;
	private string _text;
	private int _width;

	package this(StatusBar sb, string txt, int w)
	{
		this._owner = sb;
		this._text = txt;
		this._width = w;
	}

	public string text()
	{
		return this._text;
	}

	public void text(string s)
	{
		this._text = s;

		if(this._owner && this._owner.created)
		{
			this._owner.sendMessage(SB_SETTEXTA, MAKEWPARAM(this.index, 0), cast(LPARAM)toStringz(s));
		}
	}

	public int width()
	{
		return this._width;
	}

	public int index()
	{
		foreach(int i, StatusPart sp; this._owner.parts)
		{
			if(sp is this)
			{
				return i;
			}
		}

		return -1;
	}

	public StatusBar statusBar()
	{
		return this._owner;
	}
}

class StatusBar: SubclassedControl
{
	private Collection!(StatusPart) _parts;
	private bool _partsVisible = false;

	public StatusPart addPart(string s, int w)
	{
		if(!this._parts)
		{
			this._parts = new Collection!(StatusPart)();
		}

		StatusPart sp = new StatusPart(this, s, w);
		this._parts.add(sp);

		if(this.created)
		{
			StatusBar.insertPart(sp);
		}

		return sp;
	}

	public StatusPart addPart(int w)
	{
		return this.addPart(null, w);
	}

	/*
	public void removePanel(int idx)
	{

	}
	*/

	public bool partsVisible()
	{
		return this._partsVisible;
	}

	public void partsVisible(bool b)
	{
		this._partsVisible = b;

		if(this.created)
		{
			this.setStyle(SBARS_SIZEGRIP, b);
		}
	}

	public Collection!(StatusPart) parts()
	{
		return this._parts;
	}

	private static void insertPart(StatusPart sp)
	{
		StatusBar owner = sp.statusBar;
		Collection!(StatusPart) sparts = owner.parts;
		uint[] parts = new uint[sparts.length];

		foreach(int i, StatusPart sp; sparts)
		{
			if(!i)
			{
				parts[i] = sp.width;
			}
			else
			{
				parts[i] = parts[i - 1] + sp.width;
			}
		}

		owner.sendMessage(SB_SETPARTS, sparts.length, cast(LPARAM)parts.ptr);

		foreach(int i, StatusPart sp; sparts)
		{
			owner.sendMessage(SB_SETTEXTA, MAKEWPARAM(i, 0), cast(LPARAM)toStringz(sp.text));
		}
	}

	protected override void preCreateWindow(inout PreCreateWindow pcw)
	{
		this._controlInfo.Dock = DockStyle.BOTTOM; //Forza il dock

		pcw.OldClassName = WC_STATUSBAR;
		pcw.ClassName = WC_DSTATUSBAR;
		pcw.Style |= (this._partsVisible ? SBARS_SIZEGRIP : 0);

		super.preCreateWindow(pcw);
	}

	protected override void onHandleCreated(EventArgs e)
	{

		if(this._parts)
		{
			foreach(StatusPart sp; this._parts)
			{
				StatusBar.insertPart(sp);
			}
		}

		super.onHandleCreated(e);
	}
}
