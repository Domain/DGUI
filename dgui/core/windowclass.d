module dgui.core.windowclass;

public import dgui.core.winapi;
public import dgui.core.enums;
public import dgui.canvas;
public import std.string;

private alias WNDPROC[string] ClassMap; //Tiene traccia delle window procedure originali: [OrgClassName | OrgWndProc]

public void registerWindowClass(string className, ClassStyles classStyle, Cursor cursor, WNDPROC wndProc)
{
	static HINSTANCE hInst;
	WNDCLASSEXA wc;

	if(!hInst)
	{
		hInst = getHInstance();
	}

	bool found = cast(bool)GetClassInfoExA(hInst, toStringz(className), &wc);

	if(!found)
	{
		wc.cbSize = WNDCLASSEXA.sizeof;
		wc.lpszClassName = toStringz(className);
		wc.hCursor = cursor ? cursor.handle : null;
		wc.hInstance = hInst;
		wc.hbrBackground = GetSysColorBrush(COLOR_BTNFACE);
		wc.lpfnWndProc = wndProc;
		wc.style = classStyle;

		if(!RegisterClassExA(&wc))
		{
			debug
			{
				throw new Win32Exception(format("Windows Class \"%s\" not created", className), __FILE__, __LINE__);
			}
			else
			{
				throw new Win32Exception(format("Windows Class \"%s\" not created", className));
			}
		}
	}
}

public WNDPROC superClassWindowClass(string oldClassName, string newClassName, WNDPROC newWndProc)
{
	static HINSTANCE hInst;
	static ClassMap classMap;
	WNDCLASSEXA oldWc = void, newWc = void; //Non serve inizializzarli

	if(!hInst)
	{
		hInst = getHInstance();
	}

	oldWc.cbSize = WNDCLASSEXA.sizeof;
	newWc.cbSize = WNDCLASSEXA.sizeof;

	char* pOldClassName = toStringz(oldClassName);
	char* pNewClassName = toStringz(newClassName);

	if(!GetClassInfoExA(hInst, pNewClassName, &newWc)) // IF Classe Non Trovata THEN
	{
		// Super Classing
		GetClassInfoExA(hInst, pOldClassName, &oldWc);

		//Salvo la window procedure originale nella ClassMap
		classMap[oldClassName] = oldWc.lpfnWndProc;

		newWc = oldWc;
		newWc.style &= ClassStyles.PARENTDC | (~ClassStyles.GLOBALCLASS /*| ClassStyles.HREDRAW | ClassStyles.VREDRAW*/);
		newWc.lpfnWndProc = newWndProc;
		newWc.lpszClassName = pNewClassName;
		newWc.hInstance = hInst;
		//newWc.hbrBackground = null; //Lo disegno io (se serve).

		if(!RegisterClassExA(&newWc))
		{
			debug
			{
				throw new Win32Exception(format("Windows Class \"%s\" not created", newClassName), __FILE__, __LINE__);
			}
			else
			{
				throw new Win32Exception(format("Windows Class \"%s\" not created", newClassName));
			}
		}
	}

	return classMap[oldClassName]; //Ritorno la Window Procedure Originale
}
