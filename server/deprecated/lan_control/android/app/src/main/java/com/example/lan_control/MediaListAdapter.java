package com.example.lan_control;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

public class MediaListAdapter extends BaseAdapter {

    private Context _context;
    private String[][] _list;
    private LayoutInflater _layoutInflater;

    public MediaListAdapter(Context context, String[][] list) {
        _context = context;
        _list = list;
        _layoutInflater = (LayoutInflater) _context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    }

    @Override
    public int getCount() {
        return _list.length;
    }

    @Override
    public Object getItem(int position) {
        return _list[position];
    }

    @Override
    public long getItemId(int position) {
        return Integer.parseInt(_list[position][0]);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {

        // ID, APP_CONTROL_ID, TITLE, FILE_NAME, FILE_TYPE

        View view = convertView;
        if (view == null) {
            view = _layoutInflater.inflate(R.layout.media_item, parent, false);
        }

        TextView camItemName = view.findViewById(R.id.mediaItemTitle);
        camItemName.setText(_list[position][2]);

        return view;
    }
}
