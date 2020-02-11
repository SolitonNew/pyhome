package com.example.lan_control;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.example.lan_control.R;

public class CamListAdapter extends BaseAdapter {

    Context _context;
    String[][] _camList;
    LayoutInflater _layoutInflater;

    public CamListAdapter(Context context, String[][] camList) {
        _context = context;
        _camList = camList;
        _layoutInflater = (LayoutInflater) _context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    }

    @Override
    public int getCount() {
        return _camList.length;
    }

    @Override
    public Object getItem(int position) {
        return _camList[position];
    }

    @Override
    public long getItemId(int position) {
        return Integer.parseInt(_camList[position][0]);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View view = convertView;
        if (view == null) {
            view = _layoutInflater.inflate(R.layout.cam_item, parent, false);
        }

        TextView camItemName = view.findViewById(R.id.camItemName);
        camItemName.setText(_camList[position][1]);

        ImageView imageView = view.findViewById(R.id.imageView);
        int w = parent.getMeasuredWidth() / 2;
        imageView.setLayoutParams(new LinearLayout.LayoutParams(w, w * 2 / 3));

        return view;
    }
}
