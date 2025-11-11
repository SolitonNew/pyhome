package com.example.lan_control;

import android.content.Context;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.support.design.widget.BottomNavigationView;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.Animation;
import android.view.animation.RotateAnimation;
import android.view.animation.ScaleAnimation;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.Toast;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;


/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link Page1.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link Page1#newInstance} factory method to
 * create an instance of this fragment.
 */
public class Page1 extends Fragment {
    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    // TODO: Rename and change types of parameters
    private String mParam1;
    private String mParam2;

    private OnFragmentInteractionListener mListener;

    public Page1() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment Page1.
     */
    // TODO: Rename and change types and number of parameters
    public static Page1 newInstance(String param1, String param2) {
        Page1 fragment = new Page1();
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
        return inflater.inflate(R.layout.fragment_page1, container, false);
    }

    @Override
    public void onStart() {
        // TODO Auto-generated method stub
        super.onStart();

        makeRoomList();
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

    private VariableGroup[] roomList;

    private void makeRoomList() {
        ArrayList<VariableGroup> tmp = ((MainActivity) getActivity()).getVariableGroups();
        ArrayList<Variable> tmp_v = ((MainActivity) getActivity()).getVariables();

        // Формируем правильный список комнат
        ArrayList<VariableGroup> tmp_sort = new ArrayList<VariableGroup>();
        for (int i = 0; i < tmp.size(); i++) {
            boolean notChild = true;
            VariableGroup o = tmp.get(i);
            for (int k = 0; k < tmp.size(); k++) {
                VariableGroup f = tmp.get(k);
                if (f.getParentId() == o.getId()) {
                    notChild = false;
                    break;
                }
            }

            if (notChild) {
                o.setAllVariables(tmp_v);
                // Проверяем не пустой ли раздел
                boolean isNoEmpty = false;
                for (int i1 = 0; i1 < o.getVariables().size(); i1++) {
                    if (o.getVariables().get(i1).getAppControl() > 0) {
                        isNoEmpty = true;
                        break;
                    }
                }

                if (isNoEmpty) {
                    tmp_sort.add(o);
                    o.isFinish = true;

                    // Ищем имя парента
                    for (int k1 = 0; k1 < tmp.size(); k1++) {
                        VariableGroup f1 = tmp.get(k1);
                        if (f1.getId() == o.getParentId()) {
                            o.parentName = f1.getName();
                            break;
                        }
                    }
                }
            }
        }

        // Сортируем по названию
        tmp_sort.sort(new Comparator<VariableGroup>() {
            @Override
            public int compare(VariableGroup o1, VariableGroup o2) {
                return o1.getName().compareTo(o2.getName());
            }
        });

        // Сортируем по группам
        tmp_sort.sort(new Comparator<VariableGroup>() {
            @Override
            public int compare(VariableGroup o1, VariableGroup o2) {
                if (o1.getParentId() > o2.getParentId()) {
                    return 1;
                } else
                if (o1.getParentId() < o2.getParentId()) {
                    return -1;
                }
                return 0;
            }
        });

        // Делаем вставку заголовков групп
        String prevPName = "";
        for (int i = tmp_sort.size() - 1; i > -1; i--) {
            VariableGroup vg = tmp_sort.get(i);
            if (prevPName != "" && prevPName != vg.parentName) {
                String[] g = {"-999", prevPName, "", ""};
                tmp_sort.add(i + 1, new VariableGroup(g));
            }
            prevPName = vg.parentName;
        }
        if (prevPName != "") {
            String[] g = {"-999", prevPName, "", ""};
            tmp_sort.add(0, new VariableGroup(g));
        }

        // Назначаем комнатам переменные
        ListView lv = (ListView) getActivity().findViewById(R.id.rooms);
        VariableGroupAdapter ls = new VariableGroupAdapter(getActivity(), tmp_sort);
        lv.setAdapter(ls);

        lv.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, final long id) {
                (new Handler()).postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        showDetail(id);
                    }
                }, 300);
            }
        });
    }

    private Page1_detail _detail = null;

    public Page1_detail getDetail() {
        return _detail;
    }

    public boolean getDetailVisible() {
        return _detail != null;
    }

    public void showDetail(long id) {
        try {
            _detail = Page1_detail.newInstance("" + id, "");
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

        ListView lv = getActivity().findViewById(R.id.rooms);
        ((VariableGroupAdapter) lv.getAdapter()).notifyDataSetChanged();
    }

}
