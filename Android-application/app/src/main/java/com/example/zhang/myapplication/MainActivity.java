package com.example.zhang.myapplication;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.view.View;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Button;

public class MainActivity extends AppCompatActivity
        implements NavigationView.OnNavigationItemSelectedListener {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        });

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.addDrawerListener(toggle);
        toggle.syncState();

        NavigationView navigationView = (NavigationView) findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(this);

        // Setup button functionality for welcome canvas
        final WelcomeView welcomeView = (WelcomeView) findViewById(R.id.welcome_canvas);
        final Button buttonLine = (Button) findViewById(R.id.welcome_btn_line);
        final Button buttonErase = (Button) findViewById(R.id.welcome_btn_erase);
        final Button buttonCircle = (Button) findViewById(R.id.welcome_btn_circle);
        final Button buttonClear = (Button) findViewById(R.id.welcome_btn_clear);
        // Default choice is line
        buttonLine.setTextColor(Color.WHITE);
        buttonErase.setTextColor(Color.GRAY);
        buttonCircle.setTextColor(Color.GRAY);
        buttonClear.setTextColor(Color.GRAY);
        buttonLine.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                welcomeView.setObjState(WelcomeView.PaintObj.Line);
                buttonLine.setTextColor(Color.WHITE);
                buttonErase.setTextColor(Color.GRAY);
                buttonCircle.setTextColor(Color.GRAY);
                buttonClear.setTextColor(Color.GRAY);
            }
        });
        buttonErase.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                welcomeView.setObjState(WelcomeView.PaintObj.Erase);
                buttonErase.setTextColor(Color.WHITE);
                buttonLine.setTextColor(Color.GRAY);
                buttonCircle.setTextColor(Color.GRAY);
                buttonClear.setTextColor(Color.GRAY);

            }
        });
        buttonCircle.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                welcomeView.setObjState(WelcomeView.PaintObj.Circle);
                buttonCircle.setTextColor(Color.WHITE);
                buttonLine.setTextColor(Color.GRAY);
                buttonErase.setTextColor(Color.GRAY);
                buttonClear.setTextColor(Color.GRAY);
            }
        });
        buttonClear.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                welcomeView.clearCanvas();
                buttonClear.setTextColor(Color.WHITE);
                buttonCircle.setTextColor(Color.GRAY);
                buttonLine.setTextColor(Color.GRAY);
                buttonErase.setTextColor(Color.GRAY);
            }

        });
    }

    @Override
    public void onBackPressed() {
        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else {
            super.onBackPressed();
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @SuppressWarnings("StatementWithEmptyBody")
    @Override
    public boolean onNavigationItemSelected(MenuItem item) {
        // Handle navigation view item clicks here.
        int id = item.getItemId();
        item.setChecked(false);

        if (id == R.id.nav_wifi) {
            // Go to Wifi activity
            Intent intent = new Intent(this, WifiActivity.class);
            startActivity(intent);
        } else if (id == R.id.nav_pedometer) {
            // Go to Pedometer activity
            Intent intent = new Intent(this, PedometerActivity.class);
            startActivity(intent);
        } else if (id == R.id.nav_qrcode) {
            // Go to QR Code activity
            Intent intent = new Intent(this, QRCodeActivity.class);
            startActivity(intent);
        } else if (id == R.id.nav_about) {

        }

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        drawer.closeDrawer(GravityCompat.START);
        return true;
    }
}
