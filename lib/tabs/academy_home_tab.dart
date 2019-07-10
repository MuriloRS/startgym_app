import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/utils/alerts.dart';
import 'package:startgym/utils/email.dart';
import 'package:startgym/utils/listenConnectivity.dart';
import 'package:startgym/widgets/loader.dart';
import 'package:startgym/widgets/sliver_appbar.dart';

class AcademyHomeTab extends StatefulWidget {
  final PageController pageController;

  AcademyHomeTab(this.pageController);

  _AcademyHomeTabState createState() => _AcademyHomeTabState();
}

class _AcademyHomeTabState extends State<AcademyHomeTab> {
  Map<String, dynamic> academyData;
  int numberCheckIns = 0;
  bool isFirstLoad = true;
  Map<String, dynamic> userCheckIn;
  DateFormat dateFormater = new DateFormat("dd/MM/yyyy");
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  bool isFirebaseUserNull = false;
  bool isLoading = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final StreamController stream = new StreamController();
  int qtdCheckIns = 0;

  @override
  void initState() {
    super.initState();

    stream.stream.listen((v) {
      setState(() {
        isLoading = true;
      });
    });

    if (UserModel.of(context).firebaseUser == null) {
      UserModel.of(context).loadCurrentUser();
    }

    if (UserModel.of(context).userData["firstLogin"]) {
      _firstAccessAcademy(UserModel.of(context).userData["academyCheckInCode"]);
    }
  }

  void reloadScreen() {
    if (ListenConnectivity.result.index == ConnectionState.none.index) {
      new Alerts().buildCupertinoDialog(
          Text("Sem conexão"),
          [
            CupertinoDialogAction(
              child: Text("Atualizar"),
              textStyle: TextStyle(color: Theme.of(context).buttonColor),
              onPressed: () {
                reloadScreen();
              },
            )
          ],
          context);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    stream.close(); //Streams must be closed when not needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: NeverScrollableScrollPhysics(),
      slivers: <Widget>[
        CustomSliverAppbar(),
        SliverFillRemaining(
            child: Scaffold(
                key: _scaffoldKey,
                body: RefreshIndicator(
                    onRefresh: reloadList,
                    key: _refreshIndicatorKey,
                    child: Padding(
                        padding: EdgeInsets.only(
                            top: 10.0, right: 10, left: 10, bottom: 0),
                        child: Column(
                          children: <Widget>[
                            UserModel.of(context).firebaseUser != null
                                ? FutureBuilder(
                                    future: Firestore.instance
                                        .collection("userAcademy")
                                        .document(UserModel.of(context)
                                            .firebaseUser
                                            .uid)
                                        .collection("academyDetail")
                                        .getDocuments(),
                                    builder: (context,
                                        AsyncSnapshot<QuerySnapshot>
                                            querySnapshot) {
                                      if (querySnapshot.connectionState ==
                                              ConnectionState.waiting ||
                                          querySnapshot.connectionState ==
                                              ConnectionState.none) {
                                        return Container();
                                      } else if (querySnapshot.data.documents
                                              .elementAt(0)
                                              .documentID
                                              .toString() ==
                                          "firstDetail") {
                                        return Card(
                                          elevation: 3.0,
                                          color: Colors.white,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              const ListTile(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 10.0),
                                                title: Text(
                                                  'Atualize suas informações para receber mais alunos.',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Color.fromRGBO(
                                                          50, 50, 50, 1)),
                                                ),
                                              ),
                                              ButtonTheme.bar(
                                                  child: ButtonBar(
                                                      alignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                    FlatButton(
                                                      textColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                      child: const Text(
                                                        "atualizar informações",
                                                        style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: 16.0,
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        widget.pageController
                                                            .jumpToPage(1);
                                                      },
                                                    ),
                                                  ])),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    },
                                  )
                                : Container(),
                            SizedBox(
                              height: 10,
                            ),
                            StreamBuilder(
                              stream: Firestore.instance
                                  .collection("userAcademy")
                                  .document(
                                      UserModel.of(context).firebaseUser.uid)
                                  .collection("checkins")
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.none ||
                                    snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                  return Loader();
                                }

                                if (snapshot.hasData) {
                                  if (snapshot.data.documentChanges.length >
                                      0) {


                                    this.qtdCheckIns =
                                        snapshot.data.documents.length;

                                    List<ListTile> listTiles = buildCardCheckIn(
                                        snapshot.data.documentChanges);

                                    return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          listTiles.length > 0
                                              ? Text(
                                                  "${listTiles.length} " +
                                                      (listTiles.length == 1
                                                          ? " check-in pendente"
                                                          : " check-ins pendentes"),
                                                  style:
                                                      TextStyle(fontSize: 24))
                                              : Text("Nenhum check-in pendente",
                                                  style:
                                                      TextStyle(fontSize: 24)),
                                          SizedBox(
                                            height: 16,
                                          ),
                                          Container(
                                            height: 370,
                                            child: Scrollbar(
                                                child: ListView.builder(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.all(0),
                                              itemCount: listTiles.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      index) {
                                                return listTiles
                                                    .elementAt(index);
                                              },
                                            )),
                                          )
                                        ]);
                                  } else {
                                    return Text("Nenhum check-in pendente.");
                                  }
                                }

                                return Container();
                              },
                            )
                          ],
                        )))))
      ],
    );
  }

  String convertDateTimeToTime(DateTime horario) {
    String hora = horario.hour.toString();
    String minuto = horario.minute.toString();

    if (hora.length == 1) {
      hora = "0" + hora;
    }

    if (minuto.length == 1) {
      minuto = "0" + minuto;
    }

    return hora + ":" + minuto;
  }

  //Se aceitar o check-in deve adicionar o valor da diaria para a academia
  void doAcceptCheckIn(
      {@required String academyId,
      @required Map academyData,
      @required String checkInId,
      @required double valueReceived}) {
    double newValueAcademy = academyData["academyValueSack"] + valueReceived;

    try {
      Firestore.instance
          .collection("userAcademy")
          .document(academyId)
          .updateData({"academyValueSack": newValueAcademy});

      Firestore.instance
          .collection("userAcademy")
          .document(academyId)
          .collection("checkins")
          .document(checkInId)
          .updateData({"viewed": true});

      setState(() {
        isLoading = false;
      });

      this._scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              "O valor  de R\$ $valueReceived foi depositado na conta.",
            ),
            backgroundColor: Colors.white,
            duration: Duration(seconds: 3),
          ));
    } catch (er) {
      this._scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              er,
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ));
    }
  }

  Future<DocumentSnapshot> searchUserCheckin(String docUser) {
    return Firestore.instance.collection("users").document(docUser).get();
  }

  List<Widget> buildCardCheckIn(List<DocumentChange> documents) {
    List<ListTile> retornoWidgets = new List<ListTile>();

    for (int x = 0; x < documents.length; x++) {
      var data = documents.elementAt(x).document;

      if (data.data["viewed"] == false) {
        String horario = convertDateTimeToTime(data.data["time"]);

        String valorRecebido = data.data["price"].toString();
        valorRecebido = valorRecebido.replaceFirst(".", ",");

        retornoWidgets.add(ListTile(
            dense: true,
            contentPadding: EdgeInsets.all(5),
            selected: true,
            leading: Text(
              "$horario",
              style: TextStyle(fontSize: 17, color: Colors.grey[700]),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(data.data["name"].toString(),
                    style: TextStyle(fontSize: 17, color: Colors.grey[700])),
                FlatButton(
                  padding: EdgeInsets.all(0),
                  child: Text("Ok"),
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                    });
                    doAcceptCheckIn(
                        academyData: UserModel.of(context).userData,
                        academyId: UserModel.of(context).firebaseUser.uid,
                        checkInId: data.documentID,
                        valueReceived:
                            double.parse(data.data["price"].toString()));
                    setState(() {
                      isLoading = false;
                    });
                  },
                )
              ],
            )));
      }
    }

    return retornoWidgets;
  }

  Future<Null> reloadList() {
    setState(() {
      isLoading = false;
    });

    return Future.delayed(Duration(milliseconds: 1));
  }

  Future<void> _firstAccessAcademy(String checkInCode) async {
    await new Email().saveAndSendEmailToAcademy(checkInCode, context);

    new Alerts().buildCupertinoDialog(
      Text("Primeiro Acesso"),
      [
        CupertinoDialogAction(
          child: Text(
            "Entendi",
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          onPressed: () async {
            Map academyData = UserModel.of(context).userData;

            academyData["firstLogin"] = false;

            await Firestore.instance
                .collection("userAcademy")
                .document(UserModel.of(context).firebaseUser.uid)
                .updateData(academyData);

            Navigator.of(context).pop();
          },
        )
      ],
      context,
      content: Text("Você terminou o seu cadastro, te enviamos um qr-code e " +
          "instruções mais detalhadas para você começar a receber alunos, seja bem-vindo! "),
    );
  }
}
