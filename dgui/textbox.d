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

public import dgui.core.winapi;
public import dgui.control;
public import std.string;

private const string WC_EDIT = "EDIT";
private const string WC_DEDIT = "DTextBox";

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

	public final bool readOnly()
	{
		return !(this.getStyle() & ES_READONLY);
	}

	public final void readOnly(bool b)
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
		this.sendMessage(WM_SETTEXT, 0, 0);
	}

	public bool modified()
	{
		if(this.created)
		{
			return cast(bool)this.sendMessage(EM_GETMODIFY, 0, 0);
		}

		return false;
	}

	public void modified(bool b)
	in
	{
		assert(this.created);
	}
	body
	{
		this.sendMessage(EM_SETMODIFY, b, 0);
	}

	public int textLength()
	{
		return this.sendMessage(WM_GETTEXTLENGTH, 0, 0);
	}

	public final string selectedText()
	{
		CHARRANGE chrg = void; //Inizializzata sotto

		this.sendMessage(EM_EXGETSEL, 0, cast(LPARAM)&chrg);
		return this.text[chrg.cpMin..chrg.cpMax];
	}

	public final int selectionStart()
	{
		CHARRANGE chrg = void; //Inizializzata sotto

		this.sendMessage(EM_EXGETSEL, 0, cast(LPARAM)&chrg);
		return chrg.cpMin;
	}

	public final int selectionLength()
	{
		CHARRANGE chrg = void; //Inizializzata sotto

		this.sendMessage(EM_EXGETSEL, 0, cast(LPARAM)&chrg);
		return chrg.cpMax - chrg.cpMin;
	}

	protected override void preCreateWindow(inout PreCreateWindow pcw)
	{
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
		this.modified = false; //Lo metto a 0 (ci puo' essere del testo inserito mentre il componente viene creato).

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
	private bool _numbersOnly = false;
	private bool _passText = false;

	public final CharacterCasing characterCasing()
	{
		return this._chChasing;
	}

	public final void characterCasing(CharacterCasing ch)
	{
		if(this.created)
		{
			this.setStyle(this._chChasing, false); //Vecchio
			this.setStyle(ch, true); //Nuovo
		}

		this._chChasing = ch;
	}

	public final void numbersOnly(bool b)
	{
		this._numbersOnly = b;

		if(this.created)
		{
			this.setStyle(ES_NUMBER, b);
		}
	}

	public final void passwordText(bool b)
	{
		this._passText = b;

		if(this.created)
		{
			this.setStyle(ES_PASSWORD, b);
		}
	}

	protected override void preCreateWindow(inout PreCreateWindow pcw)
	{
		pcw.OldClassName = WC_EDIT;
		pcw.ClassName = WC_DEDIT;
		pcw.Style |= this._chChasing;

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
}
