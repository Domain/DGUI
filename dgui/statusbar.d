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

	@property public string text()
	{
		return this._text;
	}

	@property public void text(string s)
	{
		this._text = s;

		if(this._owner && this._owner.created)
		{
			this._owner.sendMessage(SB_SETTEXTA, MAKEWPARAM(this.index, 0), cast(LPARAM)toStringz(s));
		}
	}

	@property public int width()
	{
		return this._width;
	}

	@property public int index()
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

	@property public StatusBar statusBar()
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

	@property public bool partsVisible()
	{
		return this._partsVisible;
	}

	@property public void partsVisible(bool b)
	{
		this._partsVisible = b;

		if(this.created)
		{
			this.setStyle(SBARS_SIZEGRIP, b);
		}
	}

	@property public Collection!(StatusPart) parts()
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

	protected override void preCreateWindow(ref PreCreateWindow pcw)
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
