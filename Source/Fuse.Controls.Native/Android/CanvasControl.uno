using Uno;
using Uno.Compiler.ExportTargetInterop;

using Fuse.Drawing;

namespace Fuse.Controls.Native.Android
{
	[ForeignInclude(Language.Java, "com.fuse.android.views.CanvasControl")]
	extern(ANDROID) public class CanvasControl : ViewHandle
	{
		public delegate void DrawCallback();

		public bool DrawingEnabled
		{
			get { return GetDrawingEnabled(_canvasControl); }
			set { SetDrawingEnabled(_canvasControl, value); }
		}

		public bool CallbackEnabled
		{
			get { return GetCallbackEnabled(_canvasControl); }
			set { SetCallbackEnabled(_canvasControl, value); }
		}

		public CanvasControl(DrawCallback drawCallback)
			: this(NewCanvasControl(drawCallback)) { }

		Java.Object _canvasControl;

		CanvasControl(Java.Object canvasControl)
		{
			_canvasControl = canvasControl;
		}

		[Foreign(Language.Java)]
		static void SetDrawingEnabled(Java.Object handle, bool enabled)
		@{
			((CanvasControl)handle).setDrawingEnabled(enabled);
		@}

		[Foreign(Language.Java)]
		static void SetCallbackEnabled(Java.Object handle, bool enabled)
		@{
			((CanvasControl)handle).setCallbackEnabled(enabled);
		@}

		[Foreign(Language.Java)]
		static bool GetDrawingEnabled(Java.Object handle)
		@{
			return ((CanvasControl)handle).getDrawingEnabled();
		@}

		[Foreign(Language.Java)]
		static bool GetCallbackEnabled(Java.Object handle)
		@{
			return ((CanvasControl)handle).getCallbackEnabled();
		@}

		[Foreign(Language.Java)]
		static Java.Object NewCanvasControl(Action drawCallback)
		@{
			return new CanvasControl(
				@(Activity.Package).@(Activity.Name).GetRootActivity(),
				new CanvasControl.IDrawCallback() {
					public void onDraw() {
						drawCallback.run();
					}
				});
		@}
	}
}