import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/screens/warningConnectivity.dart';
import 'package:startgym/tiles/academy_tile.dart';
import 'package:startgym/utils/listenConnectivity.dart';
import 'package:startgym/utils/localization.dart';
import 'package:startgym/widgets/google_maps.dart';
import 'package:startgym/widgets/modal_loader.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTab extends StatefulWidget {
  final PageController _pageController;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  HomeTab(this._pageController, this._scaffoldKey);

  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  Completer<GoogleMapController> _controller = Completer();

  //Uma lista dos filtros das academias
  List filtro = ["pontos", "distância"];
  List<Widget> listAcademys = List();
  Localization localizations = Localization();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  QuerySnapshot dataAcademy;
  var result;
  bool isOnline = false;
  final Connectivity _connectivity = new Connectivity();
  final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      zoom: 19.151926040649414);

  @override
  void initState() {
    super.initState();

    if (UserModel.of(context).firebaseUser == null) {
      UserModel.of(context).loadCurrentUser();
    }

    ListenConnectivity.startListen(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void reloadScreen() async {}

  @override
  Widget build(BuildContext context) {


    var dividedTiles;

    //Stylo do cabeçalho da lista
    TextStyle styleHeader = TextStyle(
        fontSize: 22.0, fontWeight: FontWeight.normal, color: Colors.black);

    return FutureBuilder(
      future: _connectivity.checkConnectivity(),
      builder: (context, AsyncSnapshot<ConnectivityResult> result) {
        if (result.connectionState == ConnectionState.none ||
            result.connectionState == ConnectionState.waiting) {
          Future.delayed(Duration(seconds: 3));
          return ModalLoader();
        } else {
          if (result.data.index == 2) {
            return Container(child: WarningConnectivity(reloadScreen));
          } else {
            return FutureBuilder(
              future: localizations.getLocationsAcademyNearBy(),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.connectionState.index ==
                        ConnectionState.none.index ||
                    snapshot.connectionState.index ==
                        ConnectionState.waiting.index) {
                  return ModalLoader();
                } else {
                  List<Map> orderedList = snapshot.data;

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
                    for (var i = 1; i < snapshot.data.length; i++) {
                      listAcademys.add(AcademyTile(
                        drawerController: widget._pageController,
                        userData: UserModel.of(context).userData,
                        dataMap: snapshot.data,
                        dataAcademy: snapshot.data.elementAt(i),
                      ));
                    }

                    //Se listAcademys for diferente de vazio então cria uma lista das academysTiles
                    if (listAcademys.isNotEmpty) {
                      dividedTiles = ListTile.divideTiles(
                              tiles: listAcademys, color: Colors.transparent)
                          .toList();
                    }

                    return Scaffold(
                        body: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            GoogleMaps(snapshot.data, widget._pageController,
                                UserModel.of(context).userData),
                            Positioned(
                              top: 30,
                              left: 15,
                              child: IconButton(
                                icon: Icon(Icons.menu, size: 36,),
                                onPressed: () {
                                  Scaffold.of(context).openDrawer();
                                },
                              ),
                            )
                          ],
                        ));

/*
                    return CustomScrollView(
                      physics: new NeverScrollableScrollPhysics(),
                      slivers: <Widget>[
                        CustomSliverAppbar(),
                        SliverFillRemaining(
                            child: Scaffold(
                                key: _scaffoldKey,
                                body: Padding(
                                  padding: EdgeInsets.only(
                                      top: 10, left: 10, right: 10, bottom: 5),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "Academias próximas",
                                          textAlign: TextAlign.start,
                                          style:
                                              Theme.of(context).textTheme.title,
                                        ),
                                        SizedBox(height: 15.0),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                "Academia",
                                                style: styleHeader,
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Distância",
                                                style: styleHeader,
                                                textAlign: TextAlign.right,
                                              ),
                                            )
                                          ],
                                        ),
                                        Container(
                                            height: 400,
                                            child: dividedTiles != null
                                                ? ListView(
                                                    padding:
                                                        EdgeInsets.all(0.0),
                                                    children: dividedTiles)
                                                : Text("Sem academias"))
                                      ]),
                                )))
                      ],
                    );*/
                  } else {
                    return Container(
                      child: Text("Nenhuma academia encontrada."),
                    );
                  }
                }
              },
            );
          }
        }
      },
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
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
}
