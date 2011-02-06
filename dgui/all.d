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

/*
 * From: http://msdn.microsoft.com/en-us/library/bb776779%28VS.85%29.aspx
 *
 * Version	DLL				Distribution Platform
 * -------  --------------  -----------------------
 * 4.0		All				Windows 95 and Windows NT 4.0
 * 4.7		All				Windows Internet Explorer 3.x
 * 4.71		All				Internet Explorer 4.0. See note 2.
 * 4.72		All				Internet Explorer 4.01 and Windows 98. See note 2.
 * 5.0		Shlwapi.dll		Internet Explorer 5 and Windows 98 SE. See note 3.
 * 5.5		Shlwapi.dll		Internet Explorer 5.5 and Windows Millennium Edition (Windows Me)
 * 6.0		Shlwapi.dll		Windows XP and Windows Vista
 * 5.0		Shell32.dll		Windows 2000 and Windows Me. See note 3.
 * 6.0		Shell32.dll		Windows XP
 * 6.0.1	Shell32.dll		Windows Vista
 * 6.1		Shell32.dll		Windows 7
 * 5.8		Comctl32.dll	Internet Explorer 5. See note 3.
 * 5.81		Comctl32.dll	Windows 2000 and Windows Me. See note 3.
 * 5.82		Comctl32.dll	Windows XP and Windows Vista. See note 4.
 * 6.0		Comctl32.dll	Windows XP, Windows Vista and Windows 7. (Not redistributable)
 *
 * NOTE 1
 * The 4.00 versions of Shell32.dll and Comctl32.dll are found on the original
 * versions of Windows 95 and Windows NT 4.0. New versions of Commctl.dll were shipped
 * with all Internet Explorer releases. Shlwapi.dll shipped with Internet Explorer 4.0,
 * so its initial version number here is 4.71. The Shell was not updated with the Internet Explorer 3.0 release,
 * so Shell32.dll does not have a version 4.70.
 * While Shell32.dll versions 4.71 and 4.72 were shipped with the corresponding Internet Explorer releases,
 * they were not necessarily installed (see note 2).
 * For subsequent releases, the version numbers for the three DLLs are not identical.
 * In general, you should assume that all three DLLs may have different version numbers,
 * and test each one separately.
 *
 * NOTE 2
 * All systems with Internet Explorer 4.0 or 4.01 will have the associated version of Comctl32.dll
 * and Shlwapi.dll (4.71 or 4.72, respectively). However, for systems prior to Windows 98,
 * Internet Explorer 4.0 and 4.01 can be installed with or without the integrated Shell.
 * If they are installed with the integrated Shell, the associated version of Shell32.dll will be installed.
 * If they are installed without the integrated Shell, Shell32.dll is not updated.
 * No other versions of Internet Explorer update Shell32.dll. In other words, the presence of
 * version 4.71 or 4.72 of Comctl32.dll or Shlwapi.dll on a system does not guarantee that Shell32.dll
 * has the same version number. All Windows 98 systems have version 4.72 of Shell32.dll.
 *
 * NOTE 3
 * Version 5.80 of Comctl32.dll and version 5.0 of Shlwapi.dll are distributed with Internet Explorer 5.
 * They will be found on all systems on which Internet Explorer 5 is installed, except Windows 2000.
 * Internet Explorer 5 does not update the Shell, so version 5.0 of Shell32.dll will not be found on Windows NT,
 * Windows 95, or Windows 98 systems.
 * Version 5.0 of Shell32.dll will be distributed with Windows 2000 and Windows Me,
 * along with version 5.0 of Shlwapi.dll, and version 5.81 of Comctl32.dll.
 *
 * NOTE 4
 * ComCtl32.dll version 6 is not redistributable.
 * If you want your application to use ComCtl32.dll version 6,
 * you must add an application manifest that indicates that version 6 should be used if it is available.
 *
 */

module dgui.all;

public import dgui.application;
public import dgui.messagebox/*, dgui.imagelist*/;
public import /*dgui.menu,*/ dgui.toolbar, dgui.statusbar;
public import dgui.colordialog, dgui.folderbrowserdialog, dgui.fontdialog, dgui.openfiledialog, dgui.savefiledialog;
public import dgui.form, dgui.button, dgui.label, dgui.textbox, dgui.richtextbox, dgui.panel, dgui.tabcontrol,
			  dgui.combobox, dgui.listbox, dgui.listview, dgui.treeview, dgui.picturebox, dgui.splitter;
