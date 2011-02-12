module resources;

import dgui.all;

enum
{
	IDI_MYICON   = 100,
	IDB_MYBITMAP = 200,
}

class MainForm: Form
{
	private PictureBox _pict;

	public this()
	{
		this.text = "DGui Events";
		this.size = Size(300, 250);
		this.startPosition = FormStartPosition.CENTER_SCREEN; // Set Form Position
		this.icon = Application.resources.getIcon(IDI_MYICON); //Load the icon from resource and associate it with MainForm

		this._pict = new PictureBox();
		this._pict.dock = DockStyle.FILL; // Fill the whole form area
		this._pict.sizeMode = SizeMode.AUTO_SIZE; // Stretch the image
		this._pict.image = Application.resources.getBitmap(IDB_MYBITMAP); //Load the bitmap from resources
		this._pict.parent = this;
	}
}

int main(string[] args)
{
	return Application.run(new MainForm()); // Start the application
}
