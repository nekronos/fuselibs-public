using Uno;
using Uno.Collections;
using Uno.UX;
using Uno.Compiler.ExportTargetInterop;

namespace Fuse
{
	using Fuse.Elements;
	using Fuse.Controls;
	using Fuse.Controls.Native;
	using Fuse.Android;

	extern (Android && !Library) public abstract class App: AppBase
	{
		abstract class RootPanel
		{
			public abstract Visual RootVisual { get; }
			public abstract Visual ChildrenVisual { get; }
			public abstract float4 Background { set; }
		}

		class OldRootPanel : RootPanel
		{
			class RootViewHost : INativeViewRoot
			{
				void INativeViewRoot.Add(ViewHandle handle) { AppRoot.SetRootView(handle); }
				void INativeViewRoot.Remove(ViewHandle handle) { AppRoot.ClearRoot(handle); }
			}

			public override Visual RootVisual { get { return _renderPanel; } }
			public override Visual ChildrenVisual { get { return _graphicsView; } }

			public override float4 Background
			{
				set { _graphicsView.Color = value; }
			}

			TreeRendererPanel _renderPanel;
			GraphicsView _graphicsView;

			public OldRootPanel()
			{
				_renderPanel = new TreeRendererPanel(new RootViewHost());
				_graphicsView = new RootGraphicsView();
				_renderPanel.Children.Add(_graphicsView);
			}
		}

		class NewRootPanel : RootPanel
		{
			class TreeRenderer2Panel : Panel
			{
				void InsertChild(ViewHandle viewHandle) { AppRoot.ViewHandle.InsertChild(viewHandle); }
				void RemoveChild(ViewHandle viewHandle) { AppRoot.ViewHandle.RemoveChild(viewHandle); }

				ITreeRenderer _treeRenderer;

				public TreeRenderer2Panel()
				{
					_treeRenderer = new Fuse.Controls.Android.TreeRenderer2(this, InsertChild, RemoveChild);
				}

				public sealed override ITreeRenderer TreeRenderer { get { return _treeRenderer; } }
			}

			TreeRenderer2Panel _renderPanel = new TreeRenderer2Panel();

			public override Visual RootVisual { get { return _renderPanel; } }
			public override Visual ChildrenVisual { get { return _renderPanel; } }

			public override float4 Background
			{
				set { AppRoot.ViewHandle.SetBackgroundColor((int)Uno.Color.ToArgb(value)); }
			}
		}

		RootPanel _rootPanel;

		public App()
		{
			Fuse.Platform.SystemUI.OnCreate();

			Fuse.Android.StatusBarConfig.SetStatusBarColor(float4(0));

			Fuse.Controls.TextControl.TextRendererFactory = Fuse.Android.TextRenderer.Create;

			MobileBootstrapping.Init();

			RootViewport = new NativeRootViewport(new ViewHandle(AppRoot.Handle));

			if defined(TREE_RENDERER_2)
				_rootPanel = new NewRootPanel();
			else
				_rootPanel = new OldRootPanel();

			RootViewport.Children.Add(_rootPanel.RootVisual);

			Uno.Platform.Displays.MainDisplay.Tick += OnTick;
		}

		public sealed override IList<Node> Children
		{
			get { return _rootPanel.ChildrenVisual.Children; }
		}

		public sealed override Visual ChildrenVisual
		{
			get { return _rootPanel.ChildrenVisual; }
		}

		void OnTick(object sender, Uno.Platform.TimerEventArgs args)
		{
			RootViewport.InvalidateLayout();
			try
			{
				PropagateBackground();
			}
			catch (Exception e)
			{
				Fuse.AppBase.OnUnhandledExceptionInternal(e);
			}

			Time.Set(args.CurrentTime);

			try
			{
				OnUpdate();
			}
			catch (Exception e)
			{
				Fuse.AppBase.OnUnhandledExceptionInternal(e);
			}
		}

		void PropagateBackground()
		{
			_rootPanel.Background = Background;
		}
	}
}
