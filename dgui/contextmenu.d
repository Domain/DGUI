﻿/*
	Copyright (c) 2011 - 2012 Trogu Antonio Davide

	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

module dgui.contextmenu;

private import dgui.core.geometry;
public import dgui.core.menu.abstractmenu;

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

	public override void create()
	{
		this._handle = CreatePopupMenu();
		super.create();
	}
}
