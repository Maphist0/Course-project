package com.example.zhang.myapplication;

import android.content.res.TypedArray;
import android.graphics.PorterDuff;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.view.MotionEvent;
import android.widget.Button;

import java.util.Random;

public class WelcomeView extends View{

    // For canvas and pen
    public Canvas canvas;
    public Paint p,q;
    public enum PaintObj {Line, Erase, Circle};
    private Bitmap bitmap;
    // Canvas state and paint state
    private float x, y;
    private float cirleCenterX, cirleCenterY, circleRadius;
    //private float rectLeft, rectTop;
    private int bgColor, paintColor, paintColorStepSize = 5;
    private int canvasPosLeft, canvasPosTop;
    private Random rand;
    private PaintObj objState;
    // For logging
    private final String TAG = this.getClass().getName();


    public WelcomeView(Context context, AttributeSet attrs) {

        super(context, attrs);

        int viewWidth, viewHeight, innerPadding, canvasWidth, canvasHeight;
        rand = new Random();

        // Prepare attribute and parameters
        // Should exclude the background rounded rectangle
        viewWidth = (int) getResources().getDimension(R.dimen.canvas_width);
        viewHeight = (int) getResources().getDimension(R.dimen.canvas_height);
        innerPadding = (int) getResources().getDimension(R.dimen.canvas_padding);
        canvasWidth = viewWidth - 2 * innerPadding;
        canvasHeight = viewHeight - 2 * innerPadding;
        canvasPosLeft = innerPadding;
        canvasPosTop = innerPadding;
        Log.d(TAG, String.format(
                "WelcomeView: viewWidth=%d, viewHeight=%d, innerPadding=%d, canvasWidth=%d, canvasHeight=%d",
                viewHeight, viewHeight, innerPadding, canvasWidth, canvasHeight));

        // Create canvas and setup the pen
        bgColor = Color.WHITE;
        bitmap = Bitmap.createBitmap(canvasWidth, canvasHeight, Bitmap.Config.ARGB_8888);
        canvas = new Canvas();
        canvas.setBitmap(bitmap);
        objState = PaintObj.Line;
        paintColor = 0;
        p = new Paint(Paint.DITHER_FLAG);
        p.setAntiAlias(true);
        p.setColor(Color.HSVToColor(new float[]{paintColor, 1, 1}));
        p.setStrokeCap(Paint.Cap.ROUND);
        p.setStrokeWidth(8);

        q = new Paint(Paint.DITHER_FLAG);
        q.setAntiAlias(true);
        q.setColor(bgColor);
        q.setStrokeCap(Paint.Cap.ROUND);
        q.setStrokeWidth(20);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {

        // Change paint color in a circular form
        paintColor += paintColorStepSize;
        Log.d(TAG, String.format("onTouchEvent: paintColor=%d", paintColor));
        if (paintColor == 360 || paintColor == 0) {
            paintColorStepSize = -1 * paintColorStepSize;
        }
        p.setColor(Color.HSVToColor(new float[]{paintColor, 1, 1}));

        // Draw shapes according to object state
        if (event.getAction() == MotionEvent.ACTION_MOVE) {

            if (objState == PaintObj.Line) {
                // For line: Draw a line connected with previous dot
                canvas.drawLine(x, y, event.getX(), event.getY(), p);
                invalidate();
            } else if (objState == PaintObj.Erase) {
                canvas.drawLine(x, y, event.getX(), event.getY(), q);
                invalidate();
                // For Rectangle: Restore to bitmap without rectangle and re-draw
                //canvas.drawRect(rectLeft, rectTop, event.getX(), event.getY(), p);
               // Log.d(TAG, String.format("onTouchEvent: curX=%.3f, curY=%.3f",
                 //       event.getX(), event.getY()));

            } else if (objState == PaintObj.Circle) {

                // For Circle: Restore to bitmap withour circle and re-draw
                circleRadius = (float) Math.sqrt(
                        Math.pow(event.getX() - cirleCenterX, 2) +
                        Math.pow(event.getY() - cirleCenterY, 2));
                canvas.drawCircle(cirleCenterX, cirleCenterY, circleRadius, p);

            }
            // Refresh the canvas
            invalidate();

        } else if (event.getAction() == MotionEvent.ACTION_DOWN) {

            if (objState == PaintObj.Line) {

                // Paint a dot
                x = event.getX();
                y = event.getY();
                canvas.drawPoint(x, y, p);
                invalidate();

            } else if (objState == PaintObj.Erase) {
                x = event.getX();
                y = event.getY();
                canvas.drawPoint(x, y, q);
                invalidate();
                // Save previous bitmap, initialize rectangle
                //rectLeft = event.getX();
                //rectTop = event.getY();
                //Log.d(TAG, String.format("onTouchEvent: rectLeft=%.3f, rectTop=%.3f",
                 //       rectLeft, rectTop));

            } else if (objState == PaintObj.Circle) {

                // Save previous bitmap, initialize circle
                cirleCenterX = event.getX();
                cirleCenterY = event.getY();
                Log.d(TAG, String.format("onTouchEvent: cirleCenterX=%.3f, cirleCenterY=%.3f",
                        cirleCenterX, cirleCenterY));

            }
        } else if (event.getAction() == MotionEvent.ACTION_UP) {
            // Release finger
        }

        // Update previous position for Line mode
        if (objState == PaintObj.Line || objState == PaintObj.Erase) {
            x = event.getX();
            y = event.getY();
        }
        return true;
    }

    @Override
    public void onDraw(Canvas c) {
        c.drawBitmap(bitmap, canvasPosLeft, canvasPosTop, null);
    }

    public void setObjState(PaintObj obj) {
        objState = obj;
    }

    public void clearCanvas() {
        canvas.drawColor(bgColor);
    }
}
