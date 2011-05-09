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

module dgui.listbox;

import std.utf: toUTF16z;
import dgui.core.utils;
import dgui.control;

class ListBox: OwnerDrawControl
{
	private static struct ListBoxInfo
	{
		int SelectedIndex;
		Object SelectedItem;
	}

	private static class StringItem
	{
		private string _str;

		public this(string s)
		{
			this._str = s;
		}

		public override string toString()
		{
			return this._str;
		}
	}

	private Collection!(Object) _items;
	private ListBoxInfo _lbxInfo;

	public this()
	{
		super();

		this.setStyle(WS_BORDER, true);
	}

	public final int addItem(string s)
	{
		return this.addItem(new StringItem(s));
	}

	public final int addItem(Object obj)
	{
		if(!this._items)
		{
			this._items = new Collection!(Object)();
		}

		this._items.add(obj);

		if(this.created)
		{
			return this.insertItem(obj);
		}

		return this._items.length - 1;

	}

	public final void removeItem(int idx)
	{
		if(this.created)
		{
			this.sendMessage(LB_DELETESTRING, idx, 0);
		}

		this._items.removeAt(idx);
	}

	@property public final int selectedIndex()
	{
		if(this.created)
		{
			return this.sendMessage(LB_GETCURSEL, 0, 0);
		}

		return this._lbxInfo.SelectedIndex;
	}

	@property public final void selectedIndex(int i)
	{
		this._lbxInfo.SelectedIndex = i;

		if(this.created)
		{
			this.sendMessage(LB_SETCURSEL, i, 0);
		}
	}

	@property public final Object selectedItem()
	{
		int idx = this.selectedIndex;

		if(this._items)
		{
			return this._items[idx];
		}

		return null;
	}

	@property public final string selectedString()
	{
		Object obj = this.selectedItem;
		return (obj ? obj.toString() : null);
	}

	@property public final Object[] items()
	{
		if(this._items)
		{
			return this._items.get();
		}

		return null;
	}

	private int insertItem(Object obj)
	{
		return this.sendMessage(LB_ADDSTRING, 0, cast(LPARAM)toUTF16z(obj.toString()));
	}

	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		pcw.OldClassName = WC_LISTBOX;
		pcw.ClassName = WC_DLISTBOX;
		pcw.DefaultBackColor = SystemColors.colorWindow;

		super.preCreateWindow(pcw);
	}

	protected override void onHandleCreated(EventArgs e)
	{
		if(this._items)
		{
			foreach(Object obj; this._items)
			{
				this.insertItem(obj);
			}
		}

		super.onHandleCreated(e);
	}
}
