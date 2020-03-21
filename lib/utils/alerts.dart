import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Alerts {
  void buildMaterialDialog(
      Widget title, List<Widget> actions, BuildContext context,
      {Widget content}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: title,
            actions: actions,
            content: content,
          );
        });
  }

  void buildNoConnectionModal(context, VoidCallback reload) {
    buildCupertinoDialog(
        Text("Sem internet"),
        [
          CupertinoDialogAction(
            child: Text("Atualizar"),
            isDefaultAction: true,
            onPressed: () {
              reload();
            },
          )
        ],
        context,
        content: Text("Por favor se conecte à uma rede :)"));
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

  /*
   * Mostra um snackbar personalizado
   * tipo 0 = sucesso
   * tipo 1 = alerta
   * tipo 2 = erro
   */
  void showSnackBar(
      {String title,
      String description,
      @required int type,
      @required BuildContext context}) {
    Color colorStart;
    Color colorEnd;

    switch (type) {
      case 0:
        colorStart = Colors.green.shade800;
        colorEnd = Colors.green.shade700;
        break;
      case 1:
        colorStart = Colors.yellowAccent.shade700;
        colorEnd = Colors.yellowAccent.shade400;
        break;
      case 2:
        colorStart = Colors.red.shade800;
        colorEnd = Colors.red.shade700;
        break;
      default:
    }

    Flushbar(
      flushbarStyle: FlushbarStyle.FLOATING,
      backgroundGradient: LinearGradient(
        colors: [colorStart, colorEnd],
        stops: [0.6, 1],
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black45,
          offset: Offset(3, 3),
          blurRadius: 3,
        ),
      ],
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      title: title,
      message: description,
    )..show(context);
  }
}
