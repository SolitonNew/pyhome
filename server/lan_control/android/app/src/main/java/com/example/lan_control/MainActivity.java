package com.example.lan_control;

import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.UiThread;
import android.support.design.widget.BottomNavigationView;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MenuItem;
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
    implements Page1.OnFragmentInteractionListener,
               Page2.OnFragmentInteractionListener,
               Page3.OnFragmentInteractionListener,
               Page1_detail.OnFragmentInteractionListener {

    public ClientThread clientThread = null;
    private Timer _timer = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        BottomNavigationView nav = findViewById(R.id.bottomNavigationView);

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

    private int _currentPage = -1;
    private Fragment _currentPageObj = null;

    private void loadPage1() {
        if (_currentPage == 1) return ;
        Page1 p = Page1.newInstance("", "");
        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        ft.replace(R.id.fragmentContainer, p);
        ft.commit();
        _currentPage = 1;
        _currentPageObj = p;
    }

    private void loadPage2() {
        if (_currentPage == 2) return ;
        Page2 p = Page2.newInstance("", "");
        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        ft.replace(R.id.fragmentContainer, p);
        ft.commit();
        _currentPage = 2;
        _currentPageObj = p;
    }

    private void loadPage3() {
        if (_currentPage == 3) return ;
        Page3 p = Page3.newInstance("", "");
        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        ft.replace(R.id.fragmentContainer, p);
        ft.commit();
        _currentPage = 3;
        _currentPageObj = p;
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

                // Получаем и парсим группы переменных
                String[][] tmp_vg = metaQuery("load variable group", "");
                variableGroups = new VariableGroup[tmp_vg.length];
                for (int i = 0; i < tmp_vg.length; i++) {
                    variableGroups[i] = new VariableGroup(tmp_vg[i]);
                }

                // Получаем и парсим переменные, расталкивая их по группам
                String[][] tmp_v = metaQuery("load variables", "4");
                variables = new Variable[tmp_v.length];
                for (int i = 0; i < tmp_v.length; i++) {
                    variables[i] = new Variable(tmp_v[i], clientThread);
                }

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
            } catch (UnknownHostException e_1) {
            } catch (IOException e_2) {
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
}
