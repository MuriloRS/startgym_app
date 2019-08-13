import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/widgets/loader.dart';
import 'package:startgym/widgets/sliver_appbar.dart';

class AcademyAccountTab extends StatefulWidget {
  @override
  _AcademyAccountTabState createState() => _AcademyAccountTabState();
}

class _AcademyAccountTabState extends State<AcademyAccountTab> {
  var _controllerEmail = TextEditingController();
  var _controllerPhone = TextEditingController();
  var _controllerAddress = TextEditingController();
  var _controllerNumberAddress = TextEditingController();

  bool isLoading = false;
  String autenticationFailed = "";

  Map<String, dynamic> academyData;

  @override
  Widget build(BuildContext context) {
    academyData = UserModel.of(context).userData;
    _controllerEmail.text = academyData['email'];
    _controllerPhone.text = academyData['telefone'];
    _controllerAddress.text = academyData['logradouro'];
    _controllerNumberAddress.text = academyData['numero'];

    return CustomScrollView(slivers: <Widget>[
      CustomSliverAppbar(),
      SliverToBoxAdapter(
        child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Seus dados",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, color: Colors.grey[800])),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "Email",
                  style: TextStyle(fontSize: 17),
                ),
                TextField(
                  style: TextStyle(color: Colors.grey[600]),
                  controller: _controllerEmail,
                  keyboardType: TextInputType.text,
                  enabled: false,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0)),
                      fillColor: Colors.grey[200],
                      filled: true,
                      focusColor: Colors.grey[200],
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      isDense: true),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "Celular/Whatsapp",
                  style: TextStyle(fontSize: 17),
                ),
                TextField(
                  style: TextStyle(color: Colors.grey[600]),
                  controller: _controllerPhone,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0)),
                      isDense: true),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "Endereço",
                  style: TextStyle(fontSize: 17),
                ),
                TextField(
                  style: TextStyle(color: Colors.grey[600]),
                  controller: _controllerAddress,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0)),
                      isDense: true),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "Número",
                  style: TextStyle(fontSize: 17),
                ),
                TextField(
                  style: TextStyle(color: Colors.grey[600]),
                  controller: _controllerNumberAddress,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0)),
                      isDense: true),
                ),
                SizedBox(
                  height: 16,
                ),
                !isLoading
                    ? Container(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                        width: double.infinity,
                        child: FlatButton(
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          color: Theme.of(context).accentColor,
                          child: Text("Salvar", style: TextStyle(fontSize: 24)),
                          onPressed: () async {
                            await saveAcademyData(
                                _controllerEmail.text,
                                _controllerPhone.text,
                                _controllerAddress.text,
                                _controllerNumberAddress.text);
                          },
                        ),
                      )
                    : Center(
                        child: Loader(),
                      )
              ],
            )),
      )
    ]);
  }

  Future<void> saveAcademyData(email, phone, address, numberAddress) async {
    setState(() {
      isLoading = true;
    });

    this.academyData['telefone'] = phone;
    this.academyData['logradouro'] = address;
    this.academyData['numero'] = numberAddress;

    await UserModel.of(context).saveUserData(this.academyData);

    await UserModel.of(context).loadCurrentUser();

    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Os dados foram salvos!"),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 5),
    ));

    setState(() {
      isLoading = false;
    });
  }
}
