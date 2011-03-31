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

module dgui.label;

public import dgui.control;

private const string WC_STATIC = "STATIC";
private const string WC_DLABEL = "DLabel";

enum LabelDrawMode: ubyte
{
	NORMAL = 0,
	OWNER_DRAW = 1,
}

class Label: SubclassedControl
{
	private LabelDrawMode _drawMode = LabelDrawMode.NORMAL;
	private TextAlignment _textAlign = TextAlignment.MIDDLE | TextAlignment.LEFT;

	@property public final LabelDrawMode drawMode()
	{
		return this._drawMode;
	}

	@property public final void drawMode(LabelDrawMode ldm)
	{
		this._drawMode = ldm;
	}

	@property public final TextAlignment alignment()
	{
		return this._textAlign;
	}

	@property public final void alignment(TextAlignment ta)
	{
		this._textAlign = ta;
	}

	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		pcw.ClassName = WC_DLABEL;
		pcw.OldClassName = WC_STATIC;

		super.preCreateWindow(pcw);
	}

	protected override void onPaint(PaintEventArgs e)
	{
		super.onPaint(e);

		if(this._drawMode is LabelDrawMode.NORMAL)
		{
			Rect r = void; //Inizializzata da GetClientRect()
			Canvas c = e.canvas;

			GetClientRect(this._handle, &r.rect);

			//scope TextFormat tf = new TextFormat(TextFormatFlags.SINGLE_LINE);
			scope TextFormat tf = new TextFormat(TextFormatFlags.WORD_BREAK);
			tf.alignment = this._textAlign;

			scope SolidBrush sb = new SolidBrush(this._controlInfo.BackColor);
			c.fillRectangle(sb, r);
			c.drawText(this.text, r, this._controlInfo.ForeColor, this.font, tf);
		}
	}
}
