package com.example.zhang.myapplication;

import android.content.DialogInterface;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;

// TODO: Add support to save to gallery

public class QREncoder extends AppCompatActivity {

    private EditText editText;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_qrencoder);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        editText = (EditText) findViewById(R.id.qrencoder_text);
        Button button = (Button) findViewById(R.id.qrencoder_btn);

        // Setup click callback
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                try {
                    // Get string
                    String contentString = editText.getText().toString();
                    // Check whether string is empty
                    if (!contentString.equals("")) {

                        // Encode with zxing library
                        BitMatrix matrix = new MultiFormatWriter().encode(
                                contentString, BarcodeFormat.QR_CODE, 300, 300);

                        // Convert to bitmap
                        int width = matrix.getWidth();
                        int height = matrix.getHeight();
                        int[] pixels = new int[width * height];
                        for (int y = 0; y < height; y++) {
                            for (int x = 0; x < width; x++) {
                                if (matrix.get(x, y)) {
                                    pixels[y * width + x] = Color.BLACK;
                                }
                            }
                        }
                        Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
                        bitmap.setPixels(pixels, 0, width, 0, 0, width, height);

                        // Generate an image and show
                        ImageView imageView = new ImageView(QREncoder.this);
                        imageView.setImageBitmap(bitmap);
                        new AlertDialog.Builder(QREncoder.this)
                                .setTitle("QR Code")
                                .setIcon(R.drawable.ic_menu_share)
                                .setView(imageView)
                                .setPositiveButton("Confirm", new DialogInterface.OnClickListener() {
                                    @Override
                                    public void onClick(DialogInterface dialogInterface, int i) {
                                        dialogInterface.dismiss();
                                    }
                                })
                                .show();
                    } else {
                        Snackbar.make(view, "Text can not be empty", Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();
                    }
                } catch (WriterException e) {
                    e.printStackTrace();
                }
            }
        });
    }

}
