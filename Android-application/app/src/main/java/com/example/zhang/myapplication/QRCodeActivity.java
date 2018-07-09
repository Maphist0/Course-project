package com.example.zhang.myapplication;

import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.webkit.URLUtil;
import android.widget.Button;
import android.widget.Toast;

// TODO: Add support to open link after decoding - DONE
// TODO: (Minor) Fix link for Wechat pages can't be opened
// TODO: Add support to pick images from gallery

public class QRCodeActivity extends AppCompatActivity {

    private static final int QR_DECODE_REQUEST = 1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_qrcode);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        Button buttonEncode = (Button) findViewById(R.id.qrcode_btn_encode);
        Button buttonDecode = (Button) findViewById(R.id.qrcode_btn_decode);
        buttonEncode.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(QRCodeActivity.this, QREncoder.class);
                startActivity(intent);
            }
        });
        buttonDecode.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(QRCodeActivity.this, QRDecoder.class);
                startActivityForResult(intent, QR_DECODE_REQUEST);
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == QR_DECODE_REQUEST) {
            // Returned from decoder activity
            View view = (View) findViewById(R.id.qrcode_layout);
            // Check activity state
            if (resultCode == RESULT_OK) {
                // Show result, open in browser
                final String decodeResult = data.getStringExtra("result");
                new AlertDialog.Builder(this)
                        .setTitle("QR decode result")
                        .setIcon(R.drawable.ic_menu_share)
                        .setMessage(decodeResult)
                        .setNegativeButton("Open", new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialogInterface, int i) {
                                // Try to open the link in browser
                                // Right now, Wechat links will crash the program
                                dialogInterface.dismiss();
                                String uri = decodeResult;

                                // Pre-process the link
                                if (!uri.contains("http://") && !uri.contains("https://")) {
                                    uri = "http://" + uri;
                                }

                                if (!URLUtil.isValidUrl(uri)) {
                                    // Invalid link
                                    Toast.makeText(QRCodeActivity.this,
                                            "Invalid URL specified", Toast.LENGTH_SHORT).show();
                                } else {
                                    // Valid link, open the browser
                                    Intent browserIntent = new Intent(
                                            Intent.ACTION_VIEW, Uri.parse(uri));
                                    startActivity(browserIntent);
                                }
                            }
                        })
                        .setPositiveButton("Confirm", new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialogInterface, int i) {
                                dialogInterface.dismiss();
                            }
                        })
                        .show();
            } else {
                // Activity return signal Fail
                Snackbar.make(view, "Fail to decode QR code!",
                        Snackbar.LENGTH_LONG).setAction("Action", null).show();
            }
        }
        super.onActivityResult(requestCode, resultCode, data);
    }
}
