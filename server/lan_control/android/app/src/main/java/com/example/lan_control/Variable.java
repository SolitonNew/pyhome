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

    class AppControlDesign {
        String label;
        int bgColor;
        String dim;

        AppControlDesign(String aLabel, int aBgColor, String aDim) {
            label = aLabel;
            bgColor = aBgColor;
            dim = aDim;
        }
    }

    private AppControlDesign[] _appControlDesigns = {
            new AppControlDesign("", 0, ""),
            new AppControlDesign("СВЕТ", 0xffffff00, ""),
            new AppControlDesign("", 0, ""),
            new AppControlDesign("", 0xffff00ff, ""), // РОЗЕТКА
            new AppControlDesign("ТЕРМОМЕТР", 0xffffff00, "°C"),
            new AppControlDesign("ТЕРМОСТАТ", 0x4Fff0000, "°C"),
            new AppControlDesign("", 0, ""),
            new AppControlDesign("ВЕНТИЛЯЦИЯ", 0xff0000ff, "%"),
            new AppControlDesign("", 0, ""),
            new AppControlDesign("", 0, ""),
            new AppControlDesign("ГИГРОМЕТР", 0xff0000ff, "%"),

            new AppControlDesign("ГАЗ", 0, "ppm"),
            new AppControlDesign("", 0, ""),
            new AppControlDesign("АТМ. ДАВЛЕНИЕ", 0xff00ff00, "мм"),
            new AppControlDesign("ТОК", 0, "A"),
    };

    public String getCommForGroup(String groupName) {
        String s = _comm.toUpperCase().replace(groupName.toUpperCase(), "").trim();
        if (s != "") {
            s = " " + s;
        }
        return (_appControlDesigns[_appControl].label + s).trim();
    }

    public String getDim() {
        return _appControlDesigns[_appControl].dim;
    }
}
