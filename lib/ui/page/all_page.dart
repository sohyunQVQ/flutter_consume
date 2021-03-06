import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_consume/common/Event.dart';
import 'package:flutter_consume/common/common.dart';
import 'package:flutter_consume/common/model/bill_model.dart';
import 'package:flutter_consume/ui/page/add_bill_page.dart';
import 'package:flutter_consume/ui/widget/bill_money.dart';
import 'package:flutter_consume/ui/widget/common_read_record.dart';

class AllPage extends StatefulWidget {
  @override
  _AllPageState createState() => _AllPageState();
}

class _AllPageState extends State<AllPage> with AutomaticKeepAliveClientMixin{

  double payMoney = 0;
  double payedMoney = 0;

  List billData = [];
  List<Widget> widgets = [];

  int flushVersion = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    BillModel().getAll().then((value) {
     _flush(value);
    });
    eventBus.on<UpdateChangeInEvent>().listen((event) {
      if(event.version != flushVersion){
        BillModel().getAll().then((value) {
          _flush(value);
        });
        setState(() {
          flushVersion = event.version;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            child: Column(children: widgets),
          ),
        ],
      ),
    );
  }
  Future<void> _flush(List billList) async {
    Future<Map> showData = getBillShowData(billList);
    showData.then((value) {
      setState(() {
        widgets.clear();
        widgets.add(
            BillMoneyWidget(
              payedMoney: value['allData']['payed'] / 100,
              payMoney: value['allData']['pay'] / 100,
              addPage: new AddBillPage(),
              addThen: (e){
                BillModel().getAll().then((value) {
                  _flush(value);
                });
              },
              billData: billList,
            )
        );
        if(value['billData'].length > 0){
          for (int i = 0; i < value['billData'].length; i++) {
            widgets.add(ReadRecordWidget(
              id: value['billData'][i]['id'],
              name: value['billData'][i]['title'],
              payMoney: value['billData'][i]['pay'] / 100,
              payedMoney: value['billData'][i]['payed'] / 100,
              dateShow: value['billData'][i]['date_show'],
              payDate: value['billData'][i]['pay_time'],
              typeIcon: getTypeIcon(value['billData'][i]['type']),
              source: value['billData'][i]['source'],
              editPage: new AddBillPage(billId: value['billData'][i]['id'],),
              editThen: (e){
                BillModel().getAll().then((value) {
                  _flush(value);
                });
              },
            ));
          }
        }else{
          setState(() {
            widgets.add(Container(
              margin: EdgeInsets.only(top: 400),
              child: Text("还没添加账单记录, 快去添加吧", style: TextStyle(color: Colors.black54),),
            ));
          });
        }
      });
    });
  }
}
