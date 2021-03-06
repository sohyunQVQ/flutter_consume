import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_consume/common/common.dart';
import 'package:flutter_consume/common/model/bill_model.dart';
import 'package:flutter_consume/common/upx.dart';
import 'package:flutter_consume/ui/widget/common_card_button.dart';
import 'package:flutter_consume/ui/widget/common_icon_select.dart';
import 'package:flutter_consume/ui/widget/common_title.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:flutter_consume/common/Event.dart';

class AddBillPage extends StatefulWidget {

  final int billId;

  AddBillPage({this.billId});

  @override
  _AddBillPageState createState() => _AddBillPageState();
}

class _AddBillPageState extends State<AddBillPage> {

  int switchType = 0;

  String title;
  int type;
  int source;
  String number;
  String date;
  double money;

  final TextEditingController titleController = new TextEditingController();
  final TextEditingController numberController = new TextEditingController();
  final TextEditingController dateController = new TextEditingController();
  final TextEditingController moneyController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if(widget.billId != null){
      this.switchType = 1;
      Future<Map> bill =  BillModel().get(widget.billId);
      bill.then((value) {
        setState(() {
          title = value['title'];
          type = value['type'];
          number = value['number'].toString();
          date = value['pay_time'];
          money = (value['pay_money'] / 100 );
          source = getSourceId(value['source']);
        });
        titleController.text = title;
        numberController.text = number;
        dateController.text = date;
        moneyController.text = money.toString();
      });
    }
    super.initState();

  }

  List<Widget> typeForm() {
    List<Widget> widgetList = [];
    switch(switchType) {
      case 1: {
        List typeInfo = getAllTypeInfo();
        List sourceInfo = getAllSourceInfo();

        widgetList.add(
          Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Container(
                    width: upx(680),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: TextFormField(
                        controller:  titleController,
                        decoration: InputDecoration(
                            hintText: "分期项目(建议填写商品名或来源)",
                            border: new OutlineInputBorder(  //添加边框
                              gapPadding: 10.0,
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            suffixIcon: new Icon(Icons.title),
                            contentPadding: const EdgeInsets.only(left: 20)),
                        validator: (value){
                          if(value.isEmpty){
                            return "标题不能留空";
                          }
                          return null;
                        },
                        onChanged: (v){
                          setState(() {
                            this.title = v;
                          });
                        },
                        autofocus: false,
                      ),
                    ),
                  ),
                  IconSelectList(eleList: typeInfo, value: type, onSelect: (value){
                    setState(() {
                      this.type = value;
                    });
                  },),
                  IconSelectList(eleList: sourceInfo, value: source, onSelect: (value){
                    setState(() {
                      this.source = value;
                    });
                  },),
                  Container(
                    width: upx(680),
                    margin: EdgeInsets.only(top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: upx(210),
                          child: TextFormField(
                            controller: numberController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                hintText: "需还期数",
                                border: new OutlineInputBorder(  //添加边框
                                  gapPadding: 10.0,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                suffixIcon: new Icon(Icons.timer),
                                suffixIconConstraints: BoxConstraints.tightFor(width: 30),
                                contentPadding: const EdgeInsets.all(10.0)),
                            validator: (value){
                              if(value.isEmpty){
                                return "还款期数不能留空";
                              }
                              return null;
                            },
                            onChanged: (value){
                              setState(() {
                                this.number = value;
                              });
                            },
                            autofocus: false,
                          ),
                        ),
                        Container(
                          width: upx(240),
                          child: TextFormField(
                            controller: dateController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                hintText: "每月还款日",
                                border: new OutlineInputBorder(  //添加边框
                                  gapPadding: 10.0,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                suffixIcon: new Icon(Icons.date_range),
                                suffixIconConstraints: BoxConstraints.tightFor(width: 30),
                                contentPadding: const EdgeInsets.all(10.0)),
                            validator: (value){
                              if(value.isEmpty){
                                return "还款日不能留空";
                              }
                              return null;
                            },
                            onChanged: (value){
                              setState(() {
                                this.date = value;
                              });
                            },
                            autofocus: false,
                          ),
                        ),
                        Container(
                          width: upx(210),
                          child: TextFormField(
                            controller: moneyController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              ThousandsFormatter(allowFraction: true)
                            ],
                            decoration: InputDecoration(
                                hintText: "每期还款",
                                border: new OutlineInputBorder(  //添加边框
                                  gapPadding: 10.0,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                suffixIcon: new Icon(Icons.attach_money),
                                suffixIconConstraints: BoxConstraints.tightFor(width: 30),
                                contentPadding: const EdgeInsets.all(10.0)),
                            validator: (value){
                              if(value.isEmpty){
                                return "每期还款不能留空";
                              }
                              return null;
                            },
                            onChanged: (value){
                              setState(() {
                                value = value.replaceAll(",", "");
                                this.money = double.parse(value);
                              });
                            },
                            autofocus: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 15),
                      width: upx(680),
                      child:  SizedBox(
                        width: double.infinity,
                        height: upx(80),
                        child: FlatButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: Color(0xFFFFA53E),
                          onPressed: (){
                            if (_formKey.currentState.validate()) {
                              if(widget.billId == null){
                                Future<int> newId =  BillModel().insert({
                                  "title": title,
                                  "type": type ?? 1,
                                  "number": number ?? 1,
                                  "pay_time": date ?? 1,
                                  "pay_money": (money ?? 1) * 100,
                                  "source": getSourceText(source ?? 1)
                                });
                                newId.then((value){
                                  eventBus.fire(UpdateChangeInEvent(DateTime.now().second));
                                });
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.SUCCES,
                                  animType: AnimType.BOTTOMSLIDE,
                                  title: '创建成功',
                                  desc: '点击确定返回上一页',
                                  btnOkText: '确定',
                                  btnOkOnPress: () {
                                    setState(() {
                                      switchType = 0;
                                    });
                                  },
                                )..show();
                              }else{
                                Future<bool> updated =  BillModel().update(widget.billId, {
                                  "title": title,
                                  "type": type ?? 1,
                                  "number": number ?? 1,
                                  "pay_time": date ?? 1,
                                  "pay_money": (money ?? 1) * 100,
                                  "source": getSourceText(source ?? 1)
                                });
                                updated.then((value){
                                  eventBus.fire(UpdateChangeInEvent(DateTime.now().second));
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.SUCCES,
                                    animType: AnimType.BOTTOMSLIDE,
                                    title: '更新' + (value ? '成功' : '失败'),
                                    desc: '点击确定返回上一页',
                                    btnOkText: '确定',
                                    btnOkOnPress: () {
                                      setState(() {
                                        switchType = 0;
                                      });
                                    },
                                  )..show();
                                });
                              }
                            }
                          },
                          child: Text(
                            widget.billId == null ? "Create" : "Update",
                            style: TextStyle(
                              fontSize: upx(38),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                  ) // Add TextFormFields and ElevatedButton here.
                ]
              )
          )
        );
      }
      break;
      case 2: {
        this.type = 5;
        this.source = 5;
        widgetList.add(
            Form(
                key: _formKey,
                child: Column(
                    children: <Widget>[
                      Container(
                        width: upx(680),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: TextFormField(
                            decoration: InputDecoration(
                                hintText: "还款项目(建议填写来源)",
                                border: new OutlineInputBorder(  //添加边框
                                  gapPadding: 10.0,
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                suffixIcon: new Icon(Icons.title),
                                contentPadding: const EdgeInsets.only(left: 20)),
                            validator: (value){
                              if(value.isEmpty){
                                return "标题不能留空";
                              }
                              return null;
                            },
                            onChanged: (v){
                              setState(() {
                                this.title = v;
                              });
                            },
                            autofocus: false,
                          ),
                        ),
                      ),
                      Container(
                        width: upx(680),
                        margin: EdgeInsets.only(top: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: upx(210),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    hintText: "需还期数",
                                    border: new OutlineInputBorder(  //添加边框
                                      gapPadding: 10.0,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    suffixIcon: new Icon(Icons.timer),
                                    suffixIconConstraints: BoxConstraints.tightFor(width: 30),
                                    contentPadding: const EdgeInsets.all(10.0)),
                                validator: (value){
                                  if(value.isEmpty){
                                    return "还款期数不能留空";
                                  }
                                  return null;
                                },
                                onChanged: (value){
                                  setState(() {
                                    this.number = value;
                                  });
                                },
                                autofocus: false,
                              ),
                            ),
                            Container(
                              width: upx(240),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    hintText: "每月还款日",
                                    border: new OutlineInputBorder(  //添加边框
                                      gapPadding: 10.0,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    suffixIcon: new Icon(Icons.date_range),
                                    suffixIconConstraints: BoxConstraints.tightFor(width: 30),
                                    contentPadding: const EdgeInsets.all(10.0)),
                                validator: (value){
                                  if(value.isEmpty){
                                    return "还款日不能留空";
                                  }
                                  return null;
                                },
                                onChanged: (value){
                                  setState(() {
                                    this.date = value;
                                  });
                                },
                                autofocus: false,
                              ),
                            ),
                            Container(
                              width: upx(210),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  ThousandsFormatter(allowFraction: true)
                                ],
                                decoration: InputDecoration(
                                    hintText: "每期还款",
                                    border: new OutlineInputBorder(  //添加边框
                                      gapPadding: 10.0,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    suffixIcon: new Icon(Icons.attach_money),
                                    suffixIconConstraints: BoxConstraints.tightFor(width: 30),
                                    contentPadding: const EdgeInsets.all(10.0)),
                                validator: (value){
                                  if(value.isEmpty){
                                    return "每期还款不能留空";
                                  }
                                  return null;
                                },
                                onChanged: (value){
                                  setState(() {
                                    value = value.replaceAll(",", "");
                                    this.money = double.parse(value);
                                  });
                                },
                                autofocus: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 15),
                          width: upx(680),
                          child:  SizedBox(
                            width: double.infinity,
                            height: upx(80),
                            child: FlatButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              color: Color(0xFFFFA53E),
                              onPressed: (){
                                if (_formKey.currentState.validate()) {
                                  Future<int> newId =  BillModel().insert({
                                    "title": title,
                                    "type": type ?? 1,
                                    "number": number ?? 1,
                                    "pay_time": date ?? 1,
                                    "pay_money": (money ?? 1) * 100,
                                    "source": getSourceText(source ?? 1)
                                  });
                                  newId.then((value){
                                    eventBus.fire(UpdateChangeInEvent(DateTime.now().second));
                                  });
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.SUCCES,
                                    animType: AnimType.BOTTOMSLIDE,
                                    title: '创建成功',
                                    desc: '点击确定返回上一页',
                                    btnOkText: '确定',
                                    btnOkOnPress: () {
                                      setState(() {
                                        switchType = 0;
                                      });
                                    },
                                  )..show();
                                }
                              },
                              child: Text(
                                "Create",
                                style: TextStyle(
                                  fontSize: upx(38),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                      ) // Add TextFormFields and ElevatedButton here.
                    ]
                )
            )
        );
      }
      break;
      default: {
        //还没选择
        widgetList.add(CardButton(title: Text('分期债务', style: TextStyle(fontSize: upx(38)),), icon: Icon(Icons.update, size: upx(60),),
          onTap: (){
            setState(() {
              switchType = 1;
            });
          },
        ));
        widgetList.add(CardButton(title: Text('一次性借款', style: TextStyle(fontSize: upx(38)),), icon: Icon(Icons.add, size: upx(60),),
          onTap: (){
            setState(() {
              switchType = 2;
            });
          },
        ));
      }
      break;
    }
    return widgetList;
  }


  @override
  Widget build(BuildContext context) {

    List<Widget> widgets = [];


    widgets.add(TitleWidget(title: "新增账单", fontSize: upx(40),
      rightButton: IconButton(
        onPressed: (){
          if(switchType > 0){
            setState(() {
              switchType = 0;
            });
          }else{
            Navigator.pop(context);
          }
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        icon: Icon(Icons.arrow_back, size: upx(36)),
      ),
    ));

    widgets.addAll(typeForm());

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            child: Column(
              children: widgets,
            ),
          ),
        ],
      ),
    );
  }
}