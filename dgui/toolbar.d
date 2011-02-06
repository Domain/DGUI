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

module dgui.toolbar;

public import dgui.control;
public import dgui.imagelist;

private const string WC_TOOLBAR = "ToolBarWindow32";
private const string WC_DTOOLBAR = "DToolBar";

enum ToolButtonStyle: ubyte
{
	BUTTON = TBSTYLE_BUTTON,
	SEPARATOR = TBSTYLE_SEP,
	DROPDOWN = TBSTYLE_DROPDOWN,
}

class ToolButton
{
	public Signal!(ToolButton, EventArgs) click;

	private ToolBar _owner;
	private ContextMenu _ctxMenu;
	private ToolButtonStyle _tbs;
	private int _imgIndex;
	private bool _enabled;

	package this(ToolBar tb, ToolButtonStyle tbs, int imgIndex, bool enabled)
	{
		this._owner = tb;
		this._tbs = tbs;
		this._imgIndex = imgIndex;
		this._enabled = enabled;
	}

	public final int index()
	{
		if(this._owner && this._owner.created && this._owner.buttons)
		{
			int i = 0;

			foreach(ToolButton tbtn; this._owner.buttons)
			{
				if(tbtn is this)
				{
					return i;
				}

				i++;
			}
		}

		return -1;
	}

	public final ToolButtonStyle style()
	{
		return this._tbs;
	}

	public final void style(ToolButtonStyle tbs)
	{
		this._tbs = tbs;

		if(this._owner && this._owner.created)
		{
			 TBBUTTONINFOA tbinfo = void;

			 tbinfo.cbSize = TBBUTTONINFOA.sizeof;
			 tbinfo.dwMask = TBIF_BYINDEX | TBIF_STYLE;
			 tbinfo.fsStyle = tbs;

			 this._owner.sendMessage(TB_SETBUTTONINFOA, this.index, cast(LPARAM)&tbinfo);
		}
	}

	public final int imageIndex()
	{
		return this._imgIndex;
	}

	public final void imageIndex(int idx)
	{
		this._imgIndex = idx;

		if(this._owner && this._owner.created)
		{
			 TBBUTTONINFOA tbinfo = void;

			 tbinfo.cbSize = TBBUTTONINFOA.sizeof;
			 tbinfo.dwMask = TBIF_BYINDEX | TBIF_IMAGE;
			 tbinfo.iImage = idx;

			 this._owner.sendMessage(TB_SETBUTTONINFOA, this.index, cast(LPARAM)&tbinfo);
		}
	}

	public final bool enabled()
	{
		return this._enabled;
	}

	public final void enabled(bool b)
	{
		this._enabled = b;

		if(this._owner && this._owner.created)
		{
			 TBBUTTONINFOA tbinfo = void;

			 tbinfo.cbSize = TBBUTTONINFOA.sizeof;
			 tbinfo.dwMask = TBIF_BYINDEX | TBIF_STATE;
			 this._owner.sendMessage(TB_GETBUTTONINFOA, this.index, cast(LPARAM)&tbinfo); //Ricavo i dati completi.

			 b ? (tbinfo.fsState |= TBSTATE_ENABLED) : (tbinfo.fsState &= ~TBSTATE_ENABLED);
			 this._owner.sendMessage(TB_SETBUTTONINFOA, this.index, cast(LPARAM)&tbinfo);
		}
	}

	public ContextMenu contextMenu()
	{
		return this._ctxMenu;
	}

	public void contextMenu(ContextMenu cm)
	{
		this._ctxMenu = cm;
	}

	public final ToolBar toolBar()
	{
		return this._owner;
	}

	package void onToolBarButtonClick(EventArgs e)
	{
		this.click(this, e);
	}
}

class ToolBar: SubclassedControl
{
	private Collection!(ToolButton) _buttons;
	private ImageList _imgList;

	public final ImageList imageList()
	{
		return this._imgList;
	}

	public final void imageList(ImageList imgList)
	{
		this._imgList = imgList;

		if(this.created)
		{
			this.sendMessage(TB_SETIMAGELIST, 0, cast(LPARAM)this._imgList.handle);
		}
	}

	public final ToolButton addDropdownButton(int imgIndex, ContextMenu ctxMenu, bool en = true)
	{
		if(!this._buttons)
		{
			this._buttons = new Collection!(ToolButton)();
		}

		ToolButton tb = new ToolButton(this, ToolButtonStyle.DROPDOWN, imgIndex, en);
		tb.contextMenu = ctxMenu;
		this._buttons.add(tb);

		if(this.created)
		{
			ToolBar.addItem(tb);
		}

		return tb;
	}

	public final ToolButton addButton(int imgIndex, bool en = true)
	{
		if(!this._buttons)
		{
			this._buttons = new Collection!(ToolButton)();
		}

		ToolButton tb = new ToolButton(this, ToolButtonStyle.BUTTON, imgIndex, en);
		this._buttons.add(tb);

		if(this.created)
		{
			ToolBar.addItem(tb);
		}

		return tb;
	}

	public final void addSeparator()
	{
		if(!this._buttons)
		{
			this._buttons = new Collection!(ToolButton)();
		}

		ToolButton tb = new ToolButton(this, ToolButtonStyle.SEPARATOR, -1, true);
		this._buttons.add(tb);

		if(this.created)
		{
			ToolBar.addItem(tb);
		}
	}

	public final void removeButton(int idx)
	{
		this._buttons.removeAt(idx);

		if(this.created)
		{
			this.sendMessage(TB_DELETEBUTTON, idx, 0);
		}
	}

	public final Collection!(ToolButton) buttons()
	{
		return this._buttons;
	}

	private void forceToolbarSize()
	{
		uint sz = this.sendMessage(TB_GETBUTTONSIZE, 0, 0);

		this.size = Size(LOWORD(sz), HIWORD(sz));
	}

	private static void addItem(ToolButton tb)
	{
		TBBUTTON tbtn;

		switch(tb.style)
		{
			case ToolButtonStyle.BUTTON, ToolButtonStyle.DROPDOWN:
				tbtn.iBitmap = tb.imageIndex;
				tbtn.fsStyle = cast(ubyte)tb.style;
				tbtn.fsState = cast(ubyte)(tb.enabled ? TBSTATE_ENABLED : 0);
				tbtn.dwData = winCast!(uint)(tb);
				break;

			case ToolButtonStyle.SEPARATOR:
				tbtn.fsStyle = cast(ubyte)tb.style;
				break;

			default:
				assert(false, "Unknown ToolButton Style");
		}

		if(tb.toolBar._controlInfo.Dock is DockStyle.LEFT || tb.toolBar._controlInfo.Dock is DockStyle.RIGHT)
		{
			tbtn.fsState |= TBSTATE_WRAP;
		}

		tb.toolBar.sendMessage(TB_INSERTBUTTONA, tb.index, cast(LPARAM)&tbtn);
	}

	protected override void preCreateWindow(inout PreCreateWindow pcw)
	{
		pcw.OldClassName = WC_TOOLBAR;
		pcw.ClassName = WC_DTOOLBAR;
		pcw.Style |= TBSTYLE_FLAT | CCS_NODIVIDER | CCS_NOPARENTALIGN;

		if(this._controlInfo.Dock is DockStyle.NONE)
		{
			this._controlInfo.Dock = DockStyle.TOP;
		}

		if(this._controlInfo.Dock is DockStyle.LEFT || this._controlInfo.Dock is DockStyle.RIGHT)
		{
			pcw.Style |= CCS_VERT;
		}

		super.preCreateWindow(pcw);
	}

	protected override void onHandleCreated(EventArgs e)
	{
		this.sendMessage(TB_BUTTONSTRUCTSIZE, TBBUTTON.sizeof, 0);
		int exStyle = this.sendMessage(TB_GETEXTENDEDSTYLE, 0, 0);
		this.sendMessage(TB_SETEXTENDEDSTYLE, 0, exStyle | TBSTYLE_EX_DRAWDDARROWS);
		this.forceToolbarSize(); // HACK: Forza il ridimensionamento della barra strumenti.

		if(this._imgList)
		{
			this.sendMessage(TB_SETIMAGELIST, 0, cast(LPARAM)this._imgList.handle);
		}

		if(this._buttons)
		{
			foreach(ToolButton tb; this._buttons)
			{
				ToolBar.addItem(tb);
			}
		}

		super.onHandleCreated(e);
	}

	protected override int onReflectedMessage(uint msg, WPARAM wParam, LPARAM lParam)
	{
		switch(msg)
		{
			case WM_NOTIFY:
			{
				NMHDR* pNmhdr = cast(NMHDR*)lParam;

				switch(pNmhdr.code)
				{
					case NM_CLICK:
					{
						NMMOUSE* pNMouse = cast(NMMOUSE*)lParam;
						ToolButton tBtn = winCast!(ToolButton)(pNMouse.dwItemData);

						if(tBtn)
						{
							tBtn.onToolBarButtonClick(EventArgs.empty);
						}
					}
					break;

					case TBN_DROPDOWN:
					{
						NMTOOLBARA* pNmToolbar = cast(NMTOOLBARA*)lParam;

						Point pt = Cursor.location;
						convertPoint(pt, null, this);
						int idx = this.sendMessage(TB_HITTEST, 0, cast(LPARAM)&pt.point);

						if(idx != -1)
						{
							ToolButton tbtn = this._buttons[idx];

							if(tbtn && tbtn.contextMenu)
							{
								tbtn.contextMenu.popupMenu(this._handle, Cursor.location);
							}
						}
					}
					break;

					default:
						break;
				}
			}

			default:
				break;
		}

		return super.onReflectedMessage(msg, wParam, lParam);
	}

	protected override int wndProc(uint msg, WPARAM wParam, LPARAM lParam)
	{
		if(msg == WM_WINDOWPOSCHANGING)
		{
			/*
			 * HACK: Forza il ridimensionamento della barra strumenti.
			 */

			WINDOWPOS* pWindowPos = cast(WINDOWPOS*)lParam;
			uint sz = this.sendMessage(TB_GETBUTTONSIZE, 0, 0);

			switch(this._controlInfo.Dock)
			{
				case DockStyle.TOP, DockStyle.BOTTOM:
					pWindowPos.cy = HIWORD(sz);
					break;

				case DockStyle.LEFT, DockStyle.RIGHT:
					pWindowPos.cx = LOWORD(sz);
					break;

				default:
					break;
			}
		}

		return super.wndProc(msg, wParam, lParam);
	}
}
