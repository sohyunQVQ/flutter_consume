import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_consume/common/Event.dart';
import 'package:flutter_consume/common/global.dart';
import 'package:flutter_consume/common/model/bill_model.dart';
import 'package:flutter_consume/common/model/record_model.dart';
import 'package:flutter_consume/common/upx.dart';
import 'package:flutter_consume/ui/widget/common_title.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibration/vibration.dart';

class SineCurve extends Curve {
  final double count;

  SineCurve({this.count = 1});

  @override
  double transformInternal(double t) {
    return sin(count * 2 * pi * t) * 0.5 + 0.5;
  }
}

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  AnimationController controller;
  final picker = ImagePicker();

  bool cloudSync = false;
  bool editName  = false;

  String iconPath;
  String name;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    iconPath  = Global.iconPath;
    name      = Global.name ?? '';
    cloudSync = Global.cloudSync ?? false;

    controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<Widget> widgets = [];

    String _name = "";

    widgets.add(TitleWidget(title: "我的", fontSize: upx(40),));

    widgets.add(
      Column(
        children: [
          ScaleTransition(
            alignment: Alignment.center,
            scale: controller,
            child: Container(
              height: upx(200),
              width: upx(200),
              child: InkWell(
                onTap: (){
                  Future<PickedFile> pickedFile = picker.getImage(source: ImageSource.gallery);
                  pickedFile.then((value) {
                    setState(() {
                      iconPath = value.path;
                      Global.iconPath = iconPath;
                      Global.saveIconPath();
                    });
                  });
                },
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.lightBlue[600],
                  image: iconPath !=null ? DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(
                        new File(iconPath)
                    )
                  ) : null,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: upx(20), bottom: upx(20)),
            child: InkWell(
              splashColor: Colors.transparent,
              child: editName ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: upx(300),
                    height: 40,
                    child: TextFormField(
                      maxLength: 12,
                      initialValue: name,
                      onChanged: (value){
                        _name = value;
                      },
                      onEditingComplete: (){
                        setState(() {
                          if(_name.isNotEmpty){
                            name = _name;
                            Global.name = name;
                            Global.saveName();
                          }
                          editName = false;
                        });
                      },
                    ),
                  ),
                ],
              ) : Text(name.isEmpty ? '点这设置名字' : name, style: TextStyle(color: Colors.black54, fontSize: upx(42)),),
              onTap: (){
                setState(() {
                  editName = !editName;
                });
              },
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
            color: Color.fromRGBO(255, 255, 255, 0.8),
            elevation: 0.5,
            margin: EdgeInsets.symmetric(horizontal: upx(30)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: upx(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("云同步(待开发)"),
                      Switch(value: cloudSync, onChanged: (value){
                        setState(() {
                          cloudSync = value;
                          Global.cloudSync = cloudSync;
                          Global.saveCloudSync();
                        });
                      })
                    ],
                  ),
                  FlatButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    textTheme: ButtonTextTheme.accent,
                      padding: EdgeInsets.zero,
                        minWidth: double.infinity,
                        onPressed: (){
                          Vibration.vibrate(duration: 50);
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.WARNING,
                            animType: AnimType.BOTTOMSLIDE,
                            title: '确定清空数据吗',
                            desc: "数据一旦清空后无法逆转, 永远无法找回啦!",
                            btnOkText: '删除',
                            btnOkOnPress: () {
                              BillModel().deleteAll();
                              RecordModel().deleteAll();
                              eventBus.fire(UpdateChangeInEvent(DateTime.now().millisecond));
                            },
                            btnCancelText: '不删了',
                            btnCancelOnPress: () {
                            },
                          )..show();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("清空全部数据"),
                          ],
                        )
                  ),
                ],
              ),
            ),
          )
        ],
      )
    );

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: widgets,
          ),
          Container(
            padding: EdgeInsets.only(bottom: upx(105)),
            child: Text('理智消费, 合理规划。', style: TextStyle(color: Colors.black54),),
          )
        ],
      ),
    );
  }
}

