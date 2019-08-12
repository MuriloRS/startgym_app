import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/screens/academy_detail_screen.dart';
import 'package:startgym/utils/alerts.dart';
import 'package:startgym/utils/slideRightRoute.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:startgym/widgets/sliver_appbar.dart';

class AcademyCheckin extends StatefulWidget {
  final Map dataAcademy;
  final dynamic userData;
  final PageController drawerController;

  AcademyCheckin(this.dataAcademy, this.userData, this.drawerController);

  _AcademyCheckinState createState() => _AcademyCheckinState(dataAcademy);
}

class _AcademyCheckinState extends State<AcademyCheckin> {
  final Map dataAcademy;

  int stateScreen = 0;
  //CHAVE DO SCAFFOLD
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String result = "";

  _AcademyCheckinState(this.dataAcademy);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double distance = dataAcademy["distance"];
    bool planActive = widget.userData["planActive"];
    String lastCheckin = widget.userData["lastCheckin"].toString();

    //SE O LAST CHECKIN FOR IGUAL A VAZIO OU A DATA LASTCHECKIN FOR DIFERENTE DO DIA ATUAL ENTÃO O CHECKIN É VALIDO
    bool checkInValid = (lastCheckin == "" ||
            DateFormat("dd/MM/yyyy").format(DateTime.now()).toString() !=
                lastCheckin)
        ? true
        : false;


    UserModel.of(context).academyCheckIn = dataAcademy["documentId"];

    distance = double.parse(distance.toStringAsFixed(2));

    String nomeAcademia = dataAcademy["fantasia"] == ""
        ? dataAcademy["name"].toString()
        : dataAcademy["fantasia"].toString();

    if (dataAcademy["fantasia"].toString().contains(",")) {
      nomeAcademia = dataAcademy["fantasia"].toString().split(",")[0];
    }

    return CustomScrollView(physics: NeverScrollableScrollPhysics(), slivers: <
        Widget>[
      CustomSliverAppbar(),
      SliverFillRemaining(
        child: Scaffold(
          backgroundColor: Colors.white,
          key: _scaffoldKey,
          body: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    nomeAcademia,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.none),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: Theme.of(context).accentColor,
                        child: Text("FAZER CHECKIN",
                            style:
                                TextStyle(fontSize: 22.0, color: Colors.white)),
                        onPressed: checkInValid && planActive
                            ? _scanQR
                            : () {
                                showStatusError(checkInValid, planActive);
                              },
                      )),
                  SizedBox(
                    height: 15.0,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Endereço: Vereador Assmann.",
                        style: Theme.of(context).textTheme.body1,
                      ),
                      Text(
                        "Distância: $distance km",
                        style: Theme.of(context).textTheme.body1,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: FlatButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "Ver detalhes",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                decoration: TextDecoration.underline),
                          )
                        ],
                      ),
                      color: Colors.grey[300],
                      padding:
                          EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          SlideRightRoute(
                              widget: AcademyDetailScreen(dataAcademy)),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              )),
        ),
      )
    ]);
  }

  void showStatusError(checkInValid, planActive) {
    String message = "";

    if (!checkInValid) {
      message =
          "Você já fez um checkin hoje, seu plano te permite fazer um checkin por dia.";

      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[300],
        duration: Duration(seconds: 13),
      ));
    } else if (!planActive) {
      message = "Você não tem um plano ativo";

      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.black),
        ),
        action: SnackBarAction(
          label: "Comprar",
          textColor: Theme.of(context).colorScheme.primary,
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed("/buyScreen");
          },
        ),
        backgroundColor: Colors.grey[300],
        duration: Duration(seconds: 13),
      ));
    }
  }

  Future _scanQR() async {
    try {
      String qrResult = await BarcodeScanner.scan();

      result = qrResult;

      Navigator.pop(context);
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        result = "Permissão da câmera negada";
      } else {
        result = "Erro desconhecido $ex";
      }
    } on FormatException {
      result = "Você pressionou o botão de voltar antes de ler o qr-code.";
    } catch (ex) {
      result = "Erro desconhecido $ex";
    }

    if (result == dataAcademy["academyCheckInCode"]) {
      await _updateDiarysUserAndAcademy();

      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          "Check-in realizado com sucesso!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 5),
      ));
    }
  }

  //CALCULA E ATUALIZA AS DIÁRIAS DO USUÁRIO FAZENDO A CONTA userPoints - academy['points']
  //CALCULA E ATUALIZA AS O VALOR DE SAQUE DA ACADEMIA FAZENDO A CONTA valor de saque + academy['points']
  Future<void> _updateDiarysUserAndAcademy() async {
    Map userData = UserModel.of(context).userData;

    userData["lastCheckin"] = DateTime.now().toString();
    UserModel.of(context).saveUserData(userData);

    DocumentSnapshot snapshot = await Firestore.instance
        .collection("userAcademy")
        .document(widget.dataAcademy["documentId"])
        .get();

    if (snapshot.exists) {
      int newAcademyValueSack =
          snapshot.data["academyValueSack"].toInt() + 2.50;

      snapshot.data["academyValueSack"] = newAcademyValueSack;

      await Firestore.instance
          .collection("userAcademy")
          .document(widget.dataAcademy["documentId"])
          .updateData(snapshot.data);

      await Firestore.instance
          .collection("userAcademy")
          .document(widget.dataAcademy["documentId"])
          .collection("checkins")
          .add({
        "clientId": userData["documentId"],
        "time": Timestamp.now(),
        "viewed": false,
        "price": 2.5,
        "name": widget.userData["name"]
      });
    }
  }

  void reloadCurrentUser() async {
    await UserModel.of(context).loadCurrentUser();
  }
}
