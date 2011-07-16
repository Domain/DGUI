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

module dgui.form;

import dgui.core.utils;
import dgui.application;
import dgui.control;

private struct FormInfo
{
	MenuBar Menu;
	Icon FormIcon;
	FormStartPosition StartPosition = FormStartPosition.MANUAL;
	DialogResult Result = DialogResult.CANCEL;
	FormBorderStyle FrameBorder = FormBorderStyle.SIZEABLE;
	HWND hActiveWnd;
	bool ModalCompleted = false;
	bool IsModal = false;
	bool MaximizeBox = true;
	bool MinimizeBox = true;
	bool ControlBox = true;
	bool ShowInTaskbar = false;
}

alias CancelEventArgs!(Form) CancelFormEventArgs;

class Form: ContainerControl, IDialogResult
{
	private FormInfo _formInfo;

	public Signal!(Control, EventArgs) close;
	public Signal!(Control, CancelFormEventArgs) closing;

	@property public final void formBorderStyle(FormBorderStyle fbs)
	{
		if(this.created)
		{
			uint style, exStyle;

			makeFormBorderStyle(this._formInfo.FrameBorder, style, exStyle); // Vecchio Stile.
			this.setStyle(style, false);
			this.setExStyle(exStyle, false);

			style = 0;
			exStyle = 0;

			makeFormBorderStyle(fbs, style, exStyle); // Nuovo Stile.
			this.setStyle(style, true);
			this.setExStyle(exStyle, true);
		}

		this._formInfo.FrameBorder = fbs;
	}

	@property public final void dialogResult(DialogResult dr)
	{
		this._formInfo.Result = dr;
		this._formInfo.ModalCompleted =  true;

		ShowWindow(this._handle, SW_HIDE); // Hide this window (it waits to be destroyed)
		EnableWindow(this._formInfo.hActiveWnd, true);
		SetActiveWindow(this._formInfo.hActiveWnd); // Restore the previous active window
	}

	@property public final void controlBox(bool b)
	{
		this._formInfo.ControlBox = b;

		if(this.created)
		{
			this.setStyle(WS_SYSMENU, b);
		}
	}

	@property public final void maximizeBox(bool b)
	{
		this._formInfo.MaximizeBox = b;

		if(this.created)
		{
			this.setStyle(WS_MAXIMIZEBOX, b);
		}
	}

	@property public final void minimizeBox(bool b)
	{
		this._formInfo.MinimizeBox = b;

		if(this.created)
		{
			this.setStyle(WS_MINIMIZEBOX, b);
		}
	}

	@property public final void showInTaskbar(bool b)
	{
		this._formInfo.ShowInTaskbar = b;

		if(this.created)
		{
			this.setExStyle(WS_EX_APPWINDOW, b);
		}
	}

	@property public final MenuBar menu()
	{
		return this._formInfo.Menu;
	}

	@property public final void menu(MenuBar mb)
	{
		if(this.created)
		{
			if(this._formInfo.Menu)
			{
				this._formInfo.Menu.dispose();
			}

			mb.create();
			SetMenu(this._handle, mb.handle);
		}

		this._formInfo.Menu = mb;
	}

	@property public final Icon icon()
	{
		return this._formInfo.FormIcon;
	}

	@property public final void icon(Icon ico)
	{
		if(this.created)
		{
			if(this._formInfo.FormIcon)
			{
				this._formInfo.FormIcon.dispose();
			}

			this.sendMessage(WM_SETICON, ICON_BIG, cast(LPARAM)ico.handle);
			this.sendMessage(WM_SETICON, ICON_SMALL, cast(LPARAM)ico.handle);
		}

		this._formInfo.FormIcon = ico;
	}

	@property public final void startPosition(FormStartPosition fsp)
	{
		this._formInfo.StartPosition = fsp;
	}

	private void doEvents(bool isModal)
	{
		MSG m = void;

		while(GetMessageW(&m, null, 0, 0))
		{
			if(isModal && this._formInfo.ModalCompleted)
			{
				break;
			}
			else if(!IsDialogMessageW(this._handle, &m))
			{
				TranslateMessage(&m);
				DispatchMessageW(&m);
			}
		}
	}

	private void doShow(bool isModal = false)
	{
		try
		{
			if(!this.created)
			{
				this._formInfo.IsModal = isModal;

				if(isModal)
				{
					this._formInfo.hActiveWnd = GetActiveWindow();
					EnableWindow(this._formInfo.hActiveWnd, false);
				}

				this.create(isModal);
			}

			this.doEvents(isModal);
		}
		catch(Throwable e)
		{
			switch(Application.showExceptionForm(e))
			{
				case DialogResult.ABORT:
					TerminateProcess(GetCurrentProcess(), -1);
					break;

				case DialogResult.IGNORE:
					this.doShow(isModal);
					break;

				default:
					break;
			}
		}
	}

	public override void show()
	{
		this.doShow();
		super.show();
	}

	public final DialogResult showDialog()
	{
		this.doShow(true);
		return this._formInfo.Result;
	}

	private final void doFormStartPosition()
	{
		if((this._formInfo.StartPosition is FormStartPosition.CENTER_PARENT && !this.parent) ||
			this._formInfo.StartPosition is FormStartPosition.CENTER_SCREEN)
		{
			Rect wa = Screen.workArea;
			Rect b = this._controlInfo.Bounds;

			this._controlInfo.Bounds.location = Point((wa.width - b.width) / 2,
													  (wa.height - b.height) / 2);
		}
		else if(this._formInfo.StartPosition is FormStartPosition.CENTER_PARENT)
		{
			Rect pr = this.parent.bounds;
			Rect b = this._controlInfo.Bounds;

			this._controlInfo.Bounds.location = Point(pr.left + (pr.width - b.width) / 2,
													  pr.top + (pr.height - b.height) / 2);
		}
		else if(this._formInfo.StartPosition is FormStartPosition.DEFAULT_LOCATION)
		{
			this._controlInfo.Bounds.location = Point(CW_USEDEFAULT, CW_USEDEFAULT);
		}
	}

	private static void makeFormBorderStyle(FormBorderStyle fbs, ref uint style, ref uint exStyle)
	{
		switch(fbs)
		{
			case FormBorderStyle.FIXED_3D:
				style &= ~(WS_BORDER | WS_THICKFRAME | WS_DLGFRAME);
				exStyle &= ~(WS_EX_TOOLWINDOW | WS_EX_STATICEDGE);

				style |= WS_CAPTION;
				exStyle |= WS_EX_CLIENTEDGE | WS_EX_WINDOWEDGE | WS_EX_DLGMODALFRAME;
				break;

			case FormBorderStyle.FIXED_DIALOG:
				style &= ~(WS_BORDER | WS_THICKFRAME);
				exStyle &= ~(WS_EX_TOOLWINDOW | WS_EX_CLIENTEDGE | WS_EX_STATICEDGE);

				style |= WS_CAPTION | WS_DLGFRAME;
				exStyle |= WS_EX_DLGMODALFRAME | WS_EX_WINDOWEDGE;
				break;

			case FormBorderStyle.FIXED_SINGLE:
				style &= ~(WS_THICKFRAME | WS_DLGFRAME);
				exStyle &= ~(WS_EX_TOOLWINDOW | WS_EX_CLIENTEDGE | WS_EX_WINDOWEDGE | WS_EX_STATICEDGE);

				style |= WS_CAPTION | WS_BORDER;
				exStyle |= WS_EX_WINDOWEDGE | WS_EX_DLGMODALFRAME;
				break;

			case FormBorderStyle.FIXED_TOOLWINDOW:
				style &= ~(WS_BORDER | WS_THICKFRAME | WS_DLGFRAME);
				exStyle &= ~(WS_EX_CLIENTEDGE | WS_EX_STATICEDGE);

				style |= WS_CAPTION;
				exStyle |= WS_EX_TOOLWINDOW | WS_EX_WINDOWEDGE | WS_EX_DLGMODALFRAME;
				break;

			case FormBorderStyle.SIZEABLE:
				style &= ~(WS_BORDER | WS_DLGFRAME);
				exStyle &= ~(WS_EX_TOOLWINDOW | WS_EX_CLIENTEDGE | WS_EX_DLGMODALFRAME | WS_EX_STATICEDGE);

				style |= WS_CAPTION | WS_THICKFRAME;
				exStyle |= WS_EX_WINDOWEDGE;
				break;

			case FormBorderStyle.SIZEABLE_TOOLWINDOW:
				style &= ~(WS_BORDER | WS_DLGFRAME);
				exStyle &= ~(WS_EX_CLIENTEDGE | WS_EX_DLGMODALFRAME | WS_EX_STATICEDGE);

				style |= WS_THICKFRAME | WS_CAPTION;
				exStyle |= WS_EX_TOOLWINDOW | WS_EX_WINDOWEDGE;
				break;

			case FormBorderStyle.NONE:
				style &= ~(WS_BORDER | WS_THICKFRAME | WS_CAPTION | WS_DLGFRAME);
				exStyle &= ~(WS_EX_TOOLWINDOW | WS_EX_CLIENTEDGE | WS_EX_DLGMODALFRAME | WS_EX_STATICEDGE | WS_EX_WINDOWEDGE);
				break;

			default:
				assert(0, "Unknown Form Border Style");
				//break;
		}
	}

	private void drawMenuItemImage(DRAWITEMSTRUCT* pDrawItem)
	{
		MenuItem mi = winCast!(MenuItem)(pDrawItem.itemData);

		if(mi)
		{
			scope Canvas c = Canvas.fromHDC(pDrawItem.hDC, false); //HDC Not Owned by Canvas Object
			int icoSize = GetSystemMetrics(SM_CYMENU);
			c.drawImage(mi.rootMenu.imageList.images[mi.imageIndex], Rect(0, 0, icoSize, icoSize));
		}
	}

	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		pcw.ClassName = WC_FORM;
		pcw.DefaultCursor = SystemCursors.arrow;

		makeFormBorderStyle(this._formInfo.FrameBorder, pcw.Style, pcw.ExtendedStyle);
		this.doFormStartPosition();

		this._formInfo.ControlBox ? (pcw.Style |= WS_SYSMENU) : (pcw.Style &= ~WS_SYSMENU);

		if(this._formInfo.ControlBox)
		{
			this._formInfo.MaximizeBox ? (pcw.Style |= WS_MAXIMIZEBOX) : (pcw.Style &= ~WS_MAXIMIZEBOX);
			this._formInfo.MinimizeBox ? (pcw.Style |= WS_MINIMIZEBOX) : (pcw.Style &= ~WS_MINIMIZEBOX);
		}

		if(this._formInfo.ShowInTaskbar)
		{
			pcw.ExtendedStyle |= WS_EX_APPWINDOW;
		}

		AdjustWindowRectEx(&this._controlInfo.Bounds.rect, pcw.Style, false, pcw.ExtendedStyle);
		super.preCreateWindow(pcw);
	}

	protected override void onHandleCreated(EventArgs e)
	{
		if(this._formInfo.Menu)
		{
			this._formInfo.Menu.create();
			SetMenu(this._handle, this._formInfo.Menu.handle);
			DrawMenuBar(this._handle);
		}

		if(this._formInfo.FormIcon)
		{
			this.originalWndProc(WM_SETICON, ICON_BIG, cast(LPARAM)this._formInfo.FormIcon.handle);
			this.originalWndProc(WM_SETICON, ICON_SMALL, cast(LPARAM)this._formInfo.FormIcon.handle);
		}

		super.onHandleCreated(e); //Per ultimo: Prima deve creare il menu se no i componenti si dispongono male.
	}

	protected override int onReflectedMessage(uint msg, WPARAM wParam, LPARAM lParam)
	{
		if(msg == WM_MEASUREITEM)
		{
			MEASUREITEMSTRUCT* pMeasureItem = cast(MEASUREITEMSTRUCT*)lParam;

			if(pMeasureItem.CtlType == ODT_MENU)
			{
				MenuItem mi = winCast!(MenuItem)(pMeasureItem.itemData);

				if(mi)
				{
					if(mi.parent is this._formInfo.Menu) // Check if parent of 'mi' is the menu bar
					{
						Size sz = Canvas.measureString(" ");
						int icoSize = GetSystemMetrics(SM_CYMENU);

						pMeasureItem.itemWidth = icoSize + sz.width;
					}
					else
					{
						pMeasureItem.itemWidth = 10;
					}
				}
			}
		}
		else if(msg == WM_DRAWITEM)
		{
			DRAWITEMSTRUCT* pDrawItem = cast(DRAWITEMSTRUCT*)lParam;

			if(pDrawItem.CtlType == ODT_MENU)
			{
				this.drawMenuItemImage(pDrawItem);
			}
		}

		return super.onReflectedMessage(msg, wParam, lParam);
	}

	protected override int wndProc(uint msg, WPARAM wParam, LPARAM lParam)
	{
		switch(msg)
		{
			case WM_CLOSE:
			{
				scope CancelFormEventArgs e = new CancelFormEventArgs(this);
				this.onClosing(e);

				if(!e.cancel)
				{
					this.onClose(EventArgs.empty);

					if(this._formInfo.IsModal)
					{
						EnableWindow(this._formInfo.hActiveWnd, true);
						SetActiveWindow(this._formInfo.hActiveWnd);
					}

					return super.wndProc(msg, wParam, lParam);
				}

				return 0;
			}

			default:
				return super.wndProc(msg, wParam, lParam);
		}
	}

	protected void onClosing(CancelFormEventArgs e)
	{
		this.closing(this, e);
	}

	protected void onClose(EventArgs e)
	{
		this.close(this, e);
	}
}
