using Uno;
using Uno.Collections;
using Uno.UX;
using Fuse.Elements;
using Fuse.Drawing;
using Fuse.Controls.Native;

namespace Fuse.Controls
{
	public abstract class ViewHandleHost : LayoutControl
	{
		protected abstract IProxyHost ProxyHost { get; }
		protected abstract State InitialState { get; }

		readonly ViewHandle _viewHandle;

		protected ViewHandleHost(ViewHandle viewHandle)
		{
			_viewHandle = viewHandle;
		}

		protected override void OnRooted()
		{
			base.OnRooted();
		}

		protected override void OnUnrooted()
		{
			base.OnUnrooted();
		}

		bool _viewHandleRooted;

		protected void RootViewHandle()
		{
			if (_viewHandleRooted)
				return;

			ProxyHost.InsertChild(_viewHandle);
			_viewHandleRooted = true;
		}

		protected void UnrootViewHandle()
		{
			if (!_viewHandleRooted)
				return;

			ProxyHost.RemoveChild(_viewHandle);
			_viewHandleRooted = false;
		}
	}


	internal class NativeGLControl : LayoutControl, ITreeRenderer
	{
		protected override void OnInvalidateVisual()
		{
			base.OnInvalidateVisual();
		}

		protected override void DrawWithChildren(DrawContext dc)
		{

		}

		extern(ANDROID && iOS)
		public override VisualContext VisualContext
		{
			get
			{
				if defined(ANDROID && iOS)
					return VisualContext.Native;
				else
					return VisualContext.Graphics;
			}
		}

		bool IsInGraphicsContext
		{
			get { return base.VisualContext == VisualContext.Graphics; }
		}

		extern(ANDROID && iOS)
		public override ITreeRenderer TreeRenderer
		{
			get { return IsInGraphicsContext ? (ITreeRenderer)this : base.TreeRenderer; }
		}

		ITreeRenderer _treeRenderer;
		IProxyHost _proxyHost;
		CanvasControl _canvasControl;

		void CanvasControlOnDraw()
		{

		}

		protected override void OnRooted()
		{
			WorldTransformInvalidated += OnInvalidateWorldTransform;
			if (IsInGraphicsContext)
			{
				_canvasControl = new CanvasControl(CanvasControlOnDraw);
				_proxyHost = this.FindProxyHost();
				if (_proxyHost == null)
					Fuse.Diagnostics.InternalError(this + " could not find an IProxyHost");

				_treeRenderer = new Fuse.Controls.TreeRenderer(SetRoot, ClearRoot);

				if (_proxyHost != null)
					_proxyHost.Insert(_canvasControl);
				else
					Fuse.Diagnostics.InternalError(this + " does not have an IProxyHost and will malfunction");
			}
			base.OnRooted();
		}

		protected override void OnUnrooted()
		{
			WorldTransformInvalidated -= OnInvalidateWorldTransform;

			if (IsInGraphicsContext && _proxyHost != null)
				_proxyHost.Remove(_canvasControl);

			base.OnUnrooted();
			_treeRenderer = null;
			_proxyHost = null;
		}

		void OnInvalidateWorldTransform(object sender, EventArgs args)
		{
			if (!IsInGraphicsContext)
				return;
			PostUpdateTransform();
		}

		bool _updateTransform = false;
		void PostUpdateTransform()
		{
			if (!_updateTransform)
			{
				UpdateManager.AddDeferredAction(UpdateHostViewTransform, UpdateStage.Layout, LayoutPriority.Post);
				_updateTransform = true;
			}
		}

		void UpdateHostViewTransform()
		{
			_updateTransform = false;
			if (_canvasControl == null)
				return;

			var transform = IsInGraphicsContext
				? Uno.Matrix.Mul(_proxyHost.WorldTransformInverse, WorldTransform)
				: LocalTransform;
			var size = ActualSize;
			var density = Viewport.PixelsPerPoint;

			var p = Parent;
			if (p is Control)
				((Control)p).CompensateForScrollView(ref transform);

			_canvasControl.UpdateViewRect(transform, size, density);
		}

		void SetRoot(ViewHandle viewHandle)
		{
			_canvasControl.InsertChild(viewHandle);
		}

		void ClearRoot(ViewHandle viewHandle)
		{
			_canvasControl.RemoveChild(viewHandle);
		}

		void ITreeRenderer.RootingStarted(Element e) { _treeRenderer.RootingStarted(e); }
		void ITreeRenderer.Rooted(Element e) { _treeRenderer.Rooted(e); }
		void ITreeRenderer.Unrooted(Element e) { _treeRenderer.Unrooted(e); }
		void ITreeRenderer.BackgroundChanged(Element e, Brush background) { _treeRenderer.BackgroundChanged(e, background); }
		bool ITreeRenderer.Measure(Element e, LayoutParams lp, out float2 size) { return _treeRenderer.Measure(e, lp, out size); }
		void ITreeRenderer.IsVisibleChanged(Element e, bool isVisible) { _treeRenderer.IsVisibleChanged(e, isVisible); }
		void ITreeRenderer.IsEnabledChanged(Element e, bool isEnabled) { _treeRenderer.IsEnabledChanged(e, isEnabled); }
		void ITreeRenderer.OpacityChanged(Element e, float opacity) { _treeRenderer.OpacityChanged(e, opacity); }
		void ITreeRenderer.ClipToBoundsChanged(Element e, bool clipToBounds) { _treeRenderer.ClipToBoundsChanged(e, clipToBounds); }
		void ITreeRenderer.HitTestModeChanged(Element e, bool enabled) { _treeRenderer.HitTestModeChanged(e, enabled); }
		void ITreeRenderer.ZOrderChanged(Element e, Visual[] zorder) { _treeRenderer.ZOrderChanged(e, zorder); }

		void ITreeRenderer.TransformChanged(Element e)
		{
			if (e == this)
				UpdateHostViewTransform();
			else
				_treeRenderer.TransformChanged(e);
		}

		extern(!iOS) void ITreeRenderer.Placed(Element e)
		{
			if (e == this)
				UpdateHostViewTransform();
			else
				_treeRenderer.Placed(e);
		}

		// Because of iOS layout rules weirdness we have to
		// set the size ourselves. There are no sensible layout
		// rules on iOS that makes a view fill the parent like we want
		extern(iOS) void ITreeRenderer.Placed(Element e)
		{
			if (e == this)
				UpdateHostViewTransform();
			_treeRenderer.Placed(e);
		}
	}
}