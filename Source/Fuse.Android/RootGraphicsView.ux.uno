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

	extern(ANDROID)
	class CaptureContext
	{
		Java.Object _context;
		Java.Object _display;
		Java.Object _readSurface;
		Java.Object _drawSurface;

		public CaptureContext()
		{
			_context = GetCurrentContext();
			_display = GetCurrentDisplay();
			_readSurface = GetCurrentReadSurface();
			_drawSurface = GetCurrentDrawSurface();
		}

		[Foreign(Language.Java)]
		Java.Object GetCurrentContext()
		@{
			return android.opengl.EGL14.eglGetCurrentContext();
		@}

		[Foreign(Language.Java)]
		Java.Object GetCurrentDisplay()
		@{
			return android.opengl.EGL14.eglGetCurrentDisplay();
		@}

		[Foreign(Language.Java)]
		Java.Object GetCurrentReadSurface()
		@{
			return android.opengl.EGL14.eglGetCurrentSurface(android.opengl.EGL14.EGL_READ);
		@}

		[Foreign(Language.Java)]
		Java.Object GetCurrentDrawSurface()
		@{
			return android.opengl.EGL14.eglGetCurrentSurface(android.opengl.EGL14.EGL_DRAW);
		@}

		bool _restored = false;
		public void Restore()
		{
			if (_restored)
				return;

			_restored = true;
			RestoreCurrent(_context, _display, _readSurface, _drawSurface);
		}

		[Foreign(Language.Java)]
		void RestoreCurrent(
			Java.Object context,
			Java.Object display,
			Java.Object readSurface,
			Java.Object drawSurface)
		@{
			android.opengl.EGL14.eglMakeCurrent(
					(android.opengl.EGLDisplay)display,
					(android.opengl.EGLSurface)drawSurface,
					(android.opengl.EGLSurface)readSurface,
					(android.opengl.EGLContext)context);
		@}
	}

	extern(OCULUS && ANDROID)
	public class RootGraphicsViewBase : GraphicsView, IGraphicsView
	{
		protected override IGraphicsView InternalGraphicsView { get { return this; } }

		Renderer _renderer;

		public RootGraphicsViewBase()
		{
			var texture = GL.CreateTexture();
			var surfaceTexture = NewSurfaceTexture((int)texture, OnFrameAvailable);
			_renderer = new Renderer(surfaceTexture);
			UpdateManager.AddAction(OnUpdate);
		}

		CaptureContext _capture;

		bool IGraphicsView.BeginDraw(int2 size)
		{
			_capture = new CaptureContext();
			_renderer.MakeCurrent();
			return true;
		}

		bool _frameAvaiable = false;
		Java.Object _surfaceTexture;
		void OnFrameAvailable(Java.Object surfaceTexture)
		{
			_frameAvaiable = true;
			_surfaceTexture = surfaceTexture;
		}

		void OnUpdate()
		{
			if (_frameAvaiable)
			{
				UpdateTexImage(_surfaceTexture);
				_frameAvaiable = false;
				_surfaceTexture = null;
			}
		}

		[Foreign(Language.Java)]
		void UpdateTexImage(Java.Object handle)
		@{
			android.graphics.SurfaceTexture surfaceTexture = (android.graphics.SurfaceTexture)handle;
			surfaceTexture.updateTexImage();
		@}

		[Foreign(Language.Java)]
		Java.Object NewSurfaceTexture(int textureName, Action<Java.Object> onFrameAvailableCallback)
		@{
			android.graphics.SurfaceTexture surfaceTexture = new android.graphics.SurfaceTexture(textureName);
			surfaceTexture.setOnFrameAvailableListener(new android.graphics.SurfaceTexture.OnFrameAvailableListener() {
				public void onFrameAvailable(android.graphics.SurfaceTexture surfaceTexture) {
					onFrameAvailableCallback.run(surfaceTexture);
				}
			});
			return surfaceTexture;
		@}

		void IGraphicsView.EndDraw()
		{
			_renderer.SwapBuffers();
			_capture.Restore();
			_capture = null;
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