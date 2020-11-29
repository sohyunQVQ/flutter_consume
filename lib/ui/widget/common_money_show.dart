import 'package:flutter/material.dart';
import 'package:flutter_consume/common/upx.dart';

class MoneyShowWithTipsWidget extends StatelessWidget {
  final double number;
  final String tip;

   MoneyShowWithTipsWidget({Key key, this.number, this.tip});


  @override
  Widget build(BuildContext context) {
    return Container(
      height: upx(100),
      child: Column(
        children: [
          Text(number.toString(), style: TextStyle(fontSize: upx(250/(number.toString().length)), fontWeight: FontWeight.w300),),
          Text(tip, style: TextStyle(fontSize: upx(24), color: Colors.black87),),
        ],
      ),
    );
  }
}
