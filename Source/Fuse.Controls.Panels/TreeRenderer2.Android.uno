using Uno;
using Uno.UX;
using Uno.Collections;
using Fuse;
using Fuse.Drawing;
using Fuse.Elements;
using Fuse.Controls;
using Fuse.Controls.Native;
using Uno.Compiler.ExportTargetInterop;

namespace Fuse.Controls
{
	extern(Android) class TreeRenderer2 : ITreeRenderer
	{
		public delegate void InsertChildHandler(ViewHandle child);
		public delegate void RemoveChildHandler(ViewHandle child);

		InsertChildHandler _insertChild;
		RemoveChildHandler _removeChild;

		Visual _rootVisual;

		public TreeRenderer2(Visual rootVisual, InsertChildHandler insertChild, RemoveChildHandler removeChild)
		{
			_rootVisual = rootVisual;
			_insertChild = insertChild;
			_removeChild = removeChild;
			UpdateManager.AddAction(OnUpdate, UpdateStage.Draw);
		}

		void OnUpdate()
		{
			if (!_zorderValid)
			{
				EnsureZOrder(_rootVisual);
				_zorderValid = true;
			}
			for (var i = 0; i < _transformsToUpdate.Count; i++)
				UpdateTransform(_transformsToUpdate[i]);
			_transformsToUpdate.Clear();
		}

		bool _zorderValid = false;
		void InvalidateZOrder() { _zorderValid = false; }
		void EnsureZOrder(Visual parent)
		{
			var len = parent.ZOrderChildCount;
			for (var i = 0; i < len; i++)
			{
				var child = parent.GetZOrderChild(i);
				if (child is Element)
					_elements[(Element)child].BringToFront();
				EnsureZOrder(child);
			}
		}

		readonly List<Element> _transformsToUpdate = new List<Element>();

		void InvalidateTransformSubtree(Element e)
		{
			_transformsToUpdate.Add(e);
			var len = e.ZOrderChildCount;
			for (var i = 0; i < len; i++)
			{
				var child = e.GetZOrderChild(i);
				if (child is Element)
					InvalidateTransformSubtree((Element)child);
			}
		}


		readonly Dictionary<Element,ViewHandle> _elements = new Dictionary<Element,ViewHandle>();

		void ITreeRenderer.RootingStarted(Element e) { }

		void ITreeRenderer.Rooted(Element e)
		{
			var view = InstantiateView(e);
			_elements.Add(e, view);
			_insertChild(view);
			InvalidateZOrder();
		}

		void ITreeRenderer.Unrooted(Element e)
		{
			var view = _elements[e];
			_removeChild(view);
			view.Dispose();
			if (e is Control)
			{
				((Control)e).ViewHandle = null;
				((Control)e).NativeView = null;
			}
			_elements.Remove(e);
			InvalidateZOrder();
		}

		void ITreeRenderer.BackgroundChanged(Element e, Brush background)
		{
			_elements[e].SetBackgroundColor(background.GetColor());
		}

		void UpdateTransform(Element e)
		{
			var viewHandle = _elements[e];
			var transform = e.WorldTransform;
			var size = e.ActualSize;
			var density = e.Viewport.PixelsPerPoint;

			viewHandle.UpdateViewRect(transform, size, density);
		}

		void ITreeRenderer.TransformChanged(Element e)
		{
			/*var viewHandle = _elements[e];
			var transform = e.WorldTransform;
			var size = e.ActualSize;
			var density = e.Viewport.PixelsPerPoint;

			viewHandle.UpdateViewRect(transform, size, density);*/
			InvalidateTransformSubtree(e);
		}

		void ITreeRenderer.Placed(Element e)
		{
			var density = e.Viewport.PixelsPerPoint;
			var actualPosition = (int2)(e.ActualPosition * density);
			var actualSize = (int2)(e.ActualSize * density);
			_elements[e].UpdateViewRect(actualPosition.X, actualPosition.Y, actualSize.X, actualSize.Y);
		}

		void ITreeRenderer.IsVisibleChanged(Element e, bool isVisible)
		{
			_elements[e].SetIsVisible(isVisible);
		}

		void ITreeRenderer.IsEnabledChanged(Element e, bool isEnabled)
		{
			_elements[e].SetEnabled(isEnabled);
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
			InvalidateZOrder();
		}

		bool ITreeRenderer.Measure(Element e, LayoutParams lp, out float2 size)
		{
			var viewHandle = _elements[e];
			var canMeasure = viewHandle.IsLeafView;
			size = canMeasure
				? viewHandle.Measure(lp, e.Viewport.PixelsPerPoint)
				: float2(0.0f);
			return canMeasure;
		}

		ViewHandle InstantiateView(Element e)
		{
			var appearance = (InstantiateTemplate(e) ?? InstantiateViewOld(e)) as ViewHandle;
			if (appearance != null)
			{
				if (e is Control)
				{
					((Control)e).ViewHandle = appearance;
					if (appearance is IView)
						((Control)e).NativeView = (IView)appearance;
				}
				return appearance;
			}
			else
			{
				return ViewFactory.InstantiateViewGroup();
			}
		}

		object InstantiateTemplate(Element e)
		{
			var t = e.FindTemplate("AndroidAppearance");
			return t != null ? t.New() : null;
		}

		// For backwardscompatibility with old pattern
		object InstantiateViewOld(Element e)
		{
			if (e is Control)
			{
				var c = (Control)e;
				return c.InstantiateNativeView();
			}
			return null;
		}

	}
}