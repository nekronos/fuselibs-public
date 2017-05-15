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

		public void Draw(ImmutableViewport viewport)
		{
			var dc = new DrawContext(viewport);

			dc.PushViewport(viewport);
			dc.PushScissor(new Recti(0, 0, (int)viewport.PixelSize.X, (int)viewport.PixelSize.Y));
			dc.Clear(float4(0.3f, 0.3f, 0.3f, 1.0f));

			Rectangle.MakeTestRect().Draw(viewport, dc);

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

	extern(Android)
	class RenderControl : IDisposable
	{
		object _surfaceTexture;
		Thread _renderingThread;

		public RenderControl(object surfaceTexture)
		{
			_surfaceTexture = surfaceTexture;
			_renderingThread = new Thread(Entrypoint);
			_renderingThread.Start();
		}

		bool _running = true;
		void Entrypoint()
		{
			var renderer = new Renderer(_surfaceTexture);
			while (_running)
			{
				if defined(CPLUSPLUS)
					extern "uAutoReleasePool ____pool";
			}
			renderer.Dispose();
		}

		public void EnqueueFrame(ImmutableViewport viewport)
		{

		}

		public void Dispose()
		{
			_running = false;
			_renderingThread.Join();
			_renderingThread = null;
		}
	}

	extern(Android)
	class GLRenderer : ITreeRenderer, ISurfaceTextureListener
	{

		public GLRenderer()
		{

		}

		public void EnqueueFrame(ImmutableViewport viewport)
		{
			if (_renderControl != null)
			{
				_renderControl.EnqueueFrame(viewport);
			}
		}

		RenderControl _renderControl;

		void ISurfaceTextureListener.OnAvailable(object surfaceTexture, int width, int height)
		{
			_renderControl = new RenderControl(surfaceTexture);
		}

		bool ISurfaceTextureListener.OnDestroyed(object surfaceTexture)
		{
			return false;
		}

		void ISurfaceTextureListener.OnSizeChanged(object surfaceTexture, int width, int height)
		{

		}

		void ISurfaceTextureListener.OnUpdated(object surfaceTexture)
		{

		}

		int _handleCounter = 0;
		Dictionary<Element, int> _elements = new Dictionary<Element, int>();

		void ITreeRenderer.RootingStarted(Element e)
		{
			var handle = _handleCounter++;
			_elements.Add(e, handle);
		}

		void ITreeRenderer.Rooted(Element e)
		{

		}

		void ITreeRenderer.Unrooted(Element e)
		{

		}

		void ITreeRenderer.BackgroundChanged(Element e, Brush background)
		{

		}

		void ITreeRenderer.TransformChanged(Element e)
		{

		}

		void ITreeRenderer.Placed(Element e)
		{

		}

		void ITreeRenderer.IsVisibleChanged(Element e, bool isVisible)
		{

		}

		void ITreeRenderer.IsEnabledChanged(Element e, bool isEnabled)
		{

		}

		void ITreeRenderer.OpacityChanged(Element e, float opacity)
		{

		}

		void ITreeRenderer.ClipToBoundsChanged(Element e, bool clipToBounds)
		{

		}

		void ITreeRenderer.HitTestModeChanged(Element e, bool enabled)
		{

		}

		void ITreeRenderer.ZOrderChanged(Element e, List<Visual> zorder)
		{

		}

		bool ITreeRenderer.Measure(Element e, LayoutParams lp, out float2 size)
		{
			size = float2(0.0f);
			return false;
		}


	}
}