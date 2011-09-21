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

module dgui.layout.layoutcontrol;

import dgui.core.interfaces.ilayoutcontrol;
public import dgui.core.controls.containercontrol;

abstract class LayoutControl: ContainerControl, ILayoutControl
{
	public override void show()
	{
		super.show();
		this.updateLayout();
	}

	public void updateLayout()
	{
		if(this._childControls && this.created && this.visible)
		{
			Rect da = Rect(NullPoint, this.clientSize);

			foreach(Control t; this._childControls)
			{
				if(da.empty)
				{
					break;
				}

				if(t.dock !is DockStyle.NONE && t.visible && t.created)
				{
					switch(t.dock)
					{
						case DockStyle.LEFT:
							t.bounds = Rect(da.left, da.top, t.width, da.height);
							da.left += t.width;
							break;

						case DockStyle.TOP:
							t.bounds = Rect(da.left, da.top, da.width, t.height);
							da.top += t.height;
							break;

						case DockStyle.RIGHT:
							t.bounds = Rect(da.right - t.width, da.top, t.width, da.height);
							da.right -= t.width;
							break;

						case DockStyle.BOTTOM:
							t.bounds = Rect(da.left, da.bottom - t.height, da.width, t.height);
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
			}
		}
	}

	protected override void onDGuiMessage(ref Message m)
	{
		switch(m.Msg)
		{
			case DGUI_DOLAYOUT:
				this.updateLayout();
				break;

			case DGUI_CHILDCONTROLCREATED:
			{
				Control c = winCast!(Control)(m.wParam);

				if(c.dock !is DockStyle.NONE && c.visible)
				{
					this.updateLayout();
				}
			}
			break;

			default:
				break;
		}

		super.onDGuiMessage(m);
	}

	protected override void onHandleCreated(EventArgs e)
	{
		super.onHandleCreated(e);

		this.updateLayout();
	}

	protected override void onResize(EventArgs e)
	{
		this.updateLayout();

		super.onResize(e);
	}
}
