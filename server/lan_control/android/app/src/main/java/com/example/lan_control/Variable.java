package com.example.lan_control;

import android.os.NetworkOnMainThreadException;
import android.util.Log;
import android.widget.Toast;

public class Variable {
    // ID, NAME, COMM, APP_CONTROL, VALUE, GROUP_ID

    private int _id;
    private String _name;
    private String _comm;
    private int _appControl;
    private double _value;
    private int _groupId;

    private MainActivity.ClientThread _clientThread;

    public Variable(String[] row, MainActivity.ClientThread clientThread) {
        _id = Integer.parseInt(row[0]);
        _name = row[1];
        _comm = row[2];
        try {
            _appControl = Integer.parseInt(row[3]);
        } catch (Exception e) {

        }
        try {
            _value = Double.parseDouble(row[4]);
        } catch (Exception e) {

        }
        try {
            _groupId = Integer.parseInt(row[5]);
        } catch (Exception e) {
            _groupId = -1;
        }

        _clientThread = clientThread;
    }

    public int getId() {
        return _id;
    }

    public String getName() {
        return _name;
    }

    public String getComm() {
        return _comm;
    }

    public int getAppControl() {
        return _appControl;
    }

    public double getValue() {
        return _value;
    }

    public void setValue(double val) {
        _value = val;
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    _clientThread.metaQuery("setvar", "" + _id + (char)1 + _value);
                } catch (Exception e) {
                    Log.d("ERROR 2", e.toString());
                }
            }
        }).start();
    }

    public int getGroupId() {
        return _groupId;
    }

    public void syncValue(double val) {
        _value = val;
    }
}
