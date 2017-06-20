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
			/*var texture = GL.CreateTexture();
			var surfaceTexture = NewSurfaceTexture((int)texture, OnFrameAvailable);

			UpdateManager.AddAction(OnUpdate);*/
		}

		CaptureContext _capture;

		void Initialize()
		{
			var surfaceTexture = Uno.VrEntryPoint.GetSurfaceTexture();
			if (surfaceTexture == null)
				return;

			_renderer = new Renderer(surfaceTexture);
		}

		bool IGraphicsView.BeginDraw(int2 size)
		{
			if (size.X == 0 || size.Y == 0)
			{
				debug_log("------------------------------------ GOT BAD SIZE ");
				return false;
			}

			if (_renderer == null)
				Initialize();

			if (_renderer != null)
			{
				debug_log("------------------------------------ IGraphicsView.BeginDraw( " + size + " )");
				_capture = new CaptureContext();
				_renderer.MakeCurrent();
				return true;
			}
			else
			{
				debug_log("------------------------------------ IGraphicsView.BeginDraw( NO RENDERER - InvalidateVisual() )");
				InvalidateVisual();
				return false;
			}
		}
		/*
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
		*/

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
			if (_renderer != null)
			{
				if (!_renderer.SwapBuffers())
					debug_log("IGraphicsView.EndDraw(): _renderer.SwapBuffers() failed!");
				_capture.Restore();
				_capture = null;
				debug_log("------------------------------------ IGraphicsView.EndDraw()");
			}
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

	/*[ForeignInclude(Language.Java, "android.opengl.GLES20", "java.nio.IntBuffer")]
	extern(OCULUS && ANDROID)
	public class RootGraphicsViewBase : GraphicsView, IGraphicsView
	{

		protected override IGraphicsView InternalGraphicsView { get { return this; } }

		[Foreign(Language.Java)]
		bool InitializeGL(int width, int height, int[] param)
		@{
			int[] framebufferNames = new int[1];
			GLES20.glGenFramebuffers(1, framebufferNames, 0);

			int framebufferName = framebufferNames[0];

			GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, framebufferName);

			IntBuffer renderedTexNames = IntBuffer.allocate(1);
			GLES20.glGenTextures(1, renderedTexNames);

			int textureName = renderedTexNames.array()[0];

			GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureName);

			GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_RGBA, width, height, 0, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, null);

			GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_NEAREST);
			GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST);

			GLES20.glFramebufferTexture2D(GLES20.GL_FRAMEBUFFER, GLES20.GL_COLOR_ATTACHMENT0, GLES20.GL_TEXTURE_2D, textureName, 0);

			if (GLES20.glCheckFramebufferStatus(GLES20.GL_FRAMEBUFFER) != GLES20.GL_FRAMEBUFFER_COMPLETE)
				return false;
			else
			{
				param.set(0, framebufferName);
				param.set(1, textureName);
				return true;
			}
		@}

		[Foreign(Language.Java)]
		void BindFramebuffer(int name)
		@{
			GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, name);
		@}

		int _framebufferName = 0;
		int _textureName = 0;

		bool IGraphicsView.BeginDraw(int2 size)
		{
			if (size.X == 0 || size.Y == 0)
				return false;

			debug_log("IGraphicsView.BeginDraw( " + size + " )");

			if (_framebufferName == 0)
			{
				var param = new int[2];
				var result = InitializeGL(size.X, size.Y, param);
				if (!result)
				{
					debug_log("RootGraphicsViewBase: Failed to initialize GL, framebuffer not complete");
					return false;
				}
				_framebufferName = param[0];
				_textureName = param[1];
			}

			Uno.VrEntryPoint.SetTexture(_textureName);

			BindFramebuffer(_framebufferName);
			return true;
		}

		void IGraphicsView.EndDraw()
		{
			BindFramebuffer(0);
			debug_log("IGraphicsView.EndDraw()");
		}
	}*/
}