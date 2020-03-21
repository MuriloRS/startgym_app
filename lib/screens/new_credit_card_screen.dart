import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:mercado_pago/mercado_pago.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/utils/payment.dart';
import 'package:startgym/widgets/loader.dart';

class NewCreditCardScreen extends StatefulWidget {
  @override
  _NewCreditCardScreenState createState() => _NewCreditCardScreenState();
}

class _NewCreditCardScreenState extends State<NewCreditCardScreen> {
  final _formKey = GlobalKey<FormState>();

  var isFrontCard = true;
  var isProcessingPayment = false;

  FocusNode focusNodeNameCard = new FocusNode();
  FocusNode focusNodeExpirationDate = new FocusNode();
  FocusNode focusNodeCvc = new FocusNode();
  FocusNode focusNodeButton = new FocusNode();

  var controllerCardNumber =
      new MaskedTextController(mask: "0000 0000 0000 0000");
  var controllerCpfNumber = new MaskedTextController(mask: "000.000.000-00");
  var controllerExpirationDate = new MaskedTextController(mask: "00/00");
  var controllerCvc = new MaskedTextController(mask: "000");
  var controllerNameCard = new TextEditingController();
  var controllerFirstName = new TextEditingController();
  var controllerLastName = new TextEditingController();
  var controllerTelephone = new MaskedTextController(mask: "(000) 90000-0000");

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

    return WillPopScope(
      child: Material(
          child: SafeArea(
              child: Container(
                  child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          SizedBox(
            height: 16,
          ),
          Text(
            'Novo Cartão',
            style: TextStyle(color: Colors.grey[800], fontSize: 24),
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            width: MediaQuery.of(context).size.height - 470,
            child: isFrontCard
                ? Image.asset("images/front-card.png")
                : Image.asset("images/back-card.png"),
          ),
          SizedBox(height: 16),
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
                              SizedBox(height: 20),
                              Text(
                                "NÚMERO DO CARTÃO*",
                                style: styleLabel,
                                textAlign: TextAlign.left,
                              ),
                              TextFormField(
                                controller: controllerCardNumber,
                                onEditingComplete: () {
                                  FocusScope.of(context)
                                      .requestFocus(focusNodeCpf);
                                },
                                keyboardType: TextInputType.number,
                                validator: (numero) {
                                  if (numero == "") {
                                    return "O número do cartão é obrigatório";
                                  }

                                  if (numero.length < 16) {
                                    return "Preencha o número do cartão corretamente, por favor";
                                  }

                                  return null;
                                },
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(0)),
                                    isDense: true),
                              ),
                              SizedBox(height: 20),
                              Text("CPF*",
                                  style: styleLabel, textAlign: TextAlign.left),
                              TextFormField(
                                controller: controllerCpfNumber,
                                focusNode: focusNodeCpf,
                                onEditingComplete: () {
                                  FocusScope.of(context)
                                      .requestFocus(focusNodeNameCard);
                                },
                                keyboardType: TextInputType.number,
                                validator: (numero) {
                                  if (numero == "") {
                                    return "O seu cpf é obrigatório para completar a transação.";
                                  }

                                  if (numero.length < 11) {
                                    return "Preencha o cpf corretamente, por favor";
                                  }

                                  return null;
                                },
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(0)),
                                    isDense: true),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Text("NOME DO CARTÃO*",
                                  style: styleLabel, textAlign: TextAlign.left),
                              TextFormField(
                                controller: controllerNameCard,
                                focusNode: focusNodeNameCard,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                validator: (nome) {
                                  if (nome == "") {
                                    return "O campo nome é obrigatório";
                                  }

                                  if (nome.length < 6) {
                                    return "Preencha o nome do cartão corretamente, por favor";
                                  }

                                  return null;
                                },
                                onEditingComplete: () {
                                  FocusScope.of(context)
                                      .requestFocus(focusNodeExpirationDate);
                                },
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(0)),
                                    isDense: true),
                              ),
                              SizedBox(height: 16),
                              Container(
                                  width: double.maxFinite,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Expanded(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "DATA DE EXPIRAÇÃO*",
                                            style: styleLabel,
                                            textAlign: TextAlign.left,
                                          ),
                                          TextFormField(
                                            focusNode: focusNodeExpirationDate,
                                            controller:
                                                controllerExpirationDate,
                                            keyboardType: TextInputType.number,
                                            validator: (data) {
                                              if (data == "") {
                                                return "A data de expiração é obrigatório.";
                                              }

                                              if (data.length < 4) {
                                                return "Preencha a data de expiração corretamente, por favor";
                                              }

                                              return null;
                                            },
                                            onEditingComplete: () {
                                              setState(() {
                                                isFrontCard = false;
                                              });

                                              FocusScope.of(context)
                                                  .requestFocus(focusNodeCvc);
                                            },
                                            decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 5),
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0)),
                                                isDense: true),
                                          )
                                        ],
                                      )),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "CVC*",
                                            style: styleLabel,
                                            textAlign: TextAlign.left,
                                          ),
                                          TextFormField(
                                            controller: controllerCvc,
                                            focusNode: focusNodeCvc,
                                            keyboardType: TextInputType.number,
                                            validator: (cvc) {
                                              if (cvc == "") {
                                                return "O campo CVC é obrigatório";
                                              }

                                              if (cvc.length < 2) {
                                                return "Preencha o CVC corretamente, por favor";
                                              }

                                              return null;
                                            },
                                            onEditingComplete: () {
                                              setState(() {
                                                isFrontCard = true;
                                              });
                                            },
                                            decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 5),
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0)),
                                                isDense: true),
                                          )
                                        ],
                                      ))
                                    ],
                                  )),
                              SizedBox(
                                height: 16,
                              ),
                              DropDownFlag(),
                              SizedBox(
                                height: 20,
                              ),
                              isProcessingPayment
                                  ? Center(child: Loader())
                                  : Container(
                                      padding: EdgeInsets.only(bottom: 10),
                                      width: double.infinity,
                                      child: RaisedButton(
                                        color: Colors.green[600],
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        onPressed: () async {
                                          if (_formKey.currentState
                                              .validate()) {
                                            FocusScope.of(context)
                                                .requestFocus(new FocusNode());

                                            setState(() {
                                              isProcessingPayment = true;
                                            });

                                            final Payment payment =
                                                new Payment();

                                            MercadoCredentials mc = await payment
                                                .getMercadoPagoCredentials();

                                            MercadoPago mp =
                                                new MercadoPago(mc);

                                            String idCard =
                                                await payment.addNewCreditCard(
                                                    mp: mp,
                                                    cpf: controllerCpfNumber
                                                        .text,
                                                    cardNumber:
                                                        controllerCardNumber
                                                            .text,
                                                    context: context,
                                                    cvc: controllerCvc.text,
                                                    expirationDate:
                                                        controllerExpirationDate
                                                            .text,
                                                    nameCard:
                                                        controllerNameCard.text,
                                                    user: UserModel.of(context)
                                                        .userData);

                                            Navigator.of(context).pop();

                                            Navigator.of(context)
                                                .pushNamed("/buyScreen");

                                            setState(() {
                                              isProcessingPayment = false;
                                            });
                                          }
                                        },
                                        child: Text(
                                          'Adicionar Cartão',
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
            ],
          ),
        ],
      )))),
      onWillPop: _redirectPlansTab,
    );
  }

  Future<bool> _redirectPlansTab() async {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed("/buyScreen");
    await Future.delayed(Duration(milliseconds: 10));
    return false;
  }
}

class DropDownFlag extends StatefulWidget {
  @override
  _DropDownFlagState createState() => _DropDownFlagState();
}

class _DropDownFlagState extends State<DropDownFlag> {
  var selectedFlag = "Mastercard";
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      items: <String>[
        'Mastercard',
        'Visa',
        'Hipercard',
        'Elo',
        'American Express'
      ].map((String value) {
        return new DropdownMenuItem<String>(
          value: value,
          child: new Text(value),
        );
      }).toList(),
      value: selectedFlag,
      onChanged: (s) {
        setState(() {
          selectedFlag = s;
        });
      },
    );

    return Container(
        padding: EdgeInsets.all(0),
        width: double.maxFinite,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 10,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "BANDEIRA*",
                  textAlign: TextAlign.left,
                ),
                new DropdownButton<String>(
                  hint: Text("Bandeira"),
                  isExpanded: true,
                  style: TextStyle(color: Colors.black),
                  value: selectedFlag,
                  items: <String>[
                    'Mastercard',
                    'Visa',
                    'Hipercard',
                    'Elo',
                    'American Express'
                  ].map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                  onChanged: (s) {
                    setState(() {
                      selectedFlag = s;
                    });
                  },
                ),
              ],
            ))
          ],
        ));
  }
}
