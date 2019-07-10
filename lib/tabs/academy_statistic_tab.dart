import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/utils/alerts.dart';
import 'package:startgym/widgets/loader.dart';
import 'package:startgym/widgets/sliver_appbar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

class AcademyStatisticTab extends StatefulWidget {
  _AcademySettingsTabState createState() => _AcademySettingsTabState();
}

class _AcademySettingsTabState extends State<AcademyStatisticTab> {
  var isLoading = false;
  String _value = "0";

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      CustomSliverAppbar(),
      SliverToBoxAdapter(
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: !isLoading
                  ? FutureBuilder(
                      future: Firestore.instance
                          .collection("userAcademy")
                          .document(UserModel.of(context).firebaseUser.uid)
                          .get(),
                      builder:
                          (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState.index ==
                                ConnectionState.none.index ||
                            snapshot.connectionState.index ==
                                ConnectionState.waiting.index) {
                          return Loader();
                        } else {
                          var sackValue = snapshot.data["academyValueSack"];

                           FutureBuilder(
                              future: searchCheckinsNumbers(),
                              builder: (context,
                                  AsyncSnapshot<List<LineChartBarData>>
                                      chartData) {
                                if (chartData.connectionState.index ==
                                        ConnectionState.none.index ||
                                    chartData.connectionState.index ==
                                        ConnectionState.waiting.index) {
                                  return Loader();
                                } else {
                                  if(chartData.data.length > 0){
                                    
                                  }
                                  return FlChart(
                                    chart: LineChart(
                                      LineChartData(
                                        //lineBarsData: searchCheckinsNumbers(),
                                      ),
                                    ),
                                  );
                                }
                              });

                          return Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Valor para sacar: R\$ $sackValue",
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.info,
                                      color: Theme.of(context).accentColor,
                                    ),
                                    iconSize: 20,
                                    color: Theme.of(context).accentColor,
                                    onPressed: () {
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
                                    },
                                    tooltip:
                                        "Esse é o valor que você tem em 'caixa' para você retirar, o valor mínimo para saque é R\$ 300,00.",
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Divider(
                                height: 1,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                            ],
                          );
                        }
                      },
                    )
                  : Loader()))
    ]);
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
