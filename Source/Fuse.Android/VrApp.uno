using Uno;
using Uno.Collections;
using Uno.UX;
using Uno.Compiler.ExportTargetInterop;

namespace Fuse
{

	using Fuse.Controls;
	using Fuse.Controls.Native;
	using Fuse.Android;
	using Fuse.Input;

	extern (Android && Oculus && !Library) public abstract class VrApp: AppBase
	{
		RootGraphicsView _graphicsView = new RootGraphicsView();

		Visual RootVisual
		{
			get { return _graphicsView; }
		}

		static VrApp Instance
		{
			get { return Uno.Application.Current as VrApp; }
		}

		protected VrApp()
		{
			Fuse.Platform.SystemUI.OnCreate();

			Fuse.Android.StatusBarConfig.SetStatusBarColor(float4(0));

			Fuse.Controls.TextControl.TextRendererFactory = Fuse.Android.TextRenderer.Create;

			MobileBootstrapping.Init();

			RootViewport = new NativeRootViewport(AppRoot.ViewHandle);
			RootViewport.Children.Add(_graphicsView);

			Uno.Platform.Displays.MainDisplay.Tick += OnTick;

			Uno.VrEntryPoint.SetClickedHandler(OnClick);
			Uno.VrEntryPoint.SetPointerDownHandler(OnPointerDown);
			Uno.VrEntryPoint.SetPointerMovedHandler(OnPointerMove);
			Uno.VrEntryPoint.SetPointerUpHandler(OnPointerUp);
		}

		public sealed override IList<Node> Children
		{
			get { return RootVisual.Children; }
		}

		public sealed override Visual ChildrenVisual
		{
			get { return RootVisual; }
		}

		class DeferReleased
		{
			float2 _point;

			public DeferReleased(float2 point)
			{
				_point = point;
				UpdateManager.PerformNextFrame(OnRelease);
			}

			void OnRelease()
			{
				var releasedEvent = new PointerEventData()
				{
					PointIndex = 0,
					WindowPoint = _point,
					Timestamp = Uno.Diagnostics.Clock.GetSeconds(),
					PointerType = Uno.Platform.PointerType.Touch,
					IsPrimary = true,
				};
				Fuse.Input.Pointer.RaiseReleased(VrApp.Instance.RootVisual, releasedEvent);
			}
		}

		void OnClick(float x, float y)
		{
			var pressedEvent = new PointerEventData()
			{
				PointIndex = 0,
				WindowPoint = float2(x, y),
				Timestamp = Uno.Diagnostics.Clock.GetSeconds(),
				PointerType = Uno.Platform.PointerType.Touch,
				IsPrimary = true,
			};
			Fuse.Input.Pointer.RaisePressed(RootVisual, pressedEvent);
			new DeferReleased(float2(x, y));
		}

		void OnPointerDown(float x, float y)
		{
			Fuse.Input.Pointer.RaisePressed(RootVisual, new PointerEventData()
			{
				PointIndex = 0,
				WindowPoint = float2(x, y),
				Timestamp = Uno.Diagnostics.Clock.GetSeconds(),
				PointerType = Uno.Platform.PointerType.Touch,
				IsPrimary = true,
			});
		}

		void OnPointerUp(float x, float y)
		{
			Fuse.Input.Pointer.RaiseReleased(RootVisual, new PointerEventData()
			{
				PointIndex = 0,
				WindowPoint = float2(x, y),
				Timestamp = Uno.Diagnostics.Clock.GetSeconds(),
				PointerType = Uno.Platform.PointerType.Touch,
				IsPrimary = true,
			});
		}

		void OnPointerMove(float x, float y)
		{
			Fuse.Input.Pointer.RaiseMoved(RootVisual, new PointerEventData()
			{
				PointIndex = 0,
				WindowPoint = float2(x, y),
				Timestamp = Uno.Diagnostics.Clock.GetSeconds(),
				PointerType = Uno.Platform.PointerType.Touch,
				IsPrimary = true,
			});
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
