using Uno;
using Uno.UX;
using Uno.Collections;
using Uno.Threading;
using Fuse;
using Fuse.Drawing;
using Fuse.Elements;
using Fuse.Controls;
using Uno.Graphics;
using Uno.Compiler.ExportTargetInterop;
using Fuse.Graphics.Android;

namespace Fuse.Graphics
{
	class GLRenderer : ITreeRenderer, ISurfaceTextureListener
	{

		public GLRenderer()
		{

		}

		public void EnqueueFrame(ImmutableViewport viewport)
		{
			if (_renderControl != null)
				_renderControl.EnqueueFrame(new Frame(viewport, CollectCommands()));
		}

		Command[] CollectCommands()
		{
			var commands = _pendingCommands.ToArray();
			_pendingCommands.Clear();
			return commands;
		}

		List<Command> _pendingCommands = new List<Command>();

		void SendCommand(Command command)
		{
			_pendingCommands.Add(command);
		}

		RenderControl _renderControl;

		extern(Android) void ISurfaceTextureListener.OnAvailable(object surfaceTexture, int width, int height)
		{
			_renderControl = new RenderControl(surfaceTexture);
			//debug_log("ISurfaceTextureListener.OnAvailable");
		}

		extern(Android) bool ISurfaceTextureListener.OnDestroyed(object surfaceTexture)
		{
			return false;
		}

		extern(Android) void ISurfaceTextureListener.OnSizeChanged(object surfaceTexture, int width, int height)
		{

		}

		extern(Android) void ISurfaceTextureListener.OnUpdated(object surfaceTexture)
		{
			//debug_log("ISurfaceTextureListener.OnUpdated @ " + UpdateManager.FrameIndex);
		}

		Dictionary<Element, Handle> _elements = new Dictionary<Element, Handle>();

		void ITreeRenderer.RootingStarted(Element e)
		{
			var handle = Handle.NewHandle();
			_elements.Add(e, handle);

			var control = e as Control;
			if (control != null)
			{
				var del = control.NewDrawableDelegateInternal(new Context(handle, SendCommand));
				control.DrawableDelegate = del;
			}
		}

		void ITreeRenderer.Rooted(Element e)
		{

		}

		void ITreeRenderer.Unrooted(Element e)
		{
			var control = e as Control;
			if (control != null && control.DrawableDelegate != null)
			{
				control.DrawableDelegate.Dispose();
				control.DrawableDelegate = null;
			}
			_elements.Remove(e);
		}

		void ITreeRenderer.BackgroundChanged(Element e, Brush background)
		{

		}

		void ITreeRenderer.TransformChanged(Element e)
		{
			SendCommand(new UpdateTransform(_elements[e], e.WorldTransform));
		}

		void ITreeRenderer.Placed(Element e)
		{
			SendCommand(new UpdateSize(_elements[e], e.ActualSize));
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