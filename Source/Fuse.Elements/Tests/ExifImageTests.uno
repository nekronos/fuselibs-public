using Fuse.Controls;
using Fuse.Resources;
using Uno.IO;
using Uno.UX;
using Uno.Compiler;
using Uno.Testing;
using Fuse.Elements;
using FuseTest;

public class ExifImageTests
{
	//0.01 due to JPG not being very accurate
	const float ErrorMargin = 0.01f;

	void AssertImageHasBeenOrientedCorrectly(FileSource source, [CallerFilePath] string filePath = "", [CallerLineNumber] int lineNumber = 0)
	{
		var image = new Image();
		var imageSource = new FileImageSource(source);
		image.Source = imageSource;
		using (var testRootPanel = TestRootPanel.CreateWithChild(image, int2(8)))
		{
			using (var fb = testRootPanel.CaptureDraw())
			{
				fb.AssertPixel(float4(0,0,0,1), int2(2,6), ErrorMargin, filePath, lineNumber);
				fb.AssertPixel(float4(1,0,0,1), int2(6,6), ErrorMargin, filePath, lineNumber);
				fb.AssertPixel(float4(0,1,0,1), int2(2,2), ErrorMargin, filePath, lineNumber);
				fb.AssertPixel(float4(1,1,0,1), int2(6,2), ErrorMargin, filePath, lineNumber);
			}
		}
	}

	[Test]
	[Ignore("Only supported on dotnet, Android or iOS", "MSVC || CMake")]
	public void TestOrientations()
	{
		AssertImageHasBeenOrientedCorrectly(import("Assets/_1.jpg"));
		AssertImageHasBeenOrientedCorrectly(import("Assets/_2.jpg"));
		AssertImageHasBeenOrientedCorrectly(import("Assets/_3.jpg"));
		AssertImageHasBeenOrientedCorrectly(import("Assets/_4.jpg"));
		AssertImageHasBeenOrientedCorrectly(import("Assets/_5.jpg"));
		AssertImageHasBeenOrientedCorrectly(import("Assets/_6.jpg"));
		AssertImageHasBeenOrientedCorrectly(import("Assets/_7.jpg"));
		AssertImageHasBeenOrientedCorrectly(import("Assets/_8.jpg"));
	}
}
