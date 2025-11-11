package com.example.lan_control;

import android.content.Context;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.TextureView;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.VideoView;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;


/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link Page2_detail.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link Page2_detail#newInstance} factory method to
 * create an instance of this fragment.
 */
public class Page2_detail extends Fragment {
    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    // TODO: Rename and change types of parameters
    private String mParam1;
    private String mParam2;

    private OnFragmentInteractionListener mListener;

    public Page2_detail() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment Page2_detail.
     */
    // TODO: Rename and change types and number of parameters
    public static Page2_detail newInstance(String param1, String param2) {
        Page2_detail fragment = new Page2_detail();
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
        return inflater.inflate(R.layout.fragment_page2_detail, container, false);
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

        MainActivity mainActivity = (MainActivity) getActivity();

        String[] cam = mainActivity._cams[Integer.parseInt(mParam1)];

        TextView camDetailName = getActivity().findViewById(R.id.camDetailName);
        camDetailName.setText(cam[1]);

        String url = cam[2];
        url = url.replace("stream=1.sdp", "stream=0.sdp");
        url = url.replace("--rtp-caching=300", "--rtp-caching=3000");

        LinearLayout camContainer = mainActivity.findViewById(R.id.camContainer);

        //rtsp://192.168.40.3:554/user=admin&password=&channel=1&stream=1.sdp?real_stream--rtp-caching=300

        VideoView camVideoView = mainActivity.findViewById(R.id.camVideoView);
        camVideoView.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 1000));
        camVideoView.setVideoPath(url);
        camVideoView.start();

        doResize();

        Button button4 = mainActivity.findViewById(R.id.button4);
        button4.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getSnapshot("tumbnail_" + mParam1);
            }
        });

    }

    @Override
    public void onStop() {
        super.onStop();

        MainActivity mainActivity = (MainActivity) getActivity();
        mainActivity.getSupportActionBar().show();
        mainActivity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
    }

    public void doResize() {
        MainActivity mainActivity = (MainActivity) getActivity();

        if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
            mainActivity.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
            mainActivity.getSupportActionBar().hide();
            mainActivity.findViewById(R.id.camDetailToolBar).setVisibility(View.GONE);
            ((LinearLayout) mainActivity.findViewById(R.id.camContainer)).setVisibility(View.GONE);
        } else {
            mainActivity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
            mainActivity.getSupportActionBar().show();
            mainActivity.findViewById(R.id.camDetailToolBar).setVisibility(View.VISIBLE);
            ((LinearLayout) mainActivity.findViewById(R.id.camContainer)).setVisibility(View.VISIBLE);
        }
    }

    public void getSnapshot(String fileName) {
        MainActivity mainActivity = (MainActivity) getActivity();

        VideoView videoView = getActivity().findViewById(R.id.camVideoView);
        Bitmap bitmap = videoView.getDrawingCache();



        String dir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES) + "/lancontrol";

        File dirFile = new File(dir);
        if (!dirFile.exists()) dirFile.mkdirs();

        File imagePath = new File( dir + "/" + fileName + ".png");
        try {
            FileOutputStream out = new FileOutputStream(imagePath);
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, out);
            out.flush();
            out.close();
        } catch (FileNotFoundException e) {
            Log.e("GREC", e.getMessage(), e);
        } catch (IOException e) {
            Log.e("GREC", e.getMessage(), e);
        }
    }


}

