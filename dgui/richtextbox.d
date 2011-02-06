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

module dgui.richtextbox;

public import dgui.textbox;
public import dgui.core.winapi;

private const string WC_RICHEDIT = "RichEdit20A";
private const string WC_DRICHEDIT = "DRichTextBox";

class RichTextBox: TextControl
{
	private static _refCount = 0;
	private static HMODULE _hRichDll;

	public this()
	{

	}

	public override void dispose()
	{
		--_refCount;

		if(!_refCount)
		{
			FreeLibrary(_hRichDll);
			_hRichDll = null;
		}
	}

	public void redo()
	in
	{
		assert(this.created);
	}
	body
	{
		this.sendMessage(EM_REDO, 0, 0);
	}

	protected override void preCreateWindow(inout PreCreateWindow pcw)
	{
		++_refCount;

		if(!_hRichDll)
		{
			_hRichDll = LoadLibraryA(toStringz("riched20.dll"));
		}

		pcw.Style |= ES_MULTILINE | ES_WANTRETURN;
		pcw.OldClassName = WC_RICHEDIT;
		pcw.ClassName = WC_DRICHEDIT;

		super.preCreateWindow(pcw);
	}

	protected override void onHandleCreated(EventArgs e)
	{
		super.onHandleCreated(e);

		this.sendMessage(EM_SETEVENTMASK, 0, ENM_CHANGE | ENM_UPDATE);
		this.sendMessage(EM_SETBKGNDCOLOR, 0, ARGBtoCOLORREF(this._controlInfo.BackColor));
	}
}
