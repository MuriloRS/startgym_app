import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/utils/alerts.dart';
import 'package:startgym/widgets/loader.dart';
import 'package:startgym/widgets/sliver_appbar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class AcademyStatisticTab extends StatefulWidget {
  _AcademySettingsTabState createState() => _AcademySettingsTabState();
}

class _AcademySettingsTabState extends State<AcademyStatisticTab> {
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      CustomSliverAppbar(),
      SliverToBoxAdapter(
          child: !isLoading
              ? FutureBuilder(
                  future: Future.wait([
                    Firestore.instance
                        .collection("userAcademy")
                        .document(UserModel.of(context).firebaseUser.uid)
                        .get(),
                    _buildListCheckin(UserModel.of(context).firebaseUser.uid),
                  ]),
                  builder: (context, AsyncSnapshot<List<Object>> snapshot) {
                    if (snapshot.connectionState.index ==
                            ConnectionState.none.index ||
                        snapshot.connectionState.index ==
                            ConnectionState.waiting.index) {
                      return Container(
                          height: MediaQuery.of(context).size.height - 100,
                          child: Center(child: Loader()));
                    } else {
                      DocumentSnapshot sackValue = snapshot.data.elementAt(0);

                      return Column(
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.height - 50,
                            child: DefaultTabController(
                              length: 2,
                              child: Scaffold(
                                  appBar: AppBar(
                                    centerTitle: true,
                                    backgroundColor: Colors.grey[100],
                                    titleSpacing: 0,
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          "Valor para sacar: R\$ ${sackValue.data['academyValueSack'].toString().replaceAll('.', ',')}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.grey[800]),
                                          textAlign: TextAlign.center,
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.info,
                                            color:
                                                Theme.of(context).accentColor,
                                          ),
                                          iconSize: 20,
                                          color: Theme.of(context).accentColor,
                                          onPressed: () {
                                            _showMessageInformation();
                                          },
                                          tooltip:
                                              "Esse é o valor que você tem em 'caixa' para você retirar, o valor mínimo para saque é R\$ 300,00.",
                                        )
                                      ],
                                    ),
                                    bottom: TabBar(
                                      tabs: [
                                        Text("Por Checkin",
                                            style: TextStyle(
                                                color: Colors.grey[800],
                                                fontSize: 17)),
                                        Text("Por Usuário",
                                            style: TextStyle(
                                                color: Colors.grey[800],
                                                fontSize: 17))
                                      ],
                                    ),
                                  ),
                                  body: TabBarView(
                                    children: [
                                      Container(
                                          padding: EdgeInsets.all(10),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              50,
                                          child: SingleChildScrollView(
                                            child: Table(
                                              columnWidths: {
                                                0: FlexColumnWidth(0.5),
                                                1: FlexColumnWidth(0.25),
                                                2: FlexColumnWidth(0.25)
                                              },
                                              children: (snapshot.data
                                                  .elementAt(1) as Map)[0],
                                            ),
                                          )),
                                      Container(
                                          padding: EdgeInsets.all(10),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              50,
                                          child: SingleChildScrollView(
                                            child: Table(
                                              columnWidths: {
                                                0: FlexColumnWidth(0.5),
                                                1: FlexColumnWidth(0.25),
                                                2: FlexColumnWidth(0.25)
                                              },
                                              children: (snapshot.data
                                                  .elementAt(1) as Map)[1],
                                            ),
                                          )),
                                    ],
                                  )),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                )
              : Container(
                  height: MediaQuery.of(context).size.height - 100,
                  child: Center(child: Loader())))
    ]);
  }

  Future<Map<int, List<TableRow>>> _buildListCheckin(String documentId) async {
    Map<int, List<TableRow>> map = new Map();

    List<TableRow> returnList = new List<TableRow>();

    returnList.add(TableRow(children: [
      Text("NOME", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Text("DIA",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Text("HORA",
          textAlign: TextAlign.end,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
    ]));

    var formatter = new DateFormat('dd/MM/yyyy HH:mm');

    QuerySnapshot snapshot = await Firestore.instance
        .collection("userAcademy")
        .document(documentId)
        .collection('checkins')
        .orderBy('time', descending: true)
        .getDocuments();

    map[1] = _buildTableRowByUser(snapshot.documents);

    snapshot.documents.forEach((doc) {
      returnList.add(TableRow(
        children: [
          Text(
            doc.data['name'],
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            formatter
                .format(doc.data['time'] as DateTime)
                .split(" ")
                .elementAt(0),
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          Text(
            formatter
                .format(doc.data['time'] as DateTime)
                .split(" ")
                .elementAt(1),
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.end,
          )
        ],
      ));
    });

    map[0] = returnList;

    return map;
  }

  List<TableRow> _buildTableRowByUser(List<DocumentSnapshot> snapshot) {
    Map<String, int> checkinUser = new Map();
    List<TableRow> listTableRow = new List();

    snapshot.forEach((doc) {
      if (checkinUser.containsKey(doc.data['clientId'])) {
        int numberCheckins = checkinUser[doc.data['clientId']];

        numberCheckins++;

        checkinUser[doc.data['clientId']] = numberCheckins;
      } else {
        checkinUser[doc.data['clientId']] = 1;
      }
    });

    listTableRow.add(TableRow(children: [
      Text("NOME", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Text("QTD CHECKINS",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ]));

    checkinUser.values.toList().sort((i, x) {
      if (x > i) {
        return 0;
      } else {
        return 1;
      }
    });

    checkinUser.forEach((key, value) async {
      DocumentSnapshot snapshot =
          await Firestore.instance.collection("users").document(key).get();

      listTableRow.add(TableRow(children: [
        Text(
          snapshot.data['name'].toString().trimLeft(),
          style: TextStyle(color: Colors.grey[600]),
        ),
        Text(
          value.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ]));
    });

    return listTableRow;
  }

  void _showMessageInformation() {
    Alerts alerts = new Alerts();

    alerts.buildCupertinoDialog(
        Text("Informação"),
        [
          CupertinoDialogAction(
            child: Text("Entendi!"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
        context,
        content: Text(
            "Esse é o valor que você tem em 'caixa' para você retirar, o valor mínimo para saque é R\$ 300,00."));
  }

  Future<List<LineChartBarData>> searchCheckinsNumbers() async {
    List<LineChartBarData> chartData = new List();

    QuerySnapshot snapshot = await Firestore.instance
        .collection("userAcademy")
        .document(UserModel.of(context).firebaseUser.uid)
        .collection("checkins")
        .where("time",
            isGreaterThanOrEqualTo:
                Timestamp.now().toDate().add(Duration(days: -30)))
        .orderBy("time", descending: true)
        .getDocuments();

    int checkins7days = 0;
    int checkins15days = 0;
    int checkins23days = 0;
    int checkins30days = 0;

    for (int x = 1; x < snapshot.documents.length - 1; x++) {
      DateTime dateCheckin = snapshot.documents.elementAt(x).data["time"];

      if (dateCheckin.day < 7) {
        checkins7days++;
      }

      if (dateCheckin.day > 7 && dateCheckin.day < 15) {
        checkins15days++;
      }

      if (dateCheckin.day > 15 && dateCheckin.day < 23) {
        checkins23days++;
      }

      if (dateCheckin.day > 23 && dateCheckin.day < 30) {
        checkins30days++;
      }
    }

    chartData.add(LineChartBarData(
        barWidth: 1,
        colors: [Colors.greenAccent],
        curveSmoothness: 1,
        isCurved: true,
        show: true,
        spots: [FlSpot(7, checkins7days.toDouble())]));

    chartData.add(LineChartBarData(
        barWidth: 1,
        colors: [Colors.greenAccent],
        curveSmoothness: 1,
        isCurved: true,
        show: true,
        spots: [FlSpot(15, checkins15days.toDouble())]));

    chartData.add(LineChartBarData(
        barWidth: 1,
        colors: [Colors.greenAccent],
        curveSmoothness: 1,
        isCurved: true,
        show: true,
        spots: [FlSpot(23, checkins23days.toDouble())]));

    chartData.add(LineChartBarData(
        barWidth: 1,
        colors: [Colors.greenAccent],
        curveSmoothness: 1,
        isCurved: true,
        show: true,
        spots: [FlSpot(30, checkins30days.toDouble())]));

    return chartData;
  }
}
