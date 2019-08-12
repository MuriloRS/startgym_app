import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/tiles/academy_tile.dart';
import 'package:startgym/utils/alerts.dart';
import 'package:startgym/utils/localization.dart';
import 'package:startgym/widgets/google_maps.dart';
import 'package:startgym/widgets/modal_loader.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class HomeTab extends StatefulWidget {
  final PageController _pageController;

  HomeTab(this._pageController);

  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  //Uma lista dos filtros das academias
  List filtro = ["pontos", "distância"];
  List<Widget> listAcademys = List();
  Localization localizations = Localization();
  QuerySnapshot dataAcademy;
  var result;
  bool isOnline = false;
  final Connectivity _connectivity = new Connectivity();

  @override
  void initState() {
    super.initState();

    if (UserModel.of(context).firebaseUser == null) {
      UserModel.of(context).loadCurrentUser();
    }

    verifyPendingPayments();

    _verifyTypeUser();
  }

  void reloadScreen() async {}

  @override
  Widget build(BuildContext context) {
    return Localization.listAcademys == null
        ? StreamBuilder(
            stream: new Localization().getLocationsAcademyNearBy().asStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData ||
                  snapshot.connectionState.index ==
                      ConnectionState.none.index ||
                  snapshot.connectionState.index ==
                      ConnectionState.waiting.index) {
                return ModalLoader();
              } else {
                Localization.listAcademys = snapshot.data;

                return buildMap();
              }
            },
          )
        : buildMap();
  }

  Widget buildMap() {
    List<Map> orderedList = Localization.listAcademys;
    var dividedTiles;

    if (orderedList.length > 0) {
      dividedTiles = null;
      listAcademys.clear();

      orderedList.sort((a, b) {
        if (a["distance"] != null) {
          if (a["distance"] > b["distance"]) {
            return 1;
          } else {
            return 0;
          }
        } else {
          return 0;
        }
      });

      //Para cada academia cria uma academyTile
      for (var i = 1; i < Localization.listAcademys.length; i++) {
        listAcademys.add(AcademyTile(
          drawerController: widget._pageController,
          userData: UserModel.of(context).userData,
          dataMap: Localization.listAcademys,
          dataAcademy: Localization.listAcademys.elementAt(i),
        ));
      }

      //Se listAcademys for diferente de vazio então cria uma lista das academysTiles
      if (listAcademys.isNotEmpty) {
        dividedTiles =
            ListTile.divideTiles(tiles: listAcademys, color: Colors.transparent)
                .toList();
      }

      return Scaffold(
          body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          GoogleMaps(Localization.listAcademys, widget._pageController,
              UserModel.of(context).userData),
          Positioned(
            top: 30,
            left: 15,
            child: IconButton(
              icon: Icon(
                Icons.menu,
                size: 36,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ],
      ));
    } else {
      return Container(
        child: Text("Nenhuma academia encontrada."),
      );
    }
  }

  void verifyPendingPayments() async {
    bool planActive = false;

    QuerySnapshot snapshot = await Firestore.instance
        .collection("users")
        .document(UserModel.of(context).firebaseUser.uid)
        .collection("pendingPayments")
        .getDocuments();

    if (snapshot.documents.length > 0) {
      String _accessToken = await _getAccessToken(isProduction: false);

      for (int x = 0; x < snapshot.documents.length; x++) {
        DocumentSnapshot doc = snapshot.documents.elementAt(x);

        http.Response resp = await http.get(
            'https://api.mercadopago.com/v1/payments/${doc.data['idPayment']}?access_token=$_accessToken');

        Map paymentResult = json.decode(resp.body) as Map;

        if (paymentResult['status_detail'] != "pending_waiting_payment") {
          //ATIVA O PLANO DO USUÁRIO
          await UserModel.of(context).activeUserPlan(30);

          //EXCLUI O PAGAMENTO PENDENTE
          await Firestore.instance
              .collection("users")
              .document(UserModel.of(context).firebaseUser.uid)
              .collection("pendingPayments")
              .document(doc.documentID)
              .delete();

          _showPlansActiveAlert();
        }
      }
    }
  }

  void _showPlansActiveAlert() {
    Alerts al = new Alerts();
    var formatter = new DateFormat('dd/MM/yyyy');

    al.buildCupertinoDialog(
        Text("Plano ativado!"),
        [
          CupertinoDialogAction(
            child: Text("Valeu"),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
        context,
        content: Text(
            "Seu plano foi ativado até ${formatter.format(UserModel.of(context).userData['planExpires'])}"));
  }

  Future<String> _getAccessToken({@required bool isProduction}) async {
    QuerySnapshot databaseCredentials =
        await Firestore.instance.collection("config").getDocuments();

    return isProduction
        ? databaseCredentials.documents
            .elementAt(0)
            .data["accessTokenProduction"]
        : databaseCredentials.documents.elementAt(0).data["accessTokenSandbox"];
  }

  //Itens do Dropdown do filtro das academias
  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String f in filtro) {
      items.add(new DropdownMenuItem(
          value: f,
          child: new Text(
            f,
            style: TextStyle(fontSize: 15.0, decorationColor: Colors.red),
          )));
    }
    return items;
  }

  void _verifyTypeUser() async {
    if (UserModel.of(context).userData['email'].toString().contains("gmail")) {
      await UserModel.of(context).loadCurrentUser();
    }
  }
}
