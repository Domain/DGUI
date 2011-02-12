module picture;

import dgui.all;

class MainForm: Form
{
	private PictureBox _pict;

	public this()
	{
		this.text = "DGui Picture Box Text";
		this.size = Size(300, 250);
		this.startPosition = FormStartPosition.CENTER_SCREEN; // Set Form Position

		this._pict = new PictureBox();
		this._pict.dock = DockStyle.FILL;
		this._pict.sizeMode = SizeMode.AUTO_SIZE; // Stretch the image
		this._pict.image = Bitmap.fromFile("image.bmp"); //Load image from file
		this._pict.parent = this;
	}
}

int main(string[] args)
{
	return Application.run(new MainForm()); // Start the application
}
