import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/utils/alerts.dart';
import 'package:startgym/widgets/loader.dart';
import 'package:mercado_pago/mercado_pago.dart';

class PaymentCreditcard extends StatefulWidget {

  final String idCard;

  PaymentCreditcard(this.idCard);

  @override
  _PaymentCreditcardState createState() => _PaymentCreditcardState();
}

class _PaymentCreditcardState extends State<PaymentCreditcard> {
  final _formKey = GlobalKey<FormState>();

  var controllerCardNumber =
      new MaskedTextController(mask: "0000 0000 0000 0000");
  var controllerCpfNumber = new MaskedTextController(mask: "000.000.000-00");
  var controllerExpirationDate = new MaskedTextController(mask: "00/00");
  var controllerCvc = new MaskedTextController(mask: "000");
  var controllerNameCard = new TextEditingController();
  var controllerFirstName = new TextEditingController();
  var controllerLastName = new TextEditingController();
  var controllerTelephone = new MaskedTextController(mask: "(000) 90000-0000");

  var isFrontCard = true;
  var isProcessingPayment = false;

  FocusNode focusNodeNameCard = new FocusNode();
  FocusNode focusNodeExpirationDate = new FocusNode();
  FocusNode focusNodeCvc = new FocusNode();
  FocusNode focusNodeButton = new FocusNode();

  String selectedFlag = "Mastercard";
  String selectedTypePurchase = "Crédito";
  String selectedInstallments = "1x sem juros";

  DocumentSnapshot cieloKeys;
  bool isPaddingkeyboard = false;

  TextStyle styleLabel = new TextStyle(color: Colors.grey[800]);

  FocusNode focusNodeFirstName;
  FocusNode focusNodeLastName;
  FocusNode focusNodeTelephone;
  FocusNode focusNodeCpf;

  @override
  Widget build(BuildContext context) {
    focusNodeFirstName = new FocusNode();
    focusNodeLastName = new FocusNode();
    focusNodeTelephone = new FocusNode();
    focusNodeCpf = new FocusNode();

    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Container(
          width: 180,
          child: isFrontCard
              ? Image.asset("images/front-card.png")
              : Image.asset("images/back-card.png"),
        ),
        SizedBox(height: 10),
        Divider(height: 1, color: Colors.grey[700]),
        Stack(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Container(
                  height: MediaQuery.of(context).size.height - 250,
                  padding:
                      EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 5),
                  child: ScrollConfiguration(
                      behavior: ScrollBehavior(),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textDirection: TextDirection.ltr,
                          children: <Widget>[
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "PARCELAS",
                              style: styleLabel,
                              textAlign: TextAlign.left,
                            ),
                            new DropdownButton<String>(
                              hint: Text("Parcelas"),
                              isExpanded: true,
                              style: TextStyle(color: Colors.black),
                              value: selectedInstallments,
                              items: <String>[
                                '1x sem juros',
                                '2x sem juros',
                                '3x sem juros',
                              ].map((String value) {
                                return new DropdownMenuItem<String>(
                                  value: value,
                                  child: new Text(value),
                                );
                              }).toList(),
                              onChanged: (s) {
                                setState(() {
                                  selectedInstallments = s;
                                });
                              },
                            ),
                            Container(
                                padding: EdgeInsets.all(10),
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

                                      Map<String, dynamic> result;

                                      try {
                                        result = await processPayment();
                                      } catch (e) {
                                        new Alerts().buildCupertinoDialog(
                                            Text(e.toString()),
                                            [
                                              CupertinoDialogAction(
                                                child: Text("OK"),
                                                isDefaultAction: true,
                                              )
                                            ],
                                            context);
                                      }

                                      if (result["status"] == "approved") {
                                        _doAcceptPaymentMonthly();

                                        Navigator.pop(context);
                                      }

                                      if (result["status"] == "approved" ||
                                          result["status"] == "in_process") {
                                        _formKey.currentState.reset();
                                      }

                                      showResultProcessPayment(result);

                                      setState(() {
                                        isProcessingPayment = false;
                                      });
                                    }
                                  },
                                  child: Text(
                                    'Finalizar Compra',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom)),
                          ],
                        ),
                      ))),
            ),
            isProcessingPayment
                ? Container(
                    height: MediaQuery.of(context).size.height - 250,
                    decoration: new BoxDecoration(
                      color: const Color.fromRGBO(250, 250, 250, 1)
                          .withOpacity(0.7),
                    ),
                    child: Center(
                      child: Loader(),
                    ),
                  )
                : Container()
          ],
        ),
      ],
    ));
  }

  Future<String> loadAsset(BuildContext context) async {
    return await DefaultAssetBundle.of(context).loadString('assets/index.html');
  }

  Future<Map<String, dynamic>> processPayment() async {
    String userCard = "";

    
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

    //A PARTIR DO NOME DO CARTÃO PEGA O PRIMEIRO E ÚLTIMO NOME DO USUÁRIO
    Map nameUser = searchFirstAndLastNameUser(controllerNameCard.text);

    //CRIA UM NOVO USUÁRIO NO MERCADO PAGO
    MercadoObject userObject = await mp.newUser(
        email: user["email"],
        firstname: nameUser['firstName'],
        lastName: nameUser['lastName'],
        cpf:
            controllerCpfNumber.text.replaceAll(".", "").replaceFirst("-", ""));

    //SALVA ESSE NOVO USUÁRIO NO BANCO
    String newUser = await saveNewUser(userObject);

    String idCard;
    String idAssociatedCard;
    MercadoObject associate;

    //SE JÁ HOUVER ALGUM CARTÃO CADASTRADO PEGA ELE DO BANCO
    if (List.from(user["cards"]).length > 0) {
      idCard = List.from(user['cards']).elementAt(0);

      idAssociatedCard = idCard;
    } else {
      //SE NÃO CRIA UM NOVO CARTÃO MERCADO PAGO
      MercadoObject cardObject = await mp.newCard(
          card: controllerCardNumber.text.replaceAll(" ", ""),
          docType: "CPF",
          docNumber: controllerCpfNumber.text
              .replaceAll(".", "")
              .replaceFirst("-", ""),
          code: controllerCvc.text,
          month:
              int.parse(controllerExpirationDate.text.split("/").elementAt(0)),
          year: "20" + controllerExpirationDate.text.split("/").elementAt(1),
          name: controllerNameCard.text.toUpperCase());

      idCard = cardObject.data["id"];

      //ASSOCIA O CARTÃO COM O USUÁRIO
      associate = await mp.associateCardWithUser(card: idCard, user: newUser);

      //E SALVA NO BANCO
      await saveCardFromUser(associate);

      idAssociatedCard = associate.data['id'];
    }

    //CRIA UM TOKEN ÚNICO PARA O CARTÃO
    MercadoObject token = await mp.tokenWithCard(
        card: idAssociatedCard, code: controllerCvc.text);

    idAssociatedCard = token.data["id"];

    //CRIA O PAGAMENTO
    MercadoObject payment = await mp.createPayment(
        cardToken: idAssociatedCard,
        description: "Plano 30 dias",
        email: user["email"],
        paymentMethod: getPaymentMethod(),
        total: 99.0,
        userId: newUser,
        installment: getInstallment(),
        cpf: controllerCpfNumber.text);

    //RETORNA O RESULTADO
    return {
      'status': payment.data["status"],
      'status_detail': payment.data["status_detail"]
    };
  }

  double getInstallment() {
    switch (selectedInstallments) {
      case '1x sem juros':
        return 1;
        break;
      case '2x sem juros':
        return 2;
        break;
      case '3x sem juros':
        return 3;
        break;
      case '4x sem juros':
        return 4;
        break;
      case '5x sem juros':
        return 5;
        break;
      default:
    }
  }

  String getPaymentMethod() {
    switch (selectedFlag) {
      case "Mastercard":
        return 'master';
        break;
      case "Visa":
        return 'visa';
        break;
      case "Hipercard":
        return 'hipercard';
        break;
      case "Elo":
        return 'elo';
        break;
      case 'American Express':
        return "amex";
        break;
      default:
        return '';
    }
  }

  Future<String> saveCardFromUser(MercadoObject cardAssociated) async {
    UserModel userId = UserModel.of(context);

    if (cardAssociated.isSuccessful) {
      List<dynamic> cards = new List();
      cards.add(cardAssociated.data["id"]);

      await Firestore.instance
          .collection("users")
          .document(userId.firebaseUser.uid)
          .updateData({"cards": cards});

      return cardAssociated.data["id"];
    } else {
      DocumentSnapshot user = await Firestore.instance
          .collection("users")
          .document(userId.firebaseUser.uid)
          .get();

      return user.data["cards"];
    }
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

  Map<String, dynamic> searchFirstAndLastNameUser(String nameComplete) {
    String firstName = nameComplete.split(" ").elementAt(0);
    String lastName =
        nameComplete.split(" ").elementAt(nameComplete.split(" ").length - 1);

    return {'firstName': firstName, 'lastName': lastName};
  }

  void _doAcceptPaymentMonthly() {
    UserModel.of(context).activeUserPlan(30);
  }

  void showResultProcessPayment(Map<String, dynamic> result) {
    Alerts alert = new Alerts();

    switch (result["status"]) {
      case "in_process":
        alert.buildCupertinoDialog(
            Text("Quase!", style: TextStyle(color: Colors.green)),
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
                "Em breve finalizaremos sua compra e será liberado para você 30 dias. :)"));
        break;
      case "approved":
        alert.buildCupertinoDialog(
            Text("Aprovado!", style: TextStyle(color: Colors.green)),
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
                "Você vai ganhar mais 30 dias para frequentar as academias :)"));

        break;
      case "rejected":
        if (result["status_detail"] == "cc_rejected_insuficient_amount") {
          alert.buildCupertinoDialog(
              Text("Rejeitado!", style: TextStyle(color: Colors.red)),
              [
                CupertinoDialogAction(
                  child: Text("Entendido"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
              context,
              content: Text("Saldo insuficiente, tente com outro cartão"));
        } else {
          alert.buildCupertinoDialog(
              Text("Rejeitado!", style: TextStyle(color: Colors.red)),
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
                  "Algo deu errado com a compra, verifique os campos digitados do cartão novamente. Erro = ${result["status_detail"]} "));
        }

        break;

      default:
    }
  }
}
