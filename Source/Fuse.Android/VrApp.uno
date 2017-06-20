using Uno;
using Uno.Collections;
using Uno.UX;
using Uno.Compiler.ExportTargetInterop;

namespace Fuse
{

	using Fuse.Controls;
	using Fuse.Controls.Native;
	using Fuse.Android;

	extern (Android && Oculus && !Library) public abstract class VrApp: AppBase
	{
		GraphicsView _graphicsView = new RootGraphicsView();

		Visual RootVisual
		{
			get { return _graphicsView; }
		}

		protected VrApp()
		{
			debug_log("NEW VRAPP");
			Fuse.Platform.SystemUI.OnCreate();

			Fuse.Android.StatusBarConfig.SetStatusBarColor(float4(0));

			Fuse.Controls.TextControl.TextRendererFactory = Fuse.Android.TextRenderer.Create;

			MobileBootstrapping.Init();

			RootViewport = new NativeRootViewport(AppRoot.ViewHandle);
			RootViewport.Children.Add(_graphicsView);

			Uno.Platform.Displays.MainDisplay.Tick += OnTick;
		}

		public sealed override IList<Node> Children
		{
			get { return RootVisual.Children; }
		}

		public sealed override Visual ChildrenVisual
		{
			get { return RootVisual; }
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
			_graphicsView.Color = Background;
		}
	}

	extern (Android && Oculus && !Library) public abstract class App: VrApp {}
}
