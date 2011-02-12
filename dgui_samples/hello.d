module hello;

import dgui.all;

class MainForm: Form
{
	public this()
	{
		this.text = "DGui Form";
		this.size = Size(500, 400);
		this.startPosition = FormStartPosition.CENTER_SCREEN; // Set Form Position
	}
}

int main(string[] args)
{
	return Application.run(new MainForm()); // Start the application
}
