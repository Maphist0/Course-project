//package com.example.zhang.myapplication;
//
//import java.io.File;
//import java.io.FileOutputStream;
//import java.io.IOException;
//import java.io.RandomAccessFile;
//import java.sql.Date;
//import java.text.SimpleDateFormat;
//import java.util.Iterator;
//import java.util.List;
//import java.util.Vector;
//import android.content.Context;
//import android.net.wifi.ScanResult;
//import android.net.wifi.WifiManager;
//import android.util.Log;
//
//public class SuperWiFi extends WifiActivity { //The class of the parameters of WiFi
//
//    static final String TAG = "SuperWiFi";
//    static SuperWiFi wifi = null;
//    static Object sync = new Object();
//    static int TESTTIME = 1; //Number of measurement
//    WifiManager wm = null;
//    private Vector<String> scanned = null;
//    boolean isScanning = false;
//    private int[] APRSS = new int[10];
//    private FileOutputStream out;
//    private int p;
//
//    public SuperWiFi(Context context) {
//        this.wm = (WifiManager) context.getApplicationContext()
//                .getSystemService(Context.WIFI_SERVICE);
//        this.scanned = new Vector<String>();
//    }
//
//    public void ScanRss() {
//        startScan();
//    }
//
//    public boolean isscan() {
//        return isScanning;
//    }
//
//    public Vector<String> getRSSlist() {
//        return scanned;
//    }
//
//    //The start of scanning
//    private void startScan() {
//        this.isScanning = true;
//        Thread scanThread = new Thread(new Runnable() {
//            public void run() {
//                //Clear last result
//                scanned.clear();
//                for (int j = 1; j <= 10; j++) {
//                    APRSS[j - 1] = 0;
//                }
//                p = 1;
//                // Record the test time and write into the SD card
//                SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
//                Date curDate = new Date(System.currentTimeMillis());
//                //Get the current time
//                String str = formatter.format(curDate);
//                for (int k = 1; k <= 10; k++) {
//                    write2file("RSS-IWCTAP" + k + ".txt",
//                            "testID: " + testID + " TestTime: "+ str +" BEGIN\n");
//                }
//
//                //Scan for a certain times
//                while (p <= TESTTIME) {
//                    performScan();
//                    p = p + 1;
//                }
////                //Record the average of the result
////                for(int i = 1; i <= 10; i++) {
////                    scanned.add("IWCTAP" + i + "= " + APRSS[i-1] / TESTTIME + "\n");
////                }
////                //Mark the end of the test in the file
////                for(int k = 1; k <= 10; k++) {
////                    write2file("RSS-IWCTAP" + k + ".txt",
////                            "testID:" + testID + "END\n");
////                }
//                isScanning = false;
//            }
//        });
//        scanThread.start();
//    }
//
//    //The realization of the test
//    private void performScan() {
//        if (wm == null) return;
//        try {
//            if (!wm.isWifiEnabled()) {
//                wm.setWifiEnabled(true);
//            }
//            //Start to scan
//            wm.startScan();
//            try {
//                //Wait for 3000ms
//                Thread.sleep(3000);
//            } catch (InterruptedException e) {
//                e.printStackTrace();
//            }
//
//            this.scanned.clear();
//            List<ScanResult> sr = wm.getScanResults();
////            Iterator<ScanResult> it = sr.iterator();
//            for (ScanResult ap: sr) {
//                Log.i(TAG, String.format("performScan: ssid=%s, level=%d", ap.SSID, ap.level));
//            }
////            while (it.hasNext()) {
////                ScanResult ap = it.next();
////                for(int k = 1; k <= 10; k++) {
////                    //Write the result to the file
////                    if (ap.SSID.equals("IWCTAP" + k)){
////                        APRSS[k-1] = APRSS[k-1] + ap.level;
////                        write2file("RSS-IWCTAP" + k + ".txt",ap.level + "\n");
////                    }
////                }
////            }
////            this.isScanning=false;
//        } catch (Exception e) {
//            this.isScanning = false;
//            this.scanned.clear();
//            Log.d(TAG, e.toString());
//        }
//    }
//
//    //Write to the SD card
//    private void write2file(String filename, String a) {
////        try {
////            File file = new File("/sdcard/"+filename);
////            if (!file.exists()) {
////                file.createNewFile();
////            }
////            // Open a random filestream by Read&Write
////            RandomAccessFile randomFile = new
////                    RandomAccessFile("/sdcard/" + filename, "rw");
////            // The length of the file(byte)
////            long fileLength = randomFile.length();
////            // Put the writebyte to the end of the file
////            randomFile.seek(fileLength);
////            randomFile.writeBytes(a);
////            randomFile.close();
////        } catch (IOException e) {
////            e.printStackTrace();
////        }
//    }
//}