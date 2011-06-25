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

module dgui.menu;

import std.utf: toUTF16z;
import dgui.canvas;
import dgui.imagelist;
import dgui.core.winapi;
import dgui.core.geometry;
import dgui.core.collection;
import dgui.core.idisposable;
import dgui.core.events;
import dgui.core.signal;
import dgui.core.handle;
import dgui.core.utils;
import dgui.core.wincomp;

enum: uint
{
	MIIM_STRING 		= 64,
	MIIM_FTYPE  		= 256,

	MIM_MAXHEIGHT       = 1,
	MIM_BACKGROUND      = 2,
	MIM_HELPID          = 4,
	MIM_MENUDATA        = 8,
	MIM_STYLE           = 16,
	MIM_APPLYTOSUBMENUS = 0x80000000L,

	MNS_NOCHECK    		= 0x80000000,
	MNS_MODELESS    	= 0x40000000,
	MNS_DRAGDROP    	= 0x20000000,
	MNS_AUTODISMISS 	= 0x10000000,
	MNS_NOTIFYBYPOS 	= 0x08000000,
	MNS_CHECKORBMP  	= 0x04000000,
}

enum MenuStyle: ubyte
{
	NORMAL = 1,
	SEPARATOR = 2,
}

struct MenuInfo
{
	MenuStyle Style = MenuStyle.NORMAL;
	int ImageIndex = -1;
	int Index = -1;
	Menu Parent;
	string Text;
	bool Enabled = true;
	bool Checked = false;
}

abstract class Menu: Handle!(HMENU), IDisposable
{
	public Signal!(Menu, EventArgs) popup;

	protected Collection!(MenuItem) _items;
	protected MenuInfo _menuInfo;

	protected this()
	{

	}

	protected this(Menu parent, string text)
	{
		this._menuInfo.Parent = parent;
		this._menuInfo.Text = text;
	}

	public ~this()
	{
		this.dispose();
	}

	protected abstract void makeMenu();

	protected void initMenu()
	{
		MENUINFO mi;

		mi.cbSize = MENUINFO.sizeof;
		mi.fMask  = MIM_MENUDATA | MIM_APPLYTOSUBMENUS | MIM_STYLE;
		mi.dwStyle = MNS_NOTIFYBYPOS | MNS_CHECKORBMP;
		mi.dwMenuData = winCast!(uint)(this);

		SetMenuInfo(this.handle, &mi);
	}

	protected static HMENU doMenu(RootMenu root, Menu menu)
	{
		menu.makeMenu();

		if(menu._items)
		{
			foreach(MenuItem mi; menu._items)
			{
				createItem(root, menu, mi);
			}
		}

		return menu.handle;
	}

	private static void createItem(RootMenu root, Menu parent, MenuItem m)
	{
		MENUITEMINFOW minfo;

		minfo.cbSize = MENUITEMINFOW.sizeof;
		minfo.fMask = MIIM_FTYPE;
		minfo.dwItemData = winCast!(uint)(m);

		m.rootMenu = root; //Save the root menu

		if(m.style is MenuStyle.NORMAL)
		{
			WindowsVersion ver = getWindowsVersion();

			minfo.fMask |= MIIM_DATA | MIIM_STRING | MIIM_STATE;
			minfo.fState = (m.enabled ? MFS_ENABLED : MFS_DISABLED) | (m.checked ? MFS_CHECKED : 0);
			minfo.dwTypeData = toUTF16z(m._menuInfo.Text);

			if(root.imageList && m.imageIndex != -1)
			{
				minfo.fMask |= MIIM_BITMAP;

				if(ver > WindowsVersion.WINDOWS_XP) // Is Vista or 7
				{
					HBITMAP hBitmap = iconToBitmapPARGB32(root.imageList.images[m.imageIndex].handle);
					root.bitmaps.add(hBitmap);

					minfo.hbmpItem = hBitmap;
				}
				else // Is 2000 or XP
				{
					minfo.hbmpItem = HBMMENU_CALLBACK;
				}
			}
		}
		else if(m.style is MenuStyle.SEPARATOR)
		{
			minfo.fType = MFT_SEPARATOR;
		}

		if(m._items)
		{
			HMENU hMenu = doMenu(root, m);

			minfo.fMask |= MIIM_SUBMENU;
			minfo.hSubMenu = hMenu;
		}

		InsertMenuItemW(parent.handle, -1, TRUE, &minfo);
	}

	public void dispose()
	{
		//From MSDN: DestroyMenu is recursive, it will destroy the menu and its submenus.
		if(this.created)
		{
			DestroyMenu(this._handle);
		}
	}

	@property public final string text()
	{
		return this._menuInfo.Text;
	}

	@property public final void text(string s)
	{
		this._menuInfo.Text = s;

		if(this._menuInfo.Parent && this._menuInfo.Parent.created)
		{
			int idx = this.index;

			MENUITEMINFOW minfo;

			minfo.cbSize = MENUITEMINFOW.sizeof;
			minfo.fMask = MIIM_STRING;
			minfo.dwTypeData = toUTF16z(s);

			SetMenuItemInfoW(this._menuInfo.Parent.handle, idx, true, &minfo);
		}
	}

	@property public final MenuItem[] items()
	{
		if(this._items)
		{
			return this._items.get();
		}

		return null;
	}

	@property public final int index()
	{
		if(this._menuInfo.Parent)
		{
			int i = 0;

			foreach(MenuItem mi; this._menuInfo.Parent.items)
			{
				if(mi is this)
				{
					return i;
				}

				i++;
			}
		}

		return -1;
	}

	public final MenuItem addItem(string t)
	{
		return this.addItem(t, -1, true);
	}

	public final MenuItem addItem(string t, bool enabled)
	{
		return this.addItem(t, -1, enabled);
	}

	public final MenuItem addItem(string t, int imgIdx)
	{
		return this.addItem(t, imgIdx, true);
	}

	public final MenuItem addItem(string t, int imgIdx, bool enabled)
	{
		if(!this._items)
		{
			this._items = new Collection!(MenuItem)();
		}

		MenuItem item = new MenuItem(this, MenuStyle.NORMAL, t, enabled);
		item.imageIndex = imgIdx;

		this._items.add(item);

		if(this.created)
		{
			RootMenu rm = (!this._menuInfo.Parent ? cast(RootMenu)this : (cast(MenuItem)this).rootMenu);
			createItem(rm, this, item);
		}

		return item;
	}

	public final MenuItem addSeparator()
	{
		if(!this._items)
		{
			this._items = new Collection!(MenuItem)();
		}

		MenuItem item = new MenuItem(this._menuInfo.Parent, MenuStyle.SEPARATOR, null, true);
		this._items.add(item);

		if(this.created)
		{
			RootMenu rm = (!this._menuInfo.Parent ? cast(RootMenu)this : (cast(MenuItem)this).rootMenu);
			createItem(rm, this, item);
		}

		return item;
	}

	public final void removeItem(int idx)
	{
		if(this._items)
		{
			this._items.removeAt(idx);
		}

		if(this.created)
		{
			DeleteMenu(this._handle, idx, MF_BYPOSITION);
		}
	}

	package void onPopup(EventArgs e)
	{
		this.popup(this, e);
	}
}

class MenuItem: Menu
{
	public Signal!(MenuItem, EventArgs) click;
	private RootMenu _rootMenu;

	protected this(Menu parent, MenuStyle mt, string t, bool e)
	{
		this._menuInfo.Parent = parent;
		this._menuInfo.Style = mt;
		this._menuInfo.Text = t;
		this._menuInfo.Enabled = e;
	}

	package void performClick()
	{
		this.onClick(EventArgs.empty);
	}

	@property public final MenuStyle style()
	{
		return this._menuInfo.Style;
	}

	@property public Menu parent()
	{
		return this._menuInfo.Parent;
	}

	@property public RootMenu rootMenu()
	{
		return this._rootMenu;
	}

	@property package void rootMenu(RootMenu rm)
	{
		this._rootMenu = rm;
	}

	@property public int imageIndex()
	{
		return this._menuInfo.ImageIndex;
	}

	@property public void imageIndex(int imgIdx)
	{
		this._menuInfo.ImageIndex = imgIdx;

		if(this._menuInfo.Parent && this._menuInfo.Parent.created)
		{
			int idx = this.index;
			HBITMAP hBitmap = iconToBitmapPARGB32(this._rootMenu.imageList.images[imgIdx].handle);
			this._rootMenu.bitmaps.add(hBitmap);

			MENUITEMINFOW minfo;

			minfo.cbSize = MENUITEMINFOW.sizeof;
			minfo.fMask = MIIM_BITMAP;
			minfo.hbmpItem = hBitmap;

			SetMenuItemInfoW(this._menuInfo.Parent.handle, idx, true, &minfo);
		}
	}

	@property public final bool enabled()
	{
		return this._menuInfo.Enabled;
	}

	@property public final void enabled(bool b)
	{
		this._menuInfo.Enabled = b;

		if(this._menuInfo.Parent && this._menuInfo.Parent.created)
		{
			int idx = this.index;

			MENUITEMINFOW minfo;

			minfo.cbSize = MENUITEMINFOW.sizeof;
			minfo.fMask = MIIM_STATE;
			minfo.fState = b ? MFS_ENABLED : MFS_DISABLED;

			SetMenuItemInfoW(this._menuInfo.Parent.handle, idx, true, &minfo);
		}
	}

	@property public final bool checked()
	{
		return this._menuInfo.Checked;
	}

	@property public final void checked(bool b)
	{
		this._menuInfo.Checked = b;

		if(this._menuInfo.Parent && this._menuInfo.Parent.created)
		{
			int idx = this.index;

			MENUITEMINFOW minfo;

			minfo.cbSize = MENUITEMINFOW.sizeof;
			minfo.fMask = MIIM_STATE;

			if(b)
			{
				minfo.fState |= MFS_CHECKED;
			}
			else
			{
				minfo.fState &= ~MFS_CHECKED;
			}

			SetMenuItemInfoW(this._menuInfo.Parent.handle, idx, true, &minfo);
		}
	}

	protected override void makeMenu()
	{
		this._handle = CreatePopupMenu();
	}

	protected void onClick(EventArgs e)
	{
		this.click(this, e);
	}
}

class RootMenu: Menu
{
	protected Collection!(HBITMAP) _bitmaps;
	protected ImageList _imgList;

	public override void dispose()
	{
		if(this._bitmaps)
		{
			foreach(HBITMAP hBitmap; this._bitmaps)
			{
				DeleteObject(hBitmap);
			}
		}

		if(this._imgList)
		{
			this._imgList.dispose();
		}

		super.dispose();
	}

	@property package Collection!(HBITMAP) bitmaps()
	{
		return this._bitmaps;
	}

	@property public ImageList imageList()
	{
		return this._imgList;
	}

	@property public void imageList(ImageList imgList)
	{
		this._imgList = imgList;

		if(!this._bitmaps)
		{
			this._bitmaps = new Collection!(HBITMAP)();
		}
	}

	public final void create()
	{
		doMenu(this, this);
	}
}

class MenuBar: RootMenu
{
	protected override void makeMenu()
	{
		this._handle = CreateMenu();
		this.initMenu();
	}
}

class ContextMenu: RootMenu
{
	public void popupMenu(HWND hWnd, Point pt)
	{
		if(!this.created)
		{
			this.create();
		}

		TrackPopupMenu(this._handle, TPM_LEFTALIGN, pt.x, pt.y, 0, hWnd, null);
	}

	protected override void makeMenu()
	{
		this._handle = CreatePopupMenu();
		this.initMenu();
	}
}
