package com.example.zhang.myapplication;

import android.Manifest;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiManager;
import android.nfc.Tag;
import android.os.Build;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;

import java.util.List;
import java.util.Locale;
import java.util.Vector;

import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

// TODO: The "scan()" currently doesn't return anything.
// TODO: Average over multiple runs of scaning.
// TODO: Write result to file.
// TODO: (Extra) Indoor location problem.

public class WifiActivity extends AppCompatActivity {

    // The ID of the test result
    private static int testID = 0;
    private static final int TOTAL_TEST_TIME = 1;
    private boolean scanFinished = false;
    private WifiManager wifiManager = null;
    private BroadcastReceiver broadcastReceiver = null;
    private final String TAG = this.getClass().getName();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_wifi);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        // Initialize buttons and text fields
        final EditText editText = (EditText) findViewById(R.id.wifi_text);
        final Button buttonScan = (Button) findViewById(R.id.wifi_btn_scan);
        final Button buttonClear = (Button) findViewById(R.id.wifi_btn_clear);
        wifiManager = (WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        testID = 0;

        buttonScan.setOnClickListener(new Button.OnClickListener() {
            @Override
            public void onClick(View v) {
                startScan();
            }
        });

        buttonClear.setOnClickListener(new Button.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Clear the text box
                editText.setText("");
                testID += 1;
            }
        });

        // Register wifi scan receiver
        broadcastReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                scanFinished = true;
                List<ScanResult> scanResults = wifiManager.getScanResults();
                Log.i(TAG, "onReceive: Scan finished");
                Log.i(TAG, scanResults.toString());
                for (ScanResult scanResult : scanResults) {
                    if (scanResult.SSID.equals("NETGEAR")) {
                        EditText editText = (EditText) findViewById(R.id.wifi_text);
                        editText.append(String.format("performScan: ssid=%s, level=%d\n",
                                scanResult.SSID, scanResult.level, testID));
                    }
                    Log.i(TAG, String.format("performScan: ssid=%s, level=%d",
                            scanResult.SSID, scanResult.level));
                }
                editText.append(String.format(Locale.US, "End scaning %d.\n", testID));
            }
        };
        IntentFilter filter = new IntentFilter();
        filter.addAction(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION);
//        registerReceiver(broadcastReceiver,
//                new IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION));
        registerReceiver(broadcastReceiver, filter);
    }

    @Override
    protected void onDestroy() {
        unregisterReceiver(broadcastReceiver);
        super.onDestroy();
    }

    private void startScan() {
        // Print task info
        EditText editText = (EditText) findViewById(R.id.wifi_text);
        editText.append(String.format(Locale.US, "Performing scaning %d...\n", testID));
        final View parentLayout = findViewById(R.id.wifi_view);

        // Scan thread
        Thread scanThread = new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    Log.i(TAG, "run: Start wifi scan thread");
                    if (!wifiManager.isWifiEnabled()) {
                        Snackbar.make(parentLayout, "Wifi is disabled. Trying to open wifi ...",
                                Snackbar.LENGTH_LONG).setAction("Action", null).show();
                        wifiManager.setWifiEnabled(true);
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                        requestPermissions(new String[]{Manifest.permission.ACCESS_COARSE_LOCATION},
                                234);
                        //After this point you wait for callback in onRequestPermissionsResult(int, String[], int[]) overriden method

                    }
                    for (int i = 0; i < TOTAL_TEST_TIME; i++) {
                        Log.i(TAG, String.format("run: Scan iteration %d started", i));
                        scanFinished = false;
//                         Wait for scan to finish
//                        while (!scanFinished) {
//                            try {
//                                Thread.sleep(500);
//                            } catch (Exception e) {
//                                e.printStackTrace();
//                            }
//                        }
                        Thread.sleep(500);
                        wifiManager.startScan();
                    }
                } catch (Exception e) {
                    Log.i(TAG, e.toString());
                }
            }
        });
        scanThread.run();
    }

}
