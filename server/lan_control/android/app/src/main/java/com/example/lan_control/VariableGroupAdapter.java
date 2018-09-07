package com.example.lan_control;

import android.content.Context;
import android.graphics.Canvas;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import java.util.ArrayList;

public class VariableGroupAdapter extends BaseAdapter {

    private Context _context;
    private ArrayList<VariableGroup> _groupList;
    private LayoutInflater _layoutInflater;

    private boolean _programChangeLock = false;

    public VariableGroupAdapter(Context context, ArrayList<VariableGroup> groupList) {
        _context = context;
        _groupList = groupList;
        _layoutInflater = (LayoutInflater) _context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    }

    @Override
    public int getCount() {
        return _groupList.size();
    }

    @Override
    public Object getItem(int position) {
        return _groupList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return _groupList.get(position).getId();
    }

    @Override
    public View getView(final int position, final View convertView, ViewGroup parent) {
        _programChangeLock = true;

        View view = convertView;
        if (view == null) {
            view = _layoutInflater.inflate(R.layout.variable_group_item, parent, false);
        }

        VariableGroup vg = (VariableGroup) getItem(position);

        TextView vgGroup = (TextView) view.findViewById(R.id.vgGroup);

        LinearLayout vgGroupLayout = (LinearLayout) view.findViewById(R.id.vgGroupLayout);
        TextView title = (TextView) view.findViewById(R.id.vgName);
        Switch btn1 = (Switch) view.findViewById(R.id.vgBtn1);
        Switch btn2 = (Switch) view.findViewById(R.id.vgBtn2);
        Switch btn3 = (Switch) view.findViewById(R.id.vgBtn3);

        btn1.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (_programChangeLock) return ;
                VariableGroup vg = _groupList.get(position);
                Variable vr = vg.getBtnList().get(0);
                if (isChecked) {
                    vr.setValue(1);
                } else {
                    vr.setValue(0);
                }
            }
        });

        btn2.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (_programChangeLock) return ;
                VariableGroup vg = _groupList.get(position);
                Variable vr = vg.getBtnList().get(1);
                if (isChecked) {
                    vr.setValue(1);
                } else {
                    vr.setValue(0);
                }
            }
        });

        btn3.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (_programChangeLock) return ;
                VariableGroup vg = _groupList.get(position);
                Variable vr = vg.getBtnList().get(2);
                if (isChecked) {
                    vr.setValue(1);
                } else {
                    vr.setValue(0);
                }
            }
        });

        View vgLine = view.findViewById(R.id.vgLine);

        title.setText(vg.getName());
        if (vg.getBtnList() == null) {
            btn1.setVisibility(View.GONE);
            btn2.setVisibility(View.GONE);
            btn3.setVisibility(View.GONE);

            vgGroup.setVisibility(View.VISIBLE);
            vgGroup.setText(vg.getName());
            vgGroupLayout.setVisibility(View.GONE);

            vgLine.setVisibility(View.INVISIBLE);
        } else {
            vgGroup.setVisibility(View.GONE);
            vgGroupLayout.setVisibility(View.VISIBLE);

            switch (vg.getBtnList().size()) {
                case 1:
                    btn1.setVisibility(View.VISIBLE);
                    btn2.setVisibility(View.GONE);
                    btn3.setVisibility(View.GONE);

                    btn1.setChecked(vg.getBtnList().get(0).getValue() == 1);

                    break;
                case 2:
                    btn1.setVisibility(View.VISIBLE);
                    btn2.setVisibility(View.VISIBLE);
                    btn3.setVisibility(View.GONE);

                    btn1.setChecked(vg.getBtnList().get(0).getValue() == 1);
                    btn2.setChecked(vg.getBtnList().get(1).getValue() == 1);
                    break;
                case 3:
                    btn1.setVisibility(View.VISIBLE);
                    btn2.setVisibility(View.VISIBLE);
                    btn3.setVisibility(View.VISIBLE);

                    btn1.setChecked(vg.getBtnList().get(0).getValue() == 1);
                    btn2.setChecked(vg.getBtnList().get(1).getValue() == 1);
                    btn3.setChecked(vg.getBtnList().get(2).getValue() == 1);
                    break;
                default:
                    btn1.setVisibility(View.GONE);
                    btn2.setVisibility(View.GONE);
                    btn3.setVisibility(View.GONE);
            }

            int next_p = position + 1;
            if (next_p < getCount() && ((VariableGroup) getItem(next_p)).getBtnList() != null) {
                vgLine.setVisibility(View.VISIBLE);
            } else {
                vgLine.setVisibility(View.INVISIBLE);
            }
        }

        _programChangeLock = false;

        return view;
    }

}
