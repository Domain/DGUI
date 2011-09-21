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

module dgui.core.controls.containercontrol;

public import dgui.core.controls.control;

abstract class ContainerControl: Control
{
	protected Collection!(Control) _childControls;

	@property public final bool rtlLayout()
	{
		return cast(bool)(this.getExStyle() & WS_EX_LAYOUTRTL);
	}

	@property public final void rtlLayout(bool b)
	{
		this.setExStyle(WS_EX_LAYOUTRTL, b);
	}

	@property public final Control[] controls()
	{
		if(this._childControls)
		{
			return this._childControls.get();
		}

		return null;
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

	private void addChildControl(Control c)
	{
		if(!this._childControls)
		{
			this._childControls = new Collection!(Control);
		}

		this._childControls.add(c);

		if(this.created)
		{
			c.show();
		}
	}

	protected void doChildControls()
	{
		if(this._childControls)
		{
			foreach(Control c; this._childControls)
			{
				if(!c.created) //Extra Check: Avoid creating duplicate components (added at runtime)
				{
					c.show();
				}
			}
		}
	}

	protected override void createControlParams(ref CreateControlParams ccp)
	{
		ccp.ExtendedStyle |= WS_EX_CONTROLPARENT;
		ccp.Style |= WS_CLIPCHILDREN;

		super.createControlParams(ccp);
	}

	protected override void onDGuiMessage(ref Message m)
	{
		switch(m.Msg)
		{
			case DGUI_ADDCHILDCONTROL:
				this.addChildControl(winCast!(Control)(m.wParam));
				break;

			default:
				break;
		}

		super.onDGuiMessage(m);
	}

	protected override void onHandleCreated(EventArgs e)
	{
		this.doChildControls();
		super.onHandleCreated(e);
	}

	private void reflectMessageToChild(ref Message m)
	{
		HWND hFrom = void; //Inizializzata sotto

		switch(m.Msg)
		{
			case WM_NOTIFY:
				NMHDR* pNotify = cast(NMHDR*)m.lParam;
				hFrom = pNotify.hwndFrom;
				break;

			case WM_MEASUREITEM:
			{
				MEASUREITEMSTRUCT* pMeasureItem = cast(MEASUREITEMSTRUCT*)m.lParam;

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
				DRAWITEMSTRUCT* pDrawItem = cast(DRAWITEMSTRUCT*)m.lParam;

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
				hFrom = cast(HWND)m.lParam;
				break;
		}

		Control c = hFrom != this._handle ? this.getChildControl(hFrom) : this; //Checks if 'hFrom' is this window (useful for menus)

		if(c)
		{
			c.sendMessage(DGUI_REFLECTMESSAGE, cast(WPARAM)&m, 0);
		}
	}

	protected override void wndProc(ref Message m)
	{
		switch(m.Msg)
		{
			case WM_NOTIFY, WM_COMMAND, WM_MEASUREITEM, WM_DRAWITEM, WM_CTLCOLOREDIT, WM_CTLCOLORBTN:
			{
				//this.originalWndProc(m);

				if(ContainerControl.hasBit(this._cBits, ControlBits.CAN_NOTIFY)) //Avoid fake notification messages caused by component's properties (like text(), checked(), ...)
				{
					this.reflectMessageToChild(m);
				}
			}
			break;

			default:
				super.wndProc(m);
				break;
		}
	}
}
