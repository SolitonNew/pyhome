package com.example.lan_control;

import android.content.Context;
import android.content.res.Configuration;
import android.graphics.drawable.GradientDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.OrientationEventListener;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.Toolbar;
import android.widget.VideoView;


/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link Page2.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link Page2#newInstance} factory method to
 * create an instance of this fragment.
 */
public class Page2 extends Fragment {
    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    // TODO: Rename and change types of parameters
    private String mParam1;
    private String mParam2;

    private OnFragmentInteractionListener mListener;

    public Page2() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment Page2.
     */
    // TODO: Rename and change types and number of parameters
    public static Page2 newInstance(String param1, String param2) {
        Page2 fragment = new Page2();
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
        return inflater.inflate(R.layout.fragment_page2, container, false);
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

    @Override
    public void onStart() {
        super.onStart();

        ListView camList = getActivity().findViewById(R.id.camList);
        CamListAdapter a = new CamListAdapter(getActivity(), ((MainActivity) getActivity())._cams);
        camList.setAdapter(a);

        camList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                showDetail(position);
            }
        });
    }

    private Page2_detail _detail = null;

    public Page2_detail getDetail() {
        return _detail;
    }

    public boolean getDetailVisible() {
        return _detail != null;
    }

    public void showDetail(long id) {
        try {
            _detail = Page2_detail.newInstance("" + id, "");
            FragmentTransaction ft = ((MainActivity) getActivity()).getSupportFragmentManager().beginTransaction();
            ft.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_OPEN);
            ft.replace(R.id.fullFragmentContainer, _detail);
            ft.commit();
            getActivity().findViewById(R.id.bottomNavigationView).setVisibility(View.INVISIBLE);
            ((MainActivity) getActivity()).getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        } catch (Exception e) {
            Log.d("ERROR", e.toString());
        }
    }

    public void hideDetail() {
        if (_detail == null) return ;

        ((MainActivity) getActivity()).getSupportActionBar().setDisplayHomeAsUpEnabled(false);
        FragmentTransaction ft = ((MainActivity) getActivity()).getSupportFragmentManager().beginTransaction();
        ft.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_CLOSE);
        ft.detach(_detail);
        ft.commit();
        _detail = null;
        getActivity().findViewById(R.id.bottomNavigationView).setVisibility(View.VISIBLE);

        ListView lv = getActivity().findViewById(R.id.camList);
        ((CamListAdapter) lv.getAdapter()).notifyDataSetChanged();
    }

    public void doResize(int newOrientation) {
        if (_detail != null) _detail.doResize();
    }

    /*public void startVideo() {
        MainActivity mainActivity = (MainActivity) getActivity();

        LinearLayout camList = mainActivity.findViewById(R.id.camList);

        // v.ID, v.NAME, v.URL, v.ORDER_NUM, v.ALERT_VAR_ID
        for (int i = 3; i < mainActivity._cams.length; i++) {
            VideoView vv = new VideoView(getContext());
            vv.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 1000));
            vv.setBackgroundColor(0x90000000);
            camList.addView(vv);
            String u = mainActivity._cams[i][2];
            u = u.replace("stream=1.sdp", "stream=0.sdp");
            vv.setVideoPath(u);
            vv.start();
        }
    }*/
}
