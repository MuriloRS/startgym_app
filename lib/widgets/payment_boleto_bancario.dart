import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mercado_pago/mercado_pago.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/utils/alerts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'loader.dart';

class PaymentBoletoBancario extends StatefulWidget {
  @override
  _PaymentBoletoBancarioState createState() => _PaymentBoletoBancarioState();
}

class _PaymentBoletoBancarioState extends State<PaymentBoletoBancario> {
  var controllerCpfNumber = new MaskedTextController(mask: "000.000.000-00");
  var controllerName = new TextEditingController();
  var controllerLastname = new TextEditingController();

  var isProcessingPayment = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.ltr,
            children: <Widget>[
              SizedBox(height: 20),
              Text(
                "CPF*",
                textAlign: TextAlign.left,
              ),
              TextFormField(
                controller: controllerCpfNumber,
                keyboardType: TextInputType.number,
                validator: (numero) {
                  if (numero == "") {
                    return "O cpf é obrigatório";
                  }

                  if (numero.length < 14) {
                    return "Preencha o cpf corretamente, por favor";
                  }

                  return null;
                },
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0)),
                    isDense: true),
              ),
              SizedBox(height: 20),
              Text(
                "NOME*",
                textAlign: TextAlign.left,
              ),
              TextFormField(
                controller: controllerName,
                keyboardType: TextInputType.text,
                validator: (numero) {
                  if (numero == "") {
                    return "O nome é obrigatório";
                  }

                  return null;
                },
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0)),
                    isDense: true),
              ),
              SizedBox(height: 16),
              Text(
                "SOBRENOME",
                textAlign: TextAlign.left,
              ),
              TextFormField(
                controller: controllerLastname,
                keyboardType: TextInputType.text,
                validator: (numero) {
                  return null;
                },
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0)),
                    isDense: true),
              ),
              SizedBox(
                height: 25,
              ),
              !isProcessingPayment
                  ? Container(
                      padding: EdgeInsets.only(top: 10),
                      width: double.infinity,
                      child: RaisedButton(
                        color: Theme.of(context).colorScheme.primary,
                        padding: EdgeInsets.symmetric(vertical: 5),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());

                            setState(() {
                              isProcessingPayment = true;
                            });

                            Map<String, dynamic> result =
                                await processPayment();

                            showResultProcessPayment(
                                result, result['urlBoleto']);

                            if (result["status"] == "pending") {

                              _savePendingPayment(result['idPayment']);

                              _formKey.currentState.reset();
                              controllerCpfNumber.text = "";
                              controllerLastname.text = "";
                              controllerName.text = "";
                            }

                            setState(() {
                              isProcessingPayment = false;
                            });
                          }
                        },
                        child: Text(
                          'Finalizar Compra',
                          style: TextStyle(fontSize: 24),
                        ),
                      ))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Processando pagamento...",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Loader()
                      ],
                    ),
              Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom)),
            ],
          ),
        ));
  }

  void _savePendingPayment(idPayment) {
    Firestore.instance
        .collection("users")
        .document(UserModel.of(context).firebaseUser.uid)
        .collection("pendingPayments")
        .add({'dateCreated': DateTime.now(), 'idPayment': idPayment});
  }

  Future<Map<String, dynamic>> processPayment() async {
    QuerySnapshot databaseCredentials =
        await Firestore.instance.collection("config").getDocuments();

    //PEGA AS CREDENCIAS DE SANDBOX OU PRODUÇÃO DO BANCO
    final credentials = MercadoCredentials(
        publicKey: databaseCredentials.documents
            .elementAt(0)
            .data["publicKeyProduction"],
        accessToken: databaseCredentials.documents
            .elementAt(0)
            .data["accessTokenProduction"]);

    MercadoPago mp = new MercadoPago(credentials);

    Map<String, dynamic> user = UserModel.of(context).userData;

    //CRIA UM NOVO USUÁRIO NO MERCADO PAGO
    MercadoObject userObject = await mp.newUser(
        email: user["email"],
        firstname: controllerName.text,
        lastName: controllerLastname.text,
        cpf:
            controllerCpfNumber.text.replaceAll(".", "").replaceFirst("-", ""));

    //SALVA ESSE NOVO USUÁRIO NO BANCO
    String newUser = await saveNewUser(userObject);

    MercadoObject result = await mp.createBoletoPayment(
        cpf: controllerCpfNumber.text.replaceAll(".", "").replaceFirst("-", ""),
        email: user['email'],
        nome: controllerName.text,
        sobrenome: controllerLastname.text,
        userId: newUser,
        total: 99);

    return {
      'status': result.data["status"],
      'status_detail': result.data["status_detail"],
      'urlBoleto': result.data['transaction_details']['external_resource_url'],
      'idPayment': result.data['id']
    };
  }

  Future<String> saveNewUser(userObject) async {
    String userId;

    if (userObject.isSuccessful) {
      userId = userObject.data["id"];

      await Firestore.instance
          .collection("users")
          .document(UserModel.of(context).firebaseUser.uid)
          .updateData({"idCard": userObject.data["id"]});
    } else {
      await UserModel.of(context).loadCurrentUser();

      UserModel user = UserModel.of(context);

      userId = user.userData["idCard"];
    }

    return userId;
  }

  void showResultProcessPayment(Map<String, dynamic> result, String url) async {
    Alerts alert = new Alerts();

    switch (result["status"]) {
      case "pending":
        alert.buildCupertinoDialog(
            Text(
              "Aprovado!",
              style: TextStyle(color: Colors.green, fontSize: 17),
            ),
            [
              CupertinoDialogAction(
                child: Text("Entendido"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
            context,
            content: Column(
              children: <Widget>[
                Text(
                    "Te enviamos o boleto por email, basta pagá-lo e esperar 2 dias úteis para receber 30 dias e frequentar qualquer academia. :)"),
                SizedBox(
                  height: 5,
                ),
                CupertinoButton(
                  onPressed: () async {
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: Text("Visualizar boleto",
                      style: TextStyle(
                          color: Colors.grey[600],
                          decoration: TextDecoration.underline,
                          fontSize: 13)),
                )
              ],
            ));

        break;
      case "rejected":
        alert.buildCupertinoDialog(
            Text("Rejeitado!"),
            [
              CupertinoDialogAction(
                child: Text("Entendido"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
            context,
            content: Text(
                "Algo deu errado, verifique se os campos do formulário foram preenchidos corretamente."));

        break;

      default:
    }
  }
}
