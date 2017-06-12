using Uno;
using Uno.Collections;

namespace Fuse
{
	public static class FillRate
	{
		static readonly double _pixelsOnScreen;
		static readonly Rect _screen;

		static FillRate()
		{
			float2 size;
			if defined(iOS || Android)
				size = Fuse.Platform.SystemUI.Frame.Size;
			else
				size = (float2)Uno.Application.Current.Window.ClientSize;

			_pixelsOnScreen = size.X * size.Y;
			_screen = new Rect(float2(0.0f), size);

			UpdateManager.AddAction(OnUpdate);
		}

		static void OnUpdate()
		{
			if (_pixelsFilled == 0.0)
				return;

			var screenFilled = (_pixelsFilled / _pixelsOnScreen);

			debug_log("------------------------------ Pixels filled last frame: " + _pixelsFilled + ", screen filled: " + screenFilled + " times");
			foreach (var i in _frameInfo)
				debug_log(i);

			_frameInfo.Clear();
			_pixelsFilled = 0.0;
		}

		static List<string> _frameInfo = new List<string>();
		static double _pixelsFilled = 0.0;

		public static void ReportPixelsDrawn(Visual visual, float2 position, float2 size, object misc = null)
		{
			var rect = new Rect(position, size);

			if (_screen.Intersects(rect))
			{
				_pixelsFilled += (double)(size.X * size.Y);

				var m = "";
				if (misc != null)
					m = "Misc: " + misc.ToString();

				_frameInfo.Add("Drawing: " + visual + " File: " + visual.FileName + " Line: " + visual.LineNumber + " " + m + " size: " + size);
			}
		}
	}
}