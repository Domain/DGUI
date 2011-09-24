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

module dgui.combobox;

import std.utf: toUTFz;
import dgui.core.controls.subclassedcontrol;
import dgui.core.utils;
public import dgui.imagelist;

enum DropDownStyles: uint
{
	NONE 		  = 0, // Internal Use
	SIMPLE 		  = CBS_SIMPLE,
	DROPDOWN 	  = CBS_DROPDOWN,
	DROPDOWN_LIST = CBS_DROPDOWNLIST,
}

class ComboBoxItem
{
	private ComboBox _owner;
	private string _text;
	private int _imgIndex = -1;
	private int _idx;

	mixin TagProperty;

	package this(string txt, int idx = -1)
	{
		this._text = txt;
		this._imgIndex = idx;
	}

	@property public final int index()
	{
		return this._idx;
	}

	@property package void index(int idx)
	{
		this._idx = idx;
	}

	@property public final ComboBox comboBox()
	{
		return this._owner;
	}

	@property package void comboBox(ComboBox cbx)
	{
		this._owner = cbx;
	}

	@property public final int imageIndex()
	{
		return this._imgIndex;
	}

	@property public final void imageIndex(int idx)
	{
		this._imgIndex = idx;

		if(this._owner && this._owner.created)
		{
			COMBOBOXEXITEMW cbei;

			cbei.mask = CBEIF_IMAGE;
			cbei.iImage = idx;
			cbei.iItem = this._idx;

			this._owner.sendMessage(CBEM_SETITEMW, 0, cast(LPARAM)&cbei);
		}
	}

	@property public final string text()
	{
		return this._text;
	}

	@property public final void text(string txt)
	{
		this._text = txt;

		if(this._owner && this._owner.created)
		{
			COMBOBOXEXITEMW cbei;

			cbei.mask = CBEIF_TEXT;
			cbei.pszText = toUTFz!(wchar*)(txt);
			cbei.iItem = this._idx;

			this._owner.sendMessage(CBEM_SETITEMW, 0, cast(LPARAM)&cbei);
		}
	}
}

class ComboBox: SubclassedControl
{
	public Event!(Control, EventArgs) itemChanged;

	private Collection!(ComboBoxItem) _items;

	private DropDownStyles _oldDdStyle = DropDownStyles.NONE;
	private int _selectedIndex;
	private ImageList _imgList;

	public this()
	{
		this.setStyle(DropDownStyles.DROPDOWN, true);
	}

	public final ComboBoxItem addItem(string s, int imgIndex = -1)
	{
		if(!this._items)
		{
			this._items = new Collection!(ComboBoxItem)();
		}

		ComboBoxItem cbi = new ComboBoxItem(s, imgIndex);
		this._items.add(cbi);

		if(this.created)
		{
			return this.insertItem(cbi);
		}

		return cbi;
	}

	public final void removeItem(int idx)
	{
		if(this.created)
		{
			this.sendMessage(CB_DELETESTRING, idx, 0);
		}

		this._items.removeAt(idx);
	}

	@property public final int selectedIndex()
	{
		if(this.created)
		{
			return this.sendMessage(CB_GETCURSEL, 0, 0);
		}

		return this._selectedIndex;
	}

	@property public final void selectedIndex(int i)
	{
		this._selectedIndex = i;

		if(this.created)
		{
			this.sendMessage(CB_SETCURSEL, i, 0);
		}
	}

	public void clear()
	{
		if(this._items)
		{
			foreach(ComboBoxItem cbi; this._items)
			{
				this.sendMessage(CB_DELETESTRING, 0, 0);
			}

			this._items.clear();
		}

		this.selectedIndex = -1;
	}

	@property public final ComboBoxItem selectedItem()
	{
		if(this.created)
		{
			return this._items[this._selectedIndex];
		}
		else
		{
			int idx = this.selectedIndex;

			if(this._items)
			{
				return this._items[idx];
			}
		}

		return null;
	}

	@property public final ImageList imageList()
	{
		return this._imgList;
	}

	@property public void imageList(ImageList imgList)
	{
		this._imgList = imgList;

		if(this.created)
		{
			this.sendMessage(CBEM_SETIMAGELIST, 0, cast(LPARAM)this._imgList.handle);
		}
	}

	@property public final void dropDownStyle(DropDownStyles dds)
	{
		if(dds !is this._oldDdStyle)
		{
			this.setStyle(this._oldDdStyle, false); //Rimuovo il vecchio
			this.setStyle(dds, true); //Aggiungo il nuovo

			this._oldDdStyle = dds;
		}
	}

	@property public final ComboBoxItem[] items()
	{
		if(this._items)
		{
			return this._items.get();
		}

		return null;
	}

	private ComboBoxItem insertItem(ComboBoxItem cbi)
	{
		COMBOBOXEXITEMW cbei;

		cbei.mask = CBEIF_TEXT | CBEIF_IMAGE | CBEIF_SELECTEDIMAGE | CBEIF_LPARAM;
		cbei.iItem = -1;
		cbei.iImage = cbi.imageIndex;
		cbei.iSelectedImage = cbi.imageIndex;
		cbei.pszText = toUTFz!(wchar*)(cbi.text);
		cbei.lParam = winCast!(LPARAM)(cbi);

		cbi.index = this.sendMessage(CBEM_INSERTITEMW, 0, cast(LPARAM)&cbei);
		cbi.comboBox = this;
		return cbi;
	}

	protected void onItemChanged(EventArgs e)
	{
		this.itemChanged(this, e);
	}

	protected override void createControlParams(ref CreateControlParams ccp)
	{
		ccp.OldClassName = WC_COMBOBOXEX;
		ccp.ClassName = WC_DCOMBOBOX;

		if(!this.height)
		{
			// If this row is removed, the dropdown list is not displayed
			this.height = this.topLevelControl.height;
		}

		/* Use Original Paint Routine, the double buffered one causes some issues */
		ComboBox.setBit(this._cBits, ControlBits.ORIGINAL_PAINT, true);
		super.createControlParams(ccp);
	}

	protected override void onHandleCreated(EventArgs e)
	{
		if(this._imgList)
		{
			this.sendMessage(CBEM_SETIMAGELIST, 0, cast(LPARAM)this._imgList.handle);
		}

		if(this._items)
		{
			foreach(ComboBoxItem cbi; this._items)
			{
				this.insertItem(cbi);
			}
		}

		if(this._selectedIndex != -1)
		{
			this.selectedIndex = this._selectedIndex;
		}

		super.onHandleCreated(e);
	}

	protected override void onReflectedMessage(ref Message m)
	{
		switch(m.Msg)
		{
			case WM_COMMAND:
			{
				switch(HIWORD(m.wParam))
				{
					case CBN_SELCHANGE:
						this._selectedIndex = this.sendMessage(CB_GETCURSEL, 0, 0);
						this.onItemChanged(EventArgs.empty);
						break;

					default:
						break;
				}
			}
			break;

			default:
				break;
		}

		super.onReflectedMessage(m);
	}
}
