import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Alerts {
  void buildMaterialDialog(
      Widget title, List<Widget> actions, BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: title,
            actions: actions,
          );
        });
  }

  void buildCupertinoDialog(
      Widget title, List<Widget> actions, BuildContext context,
      {Widget content}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: title,
            content: content,
            actions: actions,
          );
        });
  }

  void buildDialogCreditCard(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('90 Diárias'),
          content: Card(
            color: Colors.white,
            elevation: 0.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text("Número do cartão", textAlign: TextAlign.start),
                TextField(
                  maxLength: 14,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: "",
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Text("Data de expiração", textAlign: TextAlign.left),
                TextField(
                  maxLength: 6,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                      labelText: "",
                      isDense: true,),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "CVC",
                  textAlign: TextAlign.left,
                ),
                TextField(
                  maxLength: 3,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: "",
                      isDense: true),
                ),
                SizedBox(
                  height: 16,
                ),
                CupertinoButton(
                  child: Text("Finalizar Compra"),
                  onPressed: () {},
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
