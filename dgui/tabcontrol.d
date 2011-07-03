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

module dgui.tabcontrol;

import std.utf: toUTF16z;
import dgui.imagelist;
import dgui.control;

private struct TcItem
{
	TCITEMHEADERW Header;
	TabPage Page;
}

private struct TabControlInfo
{
	TabPage SelectedPage;
	int SelectedIndex = -1;
}

enum TabAlignment
{
	TOP    = 0,
	LEFT   = TCS_VERTICAL,
	RIGHT  = TCS_VERTICAL | TCS_RIGHT,
	BOTTOM = TCS_BOTTOM,
}

class TabPage: ContainerControl
{
	private int _imgIndex;
	private TabControl _owner;

	package this()
	{
		this.initTabPage();
	}

	protected void initTabPage()
	{
		//Does Nothing
	}

	@property public final int index()
	{
		if(this._owner && this._owner.created && this._owner.tabPages)
		{
			int i = 0;

			foreach(TabPage tp; this._owner.tabPages)
			{
				if(tp is this)
				{
					return i;
				}

				i++;
			}
		}

		return -1;
	}

	@property package void tabControl(TabControl tc)
	{
		this._owner = tc;
	}

	@property public final TabControl tabControl()
	{
		return this._owner;
	}

	alias @property Control.text text;

	@property public override void text(string txt)
	{
		super.text = txt;

		if(this._owner && this._owner.created)
		{
			TcItem tci = void;

			tci.Header.mask = TCIF_TEXT;
			tci.Header.pszText = toUTF16z(txt);

			this._owner.sendMessage(TCM_SETITEMW, this.index, cast(LPARAM)&tci);
			this.redraw();
		}
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
			TcItem tci = void;

			tci.Header.mask = TCIF_IMAGE;
			tci.Header.iImage = idx;

			this._owner.sendMessage(TCM_SETITEMW, this.index, cast(LPARAM)&tci);
		}
	}

	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		pcw.ExtendedStyle |= WS_EX_STATICEDGE;
		pcw.ClassName = WC_DTABPAGE;
		pcw.DefaultCursor = SystemCursors.arrow;

		super.preCreateWindow(pcw);
	}
}

class TabControl: OwnerDrawControl, IContainerControl
{
	public Signal!(Control, CancelEventArgs) tabPageChanging;
	public Signal!(Control, EventArgs) tagPageChanged;

	private Collection!(TabPage) _tabPages;
	private ImageList _imgList;
	private int _selIndex = 0; //Di default seleziona il primo TabPage.
	private TabAlignment _ta = TabAlignment.TOP;

	public final T addPage(T: TabPage = TabPage)(string t, int imgIndex = -1)
	{
		T tp = new T();
		tp.text = t;
		tp.imageIndex = imgIndex;
		tp.visible = false;
		tp.tabControl = this;
		tp.parent = this;

		if(this.created)
		{
			this.createTabPage(tp);
		}

		return tp;
	}

	public final void removePage(int idx)
	{
		if(this.created)
		{
			this.removeTabPage(idx);
		}

		this._tabPages.removeAt(idx);
	}

	@property public final TabPage[] tabPages()
	{
		if(this._tabPages)
		{
			return this._tabPages.get();
		}

		return null;
	}

	@property public final TabPage selectedPage()
	{
		if(this._tabPages)
		{
			return this._tabPages[this._selIndex];
		}

		return null;
	}

	@property public final void selectedPage(TabPage stp)
	{
		this.selectedIndex = stp.index;
	}

	@property public final int selectedIndex()
	{
		return this._selIndex;
	}

	@property public final void selectedIndex(int idx)
	{
		if(this._tabPages)
		{
			TabPage sp = this.selectedPage; 	//Vecchio TabPage
			TabPage tp = this._tabPages[idx];	//Nuovo TabPage

			if(sp && sp !is tp)
			{
				this._selIndex = idx;
				tp.visible = true;  //Visualizzo il nuovo TabPage
				sp.visible = false; //Nascondo il vecchio TabPage
			}
			else if(sp is tp) // E' lo stesso TabPage, rendilo visibile (succede quando si aggiunge un TabPage a runtime)
			{
				/*
				 * Di default i TabPage appena creati sono nascosti.
				 */

				tp.visible = true;
			}

			if(this.created)
			{
				TabControl.adjustTabPage(tp);
			}
		}
	}

	@property public final ImageList imageList()
	{
		return this._imgList;
	}

	@property public final void imageList(ImageList imgList)
	{
		this._imgList = imgList;

		if(this.created)
		{
			this.sendMessage(TCM_SETIMAGELIST, 0, cast(LPARAM)this._imgList.handle);
		}
	}

	@property public final TabAlignment alignment()
	{
		return this._ta;
	}

	@property public final void alignment(TabAlignment ta)
	{
		this.setStyle(this._ta, false);
		this.setStyle(ta, true);

		this._ta = ta;
	}

	private static void adjustTabPage(TabPage selPage)
	{
		/*
		 * Resize TabPage e posizionamento al centro del TabControl
		 */

		Rect r, adjRect;

		TabControl tc = selPage.tabControl;
		GetClientRect(tc.handle, &r.rect);
		tc.sendMessage(TCM_ADJUSTRECT, FALSE, cast(LPARAM)&adjRect.rect);

		r.left += adjRect.left;
		r.top += adjRect.top;
		r.right += r.left + adjRect.width;
		r.bottom += r.top + adjRect.height;

		selPage.bounds = r; //Fa anche il Dock (inviati WM_WINDOWPOSCHANGED -> WM_MOVE -> WM_SIZE)
	}

	private TcItem createTabPage(TabPage tp, bool adding = true)
	{
		TcItem tci;
		tci.Header.mask = TCIF_IMAGE | TCIF_TEXT | TCIF_PARAM;
		tci.Header.iImage = tp.imageIndex;
		tci.Header.pszText = toUTF16z(tp.text);
		tci.Page = tp;

		tp.create();

		int idx = tp.index;
		this.sendMessage(TCM_INSERTITEMW, idx, cast(LPARAM)&tci);

		if(adding) //Il componente e' stato creato in precedentemente, verra' selezionato l'ultimo TabPage.
		{
			this.sendMessage(TCM_SETCURSEL, idx, 0);
			this.selectedIndex = idx;
		}

		return tci;
	}

	private void removeTabPage(int idx)
	{
		if(this._tabPages)
		{
			if(idx == this._selIndex)
			{
				this.selectedIndex = idx > 0 ? idx - 1 : 0;
			}

			if(this.created)
			{
				this.sendMessage(TCM_DELETEITEM, idx, 0);
				this.sendMessage(TCM_SETCURSEL, this._selIndex, 0); //Mi posiziono nel nuovo tab
			}

			TabPage tp = this._tabPages[idx];
			tp.dispose(); //Deallocazione Risorse.
		}
	}

	protected final void addChildControl(Control c)
	{
		if(!this._tabPages)
		{
			this._tabPages = new Collection!(TabPage)();
		}

		this._tabPages.add(cast(TabPage)c);
	}

	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		pcw.ExtendedStyle |= WS_EX_CONTROLPARENT;
		pcw.OldClassName = WC_TABCONTROL;
		pcw.ClassName = WC_DTABCONTROL;
		pcw.DefaultCursor = SystemCursors.arrow;

		super.preCreateWindow(pcw);
	}

	protected override void onHandleCreated(EventArgs e)
	{
		if(this._imgList)
		{
			this.sendMessage(TCM_SETIMAGELIST, 0, cast(LPARAM)this._imgList.handle);
		}

		if(this._tabPages)
		{
			int i;
			TcItem tci = void;

			foreach(TabPage tp; this._tabPages)
			{
				tci = this.createTabPage(tp, false);

				if(i == this._selIndex)
				{
					tp.visible = true;
					TabControl.adjustTabPage(tp);
				}

				i++;
			}

			this.selectedIndex = this._selIndex;
		}

		super.onHandleCreated(e);
	}

	protected override int onReflectedMessage(uint msg, WPARAM wParam, LPARAM lParam)
	{
		if(msg == WM_NOTIFY)
		{
			NMHDR* pNotify = cast(NMHDR*)lParam;

			switch(pNotify.code)
			{
				case TCN_SELCHANGING:
				{
					scope CancelEventArgs e = new CancelEventArgs();

					this.onTabPageChanging(e);
					return e.cancel;
				}

				case TCN_SELCHANGE:
				{
					this.selectedIndex = this.sendMessage(TCM_GETCURSEL, 0, 0);
					this.onTabPageChanged(EventArgs.empty);
					return 0;

				}

				default:
					break;
			}
		}

		return super.onReflectedMessage(msg, wParam, lParam);
	}

	protected void onTabPageChanging(CancelEventArgs e)
	{
		this.tabPageChanging(this, e);
	}

	protected void onTabPageChanged(EventArgs e)
	{
		this.tagPageChanged(this, e);
	}

	protected override int wndProc(uint msg, WPARAM wParam, LPARAM lParam)
	{
		switch(msg)
		{
			case WM_WINDOWPOSCHANGED:
			{
				WINDOWPOS* pWndPos = cast(WINDOWPOS*)lParam;

				if(!(pWndPos.flags & SWP_NOMOVE) || !(pWndPos.flags & SWP_NOSIZE))
				{
					if(this._tabPages)
					{
						TabControl.adjustTabPage(this.selectedPage);
					}
				}
			}
			break;

			default:
				break;
		}

		return super.wndProc(msg, wParam, lParam);
	}
}
