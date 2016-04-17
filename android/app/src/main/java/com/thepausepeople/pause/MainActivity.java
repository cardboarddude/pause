package com.thepausepeople.pause;

import android.Manifest;
import android.app.PendingIntent;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.Result;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.location.Geofence;
import com.google.android.gms.location.GeofencingRequest;
import com.google.android.gms.location.LocationServices;

import java.util.ArrayList;

public class MainActivity extends AppCompatActivity implements
        GoogleApiClient.ConnectionCallbacks,
        GoogleApiClient.OnConnectionFailedListener,
        ResultCallback{
    public static final float GEOFENCE_RADIUS_IN_METERS = 20;
    public static final long GEOFENCE_EXPIRATION_IN_MILLISECONDS = 2000;

    ArrayList<Geofence> mGeofenceList = new ArrayList<Geofence>();
    PendingIntent mGeofencePendingIntent;
    GoogleApiClient mGoogleApiClient;

    @Override
    protected void onStart() {
        super.onStart();

        mGoogleApiClient = new GoogleApiClient.Builder(this)
                .addConnectionCallbacks(this)
                .addOnConnectionFailedListener(this)
                .addApi(LocationServices.API)
                .build();

        mGoogleApiClient.connect();
    }

    @Override
    protected void onStop() {
        super.onStop();
        mGoogleApiClient.disconnect();
    }

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

        addNewGeofence("loc1", 11.0, -11.0);
        addNewGeofence("loc2", 22.0, -22.0);

        Button addGeofenceBtn = (Button) findViewById(R.id.addGeofenceBtn);
        addGeofenceBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


            }
        });
    }

    public void addNewGeofence(String id, double latitude, double longitude) {
        Location geofenceLocation = new Location(id);
        geofenceLocation.setLatitude(latitude);
        geofenceLocation.setLongitude(longitude);

        GeofenceLocation<String, Location> entry = new
                GeofenceLocation<String, Location>(id, geofenceLocation);

        mGeofenceList.add(new Geofence.Builder()
                // Set the request ID of the geofence. This is a string to identify this
                // geofence.
                .setRequestId(entry.getKey())

                .setCircularRegion(
                        entry.getValue().getLatitude(),
                        entry.getValue().getLongitude(),
                        GEOFENCE_RADIUS_IN_METERS
                )
                .setExpirationDuration(GEOFENCE_EXPIRATION_IN_MILLISECONDS)
                .setTransitionTypes(Geofence.GEOFENCE_TRANSITION_ENTER |
                        Geofence.GEOFENCE_TRANSITION_EXIT)
                .build());
    }

    @Override
    public void onResult(Result result) {
        String resultMessage = "";
        if (result.getStatus().isSuccess()) {
            String geofenceId = mGeofenceList.get(mGeofenceList.size()-1).getRequestId();
            resultMessage = "Geofence created: " + geofenceId;
        } else {
            resultMessage = "Failed to create geofence";
        }
        Toast toast = Toast.makeText(this, resultMessage, Toast.LENGTH_SHORT);
        toast.show();
    }

    private PendingIntent getGeofencePendingIntent() {
        // Reuse the PendingIntent if we already have it.
        if (mGeofencePendingIntent != null) {
            return mGeofencePendingIntent;
        }
        Intent intent = new Intent(this, GeofenceTransitionsIntentService.class);
        // We use FLAG_UPDATE_CURRENT so that we get the same pending intent back when
        // calling addGeofences() and removeGeofences().
        return PendingIntent.getService(this, 0, intent, PendingIntent.
                FLAG_UPDATE_CURRENT);
    }

    private GeofencingRequest getGeofencingRequest() {
        GeofencingRequest.Builder builder = new GeofencingRequest.Builder();
        builder.setInitialTrigger(GeofencingRequest.INITIAL_TRIGGER_ENTER);
        builder.addGeofences(mGeofenceList);
        return builder.build();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
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

    @Override
    public void onConnected(Bundle bundle) {


        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            // TODO: Consider calling
            //    ActivityCompat#requestPermissions
            // here to request the missing permissions, and then overriding
            //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
            //                                          int[] grantResults)
            // to handle the case where the user grants the permission. See the documentation
            // for ActivityCompat#requestPermissions for more details.
            Toast toast = Toast.makeText(this, "Permission Denied:\nLocation", Toast.LENGTH_SHORT);
            toast.show();
            return;
        }

        LocationServices.GeofencingApi.addGeofences(
                mGoogleApiClient,
                getGeofencingRequest(),
                getGeofencePendingIntent()
        ).setResultCallback(this);
    }

    @Override
    public void onConnectionSuspended(int i) {
        Toast toast = Toast.makeText(this, "Connection suspended", Toast.LENGTH_SHORT);
        toast.show();
    }

    @Override
    public void onConnectionFailed(ConnectionResult connectionResult) {
        Toast toast = Toast.makeText(this, "Connection failed", Toast.LENGTH_SHORT);
        toast.show();

    }
}
