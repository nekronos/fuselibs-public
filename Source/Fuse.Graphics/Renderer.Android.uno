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
using Fuse.Graphics.Commands;

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

			SwapBuffers(_windowSurface);
		}

		[Foreign(Language.Java)]
		void SwapBuffers(Java.Object windowSurface)
		@{
			((WindowSurface)windowSurface).swapBuffers();
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

	class RenderControl : IDisposable
	{
		object _surfaceTexture;
		Thread _renderingThread;
		bool _running = true;

		ConcurrentQueue<Frame> _frameQueue;

		public RenderControl(object surfaceTexture, ConcurrentQueue<Frame> frameQueue)
		{
			_surfaceTexture = surfaceTexture;
			_frameQueue = frameQueue;
			_renderingThread = new Thread(Entrypoint);
			_renderingThread.Start();
		}

		extern(!Android) void Entrypoint() {}
		extern(Android) void Entrypoint()
		{
			var renderer = new Renderer(_surfaceTexture);
			while (_running)
			{
				if defined(CPLUSPLUS)
					extern "uAutoReleasePool ____pool";

				Frame frame = null;
				if (_frameQueue.TryDequeue(out frame))
				{
					var viewport = frame.Viewport;
					foreach (var command in frame.Commands)
						command.Perform(this);
				}
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