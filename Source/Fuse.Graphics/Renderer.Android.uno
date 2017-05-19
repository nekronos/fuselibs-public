using Uno;
using Uno.UX;
using Uno.Collections;
using Uno.Threading;
using Fuse;
using Fuse.Drawing;
using Fuse.Elements;
using Uno.Graphics;
using Uno.Compiler.ExportTargetInterop;
using Fuse.Graphics.Android;
using OpenGL;

namespace Fuse.Graphics
{
	[ForeignInclude(Language.Java, "com.android.grafika.gles.*", " 	android.graphics.SurfaceTexture", "android.opengl.GLES20")]
	extern(Android) class Renderer : IDisposable
	{
		object _surfaceTexture;

		Java.Object _eglCore;
		Java.Object _windowSurface;

		public Renderer(object surfaceTexture)
		{
			_surfaceTexture = surfaceTexture;
			_eglCore = NewEglCore();
			_windowSurface = NewWindowSurface(_eglCore, (Java.Object)_surfaceTexture);
		}

		public void Draw(ImmutableViewport viewport, List<Drawable> drawables)
		{
			var dc = new DrawContext(viewport);

			dc.PushViewport(viewport);
			dc.PushScissor(new Recti(0, 0, (int)viewport.PixelSize.X, (int)viewport.PixelSize.Y));
			dc.Clear(float4(0.3f, 0.3f, 0.3f, 1.0f));

			foreach (var drawable in drawables)
				drawable.Draw(viewport, dc);

			dc.PopScissor();
			dc.PopViewport();

			GL.Flush();
			GL.Finish();

			SwapBuffers(_windowSurface);
		}

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

		public void Dispose(){}
	}

	class Frame
	{
		public readonly ImmutableViewport Viewport;
		public readonly Command[] Commands;

		public Frame(ImmutableViewport viewport, Command[] commands)
		{
			Viewport = viewport;
			Commands = commands;
		}
	}

	class DrawableControl
	{
		Dictionary<Handle, Drawable> _drawables = new Dictionary<Handle,Drawable>();
		List<Drawable> _renderingList = new List<Drawable>();

		public List<Drawable> RenderingList
		{
			get { return _renderingList; }
		}

		public void Root(Handle handle, Drawable drawable)
		{
			_drawables.Add(handle, drawable);
			_renderingList.Add(drawable);
		}

		public void Unroot(Handle handle)
		{
			Drawable drawable;
			if (_drawables.TryGetValue(handle, out drawable))
			{
				_renderingList.Remove(drawable);
				drawable.Dispose();
				_drawables.Remove(handle);
			}
		}

		public bool TryGetDrawable(Handle handle, out Drawable drawable)
		{
			return _drawables.TryGetValue(handle, out drawable);
		}
	}

	class RenderControl : IDisposable
	{
		object _surfaceTexture;
		Thread _renderingThread;
		bool _running = true;

		ConcurrentQueue<Frame> _frameQueue = new ConcurrentQueue<Frame>();
		AutoResetEvent _resetEvent = new AutoResetEvent(true);

		public RenderControl(object surfaceTexture)
		{
			_surfaceTexture = surfaceTexture;
			_renderingThread = new Thread(Entrypoint);
			_renderingThread.Start();
		}

		public void EnqueueFrame(Frame frame)
		{
			_frameQueue.Enqueue(frame);
			_resetEvent.Set();
		}

		extern(!Android) void Entrypoint() {}
		extern(Android) void Entrypoint()
		{
			var drawableControl = new DrawableControl();
			var renderer = new Renderer(_surfaceTexture);
			while (_running)
			{
				_resetEvent.WaitOne();
				var t1 = Uno.Diagnostics.Clock.GetSeconds();
				if defined(CPLUSPLUS)
					extern "uAutoReleasePool ____pool";

				Frame frame = null;
				while (_frameQueue.TryDequeue(out frame))
				{
					foreach (var command in frame.Commands)
						command.Perform(drawableControl);

					renderer.Draw(frame.Viewport, drawableControl.RenderingList);
				}
				var t2 = Uno.Diagnostics.Clock.GetSeconds();
				//debug_log("Frametime: " + ((t2 - t1) * 1000.0) + " ms");
			}
			renderer.Dispose();
		}

		public void Dispose()
		{
			_running = false;
			_renderingThread.Join();
			_renderingThread = null;
		}
	}
}