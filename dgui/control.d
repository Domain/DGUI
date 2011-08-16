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

module dgui.control;

public import dgui.core.charset;
public import dgui.core.winapi;
public import dgui.core.exception;
public import dgui.core.enums;
public import dgui.core.geometry;
public import dgui.core.collection;
public import dgui.core.events;
public import dgui.core.signal;
public import dgui.core.handle;
public import dgui.core.idisposable;
public import dgui.canvas;
public import dgui.menu;
public import std.variant;
import dgui.core.windowclass;
import dgui.core.utils;

final void convertRect(ref Rect rect, Control from, Control to)
{
	MapWindowPoints(from ? from.handle : null, to ? to.handle : null, cast(POINT*)&rect.rect, 2);
}

final void convertPoint(ref Point pt, Control from, Control to)
{
	MapWindowPoints(from ? from.handle : null, to ? to.handle : null, &pt.point, 1);
}

struct PreCreateWindow
{
	string ClassName;
	string OldClassName; //Used in Superlassing
	Color DefaultBackColor;
	Color DefaultForeColor;
	Cursor DefaultCursor;
	ClassStyles ClassStyle;
	uint ExtendedStyle = 0;
	uint Style = 0;
}

private struct ControlInfo
{
	Color ForeColor;
	Color BackColor;
	Rect Bounds;
	ContextMenu Menu;
	//ContainerControl Parent;
	Control Parent;
	ContextMenu CtxMenu;
	string Text;
	Font DefaultFont;
	Cursor DefaultCursor;
	ControlStyle CStyle = ControlStyle.NONE;
	DockStyle Dock = DockStyle.NONE;
	HBRUSH ForeBrush;
	HBRUSH BackBrush;
	uint ExtendedStyle = 0;
	uint Style = 0;
	bool MouseEnter = false;
	bool CanNotify = true;
}

mixin template TagProperty()
{
	private Variant _tt;

	/*
	 *	DMD 2052 BUG: Cannot differentiate var(T)() and var(T)(T t)
	 *	template functions, use variadic template with length check.
	 */
	@property public T[0] tag(T...)()
	{
		static assert(T.length == 1, "Multiple parameters not allowed");
		return this._tt.get!(T[0]);
	}

	@property public void tag(T)(T t)
	{
		this._tt = t;
	}
}

interface IDialogResult
{
	void dialogResult(DialogResult result);
}

interface IContainerControl
{
	void addChildControl(Control);
}

abstract class Control: Handle!(HWND), IDisposable
{
	protected Collection!(Control) _childControls;
	protected ControlInfo _controlInfo;
	private Object _tag;

	public Signal!(Control, KeyCharEventArgs) keyChar;
	public Signal!(Control, KeyEventArgs) keyDown;
	public Signal!(Control, KeyEventArgs) keyUp;
	public Signal!(Control, EventArgs) click;
	public Signal!(Control, MouseEventArgs) doubleClick;
	public Signal!(Control, MouseEventArgs) mouseKeyDown;
	public Signal!(Control, MouseEventArgs) mouseKeyUp;
	public Signal!(Control, MouseEventArgs) mouseMove;
	public Signal!(Control, MouseEventArgs) mouseEnter;
	public Signal!(Control, MouseEventArgs) mouseLeave;
	public Signal!(Control, MouseWheelEventArgs) mouseWheel;
	public Signal!(Control, ScrollEventArgs) scroll;
	public Signal!(Control, PaintEventArgs) paint;
	public Signal!(Control, EventArgs) handleCreated;
	public Signal!(Control, EventArgs) resize;
	public Signal!(Control, EventArgs) visibleChanged;

    mixin TagProperty; // Insert tag() property in Control

	public this()
	{
		this.setStyle(WS_VISIBLE, true);
	}

	public ~this()
	{
		this.dispose();
	}

	public void dispose()
	{
		if(this._controlInfo.BackBrush)
		{
			DeleteObject(this._controlInfo.BackBrush);
		}

		if(this._controlInfo.ForeBrush)
		{
			DeleteObject(this._controlInfo.ForeBrush);
		}

		if(this._handle)
		{
			/* From MSDN: Destroys the specified window.
			   The function sends WM_DESTROY and WM_NCDESTROY messages to the window
			   to deactivate it and remove the keyboard focus from it.
			   The function also destroys the window's menu, flushes the thread message queue,
			   destroys timers, removes clipboard ownership, and breaks the clipboard viewer chain
			   (if the window is at the top of the viewer chain).If the specified window is a parent
			   or owner window, DestroyWindow automatically destroys the associated child or owned
			   windows when it destroys the parent or owner window. The function first destroys child
			   or owned windows, and then it destroys the parent or owner window
			*/

			DestroyWindow(this._handle);
		}

		this._handle = null;
	}

	@property public final Control[] controls()
	{
		if(this._childControls)
		{
			return this._childControls.get();
		}

		return null;
	}

	@property public final Rect bounds()
	{
		return this._controlInfo.Bounds;
 	}

	@property public void bounds(Rect rect)
	{
		if(this.created)
		{
			this.setWindowPos(rect.left, rect.top, rect.width, rect.height, PositionSpecified.ALL);
		}
		else
		{
			this._controlInfo.Bounds = rect;
		}
	}

	@property public final BorderStyle borderStyle()
	{
		if(this.getExStyle() & WS_EX_CLIENTEDGE)
		{
			return BorderStyle.FIXED_3D;
		}
		else if(this.getStyle() & WS_BORDER)
		{
			return BorderStyle.FIXED_SINGLE;
		}

		return BorderStyle.NONE;
	}

	@property public final void borderStyle(BorderStyle bs)
	{
		switch(bs)
		{
			case BorderStyle.FIXED_3D:
				this.setStyle(WS_BORDER, false);
				this.setExStyle(WS_EX_CLIENTEDGE, true);
				break;

			case BorderStyle.FIXED_SINGLE:
				this.setStyle(WS_BORDER, true);
				this.setExStyle(WS_EX_CLIENTEDGE, false);
				break;

			case BorderStyle.NONE:
				this.setStyle(WS_BORDER, false);
				this.setExStyle(WS_EX_CLIENTEDGE, false);
				break;

			default:
				assert(0, "Unknown Border Style");
				//break;
		}
	}

	@property public final Control parent()
	{
		return this._controlInfo.Parent;
	}

	@property public final void parent(Control c)
	{
		this._controlInfo.Parent = c;

		c.setStyle(WS_CLIPCHILDREN, true);
		this.setStyle(WS_CHILD, true);
		this.setStyle(WS_CLIPSIBLINGS, true);

		IContainerControl cc = cast(IContainerControl)c;

		if(cc) //Is not a ContainerControl, associate handle only.
		{
			cc.addChildControl(this);
		}
	}

	public final Control topLevelControl()
	{
		Control topCtrl = this;

		while(topCtrl.parent)
		{
			topCtrl = topCtrl.parent;
		}

		return topCtrl;
	}

	public final Canvas createCanvas()
	{
		return Canvas.fromHDC(GetDC(this._handle));
	}

	public final void focus()
	{
		if(this.created)
		{
			SetFocus(this._handle);
		}
	}

	@property public final Color backColor()
	{
		return this._controlInfo.BackColor;
	}

	@property public final void backColor(Color c)
	{
		if(this._controlInfo.BackBrush)
		{
			DeleteObject(this._controlInfo.BackBrush);
		}

		this._controlInfo.BackColor = c;
		this._controlInfo.BackBrush = CreateSolidBrush(c.colorref);

		if(this.created)
		{
			this.redraw();
		}
	}

	@property public final Color foreColor()
	{
		return this._controlInfo.ForeColor;
	}

	@property public final void foreColor(Color c)
	{
		if(this._controlInfo.ForeBrush)
		{
			DeleteObject(this._controlInfo.ForeBrush);
		}

		this._controlInfo.ForeColor = c;
		this._controlInfo.ForeBrush = CreateSolidBrush(c.colorref);

		if(this.created)
		{
			this.redraw();
		}
	}

	@property public final bool scrollBars()
	{
		return cast(bool)(this.getStyle() & (WS_VSCROLL | WS_HSCROLL));
	}

	@property public final void scrollBars(bool b)
	{
		this.setStyle(WS_VSCROLL | WS_HSCROLL, true);
	}

	@property public final string text()
	{
		if(this.created)
		{
			return getWindowText(this._handle);
		}

		return this._controlInfo.Text;
	}

	@property public void text(string s) //Sovrascritto in TabPage
	{
		this._controlInfo.Text = s;

		if(this.created)
		{
			this._controlInfo.CanNotify = false; //Do not trigger TextChanged Event
			setWindowText(this._handle, s);
			this._controlInfo.CanNotify = true;
		}
	}

	@property public final Font font()
	{
		return this._controlInfo.DefaultFont;
	}

	@property public final void font(Font f)
	{
		if(this.created)
		{
			if(this._controlInfo.DefaultFont)
			{
				this._controlInfo.DefaultFont.dispose();
			}

			this.sendMessage(WM_SETFONT, cast(WPARAM)f.handle, true);
		}

		this._controlInfo.DefaultFont = f;
	}

	@property public final Point location()
	{
		return this.bounds.location;
	}

	@property public final void location(Point pt)
	{
		this._controlInfo.Bounds.location = pt;

		if(this.created)
		{
			this.setWindowPos(pt.x, pt.y, 0, 0, PositionSpecified.POSITION);
		}
	}

	@property public final Size size()
	{
		return this._controlInfo.Bounds.size;
 	}

	@property public final void size(Size sz)
	{
		this._controlInfo.Bounds.size = sz;

		if(this.created)
		{
			this.setWindowPos(0, 0, sz.width, sz.height, PositionSpecified.SIZE);
		}
	}

	@property public final ContextMenu contextMenu()
	{
		return this._controlInfo.CtxMenu;
	}

	@property public final void contextMenu(ContextMenu cm)
	{
		if(this._controlInfo.CtxMenu !is cm)
		{
			if(this._controlInfo.CtxMenu)
			{
				this._controlInfo.CtxMenu.dispose();
			}

			this._controlInfo.CtxMenu = cm;
		}
	}

	@property public final int width()
	{
		return this._controlInfo.Bounds.width;
	}

	@property public final void width(int w)
	{
		this._controlInfo.Bounds.width = w;

		if(this.created)
		{
			this.setWindowPos(0, 0, w, 0, PositionSpecified.WIDTH);
		}
	}

	@property public final int height()
	{
		return this._controlInfo.Bounds.height;
	}

	@property public final void height(int h)
	{
		this._controlInfo.Bounds.height = h;

		if(this.created)
		{
			this.setWindowPos(0, 0, 0, h, PositionSpecified.HEIGHT);
		}
	}

	@property public final DockStyle dock()
	{
		return this._controlInfo.Dock;
	}

	@property public final void dock(DockStyle ds)
	{
		this._controlInfo.Dock = ds;

		if(this.created)
		{
			this.doDock();
		}
	}

	@property public final Cursor cursor()
	{
		if(this.created)
		{
			return Cursor.fromHCURSOR(cast(HCURSOR)GetClassLongW(this._handle, GCL_HCURSOR), false);
		}

		return this._controlInfo.DefaultCursor;
	}

	@property public final void cursor(Cursor c)
	{
		if(this._controlInfo.DefaultCursor)
		{
			this._controlInfo.DefaultCursor.dispose();
		}

		this._controlInfo.DefaultCursor = c;

		if(this.created)
		{
			this.sendMessage(WM_SETCURSOR, cast(WPARAM)this._handle, 0);
		}
	}

	@property public final bool visible()
	{
		return cast(bool)(this.getStyle() & WS_VISIBLE);
	}

	@property public final void visible(bool b)
	{
		b ? this.show() : this.hide();
	}

	@property public final bool enabled()
	{
		return !(this.getStyle() & WS_DISABLED);
	}

	@property public final void enabled(bool b)
	{
		if(this.created)
		{
			EnableWindow(this._handle, b);
		}
		else
		{
			this.setStyle(WS_DISABLED, !b);
		}
	}

	public void show()
	{
		if(this.created)
		{
			SetWindowPos(this._handle, null, 0, 0, 0, 0, SWP_NOZORDER | SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW);

			if(this._controlInfo.Parent)
			{
				this._controlInfo.Parent.doDock();
			}
		}
		else
		{
			this.setStyle(WS_VISIBLE, true);
		}
	}

	public final void hide()
	{
		if(this.created)
		{
			SetWindowPos(this._handle, null, 0, 0, 0, 0, SWP_NOZORDER | SWP_NOMOVE | SWP_NOSIZE | SWP_HIDEWINDOW);
		}
		else
		{
			this.setStyle(WS_VISIBLE, false);
		}
	}

	public final void redraw()
	in
	{
		assert(this.created);
	}
	body
	{
		SetWindowPos(this._handle, null, 0, 0, 0, 0, SWP_NOZORDER | SWP_NOMOVE | SWP_NOSIZE | SWP_FRAMECHANGED);
	}

	public final void invalidate()
	in
	{
		assert(this.created);
	}
	body
	{
		this.invalidate(NullRect);
	}

	public final void invalidate(Rect r)
	in
	{
		assert(this.created);
	}
	body
	{
		InvalidateRect(this._handle, r == NullRect ? null : &r.rect, false);
	}

	@property protected bool ownClickMsg()
	{
		return false;
	}

	@property public void lockRedraw(bool b)
	{
		if(this.created)
		{
			this.sendMessage(WM_SETREDRAW, !b, 0);

			if(!b)
			{
				this.invalidate(); //Force Redraw
			}
		}
	}

	public final uint sendMessage(uint msg, WPARAM wParam, LPARAM lParam)
	in
	{
		assert(this.created, "Cannot send message (Handle not created)");
	}
	body
	{
		/*
		 * SendMessage() emulation
		 */

		this._controlInfo.CanNotify = false;
		int res = this.wndProc(msg, wParam, lParam);
		this._controlInfo.CanNotify = true;
		return res;
	}

	public final void doDock()
	{
		static void dockSingle(Control t, ref Rect da)
		{
			switch(t.dock)
			{
				case DockStyle.LEFT:
					t.setWindowPos(da.left, da.top, t.width, da.height, PositionSpecified.POSITION | PositionSpecified.HEIGHT);
					da.left += t.width;
					break;

				case DockStyle.TOP:
					t.setWindowPos(da.left, da.top, da.width, t.height, PositionSpecified.POSITION | PositionSpecified.WIDTH);
					da.top += t.height;
					break;

				case DockStyle.RIGHT:
					t.setWindowPos(da.right - t.width, da.top, t.width, da.height, PositionSpecified.ALL);
					da.right -= t.width;
					break;

				case DockStyle.BOTTOM:
					t.setWindowPos(da.left, da.bottom - t.height, da.width, t.height, PositionSpecified.ALL);
					da.bottom -= t.height;
					break;

				case DockStyle.FILL:
					t.bounds = da;
					da.size = NullSize;
					break;

				default:
					assert(false, "Unknown DockStyle");
					//break;
			}
		}

		if(this._childControls && this.created && this.visible && !(this._controlInfo.CStyle & ControlStyle.DOCKING))
		{
			this.setStyle(ControlStyle.DOCKING, true);

			Rect dockArea = void;
			GetClientRect(this._handle, &dockArea.rect); //Ricava la Client Area.

			foreach(Control t; this._childControls)
			{
				if(dockArea.empty)
				{
					break;
				}

				if(t.dock !is DockStyle.NONE && t.visible && t.created)
				{
					dockSingle(t, dockArea);
				}
			}

			this.setStyle(ControlStyle.DOCKING, false);
		}
	}

	private Control getChildControl(HWND hWnd)
	{
		if(this._childControls && hWnd)
		{
			foreach(Control c; this._childControls)
			{
				if(c.handle == hWnd)
				{
					return c;
				}
			}
		}

		return null;
	}

	private uint reflectMessage(uint msg, WPARAM wParam, LPARAM lParam)
	{
		HWND hFrom = void; //Inizializzata sotto

		switch(msg)
		{
			case WM_NOTIFY:
				NMHDR* pNotify = cast(NMHDR*)lParam;
				hFrom = pNotify.hwndFrom;
				break;

			case WM_MEASUREITEM:
			{
				MEASUREITEMSTRUCT* pMeasureItem = cast(MEASUREITEMSTRUCT*)lParam;

				switch(pMeasureItem.CtlType)
				{
					case ODT_COMBOBOX:
						hFrom = GetParent(cast(HWND)pMeasureItem.CtlID);
						break;

					case ODT_MENU:
						hFrom = this._handle; // Set the owner of the menu (this window)
						break;

					default:
						hFrom = cast(HWND)pMeasureItem.CtlID;
						break;
				}
			}
			break;

			case WM_DRAWITEM:
			{
				DRAWITEMSTRUCT* pDrawItem = cast(DRAWITEMSTRUCT*)lParam;

				switch(pDrawItem.CtlType)
				{
					case ODT_COMBOBOX:
						hFrom = GetParent(pDrawItem.hwndItem);
						break;

					case ODT_MENU:
						hFrom = this._handle; // Set the owner of the menu (this window)
						break;

					default:
						hFrom = cast(HWND)pDrawItem.hwndItem;
						break;
				}
			}
			break;

			default: // WM_COMMAND
				hFrom = cast(HWND)lParam;
				break;
		}

		Control c = hFrom != this._handle ? this.getChildControl(hFrom) : this; //Checks if 'hFrom' is this window (useful for menus)

		if(c)
		{
			return c.onReflectedMessage(msg, wParam, lParam);
		}

		return 0;
	}

	extern(Windows) private static LRESULT msgRouter(HWND hWnd, uint msg, WPARAM wParam, LPARAM lParam)
	{
		if(msg == WM_NCCREATE)
		{
			/*
			 * TRICK: Id == hWnd
			 * ---
			 * Inizializzazione Componente
			 */

			CREATESTRUCTW* pCreateStruct = cast(CREATESTRUCTW*)lParam;
			LPARAM param = cast(LPARAM)pCreateStruct.lpCreateParams;
			SetWindowLongW(hWnd, GWL_USERDATA, param);
			SetWindowLongW(hWnd, GWL_ID, cast(uint)hWnd);

			Control theThis = winCast!(Control)(param);
			theThis._handle = hWnd;	//Assign handle.
		}

		Control theThis = winCast!(Control)(GetWindowLongW(hWnd, GWL_USERDATA));

		if(theThis)
		{
			return theThis.wndProc(msg, wParam, lParam);
		}

		return Control.defWindowProc(hWnd, msg, wParam, lParam);
	}

	private void onMenuCommand(WPARAM wParam, LPARAM lParam)
	{
		MENUITEMINFOW minfo;

		minfo.cbSize = MENUITEMINFOW.sizeof;
		minfo.fMask = MIIM_DATA;

		if(GetMenuItemInfoW(cast(HMENU)lParam, cast(UINT)wParam, TRUE, &minfo))
		{
			MenuItem sender = winCast!(MenuItem)(minfo.dwItemData);
			sender.performClick();
		}
	}

	package final void create(bool modal = false)
	{
		PreCreateWindow pcw;
		HINSTANCE hInst = getHInstance();

		pcw.Style = this._controlInfo.Style;				 //Copio Style Attuale
		pcw.ExtendedStyle = this._controlInfo.ExtendedStyle; //Copio ExtendedStyle Attuale
		pcw.DefaultBackColor = SystemColors.colorBtnFace;
		pcw.DefaultForeColor = SystemColors.colorBtnText;

		this.preCreateWindow(pcw);

		this._controlInfo.BackBrush = CreateSolidBrush(pcw.DefaultBackColor.colorref);
		this._controlInfo.ForeBrush = CreateSolidBrush(pcw.DefaultForeColor.colorref);

		if(pcw.DefaultCursor)
		{
			this._controlInfo.DefaultCursor = pcw.DefaultCursor;
		}

		if(!this._controlInfo.DefaultFont)
		{
			this._controlInfo.DefaultFont = SystemFonts.windowsFont;
		}

		if(!this._controlInfo.BackColor.valid) // Invalid Color
		{
			this.backColor = pcw.DefaultBackColor;
		}

		if(!this._controlInfo.ForeColor.valid) // Invalid Color
		{
			this.foreColor = pcw.DefaultForeColor;
		}

		uint style = pcw.Style;

		if(modal) //E' una finestra modale?
		{
			style &= ~WS_CHILD;
			style |= WS_POPUP;
		}

		HWND hParent = null;

		if(this._controlInfo.Parent)
		{
			hParent = this._controlInfo.Parent.handle;
		}

		if(modal) //Is a modal window?
		{
			hParent = GetActiveWindow();
		}

		createWindowEx(pcw.ExtendedStyle,
					   pcw.ClassName,
					   this._controlInfo.Text,
					   style,
					   this._controlInfo.Bounds.x,
					   this._controlInfo.Bounds.y,
					   this._controlInfo.Bounds.width,
					   this._controlInfo.Bounds.height,
					   hParent,
					   winCast!(void*)(this));

		if(!this._handle)
		{
			throwException!(Win32Exception)("Control Creation failed: (ClassName: '%s', Text: '%s')",
											 pcw.ClassName, this._controlInfo.Text);
		}
	}

	protected final void scrollWindow(ScrollWindowDirection swd, int amount)
	{
		this.scrollWindow(swd, amount, NullRect);
	}

	protected final void scrollWindow(ScrollWindowDirection swd, int amount, Rect rectScroll)
	{
		if(this.created)
		{
			switch(swd)
			{
				case ScrollWindowDirection.LEFT:
					ScrollWindowEx(this._handle, amount, 0, null, rectScroll == NullRect ? null : &rectScroll.rect, null, null, SW_INVALIDATE);
					break;

				case ScrollWindowDirection.UP:
					ScrollWindowEx(this._handle, 0, amount, null, rectScroll == NullRect ? null : &rectScroll.rect, null, null, SW_INVALIDATE);
					break;

				case ScrollWindowDirection.RIGHT:
					ScrollWindowEx(this._handle, -amount, 0, null, rectScroll == NullRect ? null : &rectScroll.rect, null, null, SW_INVALIDATE);
					break;

				case ScrollWindowDirection.DOWN:
					ScrollWindowEx(this._handle, 0, -amount, null, rectScroll == NullRect ? null : &rectScroll.rect, null, null, SW_INVALIDATE);
					break;

				default:
					break;
			}
		}
	}

	protected final void setWindowPos(int x, int y, int w, int h, PositionSpecified ps)
	{
		if(ps is PositionSpecified.NONE)
		{
			return;
		}

		if(this.created)
		{
			uint wpf = SWP_NOZORDER | SWP_NOACTIVATE | SWP_NOOWNERZORDER | SWP_NOMOVE | SWP_NOSIZE;

			if(ps & PositionSpecified.X)
			{
				if(!(ps & PositionSpecified.Y))
				{
					y = this._controlInfo.Bounds.y;
				}

				wpf &= ~SWP_NOMOVE;
			}
			else if(ps & PositionSpecified.Y)
			{
				x = this._controlInfo.Bounds.x;
				wpf &= ~SWP_NOMOVE;
			}

			if(ps & PositionSpecified.WIDTH)
			{
				if(!(ps & PositionSpecified.HEIGHT))
				{
					h = this._controlInfo.Bounds.height;
				}

				wpf &= ~SWP_NOSIZE;
			}
			else if(ps & PositionSpecified.HEIGHT)
			{
				w = this._controlInfo.Bounds.width;
				wpf &= ~SWP_NOSIZE;
			}

			SetWindowPos(this._handle, null, x, y, w, h, wpf); //Bounds aggiornati in WM_WINDOWPOSCHANGED
		}
		else
		{
			if(ps & PositionSpecified.X)
			{
				this._controlInfo.Bounds.x = x;
			}

			if(ps & PositionSpecified.Y)
			{
				this._controlInfo.Bounds.y = y;
			}

			if(ps & PositionSpecified.WIDTH)
			{
				if(w < 0)
				{
					w = 0;
				}

				this._controlInfo.Bounds.width = w;
			}

			if(ps & PositionSpecified.HEIGHT)
			{
				if(h < 0)
				{
					h = 0;
				}

				this._controlInfo.Bounds.height = h;
			}
		}
	}

	protected final void initDC(HDC hdc)
	{
		SetBkColor(hdc, this.backColor.colorref);
		SetTextColor(hdc, this.foreColor.colorref);
	}

	protected final uint getStyle()
	{
		if(this.created)
		{
			return GetWindowLongW(this._handle, GWL_STYLE);
		}

		return this._controlInfo.Style;
	}

	protected final void setStyle(uint cstyle, bool set)
	{
		if(this.created)
		{
			uint style = this.getStyle();
			set ? (style |= cstyle) : (style &= ~cstyle);

			SetWindowLongW(this._handle, GWL_STYLE, style);
			this.redraw();
			this._controlInfo.Style = style;
		}
		else
		{
			set ? (this._controlInfo.Style |= cstyle) : (this._controlInfo.Style &= ~cstyle);
		}
	}

	protected final void setStyle(ControlStyle cstyle, bool set)
	{
		set ? (this._controlInfo.CStyle |= cstyle) : (this._controlInfo.CStyle &= ~cstyle);
	}

	protected final uint getExStyle()
	{
		if(this.created)
		{
			return GetWindowLongW(this._handle, GWL_EXSTYLE);
		}

		return this._controlInfo.ExtendedStyle;
	}

	protected final void setExStyle(uint cstyle, bool set)
	{
		if(this.created)
		{
			uint exStyle = this.getExStyle();
			set ? (exStyle |= cstyle) : (exStyle &= ~cstyle);

			SetWindowLongW(this._handle, GWL_EXSTYLE, exStyle);
			this.redraw();
			this._controlInfo.ExtendedStyle = exStyle;
		}
		else
		{
			set ? (this._controlInfo.ExtendedStyle |= cstyle) : (this._controlInfo.ExtendedStyle &= ~cstyle);
		}
	}

	protected void preCreateWindow(ref PreCreateWindow pcw)
	{
		ClassStyles cstyle = pcw.ClassStyle | ClassStyles.PARENTDC | ClassStyles.DBLCLKS;

		if(this._controlInfo.CStyle & ControlStyle.RESIZE_REDRAW)
		{
			cstyle |= ClassStyles.HREDRAW | ClassStyles.VREDRAW;
		}

		registerWindowClass(pcw.ClassName, cstyle, pcw.DefaultCursor, &Control.msgRouter);
	}

	protected int originalWndProc(uint msg, WPARAM wParam, LPARAM lParam)
	{
		return Control.defWindowProc(this._handle, msg, wParam, lParam);
	}

	protected static int defWindowProc(HWND hWnd, uint msg, WPARAM wParam, LPARAM lParam)
	{
		if(!IsWindowUnicode(hWnd))
		{
			return DefWindowProcA(hWnd, msg, wParam, lParam);
		}
		else
		{
			return DefWindowProcW(hWnd, msg, wParam, lParam);
		}
	}

	protected int onReflectedMessage(uint msg, WPARAM wParam, LPARAM lParam)
	{
		switch(msg)
		{
			case WM_CTLCOLOREDIT, WM_CTLCOLORBTN:
				initDC(cast(HDC)wParam);
				return cast(int)this._controlInfo.BackBrush;
				//break;

			default:
				return Control.defWindowProc(this._handle, msg, wParam, lParam);
		}
	}

	protected void onClick(EventArgs e)
	{
		this.click(this, e);
	}

	protected void onKeyUp(KeyEventArgs e)
	{
		this.keyUp(this, e);
	}

	protected void onKeyDown(KeyEventArgs e)
	{
		this.keyDown(this, e);
	}

	protected void onKeyChar(KeyCharEventArgs e)
	{
		this.keyChar(this, e);
	}

	protected void onPaint(PaintEventArgs e)
	{
		this.paint(this, e);
	}

	protected void onHandleCreated(EventArgs e)
	{
		this.handleCreated(this, e);
	}

	protected void onResize(EventArgs e)
	{
		this.resize(this, e);
	}

	protected void onVisibleChanged(EventArgs e)
	{
		this.visibleChanged(this, e);
	}

	protected void onMouseKeyDown(MouseEventArgs e)
	{
		this.mouseKeyDown(this, e);
	}

	protected void onMouseKeyUp(MouseEventArgs e)
	{
		this.mouseKeyUp(this, e);
	}

	protected void onDoubleClick(MouseEventArgs e)
	{
		this.doubleClick(this, e);
	}

	protected void onMouseMove(MouseEventArgs e)
	{
		this.mouseMove(this, e);
	}

	protected void onMouseEnter(MouseEventArgs e)
	{
		this.mouseEnter(this, e);
	}

	protected void onMouseLeave(MouseEventArgs e)
	{
		this.mouseLeave(this, e);
	}

	protected void onMouseWheel(MouseWheelEventArgs e)
	{
		this.mouseWheel(this, e);
	}

	protected void onScroll(ScrollEventArgs e)
	{
		this.scroll(this, e);
	}

	protected void onPaintBackground(HDC hdc)
	{
		RECT r = void;
		GetClientRect(this._handle, &r);
		extTextOut(hdc, 0, 0, ETO_OPAQUE, &r, "", 0, null);
	}

	protected int wndProc(uint msg, WPARAM wParam, LPARAM lParam)
	{
		switch(msg)
		{
			case WM_ERASEBKGND:
			{
				if(!(this._controlInfo.CStyle & ControlStyle.NO_ERASE))
				{
					Rect r = void;
					GetClientRect(this._handle, &r.rect);

					HDC hdc = cast(HDC)wParam;
					initDC(hdc);
					this.onPaintBackground(hdc);
				}

				return 1;
			}

			case WM_PAINT, WM_PRINTCLIENT:
			{
				PAINTSTRUCT ps; //Inizializzata da BeginPaint()
				BeginPaint(this._handle, &ps);
				initDC(ps.hdc);

				Rect r = Rect.fromRECT(&ps.rcPaint);
				scope Canvas c = Canvas.fromHDC(ps.hdc);
				scope PaintEventArgs e = new PaintEventArgs(c, r);

				if((!(this._controlInfo.CStyle & ControlStyle.NO_ERASE)) && ps.fErase)
				{
					this.onPaintBackground(ps.hdc);
				}

				this.onPaint(e);
				EndPaint(this._handle, &ps);
				return 0;
			}

			case WM_CREATE: // Aggiornamento Font, rimuove FIXED SYS
			{
				this.sendMessage(WM_SETFONT, cast(WPARAM)this._controlInfo.DefaultFont.handle, true);

				if(this._controlInfo.CtxMenu)
				{
					HMENU hDefaultMenu = GetMenu(this._handle);

					if(hDefaultMenu)
					{
						DestroyMenu(hDefaultMenu); //Distruggo il menu predefinito (se esiste)
					}

					this._controlInfo.CtxMenu.create();
				}

				this.onHandleCreated(EventArgs.empty);
				return 0; //Continua...
			}

			case WM_WINDOWPOSCHANGED:
			{
				WINDOWPOS* pWndPos = cast(WINDOWPOS*)lParam;

				if(!(pWndPos.flags & SWP_NOMOVE) || !(pWndPos.flags & SWP_NOSIZE))
				{
					/*
					this._controlInfo.Bounds.x = pWndPos.x;
					this._controlInfo.Bounds.y = pWndPos.y;
					this._controlInfo.Bounds.width = pWndPos.cx;
					this._controlInfo.Bounds.height = pWndPos.cy;
					*/

					GetWindowRect(this._handle, &this._controlInfo.Bounds.rect);

					if(this._controlInfo.Parent)
					{
						convertRect(this._controlInfo.Bounds, null, this._controlInfo.Parent);
					}

					if(!(pWndPos.flags & SWP_NOSIZE))
					{
						this.onResize(EventArgs.empty);
					}
				}
				else if(pWndPos.flags & SWP_SHOWWINDOW || pWndPos.flags & SWP_HIDEWINDOW)
				{
					if(pWndPos.flags & SWP_SHOWWINDOW)
					{
						this.doDock();
					}

					this.onVisibleChanged(EventArgs.empty);
				}

				return this.originalWndProc(msg, wParam, lParam); //Cosi' invia anche WM_SIZE
			}

			case WM_NOTIFY, WM_COMMAND, WM_MEASUREITEM, WM_DRAWITEM, WM_CTLCOLOREDIT, WM_CTLCOLORBTN:
			{
				if(this._controlInfo.CanNotify) //Avoid fake notification messages caused by component's properties (like text(), checked(), ...)
				{
					this.originalWndProc(msg, wParam, lParam);
					return this.reflectMessage(msg, wParam, lParam);
				}

				return this.originalWndProc(msg, wParam, lParam);
			}

			case WM_KEYDOWN:
			{
				scope KeyEventArgs e = new KeyEventArgs(cast(Keys)wParam);
				this.onKeyDown(e);

				if(e.handled)
				{
					return this.originalWndProc(msg, wParam, lParam);
				}

				return 0;
			}

			case WM_KEYUP:
			{
				scope KeyEventArgs e = new KeyEventArgs(cast(Keys)wParam);
				this.onKeyUp(e);

				if(e.handled)
				{
					return this.originalWndProc(msg, wParam, lParam);
				}

				return 0;
			}

			case WM_CHAR:
			{
				scope KeyCharEventArgs e = new KeyCharEventArgs(cast(Keys)wParam, cast(char)wParam);
				this.onKeyChar(e);

				if(e.handled)
				{
					return this.originalWndProc(msg, wParam, lParam);
				}

				return 0;
			}

			case WM_MOUSELEAVE:
			{
				this._controlInfo.MouseEnter = false;

				scope MouseEventArgs e = new MouseEventArgs(Point(LOWORD(lParam), HIWORD(lParam)), cast(MouseKeys)wParam);
				this.onMouseLeave(e);

				return this.originalWndProc(msg, wParam, lParam);
			}

			case WM_MOUSEMOVE:
			{
				scope MouseEventArgs e = new MouseEventArgs(Point(LOWORD(lParam), HIWORD(lParam)), cast(MouseKeys)wParam);
				this.onMouseMove(e);

				if(!this._controlInfo.MouseEnter)
				{
					this._controlInfo.MouseEnter = true;

					TRACKMOUSEEVENT tme;

					tme.cbSize = TRACKMOUSEEVENT.sizeof;
					tme.dwFlags = TME_LEAVE;
					tme.hwndTrack = this._handle;

					TrackMouseEvent(&tme);

					this.onMouseEnter(e);
				}

				return this.originalWndProc(msg, wParam, lParam);
			}

			case WM_MOUSEWHEEL:
			{
				short delta = GetWheelDelta(wParam);
				scope MouseWheelEventArgs e = new MouseWheelEventArgs(Point(LOWORD(lParam), HIWORD(lParam)),
																      cast(MouseKeys)wParam, delta > 0 ? MouseWheel.UP : MouseWheel.DOWN);
				this.onMouseWheel(e);
				return this.originalWndProc(msg, wParam, lParam);
			}

			case WM_LBUTTONDOWN, WM_MBUTTONDOWN, WM_RBUTTONDOWN:
			{
				scope MouseEventArgs e = new MouseEventArgs(Point(LOWORD(lParam), HIWORD(lParam)), cast(MouseKeys)wParam);
				this.onMouseKeyDown(e);

				return this.originalWndProc(msg, wParam, lParam);
			}

			case WM_LBUTTONUP, WM_MBUTTONUP, WM_RBUTTONUP:
			{
				MouseKeys mk = MouseKeys.NONE;

				if(GetAsyncKeyState(MK_LBUTTON))
				{
					mk |= MouseKeys.LEFT;
				}

				if(GetAsyncKeyState(MK_MBUTTON))
				{
					mk |= MouseKeys.MIDDLE;
				}

				if(GetAsyncKeyState(MK_RBUTTON))
				{
					mk |= MouseKeys.RIGHT;
				}

				Point p = Point(LOWORD(lParam), HIWORD(lParam));
				scope MouseEventArgs e = new MouseEventArgs(p, mk);
				this.onMouseKeyUp(e);

				convertPoint(p, this, null);

				if(msg == WM_LBUTTONUP && !this.ownClickMsg && WindowFromPoint(p.point) == this._handle)
				{
					this.onClick(EventArgs.empty);
				}

				return this.originalWndProc(msg, wParam, lParam);
			}

			case WM_LBUTTONDBLCLK, WM_MBUTTONDBLCLK, WM_RBUTTONDBLCLK:
			{
				scope MouseEventArgs e = new MouseEventArgs(Point(LOWORD(lParam), HIWORD(lParam)), cast(MouseKeys)wParam);
				this.onDoubleClick(e);

				return this.originalWndProc(msg, wParam, lParam);
			}

			case WM_VSCROLL, WM_HSCROLL:
			{
				ScrollDirection sd = msg == WM_VSCROLL ? ScrollDirection.VERTICAL : ScrollDirection.HORIZONTAL;
				ScrollMode sm = cast(ScrollMode)wParam;

				scope ScrollEventArgs e = new ScrollEventArgs(sd, sm);
				this.onScroll(e);

				return this.originalWndProc(msg, wParam, lParam);
			}

			case WM_SETCURSOR:
			{
				if(this._controlInfo.DefaultCursor && cast(LONG)this._controlInfo.DefaultCursor.handle != GetClassLongW(this._handle, GCL_HCURSOR))
				{
					SetClassLongW(this._handle, GCL_HCURSOR, cast(LONG)this._controlInfo.DefaultCursor.handle);
				}

				return this.originalWndProc(msg, wParam, lParam); //Continuo selezione cursore
			}

			case WM_MENUCOMMAND:
				this.onMenuCommand(wParam, lParam);
				return 0;

			case WM_CONTEXTMENU:
			{
				if(this._controlInfo.CtxMenu)
				{
					this._controlInfo.CtxMenu.popupMenu(this._handle, Cursor.location);
				}

				return this.originalWndProc(msg, wParam, lParam);
			}

			case WM_INITMENU:
			{
				if(this._controlInfo.CtxMenu)
				{
					this._controlInfo.CtxMenu.onPopup(EventArgs.empty);
				}

				return 0;
			}

			default:
				return this.originalWndProc(msg, wParam, lParam); //Processa il messaggio col codice originale
		}
	}
}

abstract class SubclassedControl: Control
{
	private WNDPROC _oldWndProc; // Window procedure originale

	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		this._oldWndProc = superClassWindowClass(pcw.OldClassName, pcw.ClassName, &SubclassedControl.msgRouter);
	}

	protected override void onPaintBackground(HDC hdc)
	{
		this.originalWndProc(WM_ERASEBKGND, cast(WPARAM)hdc, 0);
	}

	protected override int originalWndProc(uint msg, WPARAM wParam, LPARAM lParam)
	{
		if(!IsWindowUnicode(this._handle))
		{
			return CallWindowProcA(this._oldWndProc, this._handle, msg, wParam, lParam);
		}
		else
		{
			return CallWindowProcW(this._oldWndProc, this._handle, msg, wParam, lParam);
		}
	}

	protected override int wndProc(uint msg, WPARAM wParam, LPARAM lParam)
	{
		switch(msg)
		{
			case WM_PAINT:
			{
				if(this._controlInfo.CStyle & ControlStyle.USER_PAINT)
				{
					return super.wndProc(msg, wParam, lParam);
				}
				else
				{
					Rect r = void; // Inizializzato da GetUpdateRect()
					GetUpdateRect(this._handle, &r.rect, false); //Conserva area da disegnare
					this.originalWndProc(msg, wParam, lParam);

					HDC hdc = GetDC(this._handle);
					HRGN hRgn = CreateRectRgnIndirect(&r.rect);
					SelectClipRgn(hdc, hRgn);
					DeleteObject(hRgn);

					initDC(hdc);
					scope Canvas c = Canvas.fromHDC(hdc);
					scope PaintEventArgs e = new PaintEventArgs(c, r);
					this.onPaint(e);

					ReleaseDC(this._handle, hdc);
				}

				return 0;
			}

			case WM_PRINTCLIENT:
				return this.originalWndProc(msg, wParam, lParam);

			case WM_CREATE:
				this.originalWndProc(msg, wParam, lParam); //Gestisco prima il messaggio originale
				return super.wndProc(msg, wParam, lParam);

			default:
				return super.wndProc(msg, wParam, lParam);
		}
	}
}

abstract class ContainerControl: Control, IContainerControl
{
	protected final void addChildControl(Control c)
	{
		if(!this._childControls)
		{
			this._childControls = new Collection!(Control);
		}

		this._childControls.add(cast(Control)c);

		if(this.created)
		{
			c.create();

			if(c.dock !is DockStyle.NONE)
			{
				this.doDock();
			}
		}
	}

	protected final void doChildControls()
	{
		if(this.controls)
		{
			foreach(Control c; this.controls)
			{
				if(!c.created) //Extra Check: Avoid creating duplicate components (added at runtime)
				{
					c.create();
					this.doDock();
				}
			}
		}
	}

	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		pcw.ExtendedStyle |= WS_EX_CONTROLPARENT;

		super.preCreateWindow(pcw);
	}

	protected override void onHandleCreated(EventArgs e)
	{
		this.doChildControls();   //Create compile-time components first...
		this.doDock(); //...dock it...
		super.onHandleCreated(e); //...handle runtime created components.
	}

	protected override void onResize(EventArgs e)
	{
		this.doDock();
		super.onResize(e);
	}

	protected override int wndProc(uint msg, WPARAM wParam, LPARAM lParam)
	{
		switch(msg)
		{
			case WM_CLOSE:
				super.wndProc(msg, wParam, lParam);
				//this.dispose();
				return 0;

			default:
				return super.wndProc(msg, wParam, lParam);
		}
	}
}

abstract class OwnerDrawControl: SubclassedControl
{
	public Signal!(Control, MeasureItemEventArgs) measureItem;
	public Signal!(Control, DrawItemEventArgs) drawItem;

	protected ItemDrawMode _drawMode = ItemDrawMode.NORMAL;

	@property public ItemDrawMode drawMode()
	{
		return this._drawMode;
	}

	@property public void drawMode(ItemDrawMode dm)
	{
		this._drawMode = dm;
	}

	protected void onMeasureItem(MeasureItemEventArgs e)
	{
		this.measureItem(this, e);
	}

	protected void onDrawItem(DrawItemEventArgs e)
	{
		this.drawItem(this, e);
	}

	protected override int onReflectedMessage(uint msg, WPARAM wParam, LPARAM lParam)
	{
		switch(msg)
		{
			case WM_MEASUREITEM:
			{
				MEASUREITEMSTRUCT* pMeasureItem = cast(MEASUREITEMSTRUCT*)lParam;
				HDC hdc = GetDC(this._handle);
				initDC(hdc);

				scope Canvas c = Canvas.fromHDC(hdc);
				scope MeasureItemEventArgs e = new MeasureItemEventArgs(c, pMeasureItem.itemWidth, pMeasureItem.itemHeight,
																		   pMeasureItem.itemID);

				this.onMeasureItem(e);

				if(e.width)
				{
					pMeasureItem.itemWidth = e.width;
				}

				if(e.height)
				{
					pMeasureItem.itemHeight = e.height;
				}

				ReleaseDC(this._handle, null);
			}
			break;

			case WM_DRAWITEM:
			{
				DRAWITEMSTRUCT* pDrawItem = cast(DRAWITEMSTRUCT*)lParam;
				Rect r = Rect.fromRECT(&pDrawItem.rcItem);

				Color fc, bc;

				if(pDrawItem.itemState & ODS_SELECTED)
				{
					fc = SystemColors.colorHighLightText;
					bc = SystemColors.colorHighLight;
				}
				else
				{
					fc = this.foreColor;
					bc = this.backColor;
				}

				scope Canvas c = Canvas.fromHDC(pDrawItem.hDC);
				scope DrawItemEventArgs e = new DrawItemEventArgs(c, cast(DrawItemState)pDrawItem.itemState,
																  r, fc, bc, pDrawItem.itemID);

				this.onDrawItem(e);
			}
			break;

			default:
				break;
		}

		return super.onReflectedMessage(msg, wParam, lParam);
	}
}
