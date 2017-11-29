package com.fuse.android.views;

import android.graphics.Canvas;

public class CanvasControl extends ViewGroup {

	public interface IDrawCallback {
		void onDraw();
	}

	public CanvasControl(android.content.Context context, IDrawCallback drawCallback) {
		super(context);
		setWillNotDraw(false);
		_drawingEnabled = true;
		_callbackEnabled = true;
		_canvas = new Canvas();
	}

	boolean _drawingEnabled;
	boolean _callbackEnabled;
	Canvas _canvas;
	IDrawCallback _drawCallback;

	@Override
	protected void onDraw(Canvas canvas) {
		if (_callbackEnabled) {
			_drawCallback.onDraw();
		}
		super.onDraw(_drawingEnabled ? canvas : _canvas);
	}

	@Override
	public void draw(Canvas canvas) {
		super.draw(_drawingEnabled ? canvas : _canvas);
	}

	public void setDrawingEnabled(boolean drawingEnabled) {
		_drawingEnabled = drawingEnabled;
	}

	public void setCallbackEnabled(boolean callbackEnabled) {
		_callbackEnabled = callbackEnabled;
	}

	public boolean getDrawingEnabled() {
		return _drawingEnabled;
	}

	public boolean getCallbackEnabled() {
		return _callbackEnabled;
	}
}
