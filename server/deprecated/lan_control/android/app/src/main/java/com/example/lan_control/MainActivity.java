package com.example.lan_control;

import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.graphics.SurfaceTexture;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.UiThread;
import android.support.design.widget.BottomNavigationView;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MenuItem;
import android.view.Surface;
import android.view.TextureView;
import android.view.View;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.SocketAddress;
import java.net.UnknownHostException;
import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.nio.charset.CharsetEncoder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Timer;
import java.util.TimerTask;

public class MainActivity extends AppCompatActivity
    implements TextureView.SurfaceTextureListener,
               Page0.OnFragmentInteractionListener,
               Page1.OnFragmentInteractionListener,
               Page1_detail.OnFragmentInteractionListener,
               Page2.OnFragmentInteractionListener,
               Page2_detail.OnFragmentInteractionListener,
               Page3.OnFragmentInteractionListener {

    public ClientThread clientThread = null;
    private Timer _timer = null;
    public SharedPreferences settings;
    private String[][] _tmp_apps;
    public String[][] _cams;
    public String[][] _media;

    public MediaPlayer mMediaPlayer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        BottomNavigationView nav = findViewById(R.id.bottomNavigationView);
        nav.setVisibility(View.GONE);
        nav.setOnNavigationItemSelectedListener(new BottomNavigationView.OnNavigationItemSelectedListener() {
            @Override
            public boolean onNavigationItemSelected(@NonNull MenuItem item) {
                switch (item.getItemId()) {
                    case R.id.navigation_page1:
                        loadPage1();
                        break;
                    case R.id.navigation_page2:
                        loadPage2();
                        break;
                    case R.id.navigation_page3:
                        loadPage3();
                        break;
                }
                return true;
            }
        });

        getSupportActionBar().setElevation(0);

        loadPage0();

        settings = getSharedPreferences("APP_SETTINGS", Context.MODE_PRIVATE);
        connectSocket();
    }

    @Override
    protected void onDestroy() {
        try {
            clientThread.socket.close();
        } catch (Exception e) {}
        super.onDestroy();
    }

    @Override
    public void onFragmentInteraction(Uri uri){
        //you can leave it empty
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);

        switch(_currentPage) {
            case 2:
                ((Page2) _currentPageObj).doResize(newConfig.orientation);
                break;
        }
    }

    private int _currentPage = -1;
    private Fragment _currentPageObj = null;

    private void loadPage0() {
        Page0 p = Page0.newInstance("", "");
        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        ft.replace(R.id.fragmentContainer, p);
        ft.commit();
        _currentPage = -1;
        _currentPageObj = p;
    }

    private void loadPage1() {
        if (_currentPage == 1) return ;
        Page1 p = Page1.newInstance("", "");
        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        ft.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
        ft.replace(R.id.fragmentContainer, p);
        ft.commit();
        _currentPage = 1;
        _currentPageObj = p;

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                ((BottomNavigationView) findViewById(R.id.bottomNavigationView)).setVisibility(View.VISIBLE);
            }
        });
    }

    private void loadPage2() {
        if (_currentPage == 2) return ;
        Page2 p = Page2.newInstance("", "");
        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        ft.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
        ft.replace(R.id.fragmentContainer, p);
        ft.commit();
        _currentPage = 2;
        _currentPageObj = p;

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                ((BottomNavigationView) findViewById(R.id.bottomNavigationView)).setVisibility(View.VISIBLE);
            }
        });
    }

    private void loadPage3() {
        if (_currentPage == 3) return ;
        Page3 p = Page3.newInstance("", "");
        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        ft.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
        ft.replace(R.id.fragmentContainer, p);
        ft.commit();
        _currentPage = 3;
        _currentPageObj = p;

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                ((BottomNavigationView) findViewById(R.id.bottomNavigationView)).setVisibility(View.VISIBLE);
            }
        });
    }


    private void connectSocket() {
        clientThread = new ClientThread();
        new Thread(clientThread).start();
    }

    public ArrayList<VariableGroup> getVariableGroups() {
        // ID, NAME, PARENT_ID, ORDER_NUM
        if (clientThread != null) {
            return new ArrayList<VariableGroup>(Arrays.asList(clientThread.variableGroups));
        }
        return new ArrayList<VariableGroup>();
    }

    public ArrayList<Variable> getVariables() {
        // ID, NAME, COMM, APP_CONTROL, VALUE, GROUP_ID
        if (clientThread != null) {
            return new ArrayList<Variable>(Arrays.asList(clientThread.variables));
        }
        return new ArrayList<Variable>();
    }

    class ClientThread implements Runnable {
        private String host = "192.168.40.2";
        private int port = 8090;
        private Socket socket;

        private PrintWriter out = null;
        private BufferedReader in = null;

        public VariableGroup[] variableGroups;
        public Variable[] variables;

        @Override
        public void run() {
            try {
                InetAddress serverAddr = InetAddress.getByName(host);
                socket = new Socket(serverAddr, port);
                out = new PrintWriter(socket.getOutputStream());
                in = new BufferedReader(new InputStreamReader(socket.getInputStream(), "cp1251"));

                if (settings.contains("KEY")) {
                    firstLoad();
                } else {
                    // ID, COMM
                    _tmp_apps = metaQuery("apps list", "");
                    runLogon();
                }

            } catch (UnknownHostException e_1) {
            } catch (IOException e_2) {
            };
        }

        public void firstLoad() {
            // Получаем и парсим группы переменных
            String[][] tmp_vg = metaQuery("load variable group", "");
            variableGroups = new VariableGroup[tmp_vg.length];
            for (int i = 0; i < tmp_vg.length; i++) {
                variableGroups[i] = new VariableGroup(tmp_vg[i]);
            }

            // Получаем и парсим переменные, расталкивая их по группам
            String[][] tmp_v = metaQuery("load variables", settings.getString("KEY", "4"));
            variables = new Variable[tmp_v.length];
            for (int i = 0; i < tmp_v.length; i++) {
                variables[i] = new Variable(tmp_v[i], clientThread);
            }

            _cams = metaQuery("cams", "");
            //_media = metaQuery("get media list", "");

            _timer = new Timer();
            _timer.scheduleAtFixedRate(new TimerTask() {
                @Override
                public void run() {
                    new Thread(new Runnable() {
                        @Override
                        public void run() {
                            try {
                                // c.ID, c.VARIABLE_ID, c.VALUE, v.APP_CONTROL, v.GROUP_ID
                                String[][] res = clientThread.metaQuery("sync", "");
                                for (int i = 0; i < res.length; i++) {
                                    try {
                                        int res_id = Integer.parseInt(res[i][1]);
                                        double res_val = Double.parseDouble(res[i][2]);
                                        for (int k = 0; k < variables.length; k++) {
                                            Variable v = (Variable) variables[k];
                                            if (v.getId() == res_id) {
                                                v.syncValue(res_val);
                                                break;
                                            }
                                        }
                                    } catch (Exception e) {

                                    }
                                }

                                if (res.length > 0) {
                                    runOnUiThread(new Runnable() {
                                        @Override
                                        public void run() {
                                            try {
                                                ListView lv = findViewById(R.id.rooms);
                                                ((VariableGroupAdapter) lv.getAdapter()).notifyDataSetChanged();
                                            } catch (Exception e) {

                                            }

                                            try {
                                                if (_currentPage == 1) {
                                                    Page1 p = (Page1) _currentPageObj;
                                                    if (p.getDetailVisible()) {
                                                        p.getDetail().syncVariables();
                                                    }
                                                }
                                            } catch (Exception e) {

                                            }
                                        }
                                    });
                                }

                            } catch (Exception e) {
                                Log.d("ERROR 3", e.toString());
                            }
                        }

                    }).start();
                }
            }, 0, 500);

            if (_currentPage == -1) {
                loadPage1();
            }
        }

        public String[][] metaQuery(String pack_name, String pack_data) {
            try {
                if (null != socket) {
                    out.print(pack_name + (char)1 + pack_data + (char)2 );
                    out.flush();

                    int charsRead = 0;
                    char[] buffer = new char[10024];
                    String res = "";
                    while ((charsRead = in.read(buffer)) > 0) {
                        res += new String(buffer).substring(0, charsRead);
                        if (res.indexOf((char)2) > 0) {
                            break;
                        }
                    }

                    String l = "" + (char)1;
                    String[] res_spl = res.split(l);
                    int cols = Integer.parseInt(res_spl[0]);
                    if (cols > 0) {
                        int rows = (int) Math.ceil((res_spl.length - 1) / cols);

                        String[][] res_arr = new String[rows][cols];
                        int i = 1;
                        for (int r = 0; r < rows; r++) {
                            for (int c = 0; c < cols; c++) {
                                res_arr[r][c] = res_spl[i];
                                i++;
                            }
                        }
                        return res_arr;
                    } else {
                        return new String[0][0];
                    }
                }
            } catch (IOException e) {
                Log.d("ERROR", e.toString());
            }

            return new String[0][0];
        }
    }

    @Override
    public boolean onSupportNavigateUp() {
        switch (_currentPage) {
            case 1:
                Page1 p = (Page1) _currentPageObj;
                if (p.getDetailVisible()) {
                    p.hideDetail();
                    return true;
                }
                return false;

            case 2:
                Page2 p2 = (Page2) _currentPageObj;
                if (p2.getDetailVisible()) {
                    p2.hideDetail();
                    return true;
                }
                return false;
        }

        return super.onSupportNavigateUp();
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            if (onSupportNavigateUp()) {
                return true;
            }
        }
        return super.onKeyDown(keyCode, event);
    }

    public void runLogon() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                String[] ls = new String[_tmp_apps.length];
                for (int i = 0; i < ls.length; i++) {
                    ls[i] = _tmp_apps[i][1];
                }

                AlertDialog.Builder adb = new AlertDialog.Builder(MainActivity.this);
                adb.setSingleChoiceItems(ls, 0, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        SharedPreferences.Editor e = settings.edit();
                        e.putString("KEY", _tmp_apps[which][0]);
                        e.commit();
                    }
                });

                AlertDialog alertDialog = adb.create();

                alertDialog.setTitle("Регистрация");

                alertDialog.setButton(Dialog.BUTTON_POSITIVE,"Готово", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        new Thread(new Runnable() {
                            @Override
                            public void run() {
                                MainActivity.this.clientThread.firstLoad();
                            }
                        }).start();
                    }
                });

                alertDialog.setOnCancelListener(new DialogInterface.OnCancelListener() {
                    @Override
                    public void onCancel(DialogInterface dialog) {
                        finish();
                    }
                });

                alertDialog.show();
            }
        });
    }



    @Override
    public void onSurfaceTextureAvailable(SurfaceTexture surfaceTexture, int i, int i1) {
        Surface surface = new Surface(surfaceTexture);
        try {
            mMediaPlayer = new MediaPlayer();
            mMediaPlayer.setDataSource("");
            mMediaPlayer.setSurface(surface);
            mMediaPlayer.setLooping(true);
            mMediaPlayer.prepareAsync();
            mMediaPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                @Override
                public void onPrepared(MediaPlayer mediaPlayer) {
                    mediaPlayer.start();
                }
            });
        } catch (IOException e) {
            Log.d("MEDIA PLAYER", "ERROR");
        }
    }

    @Override
    public void onSurfaceTextureSizeChanged(SurfaceTexture surfaceTexture, int i, int i1) {

    }

    @Override
    public boolean onSurfaceTextureDestroyed(SurfaceTexture surfaceTexture) {
        return false;
    }

    @Override
    public void onSurfaceTextureUpdated(SurfaceTexture surfaceTexture) {

    }
}
