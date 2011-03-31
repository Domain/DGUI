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

module dgui.panel;

public import dgui.control;

private const string WC_DPANEL = "DPanel";

class Panel: ContainerControl
{
	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		pcw.ClassName = WC_DPANEL;

		super.preCreateWindow(pcw);
	}
}
