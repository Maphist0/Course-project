package com.example.zhang.myapplication;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.hardware.Camera;
import android.graphics.PixelFormat;
import android.net.Uri;
import android.os.Bundle;
import android.support.design.widget.Snackbar;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import com.google.zxing.BinaryBitmap;
import com.google.zxing.PlanarYUVLuminanceSource;
import com.google.zxing.Reader;
import com.google.zxing.Result;
import com.google.zxing.common.HybridBinarizer;
import com.google.zxing.qrcode.QRCodeReader;

public class QRDecoder extends AppCompatActivity implements SurfaceHolder.Callback {

    // For video showing
    private SurfaceView surfaceView = null;
    private SurfaceHolder surfaceHolder = null;
    private Camera camera = null;
    private Boolean ifPreview = false, isFinished = false;
    private int previewWidth = 720, previewHeight = 1280, colorNum, unitC;
    private static final int PERMISSIONS_REQUEST_CAMERA = 1;
    private final String TAG = getClass().getName();


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_qrdecoder);

        // Ask for camera permission
        // Ref: https://developer.android.com/training/permissions/requesting.html
        // Here, thisActivity is the current activity
        if (checkSelfPermission(Manifest.permission.CAMERA)
                != PackageManager.PERMISSION_GRANTED) {

            // Should we show an explanation?
            if (ActivityCompat.shouldShowRequestPermissionRationale(this,
                    Manifest.permission.READ_CONTACTS)) {

                // Show an expanation to the user *asynchronously* -- don't block
                // this thread waiting for the user's response! After the user
                // sees the explanation, try again to request the permission.

            } else {

                // No explanation needed, we can request the permission.

                ActivityCompat.requestPermissions(this,
                        new String[]{Manifest.permission.CAMERA},
                        PERMISSIONS_REQUEST_CAMERA);

                // MY_PERMISSIONS_REQUEST_READ_CONTACTS is an
                // app-defined int constant. The callback method gets the
                // result of the request.
            }
        }

        initSurfaceView();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String permissions[], int[] grantResults) {
        switch (requestCode) {
            case PERMISSIONS_REQUEST_CAMERA: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    // permission was granted, yay! Do the
                    // contacts-related task you need to do.
                    View view = (View) findViewById(R.id.qrdecoder_view);
                    Snackbar.make(view,
                            "Camera permission granted. Please go back and re-enter this page.",
                            Snackbar.LENGTH_LONG).setAction("Action", null).show();

                } else {

                    // permission denied, boo! Disable the
                    // functionality that depends on this permission.
                    View view = (View) findViewById(R.id.qrdecoder_view);
                    Snackbar.make(view, "Fail to get camera permission. Quit.",
                            Snackbar.LENGTH_LONG).setAction("Action", null).show();
                }
                return;
            }

            // other 'case' lines to check for other
            // permissions this app might request
        }
    }

    private void initSurfaceView() {
        surfaceView = (SurfaceView) findViewById(R.id.qrdecoder_view);
        surfaceHolder = surfaceView.getHolder();
        surfaceHolder.addCallback(this);
        surfaceHolder.setFixedSize(720, 1080);
        surfaceHolder.setFormat(PixelFormat.TRANSPARENT);
    }

    @Override
    public void surfaceCreated(SurfaceHolder surfaceHolder) {

        // Setup camera
        camera = Camera.open();
        try {
            Log.i(TAG, "surfaceCreated: Camera created");
            camera.setPreviewDisplay(surfaceHolder);
        } catch (Exception e) {
            if (camera != null) {
                camera.release();
                camera = null;
            }
            e.printStackTrace();
        }

        camera.setPreviewCallback(new Camera.PreviewCallback() {
            @Override
            public void onPreviewFrame(byte[] bytes, Camera camera) {
                if (!isFinished) {
                    int previewWidth = camera.getParameters().getPreviewSize().width;
                    int previewHeight = camera.getParameters().getPreviewSize().height;

                    PlanarYUVLuminanceSource source = new PlanarYUVLuminanceSource(
                            bytes, previewWidth, previewHeight, 0, 0, previewWidth,
                            previewHeight, false);
                    BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));

                    Reader reader = new QRCodeReader();
                    try {
                        Result result = reader.decode(bitmap);
                        String text = result.getText();
                        Log.i(TAG, String.format("onPreviewFrame: QR code decode result: %s", text));
                        Intent intent = new Intent();
                        intent.putExtra("result", text);
                        setResult(RESULT_OK, intent);
                        isFinished = true;
                        finish();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        });
    }

    @Override
    public void surfaceChanged(SurfaceHolder surfaceHolder, int i, int i1, int i2) {
        Log.i(TAG, "surfaceChanged: Surface Changed");
        initCamera();
        camera.cancelAutoFocus();
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder surfaceHolder) {
        Log.i(TAG, "surfaceDestroyed: Surface Destroyed");
        if (camera != null) {
            camera.setPreviewCallback(null);
            camera.stopPreview();
            ifPreview = false;
            camera.release();
            camera = null;
        }
    }

    private void initCamera() {
        Log.i(TAG, "initCamera: Initialize camera");
        if (ifPreview) {
            camera.stopPreview();
        }
        if (camera != null) {
            try {
                Camera.Parameters parameters = camera.getParameters();
                parameters.setFlashMode("off");
                parameters.setPictureFormat(PixelFormat.JPEG);
                parameters.setPreviewFormat(PixelFormat.YCbCr_420_SP);
                parameters.setFocusMode(Camera.Parameters.FOCUS_MODE_CONTINUOUS_VIDEO);
                parameters.setPictureSize(1280, 720);
                parameters.setPreviewSize(previewHeight, previewWidth);
                if (getResources().getConfiguration().orientation !=
                        Configuration.ORIENTATION_LANDSCAPE) {
                    parameters.set("Orientation", "portrait");
                    parameters.set("rotation", 90);
                    camera.setDisplayOrientation(90);
                } else {
                    parameters.set("Orientation", "landscape");
                    camera.setDisplayOrientation(0);
                }
                camera.setParameters(parameters);
                camera.startPreview();
                camera.cancelAutoFocus();
                ifPreview = true;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
