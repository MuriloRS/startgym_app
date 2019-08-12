import 'dart:async';
import 'dart:convert';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:startgym/models/checkin_model.dart';
import 'package:startgym/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:startgym/screens/academy_detail_screen.dart';
import 'package:startgym/utils/alerts.dart';
import 'package:startgym/utils/slideRightRoute.dart';
import 'package:startgym/widgets/loader.dart';
import 'package:http/http.dart' as http;

class GoogleMaps extends StatefulWidget {
  final List result;
  final Map<dynamic, dynamic> userData;
  final PageController _pageController;

  GoogleMaps(this.result, this._pageController, this.userData);

  _GoogleMapsState createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {
  @override
  void initState() {
    super.initState();
  }

  bool isLoadingCarousel = false;
  bool isFirstImage = true;
  List<Widget> listaImagens = [Image.asset("images/empty-photo.jpg")];
  Map<String, dynamic> dataAcademyDetail;
  double distance;
  CheckinModel modelCheckin;

  @override
  Widget build(BuildContext context) {
    String lastCheckin = widget.userData["lastCheckin"].toString();
    final String docUser = UserModel.of(context).firebaseUser.uid;

    bool planActive = widget.userData["planActive"];

    List<Marker> listMarkers = List();

    List listCoordenates = widget.result;

    Completer<GoogleMapController> _controller = Completer();

    final CameraPosition _initialPosition = CameraPosition(
        bearing: 0,
        zoom: 14,
        target: new LatLng(listCoordenates.elementAt(0)["latitude"],
            listCoordenates.elementAt(0)["longitude"]));

    //Percorre o resultado que traz as coordenadas das academias cadastradas no serviço
    //E adiciona marcas para cada uma delas no mapa
    if (listCoordenates != null && listCoordenates.length > 1) {
      for (int i = 1; i < (listCoordenates.length); i++) {
        listMarkers.add(
          new Marker(
            position: new LatLng(listCoordenates.elementAt(i)["latitude"],
                listCoordenates.elementAt(i)["longitude"]),
            markerId: MarkerId(i.toString()),
            infoWindow: InfoWindow(
              title: i != 0
                  ? listCoordenates.elementAt(i)['name'].toString()
                  : "Você",
              onTap: () {
                if (i > 0) {
                  showBottomSheetAcademy(
                      planActive,
                      lastCheckin,
                      listCoordenates.elementAt(i),
                      listCoordenates.elementAt(i)['documentID'],
                      docUser);
                }
              },
            ),
            icon: BitmapDescriptor.defaultMarker,
          ),
        );
      }
    } else {
      listMarkers.clear();
    }

    return ScopedModel<CheckinModel>(
        model: CheckinModel(),
        child: ScopedModelDescendant<CheckinModel>(
            builder: (context, child, model) {
          modelCheckin = model;
          return SafeArea(
            child: GoogleMap(
              myLocationEnabled: true,
              compassEnabled: false,
              rotateGesturesEnabled: false,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              initialCameraPosition: _initialPosition,
              markers: listMarkers.toSet(),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          );
        }));
  }

  Future<bool> _checkCheckinValid(userId) async {
    DocumentSnapshot snapshot =
        await Firestore.instance.collection("users").document(userId).get();

    //SE O LAST CHECKIN FOR IGUAL A VAZIO OU A DATA LASTCHECKIN
    //FOR DIFERENTE DO DIA ATUAL ENTÃO O CHECKIN É VALIDO
    bool checkInValid = (snapshot.data['lastCheckin'] == "" ||
            DateFormat("yyyy-MM-dd").format(DateTime.now()).toString() !=
                snapshot.data['lastCheckin'].toString().split(" ").elementAt(0))
        ? true
        : false;

    return checkInValid;
  }

  void showBottomSheetAcademy(
      planActive, lastCheckin, dataAcademy, academyDocId, userId) {
    String nomeAcademia = dataAcademy["fantasia"] == ""
        ? dataAcademy["name"].toString()
        : dataAcademy["fantasia"].toString();

    this.distance = dataAcademy["distance"];
    distance = double.parse(distance.toStringAsFixed(2));

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        backgroundColor: Colors.grey[200],
        builder: (builder) {
          return FutureBuilder(
              future: Future.wait(
                [
                  searchAcademyImagesDetails(dataAcademy['documentId']),
                  _checkCheckinValid(userId)
                ],
              ),
              builder: (BuildContext context, snapshot) {
                if (snapshot.connectionState.index ==
                        ConnectionState.none.index ||
                    snapshot.connectionState.index ==
                        ConnectionState.waiting.index) {
                  return Container(
                    height: 400,
                    child: Center(
                      child: Loader(),
                    ),
                  );
                } else {
                  List snapshotToList = snapshot.data as List;

                  return Container(
                      height: 400,
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Column(
                        children: <Widget>[
                          Container(
                              width: double.infinity,
                              child: CupertinoButton(
                                color: Theme.of(context).accentColor,
                                child: Text("FAZER CHECKIN",
                                    style: TextStyle(
                                        fontSize: 20.0, color: Colors.white)),
                                onPressed: () {
                                  if (snapshotToList.elementAt(1) &&
                                      planActive) {
                                    _scanQR(dataAcademy);
                                  } else {
                                    showStatusError(snapshotToList.elementAt(1),
                                        planActive);
                                  }
                                },
                              )),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            nomeAcademia,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                decoration: TextDecoration.none),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          listaImagens.length == 0
                              ? Image.asset(
                                  "images/empty-photo.jpg",
                                  height: 230,
                                )
                              : new CarouselSlider(
                                  items: listaImagens,
                                  viewportFraction: 0.9,
                                  initialPage: 0,
                                  aspectRatio: 0.7,
                                  height: 150,
                                  reverse: false,
                                  autoPlay: false,
                                  autoPlayCurve: Curves.fastOutSlowIn,
                                ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            "Endereço: Vereador Assmann.",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "Distância: $distance km",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            height: 16,
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 8.0),
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(30.0)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  SlideRightRoute(
                                      widget: AcademyDetailScreen(dataAcademy)),
                                );
                              },
                            ),
                          ),
                        ],
                      ));
                }
              });
        });
  }

  void showStatusError(checkInValid, planActive) {
    String message = "";
    Alerts alert = new Alerts();

    if (!checkInValid) {
      message =
          "Você já fez um checkin hoje, seu plano te permite fazer um checkin por dia.";

      alert.buildCupertinoDialog(
          Container(),
          [
            CupertinoDialogAction(
              child: Text("Ver planos"),
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed("/buyScreen");
              },
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              isDestructiveAction: true,
              child: Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
          context,
          content: Text(message, style: TextStyle(fontSize: 18)));
    } else if (!planActive) {
      message = "Você não tem um plano ativo";

      alert.buildCupertinoDialog(
          Container(),
          [
            CupertinoDialogAction(
              child: Text("Ver planos"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed("/buyScreen");
              },
            )
          ],
          context,
          content: Text(message, style: TextStyle(fontSize: 18)));
    }
  }

  Future _scanQR(dataAcademy) async {
    String result;
    try {
      String qrResult = await BarcodeScanner.scan();

      result = qrResult;

      Navigator.pop(context);
    } on FormatException {
      result = "Você pressionou o botão de voltar antes de ler o qr-code.";
    } catch (ex) {
      result = "Erro desconhecido $ex";
    }

    if (result == dataAcademy["academyCheckInCode"]) {
      await _updateDiarysUserAndAcademy(dataAcademy);

      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          "Check-in realizado com sucesso!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 5),
      ));

      _handleSendSilentNotification(dataAcademy);
    }
  }

  void _handleSendSilentNotification(dataAcademy) async {
    final msg = jsonEncode({'sendTo': dataAcademy['idOneSignal']});

    Map<String, String> headers = {'Content-Type': 'application/json'};

    await http.post(
        "https://us-central1-startgym-220814.cloudfunctions.net/notification",
        body: msg);
  }

  Future<void> _updateDiarysUserAndAcademy(dataAcademy) async {
    Map userData = UserModel.of(context).userData;

    userData["lastCheckin"] = DateTime.now().toString();
    UserModel.of(context).saveUserData(userData);

    DocumentSnapshot snapshot = await Firestore.instance
        .collection("userAcademy")
        .document(dataAcademy["documentId"])
        .get();

    if (snapshot.exists) {
      double newAcademyValueSack =
          snapshot.data["academyValueSack"].toInt() + 2.50;

      snapshot.data["academyValueSack"] = newAcademyValueSack;

      //Atualiza o valor de saque da academia
      await Firestore.instance
          .collection("userAcademy")
          .document(dataAcademy["documentId"])
          .updateData(snapshot.data);

      String clientId =
          ScopedModel.of<UserModel>(context, rebuildOnChange: true)
              .firebaseUser
              .uid;

      await modelCheckin.newCheckin(
          academyId: dataAcademy["documentId"],
          client: clientId,
          clientName: widget.userData["name"]);

      await modelCheckin.updateCheckinsAcademy(
          academyId: dataAcademy["documentId"], clientId: clientId);
    }
  }

  Future<int> searchAcademyImagesDetails(academyDocId) async {
    int qtdImages = 0;

    if (academyDocId != null) {
      DocumentSnapshot snapshot = await Firestore.instance
          .collection("userAcademy")
          .document(academyDocId)
          .collection("academyDetail")
          .document("firstDetail")
          .get();

      if (!snapshot.data["firstImage"]) {
        this.isFirstImage = false;
        qtdImages = snapshot.data.values.length;
        this.listaImagens.clear();

        for (var i = 1; i <= qtdImages; i++) {
          if (snapshot.data["Images" + i.toString()] != null) {
            this.listaImagens.add(GestureDetector(
                  child: Image.network(snapshot.data["Images" + i.toString()]),
                  onTap: () {
                    Alerts alerts = new Alerts();

                    alerts.buildCupertinoDialog(
                        Container(),
                        [
                          CupertinoDialogAction(
                            child: Text("Fechar"),
                            isDefaultAction: false,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          )
                        ],
                        context,
                        content: Image.network(
                            snapshot.data["Images" + i.toString()]));
                  },
                ));
          }
        }
      }

      this.dataAcademyDetail = snapshot.data;
    }

    return this.listaImagens.length;
  }
}
