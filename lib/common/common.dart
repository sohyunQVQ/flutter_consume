import 'package:flutter/material.dart';
import 'package:flutter_consume/common/AliIcon.dart';
import 'package:flutter_consume/common/model/record_model.dart';

Future<List> getMonthData(int month, List billData, {int year}) async {

  List result = [];

  for(int i = 0; i<billData.length; i++){
    DateTime billDate  = DateTime.parse(billData[i]['create_time']);
    if(year == null){
      year = billDate.year;
    }
    DateTime monthDate = new DateTime(year, month+1); //选择的日期
    DateTime billStartDate  = new DateTime(billDate.year, billDate.month); //账单开始时间
    DateTime endDate = new DateTime(billDate.year, billDate.month+billData[i]['number']+1, 1); //账单结束时间

    Map data = new Map.from(billData[i]);
    if(monthDate.isAfter(billStartDate) && monthDate.isBefore(endDate)){
      //属于账单范围
      List recordData = await RecordModel().getByBillId(billData[i]['id']);
      data['count'] = recordData.length;
      data['status'] = 0;
      recordData.forEach((ele) {
        DateTime recordDate = DateTime.parse(ele['create_time']);
        if(recordDate.month == month || data['status'] == 1){
          data['status'] = 1;
          data['record_id'] = ele['id'];
        }
      });
      result.add(data);
    }
  }
  return result;
}


Future<Map> getMonthMoneyData(int month, List billData, {int year}) async{

  int payMoney = 0;
  int payedMoney = 0;

  if(year == null){
    year = DateTime.now().year;
  }
  DateTime selectDate = new DateTime(year, month+1);
  for(int i = 0; i<billData.length; i++){
    DateTime billDate  = DateTime.parse(billData[i]['create_time']);
    DateTime billStartDate  = new DateTime(billDate.year, billDate.month); //账单开始时间
    DateTime endDate = new DateTime(billDate.year, billDate.month+billData[i]['number']+1, 1); //账单结束时间

    if(selectDate.isAfter(billStartDate) && selectDate.isBefore(endDate)) {
      List recordData = await RecordModel().getByBillId(billData[i]['id']);
      bool payed = false;
      recordData.forEach((ele) {
        DateTime recordDate = DateTime.parse(ele['create_time']);
        if((recordDate.year == year && recordDate.month == month) || payed == true){
          payed = true;
        }
      });

      if(payed){
        payedMoney += billData[i]['pay_money'];
      }else{
        payMoney += billData[i]['pay_money'];
      }
    }
  }

  return new Map.from({"pay": payMoney, "payed": payedMoney});
}

String getTypeText(int type){
  Map types = Map.from({
    1: '生活日常',
    2: '快乐美食',
    3: '数码产品',
    4: '美妆美容',
    5: '其他'
  });
  return types[type];
}

IconData getTypeIcon(int type){
  Map types = Map.from({
    1: AliIcon.kafei,
    2: AliIcon.huabei,
    3: AliIcon.shouji,
    4: AliIcon.kouhong,
    5: AliIcon.liebiao
  });
  return types[type];
}

List getAllTypeInfo(){
  List types = [
    {"id": 1, "title": "生活日常", "icon": AliIcon.kafei},
    {"id": 2, "title": "快乐美食", "icon": AliIcon.hanbao},
    {"id": 3, "title": "数码产品", "icon": AliIcon.shouji},
    {"id": 4, "title": "美妆美容", "icon": AliIcon.kouhong},
    {"id": 5, "title": "其他", "icon": AliIcon.liebiao},
  ];
  return types;
}

List getAllSourceInfo(){
  List types = [
    {"id": 1, "title": "花呗/借呗", "icon": AliIcon.huabei},
    {"id": 2, "title": "分期消费", "icon": AliIcon.tianmaotigongfapiao},
    {"id": 3, "title": "信用卡", "icon": AliIcon.xinyongqiafenqi},
    {"id": 4, "title": "借款", "icon": AliIcon.jiage},
    {"id": 5, "title": "贷款", "icon": AliIcon.tianmaohuodaofukuan},
  ];
  return types;
}

int getSourceId(title){
  List allInfo = getAllSourceInfo();
  for(int i = 0; i<allInfo.length; i++) {
    if(allInfo[i]['title'] == title){
      return allInfo[i]['id'];
    }
  }
  return 1;
}

String getSourceText(id){
  List allInfo = getAllSourceInfo();
  for(int i = 0; i<allInfo.length; i++) {
    if(allInfo[i]['id'] == id){
      return allInfo[i]['title'];
    }
  }
  return "";
}

Map getTimeImagePath() {
  var today = DateTime.now();

  String imgBack;
  String time;

  if(today.hour >= 0 ){
    imgBack = "assets/images/em-back.png";
    time = 'em';
  }
  if(today.hour >=7 ){
    imgBack = "assets/images/am-back.png";
    time = 'am';
  }
  if(today.hour >= 16){
    imgBack = "assets/images/pm-back.png";
    time = 'pm';
  }
  if(today.hour >= 20){
    imgBack = "assets/images/em-back.png";
    time = 'em';
  }
  return {'time': time, 'path': imgBack};
}

Future<Map> getBillShowData(List billData) async{
  Map allData = new Map.from({"pay":0, "payed":0});
  List newBillData = [];

  for(int i = 0; i<billData.length; i++){
    Map data = new Map.from(billData[i]);
    List recordData = await RecordModel().getByBillId(billData[i]['id']);
    data['count'] = recordData.length;
    data['payed'] = recordData.length * billData[i]['pay_money'];
    data['pay']   = (billData[i]['number'] - recordData.length) * billData[i]['pay_money'];
    data['date_show'] = recordData.length.toString()+"/"+billData[i]['number'].toString();
    newBillData.add(data);
    allData['pay'] += data['pay'];
    allData['payed'] += data['payed'];
  }
  return {"allData": allData, "billData": newBillData};
}