import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/utils/alerts.dart';
import 'package:startgym/utils/email.dart';
import 'package:startgym/widgets/loader.dart';
import 'package:startgym/widgets/sliver_appbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class SendInviteTab extends StatefulWidget {
  @override
  _SendInviteTabState createState() => _SendInviteTabState();
}

class _SendInviteTabState extends State<SendInviteTab> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    MaskedTextController maskara =
        new MaskedTextController(mask: "00 00000-0000");

    TextEditingController controllerEmail = new TextEditingController();

    return CustomScrollView(slivers: <Widget>[
      CustomSliverAppbar(),
      SliverToBoxAdapter(
          child: isLoading
              ? Loader()
              : Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Como funciona?",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                          "Se você convidar um amigo e ele pagar uma mensalidade, " +
                              "você ganha 5 dias a mais no seu plano, para frequentar qualquer academia cadastrada",
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.normal)),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                          "Se você cadastrar alguma academia, você ganha 30 dias de graça para ir a qualquer academia cadastrada.",
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.normal)),
                      SizedBox(
                        height: 25,
                      ),
                      Divider(
                        height: 1,
                        color: Colors.grey[350],
                      ),
                      SizedBox(height: 16,),                      
                      Center(
                          child: Container(
                        padding: EdgeInsets.all(30),
                        child: Column(
                          children: <Widget>[
                            FlatButton(
                              onPressed: () async {
                                await showAskNumber(maskara, controllerEmail);
                              },
                              padding: EdgeInsets.all(20),
                              color: Color.fromRGBO(37, 211, 102, 1),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.whatsapp,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    "WHATSAPP",
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              "ou",
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            FlatButton(
                              onPressed: () {
                                showAskEmail(controllerEmail);
                              },
                              padding: EdgeInsets.all(20),
                              color: Colors.grey[350],
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.email,
                                    color: Colors.grey[800],
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    "EMAIL",
                                    style: TextStyle(color: Colors.grey[800]),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      )),
                    ],
                  ))),
    ]);
  }

  Future<void> showAskNumber(maskara, controllerEmail) async {
    Alerts alert = new Alerts();

    alert.buildMaterialDialog(
        Text(
          "Digite o número de seu amigo",
          textAlign: TextAlign.center,
        ),
        [
          FlatButton(
            textColor: Colors.white,
            color: Theme.of(context).accentColor,
            child: Text(
              "Feito",
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              setState(() {
                isLoading = true;
              });

              sendInviteByWhats(maskara, controllerEmail);

              setState(() {
                isLoading = false;
              });

              Navigator.pop(context);
            },
          ),
          FlatButton(
            textColor: Colors.grey[800],
            child: Text(
              "Cancelar",
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
        context,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: controllerEmail,
              decoration: InputDecoration(hintText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(
              height: 16,
            ),
            TextField(
              controller: maskara,
              decoration: InputDecoration(hintText: "Telefone"),
              keyboardType: TextInputType.number,
            )
          ],
        ));
  }

  Future<void> sendInviteByWhats(MaskedTextController maskara,
      TextEditingController controllerEmail) async {
    if (maskara.text.length > 0 && controllerEmail.text.length > 0) {
      String friendNumber = maskara.text.trim();

      var whatsappUrl = "whatsapp://send?phone=55$friendNumber&text=Olá seu amigo " +
          UserModel.of(context).userData['name'] +
          " está te convidando para se cadastrar no startgym que é " +
          " um aplicativo que te permite frequentar qualquer academia pagando apenas uma mensalidade." +
          " Baixe o aplicativo e se cadastre usando seu email = ${controllerEmail.text} . https://play.google.com/store/apps/details?id=com.murilo.startgym&launch=true";

      await canLaunch(whatsappUrl)
          ? launch(whatsappUrl)
          : print("Whatsapp não instalado");

      await saveNumberFriend(
          friendNumber: friendNumber, controllerEmail: controllerEmail.text);
    }
  }

  Future<void> saveNumberFriend(
      {String friendNumber, String controllerEmail}) async {
    await Firestore.instance.collection("friendsInvited").add({
      'telephone': friendNumber,
      'from': UserModel.of(context).firebaseUser.uid,
      'to': controllerEmail,
      'date': DateTime.now()
    });
  }

  void showAskEmail(TextEditingController controllerEmail) {
    Alerts alert = new Alerts();

    alert.buildMaterialDialog(
        Text(
          "Digite o email do seu amigo",
          textAlign: TextAlign.center,
        ),
        [
          FlatButton(
            textColor: Colors.white,
            color: Theme.of(context).accentColor,
            child: Text(
              "Feito",
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              setState(() {
                isLoading = true;
              });

              Email email = new Email();

              email.sendEmail(
                  buildHtmlFriendInvit(),
                  UserModel.of(context).userData["email"],
                  controllerEmail.text,
                  "Convite - ${UserModel.of(context).userData["email"]}");

              saveNumberFriend(
                  friendNumber: "", controllerEmail: controllerEmail.text);

              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(
                  "O email com o convite foi enviado. Agora é só esperar seu amigo pagar uma mensalidade e você ganha 5 diárias.",
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 10),
              ));

              setState(() {
                isLoading = false;
              });

              Navigator.pop(context);
            },
          ),
          FlatButton(
            textColor: Colors.grey[800],
            child: Text(
              "Cancelar",
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
        context,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: controllerEmail,
              decoration: InputDecoration(hintText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ));
  }

  String buildHtmlFriendInvit() {
    String email = "<h3>Parabéns!</h3>";

    email += "<div>";
    email +=
        "Você recebeu um convite do seu amigo ${UserModel.of(context).userData['name']}, ";
    email +=
        "se você baixar o aplicativo você poderá frequentar qualquer academia pagando uma única mensalidade. ";
    email +=
        "<a href='https://play.google.com/store/apps/details?id=com.murilo.startgym&launch=true'>Baixe aqui</a>";
    email += "</div>";

    return email;
  }
}
