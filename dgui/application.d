﻿module dgui.application;

pragma(lib, "comdlg32.lib");
pragma(lib, "comctl32.lib");
pragma(lib, "ole32.lib");
pragma(lib, "gdi32.lib");
pragma(lib, "gdiplus.lib");

public import dgui.core.winapi;
public import dgui.resources;
private import dgui.richtextbox;
private import dgui.form;
private import dgui.button;
private import dgui.label;
private import std.path;
private import std.file;

private const string INFO = "Exception Information:";
private const string XP_MANIFEST_FILE = "dgui.xml.manifest";

private const string ERR_MSG = "An application exception has occured.\r\n1) Click \"Ignore\" to continue (The program can be unstable).\r\n2) Click \"Quit\" to exit.\r\n";


private const string XP_MANIFEST = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>` "\r\n"
									`<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">` "\r\n"
									  `<assemblyIdentity` "\r\n"
										  `version="1.0.0.0"` "\r\n"
										  `processorArchitecture="X86"` "\r\n"
										  `name="client"` "\r\n"
										  `type="win32"` "\r\n"
									  `/>` "\r\n"
									  `<description></description>` "\r\n"
									 "\r\n"
									  `<!-- Enable Windows XP and higher themes with common controls -->` "\r\n"
									  `<dependency>` "\r\n"
										`<dependentAssembly>` "\r\n"
										  `<assemblyIdentity` "\r\n"
											`type="win32"` "\r\n"
											`name="Microsoft.Windows.Common-Controls"` "\r\n"
											`version="6.0.0.0"` "\r\n"
											`processorArchitecture="X86"` "\r\n"
											`publicKeyToken="6595b64144ccf1df"` "\r\n"
											`language="*"` "\r\n"
										  `/>` "\r\n"
										`</dependentAssembly>` "\r\n"
									  `</dependency>` "\r\n"
									  "\r\n"
									  `<!-- Disable Windows Vista UAC compatibility heuristics -->` "\r\n"
									  `<trustInfo xmlns="urn:schemas-microsoft-com:asm.v2">` "\r\n"
										`<security>` "\r\n"
										  `<requestedPrivileges>` "\r\n"
											`<requestedExecutionLevel level="asInvoker"/>` "\r\n"
										  `</requestedPrivileges>` "\r\n"
										`</security>` "\r\n"
									  `</trustInfo> ` "\r\n"
									  "\r\n"
									  `<!-- Enable Windows Vista-style font scaling on Vista -->` "\r\n"
									  `<asmv3:application xmlns:asmv3="urn:schemas-microsoft-com:asm.v3">` "\r\n"
										`<asmv3:windowsSettings xmlns="http://schemas.microsoft.com/SMI/2005/WindowsSettings">` "\r\n"
										  `<dpiAware>true</dpiAware>` "\r\n"
										`</asmv3:windowsSettings>` "\r\n"
									  `</asmv3:application>` "\r\n"
									`</assembly>` "\r\n";

/*
private const string XP_MANIFEST =  `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>` "\r\n"
									  `<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">` "\r\n"
										`<description>DGui Manifest</description>` "\r\n"
											`<dependency>` "\r\n"
											`<dependentAssembly>` "\r\n"
												`<assemblyIdentity ``type="win32" ``name="Microsoft.Windows.Common-Controls" `
												`version="6.0.0.0" ``processorArchitecture="X86" ``publicKeyToken="6595b64144ccf1df" `
												`language="*" ``/>` "\r\n"
											`</dependentAssembly>` "\r\n"
										`</dependency>` "\r\n"
									`</assembly>` "\r\n";
*/

private alias extern(Windows) BOOL function(HANDLE hActCtx, ULONG_PTR* lpCookie) ActivateActCtxProc;
private alias extern(Windows) HANDLE function(ACTCTXA* pActCtx) CreateActCtxAProc;
private alias extern(Windows) bool function(INITCOMMONCONTROLSEX*) InitCommonControlsExProc;

class Application
{
	private static class ExceptionForm: Form
	{
		public this(Object e)
		{
			this.text = "An Exception was thrown...";
			this.size = Size(400, 250);
			this.controlBox = false;
			this.startPosition = FormStartPosition.CENTER_PARENT;
			this.formBorderStyle = FormBorderStyle.FIXED_DIALOG;

			this._lblHead = new Label();
			this._lblHead.alignment = ContentAlignment.MIDDLE_LEFT;
			this._lblHead.foreColor = Colors.DARK_RED;
			this._lblHead.dock = DockStyle.TOP;
			this._lblHead.height = 50;
			this._lblHead.text = ERR_MSG;
			this._lblHead.parent = this;

			this._lblInfo = new Label();
			this._lblInfo.alignment = ContentAlignment.MIDDLE_LEFT;
			this._lblInfo.dock = DockStyle.TOP;
			this._lblInfo.height = 50;
			this._lblInfo.text = INFO;
			this._lblInfo.parent = this;

			this._rtfText = new RichTextBox();
			this._rtfText.dock = DockStyle.TOP;
			this._rtfText.height = 90;
			this._rtfText.backColor = SystemColors.colorBtnFace;
			this._rtfText.scrollBars = true;
			this._rtfText.readOnly = true;
			this._rtfText.text = e.toString();
			this._rtfText.parent = this;

			this._btnQuit = new Button();
			this._btnQuit.bounds = Rect(306, 194, 80, 23);
			this._btnQuit.dialogResult = DialogResult.ABORT;
			this._btnQuit.text = "Quit";
			this._btnQuit.parent = this;

			this._btnIgnore = new Button();
			this._btnIgnore.bounds = Rect(216, 194, 80, 23);
			this._btnIgnore.dialogResult = DialogResult.IGNORE;
			this._btnIgnore.text = "Ignore";
			this._btnIgnore.parent = this;
		}

		private RichTextBox _rtfText;
		private Label _lblHead;
		private Label _lblInfo;
		private Button _btnIgnore;
		private Button _btnQuit;
	}

	private static uint _gdipTok;

	static this()
	{
		GdiplusStartupInput gsi;
		gsi.GdiplusVersion = 1;
		GdiplusStartup(&_gdipTok, &gsi, null);
	}

	public static HINSTANCE instance()
	{
		return getHInstance();
	}

	public static string executablePath()
	{
		return getExecutablePath();
	}

	public static string tempPath()
	{
		return getTempPath();
	}

	public static string startupPath()
	{
		return getStartupPath();
	}

	public static Resources resources()
	{
		return Resources.instance;
	}

	public static void enableManifest()
	{
		initCommonControls();

		HMODULE hKernel32 = GetModuleHandleA("kernel32.dll");

		if(hKernel32)
		{
			CreateActCtxAProc createActCtx = cast(CreateActCtxAProc)GetProcAddress(hKernel32, "CreateActCtxA");

			if(createActCtx) // Esiste da WinXP in su, per non perdere la compatibilita' con Win2k faccio un check
			{
				char[MAX_PATH] tempPath;

				ActivateActCtxProc activateActCtx = cast(ActivateActCtxProc)GetProcAddress(hKernel32, "ActivateActCtx");

				GetTempPathA(MAX_PATH, tempPath.ptr);
				string path = std.path.join(std.string.toString(tempPath.ptr), XP_MANIFEST_FILE);
				std.file.write(path, XP_MANIFEST);

				ACTCTXA actx;

				actx.cbSize = ACTCTXA.sizeof;
				actx.dwFlags = 0;
				actx.lpSource = toStringz(path);

				HANDLE hActx = createActCtx(&actx);

				if(hActx != INVALID_HANDLE_VALUE)
				{
					ULONG_PTR cookie;
					activateActCtx(hActx, &cookie);
				}

				std.file.remove(path);
			}
		}
	}

	private static void initCommonControls()
	{
		INITCOMMONCONTROLSEX icc = void; //Inizializzata Sotto.

		icc.dwSize = INITCOMMONCONTROLSEX.sizeof;
		icc.dwICC = 0xFFFFFFFF;

		HMODULE hComCtl32 = LoadLibraryA(toStringz("comctl32.dll"));

		if(hComCtl32)
		{
			InitCommonControlsExProc iccex = cast(InitCommonControlsExProc)GetProcAddress(hComCtl32, toStringz("InitCommonControlsEx"));
			iccex(&icc);
		}
		else
		{
			InitCommonControlsEx(&icc);
		}
	}

	public static int run(Form mainForm)
	{
		return doRun(mainForm, false);
	}

	public static void exit(int exitCode = 0)
	{
		GdiplusShutdown(_gdipTok);
		ExitProcess(exitCode);
	}

	private static int doRun(Form mainForm, bool cont)
	{
		MSG m = void; //Non serve l'inizializzazione, ci pensa GetMessage()

		try
		{
			if(!cont)
			{
				mainForm.close.attach(&onMainFormClose);
				mainForm.show();
			}

			for(;;)
			{
				while(PeekMessageA(&m, null, 0, 0, PM_REMOVE)) //Gestisci tutti i messaggi in coda
				{
					if(m.message == WM_QUIT) //Esci dal programma
					{
						break;
					}

					TranslateMessage(&m);
					DispatchMessageA(&m);
				}

				WaitMessage(); //Aspetta fino al prossimo messaggio.
			}
		}
		catch(Object e)
		{
			scope ExceptionForm ef = new ExceptionForm(e);

			switch(ef.showDialog())
			{
				case DialogResult.ABORT:
					GdiplusShutdown(_gdipTok);
					TerminateProcess(GetCurrentProcess(), -1);
					break;

				case DialogResult.IGNORE:
					return Application.doRun(mainForm, true);

				default:
					break;
			}
		}

		return m.wParam;
	}

	private static void onMainFormClose(Control sender, EventArgs e)
	{
		Application.exit();
	}
}
