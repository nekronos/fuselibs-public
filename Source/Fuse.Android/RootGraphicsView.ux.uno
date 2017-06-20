using OpenGL;
using Fuse.Controls.Native;
using Fuse.Controls;
using Uno;
using Uno.Compiler.ExportTargetInterop;
using Uno.Graphics;

namespace Fuse.Android
{

	extern(!OCULUS)
	public class RootGraphicsViewBase : GraphicsView {}

	extern(OCULUS && ANDROID)
	public class RootGraphicsViewBase : GraphicsView, IGraphicsView
	{
		protected override IGraphicsView InternalGraphicsView { get { return this; } }

		Renderer _renderer;

		public RootGraphicsViewBase()
		{
			var texture = GL.CreateTexture();
			var surfaceTexture = NewSurfaceTexture((int)texture);
			_renderer = new Renderer(surfaceTexture);
		}

		bool IGraphicsView.BeginDraw(int2 size)
		{
			debug_log("BeginDraw: " + size);
			_renderer.MakeCurrent();
			return true;
		}

		[Foreign(Language.Java)]
		Java.Object NewSurfaceTexture(int textureName)
		@{
			android.graphics.SurfaceTexture surfaceTexture = new android.graphics.SurfaceTexture(textureName);
			surfaceTexture.setOnFrameAvailableListener(new android.graphics.SurfaceTexture.OnFrameAvailableListener() {
				public void onFrameAvailable(android.graphics.SurfaceTexture surfaceTexture) {
					android.util.Log.d("XXXXXXXXXXXX", "On FRAME AVAILABLE");
				}
			});
			return surfaceTexture;
		@}

		void IGraphicsView.EndDraw()
		{
			_renderer.SwapBuffers();
			debug_log("EndDraw");
		}
	}

	[ForeignInclude(Language.Java, "com.android.grafika.gles.*", " 	android.graphics.SurfaceTexture", "android.opengl.GLES20")]
	extern(ANDROID) class Renderer
	{
		Java.Object _eglCore;
		Java.Object _windowSurface;

		public Renderer(Java.Object surfaceTexture)
		{
			_eglCore = NewEglCore();
			_windowSurface = NewWindowSurface(_eglCore, surfaceTexture);
		}

		public bool SwapBuffers() { return SwapBuffers(_windowSurface); }

		[Foreign(Language.Java)]
		bool SwapBuffers(Java.Object windowSurface)
		@{
			return ((WindowSurface)windowSurface).swapBuffers();
		@}

		[Foreign(Language.Java)]
		Java.Object NewEglCore()
		@{
			return new EglCore(null, EglCore.FLAG_TRY_GLES3);
		@}

		[Foreign(Language.Java)]
		Java.Object NewWindowSurface(Java.Object eglCore, Java.Object surfaceTexture)
		@{
			WindowSurface windowSurface = new WindowSurface((EglCore)eglCore, (SurfaceTexture)surfaceTexture);
			windowSurface.makeCurrent();
			return windowSurface;
		@}

		public void MakeCurrent() { MakeCurrent(_windowSurface); }

		[Foreign(Language.Java)]
		void MakeCurrent(Java.Object windowSurfaceHandle)
		@{
			WindowSurface windowSurface = (WindowSurface)windowSurfaceHandle;
			windowSurface.makeCurrent();
		@}

	}
}