package com.fuse.android.views;

import android.hardware.display.VirtualDisplay;
import android.hardware.display.DisplayManager;
import android.graphics.SurfaceTexture;
import android.graphics.PixelFormat;
import android.graphics.Canvas;
import android.widget.FrameLayout;
import android.view.WindowManager;
import android.view.ViewGroup;
import android.view.Surface;
import android.view.View;
import android.content.Intent;
import android.app.Presentation;

public class OffscreenRenderer {

	SurfaceTexture _surfaceTexture;
	Surface _surface;
	VirtualDisplay _virtualDisplay;
	Presentation _presentation;
	FrameLayout _frameLayout;
	View _view;

	public OffscreenRenderer(int textureName, int width, int height, int densityDpi, SurfaceTexture.OnFrameAvailableListener onFrameAvailableListener) {

		width /= densityDpi;
		height /= densityDpi;

		_surfaceTexture = new SurfaceTexture(textureName);
		_surfaceTexture.setDefaultBufferSize(width, height);
		_surfaceTexture.setOnFrameAvailableListener(onFrameAvailableListener);
		_surface = new Surface(_surfaceTexture);

		DisplayManager dm = (DisplayManager)com.fuse.Activity.getRootActivity().getSystemService(android.content.Context.DISPLAY_SERVICE);
		_virtualDisplay = dm.createVirtualDisplay(
			"FuseOffscreenDisplay",
			width,
			height,
			densityDpi,
			_surface,
			0);

		_frameLayout = new FrameLayout(com.fuse.Activity.getRootActivity());
		_frameLayout.setBackgroundColor((int)0xffffcc00);

		//_frameLayout.addView(button);

		_presentation = new Presentation(com.fuse.Activity.getRootActivity(), _virtualDisplay.getDisplay(), getTheme());

		android.view.View view = new android.view.View(_presentation.getContext()) {
			@Override
			protected void onDraw(Canvas canvas) {
				canvas.drawARGB(0xff, 0x00, 0xcc, 0xff);
				android.graphics.Paint paint = new android.graphics.Paint(android.graphics.Paint.LINEAR_TEXT_FLAG | android.graphics.Paint.ANTI_ALIAS_FLAG);
				paint.setARGB(0xff, 0x00, 0xff, 0x00);
				paint.setAntiAlias(true);
				paint.setTextSize(80.0f);
				paint.setStyle(android.graphics.Paint.Style.FILL);
				paint.setFakeBoldText(true);

				canvas.drawCircle(20f, 20f, 40.0f, paint);
				paint.setARGB(0xff, 0xff, 0x00, 0x00);
				canvas.drawText("//// FUSETOOLS", 40.0f, 80.0f, paint);
			}
		};

		_view = view;

		android.widget.TextView textView = new android.widget.TextView(_presentation.getContext());

		textView.setText("//// FUSETOOLS");
		textView.setTextSize(80.0f);
		textView.setBackgroundColor((int)0xffffcc00);

		view.setBackgroundColor((int)0xffffcc00);
		view.setWillNotDraw(false);
		textView.setLayoutParams(new ViewGroup.LayoutParams(width, height));

		_presentation.setContentView(textView, new ViewGroup.LayoutParams(width, height));
		_presentation.show();

	}

	public void setContent(View view) {
		/*_frameLayout.removeAllViews();
		view.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
		_frameLayout.addView(view);*/
	}

	public void invalidate() {
		//_frameLayout.invalidate();
		_view.invalidate();
	}

	public void updateTexImage() {
		_surfaceTexture.updateTexImage();
	}

	private int getTheme() {
		return com.fuse.Activity.getRootActivity().getApplicationInfo().theme;
	}

}