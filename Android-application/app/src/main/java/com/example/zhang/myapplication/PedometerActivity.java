package com.example.zhang.myapplication;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.Button;
import android.widget.CheckedTextView;
import android.widget.TextView;

import java.io.FileOutputStream;
import java.io.IOException;
import java.text.DecimalFormat;

// TODO: Code save to file functionality
// TODO: Step counting method
// TODO: Draw the curve on screen

public class PedometerActivity extends AppCompatActivity implements SensorEventListener {

    private Button buttonWrite, buttonStop;
    private CheckedTextView checkedTextView;
    private TextView textX, textY, textZ, textA;
    private boolean doWrite = false;
    private SensorManager sensorManager;
    private float lowX = 0, lowY = 0, lowZ = 0;
    private final float FILTERING_VALAUE = 0.1f;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_pedometer);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        // Get view element
        buttonWrite = (Button) findViewById(R.id.pedometer_btn_write);
        buttonStop = (Button) findViewById(R.id.pedometer_btn_stop);
        checkedTextView = (CheckedTextView) findViewById(R.id.text_acc_change);
        textX = (TextView) findViewById(R.id.pedometer_edit_X);
        textY = (TextView) findViewById(R.id.pedometer_edit_Y);
        textZ = (TextView) findViewById(R.id.pedometer_edit_Z);
        textA = (TextView) findViewById(R.id.pedometer_edit_A);
        checkedTextView.setChecked(false);

        // Create a SensorManager to get the system’s sensor service
        sensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);
        // High sampling rate；.SENSOR_DELAY_NORMAL means a lower sampling rate
        sensorManager.registerListener(this,
                sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER),
                SensorManager.SENSOR_DELAY_NORMAL); //SENSOR_DELAY_FASTEST
        // Create a file
        try {
            FileOutputStream fout = openFileOutput("acc.txt", MODE_PRIVATE);
            fout.close();
        } catch (IOException e) {
            e.printStackTrace();
        }

        // Register button
        buttonWrite.setOnClickListener(new Button.OnClickListener() {
            @Override
            public void onClick(View v) {
                doWrite = true;
            }
        });
        buttonStop.setOnClickListener(new Button.OnClickListener() {
            @Override
            public void onClick(View view) {
                doWrite = false;
            }
        });
    }

    @Override
    protected void onDestroy() {
        sensorManager.unregisterListener(this);
        super.onDestroy();
    }

    public void onPause(){
        super.onPause();
    }

    public void onAccuracyChanged(Sensor sensor, int accuracy) {
        checkedTextView.setChecked(true);
    }

    public void onSensorChanged(SensorEvent event) {
        if(event.sensor.getType() == Sensor.TYPE_ACCELEROMETER) {
            // Get sensor data
            float X = event.values[0];
            float Y = event.values[1];
            float Z = event.values[2];
            // Low-Pass Filter
            lowX = X * FILTERING_VALAUE + lowX * (1.0f - FILTERING_VALAUE);
            lowY = Y * FILTERING_VALAUE + lowY * (1.0f - FILTERING_VALAUE);
            lowZ = Z * FILTERING_VALAUE + lowZ * (1.0f - FILTERING_VALAUE);
            // High-pass filter
            float highX = X - lowX;
            float highY = Y - lowY;
            float highZ = Z - lowZ;
            double highA = Math.sqrt(highX * highX + highY * highY + highZ * highZ);
            DecimalFormat df = new DecimalFormat("#,##0.000");
            // Display
            textX.setText(df.format(highX));
            textY.setText(df.format(highY));
            textZ.setText(df.format(highZ));
            textA.setText(df.format(highA));
            if (doWrite) {
//                write2file(message);
            }
        }
    }
//    private void write2file(String a){
//        try {
//            File file = new File("/sdcard/acc.txt");//write the result
//            into/sdcard/acc.txt
//            if (!file.exists()){
//                file.createNewFile();}
//// Open a random access file stream for reading and writing
//            RandomAccessFile randomFile = new
//                    RandomAccessFile("/sdcard/acc.txt", "rw");
//// The length of the file (the number of bytes)
//            long fileLength = randomFile.length();
//// Move the file pointer to the end of the file
//            randomFile.seek(fileLength);
//            randomFile.writeBytes(a);
//            randomFile.close();
//        } catch (IOException e) {
//// TODO Auto-generated catch block
//            e.printStackTrace();
//        }
//    }
//    }

}
