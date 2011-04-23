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

module dgui.textbox;

import std.string;
import dgui.control;

enum CharacterCasing
{
	NORMAL = 0,
	UPPERCASE = ES_UPPERCASE,
	LOWERCASE = ES_LOWERCASE,
}

abstract class TextControl: SubclassedControl
{
	public Signal!(Control, EventArgs) textChanged;

	public this()
	{

	}

	public void appendText(string s)
	{
		if(this.created)
		{
			this.sendMessage(EM_REPLACESEL, true, cast(LPARAM)toStringz(s));
		}
		else
		{
			this._controlInfo.Text ~= s;
		}
	}

	@property public final bool readOnly()
	{
		return !(this.getStyle() & ES_READONLY);
	}

	@property public final void readOnly(bool b)
	{
		this.setStyle(ES_READONLY, b);
	}

	public void undo()
	in
	{
		assert(this.created);
	}
	body
	{
		this.sendMessage(EM_UNDO, 0, 0);
	}

	public void cut()
	in
	{
		assert(this.created);
	}
	body
	{
		this.sendMessage(WM_CUT, 0, 0);
	}

	public void copy()
	in
	{
		assert(this.created);
	}
	body
	{
		this.sendMessage(WM_COPY, 0, 0);
	}

	public void paste()
	in
	{
		assert(this.created);
	}
	body
	{
		this.sendMessage(WM_PASTE, 0, 0);
	}
	public void selectAll()
	in
	{
		assert(this.created);
	}
	body
	{
		this.sendMessage(EM_SETSEL, 0, -1);
	}

	public void clear()
	in
	{
		assert(this.created);
	}
	body
	{
		this.sendMessage(WM_CLEAR, 0, 0);
	}

	@property public bool modified()
	{
		if(this.created)
		{
			return cast(bool)this.sendMessage(EM_GETMODIFY, 0, 0);
		}

		return false;
	}

	@property public void modified(bool b)
	in
	{
		assert(this.created);
	}
	body
	{
		this.sendMessage(EM_SETMODIFY, b, 0);
	}

	@property public int textLength()
	{
		return this.sendMessage(WM_GETTEXTLENGTH, 0, 0);
	}

	@property public final string selectedText()
	{
		CHARRANGE chrg = void; //Inizializzata sotto

		this.sendMessage(EM_EXGETSEL, 0, cast(LPARAM)&chrg);
		return this.text[chrg.cpMin..chrg.cpMax];
	}

	@property public final int selectionStart()
	{
		CHARRANGE chrg = void; //Inizializzata sotto

		this.sendMessage(EM_EXGETSEL, 0, cast(LPARAM)&chrg);
		return chrg.cpMin;
	}

	@property public final int selectionLength()
	{
		CHARRANGE chrg = void; //Inizializzata sotto

		this.sendMessage(EM_EXGETSEL, 0, cast(LPARAM)&chrg);
		return chrg.cpMax - chrg.cpMin;
	}

	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		pcw.Style |= WS_TABSTOP;
		pcw.ExtendedStyle = WS_EX_CLIENTEDGE;
		pcw.DefaultBackColor = SystemColors.colorWindow;

		super.preCreateWindow(pcw);
	}

	protected override int onReflectedMessage(uint msg, WPARAM wParam, LPARAM  lParam)
	{
		if(msg == WM_COMMAND)
		{
			if(HIWORD(wParam) == EN_CHANGE)
			{
				this.onTextChanged(EventArgs.empty);
			}
		}

		return super.onReflectedMessage(msg, wParam, lParam);
	}

	protected override void onHandleCreated(EventArgs e)
	{
		this.focus();
		this.modified = false; // Force to 'False'

		super.onHandleCreated(e);
	}

	protected void onTextChanged(EventArgs e)
	{
		this.textChanged(this, e);
	}
}

class TextBox: TextControl
{
	private CharacterCasing _chChasing  = CharacterCasing.NORMAL;
	private uint _maxLength = 0;
	private bool _multiline = false;
	private bool _numbersOnly = false;
	private bool _passText = false;

	@property public final bool multiline()
	{
		return this._multiline;
	}

	@property public final void multiline(bool b)
	{
		this._multiline = b;

		if(this.created)
		{
			this.setStyle(ES_MULTILINE, b);
		}
	}

	@property public final uint maxLength()
	{
		if(!this._maxLength)
		{
			if(this._multiline)
			{
				return 0xFFFFFFFF;
			}
			else
			{
				return 0xFFFFFFFE;
			}
		}

		return this._maxLength;
	}

	@property public final void maxLength(uint len)
	{
		this._maxLength = len;

		if(!len)
		{
			if(this._multiline)
			{
				len = 0xFFFFFFFF;
			}
			else
			{
				len = 0xFFFFFFFE;
			}
		}

		if(this.created)
		{
			this.sendMessage(EM_SETLIMITTEXT, len, 0);
		}
	}

	@property public final CharacterCasing characterCasing()
	{
		return this._chChasing;
	}

	@property public final void characterCasing(CharacterCasing ch)
	{
		if(this.created)
		{
			this.setStyle(this._chChasing, false); //Vecchio
			this.setStyle(ch, true); //Nuovo
		}

		this._chChasing = ch;
	}

	@property public final void numbersOnly(bool b)
	{
		this._numbersOnly = b;

		if(this.created)
		{
			this.setStyle(ES_NUMBER, b);
		}
	}

	@property public final void passwordText(bool b)
	{
		this._passText = b;

		if(this.created)
		{
			this.setStyle(ES_PASSWORD, b);
		}
	}

	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		pcw.OldClassName = WC_EDIT;
		pcw.ClassName = WC_DEDIT;
		pcw.Style |= this._chChasing | (this._multiline ? ES_MULTILINE : 0);

		if(this._numbersOnly)
		{
			pcw.Style |= ES_NUMBER;
		}

		if(this._passText)
		{
			pcw.Style |= ES_PASSWORD;
		}

		this.height = 20;
		super.preCreateWindow(pcw);
	}

	protected override void onHandleCreated(EventArgs e)
	{
		if(this._maxLength)
		{
			this.sendMessage(EM_SETLIMITTEXT, this._maxLength, 0);
		}

		super.onHandleCreated(e);
	}
}
