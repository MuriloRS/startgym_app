import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'alerts.dart';

class ListenConnectivity {
  static StreamSubscription<ConnectivityResult> streamConnection;
  static ConnectivityResult result;
  static BuildContext _context;
  static bool isShowedAlert = false;

  static void startListen(BuildContext context) {
    ListenConnectivity.streamConnection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result.index == ConnectivityResult.none.index) {
        result = result;
        _context = context;

        showMessageOfflineInternet();
      }
    });
  }

  static void showMessageOfflineInternet() async {
    if (isShowedAlert == false) {
      Alerts alerts = new Alerts();

      alerts.buildCupertinoDialog(
          Text("Sem conexão"),
          [
            CupertinoDialogAction(
              child: Text("Atualizar"),
              onPressed: reloadScreen,
              isDefaultAction: true,
            )
          ],
          _context,
          content: Text("Por favor se conecte a uma rede."));

      isShowedAlert = true;
    }
  }

  static Future<Null> reloadScreen() async {
    ConnectivityResult status = await Connectivity().checkConnectivity();

    if (status.index == ConnectivityResult.none.index) {
      showMessageOfflineInternet();
    } else {
      isShowedAlert = false;
      Navigator.of(_context).pop();
    }
  }

  static void cancelListen() {
    streamConnection.cancel();
  }
}
