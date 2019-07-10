import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:startgym/widgets/loader.dart';
import 'package:startgym/widgets/logo.dart';

class AcademyDetailScreen extends StatefulWidget {
  final Map dataAcademy;

  AcademyDetailScreen(this.dataAcademy);

  _AcademyDetailScreenState createState() => _AcademyDetailScreenState();
}

class _AcademyDetailScreenState extends State<AcademyDetailScreen> {
  Map dataAcademy;

  @override
  Widget build(BuildContext context) {
    this.dataAcademy = widget.dataAcademy;

    return Container(
        child: Scaffold(
            appBar: AppBar(
              actions: <Widget>[Logo()],
            ),
            body: FutureBuilder(
              future: Firestore.instance
                  .collection("userAcademy")
                  .document(this.dataAcademy["documentId"])
                  .collection("academyDetail")
                  .document("firstDetail")
                  .get(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState.index ==
                        ConnectionState.done.index ||
                    snapshot.connectionState.index ==
                        ConnectionState.active.index) {
                  List<Widget> imagensAcademia = new List();
                  String address = snapshot.data.data["address"];
                  String email = snapshot.data.data["email"];
                  String phone = snapshot.data.data["phone"];
                  String observation = snapshot.data.data["observation"];
                  String horaryWeek = snapshot.data.data["horaryWeek"];
                  String horarySaturday = snapshot.data.data["horarySaturday"];
                  String horarySunday = snapshot.data.data["horarySunday"];
                  String horaryHoliday = snapshot.data.data["horaryHoliday"];
                  Map optionals = snapshot.data.data["optionals"];
                  String academyName = dataAcademy["fantasia"] == ""
                      ? dataAcademy["name"]
                      : dataAcademy["fantasia"];

                  TextStyle styleDescription =
                      TextStyle(color: Colors.black54, fontSize: 18);

                  for (var i = 1; i <= 10; i++) {
                    if (snapshot.data.data["Images" + i.toString()] != null) {
                      imagensAcademia.add(Image.network(
                          snapshot.data.data["Images" + i.toString()]));
                    }
                  }

                  return Container(
                      padding: EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Text(
                              "$academyName",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(height: 16),
                            new CarouselSlider(
                              items: imagensAcademia,
                              viewportFraction: 0.9,
                              initialPage: 0,
                              aspectRatio: 0.9,
                              height: 230,
                              reverse: false,
                              autoPlay: true,
                              autoPlayCurve: Curves.fastOutSlowIn,
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text("Dados de contato",
                                textAlign: TextAlign.start,
                                style: Theme.of(context).textTheme.subtitle),
                            SizedBox(
                              height: 16,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  address != null
                                      ? Text(
                                          "Endereço: " + address,
                                          style: styleDescription,
                                        )
                                      : Container(),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  email != ""
                                      ? Text(
                                          "Email: $email",
                                          style: styleDescription,
                                        )
                                      : Container(),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  phone != ""
                                      ? Text(
                                          "Telefone: $phone",
                                          style: styleDescription,
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            SizedBox(height: 25),
                            Text("Horários",
                                style: Theme.of(context).textTheme.subtitle),
                            SizedBox(height: 16),
                            Container(
                                padding: EdgeInsets.symmetric(horizontal: 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    horaryWeek != ""
                                        ? Text("Dias de semana: $horaryWeek",
                                            textAlign: TextAlign.right,
                                            style: styleDescription)
                                        : Container(),
                                    horarySaturday != ""
                                        ? Text("Sábados: $horarySaturday",
                                            textAlign: TextAlign.right,
                                            style: styleDescription)
                                        : Container(),
                                    horarySunday != ""
                                        ? Text("Domingos: $horarySunday",
                                            textAlign: TextAlign.right,
                                            style: styleDescription)
                                        : Container(),
                                    horaryHoliday != ""
                                        ? Text("Feriados: $horaryHoliday",
                                            textAlign: TextAlign.right,
                                            style: styleDescription)
                                        : Container(),
                                  ],
                                )),
                            Text("Obervação: $observation"),
                            SizedBox(
                              height: 25,
                            ),
                            Text(
                              "Opcionais",
                              style: Theme.of(context).textTheme.subtitle,
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Container(
                                height: 260,
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: optionals.length,
                                  itemBuilder: (context, i) {
                                    String description =
                                        optionals.keys.elementAt(i);
                                    bool isChecked = optionals[description];

                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                            width: 170,
                                            child: Text(
                                              description,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black54),
                                            )),
                                        isChecked
                                            ? Icon(
                                                Icons.check,
                                                color: Colors.green,
                                                size: 18,
                                              )
                                            : Icon(
                                                Icons.close,
                                                color: Colors.red,
                                                size: 18,
                                              )
                                      ],
                                    );
                                  },
                                ))
                          ],
                        ),
                      ));
                } else {
                  return Center(child: Loader());
                }
              },
            )));
  }

  Row buildRow(Text titulo, Text descricao) {
    return Row(
      children: <Widget>[titulo, descricao],
    );
  }
}
