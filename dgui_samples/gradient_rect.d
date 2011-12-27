module gradient_rect;

import dgui.all;

class MainForm: Form
{
	public this()
	{
		this.text = "GDI: Gradient Fill Rect";
		this.size = Size(400, 200);
		this.startPosition = FormStartPosition.CENTER_SCREEN;
	}

	protected override void onPaint(PaintEventArgs e)
	{
		Canvas c = e.canvas;

		c.fillRectGradient(Rect(NullPoint, this.size), SystemColors.blue, SystemColors.green, GradientFillRectMode.VERTICAL);
		super.onPaint(e);
	}
}

int main(string[] args)
{
	return Application.run(new MainForm()); // Start the application
}
