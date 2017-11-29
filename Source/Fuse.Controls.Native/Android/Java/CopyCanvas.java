package com.fuse.android.views;

import android.graphics.Canvas;

public class CopyCanvas extends Canvas {

	abstract class Command {
		public abstract void perform(Canvas canvas);
	}

	ArrayList<Command> _commandBuffer;

	public CopyCanvas() {
		super();
		_commandBuffer = new ArrayList<Command>();
	}

    public void setBitmap(Bitmap bitmap) {
        super.setBitmap(bitmap);
        _commandBuffer.add(new Command() {
        	final Bitmap _bitmap = bitmap;
        	public void perform(Canvas canvas) {
        		canvas.setBitmap(_bitmap);
        	}
        });
    }

    public void setHighContrastText(boolean highContrastText) {
        super.setHighContrastText(highContrastText);
        _commandBuffer.add(new Command() {
        	public void perform(Canvas canvas) {
        		canvas.setHighContrastText(highContrastText);
        	}
        });
    }

    public void insertReorderBarrier() {
    	super.insertReorderBarrier();
        _commandBuffer.add(new Command() {
            public void perform(Canvas canvas) {
                canvas.insertReorderBarrier();
            }
        });
    }

    public void insertInorderBarrier() {
    	super.insertInorderBarrier();
    }

    public void setDensity(int density) {
        super.setDensity(density);
    }

    public void setScreenDensity(int density) {
        super.setScreenDensity(density);
    }

    public int save() {
        return super.save();
    }

    public int save(int saveFlags) {
        return super.save(saveFlags);
    }

    public int saveLayer(RectF bounds, Paint paint, int saveFlags) {
        return super.saveLayer(bounds, paint, saveFlags);
    }

    public int saveLayer(RectF bounds, Paint paint) {
        return super.saveLayer(bounds, paint);
    }

    public int saveLayer(float left, float top, float right, float bottom, Paint paint, int saveFlags) {
        return super.saveLayer(left, top, right, bottom, paint);
    }

    public int saveLayer(float left, float top, float right, float bottom, Paint paint) {
        return super.saveLayer(left, top, right, bottom, paint);
    }

    public int saveLayerAlpha(RectF bounds, int alpha, int saveFlags) {
        return super.saveLayerAlpha(bounds, alpha, saveFlags);
    }

    public int saveLayerAlpha(RectF bounds, int alpha) {
        return super.saveLayerAlpha(bounds, alpha);
    }

    public int saveLayerAlpha(float left, float top, float right, float bottom, int alpha, int saveFlags) {
        return super.saveLayerAlpha(left, top, right, bottom, alpha, saveFlags);
    }

    public int saveLayerAlpha(float left, float top, float right, float bottom, int alpha) {
        return super.saveLayerAlpha(left, top, right, bottom, alpha);
    }

    public void restore() {
        super.restore();
    }

    public void restoreToCount(int saveCount) {
        super.restoreToCount(saveCount);
    }

    public void translate(float dx, float dy) {
        super.translate(dx, dy);
    }

    public void scale(float sx, float sy) {
        super.scale(sx, sy);
    }

    public void rotate(float degrees) {
        super.rotate(degrees);
    }

    public final void rotate(float degrees, float px, float py) {
        super.rotate(degrees, px, py);
    }

    public void skew(float sx, float sy) {
        super.skew(sx, sy);
    }

    public void concat(Matrix matrix) {
        super.concat(matrix);
    }

    public void setMatrix(Matrix matrix) {
        super.setMatrix(matrix);
    }

    public boolean clipRect(RectF rect, Region.Op op) {
        return super.clipRect(rect, op);
    }

    public boolean clipRect(Rect rect, Region.Op op) {
        return super.clipRect(rect, op);
    }

    public boolean clipRect(RectF rect) {
        return super.clipRect(rect);
    }

    public boolean clipOutRect(RectF rect) {
        return super.clipOutRect(rect);
    }

    public boolean clipRect(Rect rect) {
        return super.clipRect(rect);
    }

    public boolean clipOutRect(Rect rect) {
       	return super.clipOutRect(rect);
    }

    public boolean clipRect(float left, float top, float right, float bottom,
            Region.Op op) {
        return super.clipRect(left, top, right, bottom, op);
    }

    public boolean clipRect(float left, float top, float right, float bottom) {
        return super.clipRect(left, top, right, bottom);
    }

    public boolean clipOutRect(float left, float top, float right, float bottom) {
        return super.clipOutRect(left, top, right, bottom);
    }

    public boolean clipRect(int left, int top, int right, int bottom) {
        super.clipRect(left, top, right, bottom);
    }

    public boolean clipOutRect(int left, int top, int right, int bottom) {
        return super.clipOutRect(left, top, right, bottom);
    }

    public boolean clipPath(Path path, Region.Op op) {
        return super.clipPath(path, op);
    }

    public boolean clipPath(Path path) {
        return super.clipPath(path);
    }

    public boolean clipOutPath(Path path) {
        return super.clipOutPath(path);
    }

    public void setDrawFilter(DrawFilter filter) {
        super.setDrawFilter(filter);
    }

    public void drawPicture(Picture picture) {

    }

    public void drawPicture(Picture picture, RectF dst) {

    }

    public void drawPicture(Picture picture, Rect dst) {

    }

    public void drawArc(RectF oval, float startAngle, float sweepAngle, boolean useCenter, Paint paint) {

    }

    public void drawArc(float left, float top, float right, float bottom, float startAngle,
            float sweepAngle, boolean useCenter, Paint paint) {

    }

    public void drawARGB(int a, int r, int g, int b) {

    }

    public void drawBitmap(Bitmap bitmap, float left, float top, Paint paint) {

    }

    public void drawBitmap(Bitmap bitmap, Rect src, RectF dst,
            Paint paint) {

    }

    public void drawBitmap(Bitmap bitmap, Rect src, Rect dst,
            Paint paint) {

    }

    @Deprecated
    public void drawBitmap(int[] colors, int offset, int stride, float x, float y,
            int width, int height, boolean hasAlpha, Paint paint) {

    }

    @Deprecated
    public void drawBitmap(int[] colors, int offset, int stride, int x, int y,
            int width, int height, boolean hasAlpha, Paint paint) {

    }

    public void drawBitmap(Bitmap bitmap, Matrix matrix, Paint paint) {

    }

    public void drawBitmapMesh(Bitmap bitmap, int meshWidth, int meshHeight,
            float[] verts, int vertOffset, int[] colors, int colorOffset,
            Paint paint) {

                paint);
    }

    public void drawCircle(float cx, float cy, float radius, Paint paint) {

    }

    public void drawColor(@ColorInt int color) {

    }

    public void drawColor(@ColorInt int color, PorterDuff.Mode mode) {

    }

    public void drawLine(float startX, float startY, float stopX, float stopY,
            Paint paint) {

    }

    public void drawLines(float[] pts, int offset, int count, Paint paint) {

    }

    public void drawLines(float[] pts, Paint paint) {

    }

    public void drawOval(RectF oval, Paint paint) {

    }

    public void drawOval(float left, float top, float right, float bottom, Paint paint) {

    }

    public void drawPaint(Paint paint) {

    }

    public void drawPatch(NinePatch patch, Rect dst, Paint paint) {

    }

    public void drawPatch(NinePatch patch, RectF dst, Paint paint) {

    }

    public void drawPath(Path path, Paint paint) {

    }

    public void drawPoint(float x, float y, Paint paint) {

    }

    public void drawPoints(float[] pts, int offset, int count, Paint paint) {

    }

    public void drawPoints(float[] pts, Paint paint) {

    }

    public void drawPosText(char[] text, int index, int count, float[] pos, Paint paint) {

    }

    public void drawPosText(String text, float[] pos, Paint paint) {

    }

    public void drawRect(RectF rect, Paint paint) {

    }

    public void drawRect(Rect r, Paint paint) {

    }

    public void drawRect(float left, float top, float right, float bottom, Paint paint) {

    }

    public void drawRGB(int r, int g, int b) {

    }

    public void drawRoundRect(RectF rect, float rx, float ry, Paint paint) {

    }

    public void drawRoundRect(
    	float left,
    	float top,
    	float right,
    	float bottom,
    	float rx,
    	float ry,
        Paint paint) {

    }

    public void drawText(
    	char[] text,
    	int index,
    	int count,
    	float x,
    	float y,
        Paint paint) {

    }

    public void drawText(String text, float x, float y, Paint paint) {

    }

    public void drawText(
    	String text,
    	int start,
    	int end,
    	float x,
    	float y,
        Paint paint) {

    }

    public void drawText(
    	CharSequence text,
    	int start,
    	int end,
    	float x,
    	float y,
        Paint paint) {

    }

    public void drawTextOnPath(
    	char[] text,
    	int index,
    	int count,
    	Path path,
        float hOffset,
        float vOffset,
        Paint paint) {

    }

    public void drawTextOnPath(
    	String text,
    	Path path,
    	float hOffset,
        float vOffset,
        Paint paint) {
    }

    public void drawTextRun(
    	char[] text,
    	int index,
    	int count,
    	int contextIndex,
        int contextCount,
        float x,
        float y,
        boolean isRtl,
        Paint paint) {

    }

    public void drawTextRun(
    	CharSequence text,
    	int start,
    	int end,
    	int contextStart,
        int contextEnd,
        float x,
        float y,
        boolean isRtl,
        Paint paint) {
    }

    public void drawVertices(
    	VertexMode mode,
    	int vertexCount,
    	float[] verts,
        int vertOffset,
        float[] texs,
        int texOffset,
        int[] colors,
		int colorOffset,
		short[] indices,
		int indexOffset,
		int indexCount,
        Paint paint) {
    }
}
