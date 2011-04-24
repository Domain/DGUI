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

module dgui.picturebox;

import dgui.control;
import dgui.canvas;

enum SizeMode
{
	NORMAL = 0,
	AUTO_SIZE = 1,
}

class PictureBox: Control
{
	private SizeMode _sm = SizeMode.NORMAL;
	private Image _img;

	public override void dispose()
	{
		if(this._img)
		{
			this._img.dispose();
			this._img = null;
		}

		super.dispose();
	}

	alias @property Control.bounds bounds;

	@property public override void bounds(Rect r)
	{
		if(this._img && this._sm is SizeMode.AUTO_SIZE)
		{
			// Ignora 'r.size' e usa la dimensione dell'immagine
			Size sz = r.size;
			super.bounds = Rect(r.x, r.y, sz.width, sz.height);

		}
		else
		{
			super.bounds = r;
		}
	}

	@property public final SizeMode sizeMode()
	{
		return this._sm;
	}

	@property public final void sizeMode(SizeMode sm)
	{
		this._sm = sm;

		if(this.created)
		{
			this.redraw();
		}
	}

	@property public final Image image()
	{
		return this._img;
	}

	@property public final void image(Image img)
	{
		if(this._img)
		{
			this._img.dispose(); //Distruggo l'immagine precedente
		}

		this._img = img;

		if(this.created)
		{
			this.redraw();
		}
	}

	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		pcw.ClassName  = WC_DPICTUREBOX;
		pcw.DefaultCursor = SystemCursors.arrow;
		pcw.ClassStyle = ClassStyles.HREDRAW | ClassStyles.VREDRAW;

		this.setStyle(ControlStyle.NO_ERASE, true);
		super.preCreateWindow(pcw);
	}

	protected override void onPaint(PaintEventArgs e)
	{
		if(this._img)
		{
			Canvas c = e.canvas;

			switch(this._sm)
			{
				case SizeMode.AUTO_SIZE:
					c.drawImage(this._img, Rect(NullPoint, this.size));
					break;

				default:
					c.drawImage(this._img, 0, 0);
					break;
			}
		}

		super.onPaint(e);
	}
}
