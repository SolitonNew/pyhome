package com.example.lan_control;

import android.content.Context;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.ToggleButton;

import java.util.ArrayList;
import java.util.Comparator;


/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link Page1_detail.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link Page1_detail#newInstance} factory method to
 * create an instance of this fragment.
 */
public class Page1_detail extends Fragment {
    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    // TODO: Rename and change types of parameters
    private String mParam1;
    private String mParam2;

    private OnFragmentInteractionListener mListener;

    private VariableGroup _variableGroup = null;

    public Page1_detail() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment Page1_detail.
     */
    // TODO: Rename and change types and number of parameters
    public static Page1_detail newInstance(String param1, String param2) {
        Page1_detail fragment = new Page1_detail();
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, param1);
        args.putString(ARG_PARAM2, param2);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            mParam1 = getArguments().getString(ARG_PARAM1);
            mParam2 = getArguments().getString(ARG_PARAM2);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_page1_detail, container, false);
    }

    // TODO: Rename method, update argument and hook method into UI event
    public void onButtonPressed(Uri uri) {
        if (mListener != null) {
            mListener.onFragmentInteraction(uri);
        }
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OnFragmentInteractionListener) {
            mListener = (OnFragmentInteractionListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement OnFragmentInteractionListener");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    @Override
    public void onStart() {
        super.onStart();

        _initPage();
    }

    /**
     * This interface must be implemented by activities that contain this
     * fragment to allow an interaction in this fragment to be communicated
     * to the activity and potentially other fragments contained in that
     * activity.
     * <p>
     * See the Android Training lesson <a href=
     * "http://developer.android.com/training/basics/fragments/communicating.html"
     * >Communicating with Other Fragments</a> for more information.
     */
    public interface OnFragmentInteractionListener {
        // TODO: Update argument type and name
        void onFragmentInteraction(Uri uri);
    }

    private boolean _programChangeLock = false;

    class PanelItem {
        int panelTyp;
        Variable variable;
        View control[];
        PanelItem(int typ, Variable var, View ctrl[]) {
            panelTyp = typ;
            variable = var;
            control = ctrl;
        }
    }

    private ArrayList<PanelItem> _panels = new ArrayList<PanelItem>();

    private int one_dip = 1;

    private void _initPage() {
        one_dip = (int) (getResources().getDisplayMetrics().density + 0.5f);

        MainActivity mainActivity = (MainActivity) getActivity();

        int id = Integer.parseInt(mParam1);

        ArrayList<VariableGroup> a = mainActivity.getVariableGroups();
        for (int i = 0; i < a.size(); i++) {
            VariableGroup v = a.get(i);
            if (v.getId() == id) {
                _variableGroup = v;
                break;
            }
        }

        ((TextView) mainActivity.findViewById(R.id.varGroupName)).setText(_variableGroup.getName());
        LinearLayout varDetailList = mainActivity.findViewById(R.id.varDetailList);

        ArrayList<Variable> tmp = _variableGroup.getVariables();

        tmp.sort(new Comparator<Variable>() {
            @Override
            public int compare(Variable o1, Variable o2) {
                if (o1.getAppControl() > o2.getAppControl()) {
                    return 1;
                } else
                if (o1.getAppControl() < o2.getAppControl()) {
                    return -1;
                }
                return 0;
            }
        });

        _programChangeLock = true;

        for (int i = 0; i < tmp.size(); i++) {
            Variable v = tmp.get(i);

            switch (v.getAppControl()) {
                case 1: // Свет
                case 3: // Розетка
                    varDetailList.addView(createSwitchPanel(v));
                    break;
                case 5: // Термостат
                case 7: // Вентилятор
                    varDetailList.addView(createProgressPanel(v));
                    break;
                case 4: // Термометр
                case 10:// Гигрометр
                case 11:// Датчик газа
                case 13:// Датчик атмосферного давления
                case 14:// Датчик тока
                    varDetailList.addView(createSensPanel(v, v.getAppControl()));
                    break;
            }
        }

        _programChangeLock = false;
    }

    public View createSwitchPanel(Variable variable) {
        LinearLayout ll_v = new LinearLayout(getContext());
        ll_v.setOrientation(LinearLayout.VERTICAL);
        ll_v.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT));

        LinearLayout ll = new LinearLayout(getContext());
        ll.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 75));
        ll.setPadding(20,8,20,10);
        ll.setGravity(Gravity.CENTER_VERTICAL);

        TextView tv = new TextView(getContext());
        tv.setText(variable.getCommForGroup(_variableGroup.getName()));
        tv.setTextSize(17);
        tv.setPadding(0,0,8,0);
        tv.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, 1.0f));
        ll.addView(tv);

        Switch sw = new Switch(getContext());
        sw.setChecked(variable.getValue() > 0);
        ll.addView(sw);

        ll_v.addView(ll);

        View line = new View(getContext());
        line.setBackgroundColor(0x1f000000);
        line.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, one_dip));
        ll_v.addView(line);

        View control[] = {sw};
        _panels.add(new PanelItem(1, variable, control));

        sw.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (_programChangeLock) return ;

                LinearLayout panel = (LinearLayout) buttonView.getParent().getParent();
                LinearLayout parent = (LinearLayout) panel.getParent();
                int index = parent.indexOfChild(panel);
                if (isChecked) {
                    _panels.get(index).variable.setValue(1);
                } else {
                    _panels.get(index).variable.setValue(0);
                }
            }
        });

        return ll_v;
    }

    public View createProgressPanel(Variable variable) {
        LinearLayout ll_v = new LinearLayout(getContext());
        ll_v.setOrientation(LinearLayout.VERTICAL);
        ll_v.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT));

        LinearLayout ll = new LinearLayout(getContext());
        ll.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT));
        ll.setPadding(20,8,20,0);
        ll.setGravity(Gravity.CENTER_VERTICAL);
        ll_v.addView(ll);

        TextView tv = new TextView(getContext());
        tv.setText(variable.getCommForGroup(_variableGroup.getName()));
        tv.setTextSize(17);
        tv.setPadding(0,0,8,0);
        tv.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, 1.0f));
        ll.addView(tv);

        TextView tv_val = new TextView(getContext());
        tv_val.setTextSize(30);
        tv_val.setTextColor(0xff000000);
        ll.addView(tv_val);

        TextView tv_dim = new TextView(getContext());
        tv_dim.setTextSize(17);
        tv_dim.setText(variable.getDim());
        tv_dim.setPadding(4,13,0,0);
        ll.addView(tv_dim);

        SeekBar sb = new SeekBar(getContext());
        sb.setPadding(24,0,24,0);
        sb.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 60));
        switch (variable.getAppControl()) {
            case 5:
                sb.setMax(150);
                sb.setProgress((int)((variable.getValue() - 15) * 10));
                tv_val.setText("" + variable.getValue());
                break;
            case 7:
                sb.setMax(10);
                sb.setProgress((int) variable.getValue());
                tv_val.setText("" + (int) (variable.getValue() * 10));
                break;
        }
        ll_v.addView(sb);

        View line = new View(getContext());
        line.setBackgroundColor(0x1f000000);
        line.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, one_dip));
        ll_v.addView(line);

        View control[] = {sb, tv_val};
        _panels.add(new PanelItem(2, variable, control));

        sb.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                PanelItem p = null;
                for (int i = 0; i < _panels.size(); i++) {
                    p = _panels.get(i);
                    if (p.control[0] == seekBar) {
                        break;
                    }
                }
                if (seekBar.getMax() <= 10) {
                    ((TextView) p.control[1]).setText("" + progress * 10);
                } else {
                    ((TextView) p.control[1]).setText("" + (progress + 150) / 10.0);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                PanelItem p = null;
                for (int i = 0; i < _panels.size(); i++) {
                    p = _panels.get(i);
                    if (p.control[0] == seekBar) {
                        break;
                    }
                }
                if (seekBar.getMax() <= 10) {
                    p.variable.setValue(seekBar.getProgress());
                } else {
                    p.variable.setValue((seekBar.getProgress() / 10.0) + 15);
                }
            }
        });

        return ll_v;
    }

    public View createSensPanel(Variable variable, int typ) {
        LinearLayout ll_v = new LinearLayout(getContext());
        ll_v.setOrientation(LinearLayout.VERTICAL);
        ll_v.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT));

        LinearLayout ll = new LinearLayout(getContext());
        ll.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT));
        ll.setPadding(20, 8, 20, 10);
        ll.setGravity(Gravity.CENTER_VERTICAL);
        ll_v.addView(ll);

        TextView tv = new TextView(getContext());
        tv.setText(variable.getCommForGroup(_variableGroup.getName()));
        tv.setTextSize(17);
        tv.setPadding(0,0,8,0);
        tv.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, 1.0f));
        ll.addView(tv);

        TextView tv_val = new TextView(getContext());
        tv_val.setTextSize(30);
        tv_val.setTextColor(0xff000000);
        tv_val.setText("" + variable.getValue());
        ll.addView(tv_val);

        TextView tv_dim = new TextView(getContext());
        tv_dim.setTextSize(17);
        tv_dim.setText(variable.getDim());
        tv_dim.setPadding(4,13,0,0);
        ll.addView(tv_dim);

        View line = new View(getContext());
        line.setBackgroundColor(0x1f000000);
        line.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, one_dip));
        ll_v.addView(line);

        View control[] = {tv_val};
        _panels.add(new PanelItem(3, variable, control));

        return ll_v;
    }

    public void syncVariables() {
        _programChangeLock = true;

        for (int i = 0; i < _panels.size(); i++) {

            PanelItem p = _panels.get(i);

            switch (p.panelTyp) {
                case 1:
                    ((Switch) p.control[0]).setChecked(p.variable.getValue() == 1);
                    break;
                case 2:
                    TextView tw = ((TextView) p.control[1]);
                    SeekBar sb = ((SeekBar) p.control[0]);
                    if (sb.getMax() <= 10) {
                        sb.setProgress((int)p.variable.getValue());
                        tw.setText("" + (int) (p.variable.getValue() * 10));
                    } else {
                        sb.setProgress((int)((p.variable.getValue() - 15) * 10));
                        tw.setText("" + p.variable.getValue());
                    }
                    break;
                case 3:
                    ((TextView) p.control[0]).setText("" + p.variable.getValue());
                    break;
            }
        }

        _programChangeLock = false;
    }
}
