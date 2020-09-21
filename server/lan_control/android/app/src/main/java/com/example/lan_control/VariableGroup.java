package com.example.lan_control;

import java.util.ArrayList;

public class VariableGroup {
    // ID, NAME, PARENT_ID, ORDER_NUM

    private int _id;
    private String _name;
    private int _parentId;
    private int _orderNum;

    public boolean isFinish = false;
    public String parentName = "";

    private ArrayList<Variable> _variables;

    private ArrayList<Variable> _btnList;

    public VariableGroup(String[] row) {
        _id = Integer.parseInt(row[0]);
        _name = row[1];
        try {
            _parentId = Integer.parseInt(row[2]);
        } catch (Exception e) {
            _parentId = -1;
        }
        try {
            _orderNum = Integer.parseInt(row[3]);
        } catch (Exception e) {
            _orderNum = -1;
        }
    }

    public int getId() {
        return _id;
    }

    public String getName() {
        return _name.trim();
    }

    public String getTitle() {
        return _name.replace(parentName.toLowerCase(), "").trim();
    }

    public int getParentId() {
        return _parentId;
    }

    public int getOrderNum() {
        return _orderNum;
    }

    /*
        0 --//--
        1 Свет
        2 Выключатель
        3 Розетка
        4 Термометр
        5 Термостат
        6 Камера
        7 Вентилятор
        8 Датчик движения
        9 Датчик затопления
        10 Гигрометр
        11 Датчик газа
        12 Датчик двери
        13 Датчик атмосферного давления
        14 Датчик тока
     */

    public void setAllVariables(ArrayList<Variable> allList) {
        _btnList = new ArrayList<Variable>();
        _variables = new ArrayList<Variable>();
        for (int i = 0; i < allList.size(); i++) {
            Variable v = allList.get(i);
            if (v.getGroupId() == _id) {
                _variables.add(v);
                switch (v.getAppControl()) {
                    case 1:
                        _btnList.add(v);
                        break;
                }
            }
        }
    }

    public ArrayList<Variable> getVariables() {
        return _variables;
    }

    public ArrayList<Variable> getBtnList() {
        return _btnList;
    }
}
