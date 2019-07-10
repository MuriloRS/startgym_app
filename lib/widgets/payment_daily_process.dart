import 'package:flutter/material.dart';
import 'package:flutter_cielo/flutter_cielo.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/widgets/loader.dart';

class PaymentDailyProcess extends StatefulWidget {
  final int planDays;
  final int valuePoints;

  PaymentDailyProcess(this.planDays, this.valuePoints);

  @override
  _PaymentDailyProcessState createState() => _PaymentDailyProcessState();
}

class _PaymentDailyProcessState extends State<PaymentDailyProcess> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var controllerCardNumber =
      new MaskedTextController(mask: "0000-0000-0000-0000");
  var controllerExpirationDate = new MaskedTextController(mask: "00/0000");
  var controllerCvc = new MaskedTextController(mask: "000");
  var controllerNameCard = new TextEditingController();
  var isFrontCard = true;
  var isProcessingPayment = false;

  FocusNode focusNodeNameCard = new FocusNode();
  FocusNode focusNodeExpirationDate = new FocusNode();
  FocusNode focusNodeCvc = new FocusNode();
  FocusNode focusNodeButton = new FocusNode();

  String selectedFlag = "Mastercard";
  String selectedTypePurchase = "Crédito";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,

          title: Text(widget.planDays.toString() + " dias", style: TextStyle(color: Colors.black, fontSize: 24),),
        ),
        key: _scaffoldKey,
        body: Container(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Container(
                  width: 300,
                  height: 150,
                  child: isFrontCard
                      ? Image.asset("images/front-card.png")
                      : Image.asset("images/back-card.png"),
                ),
                SizedBox(height: 20),
                Text("Número do cartão"),
                TextFormField(
                  controller: controllerCardNumber,
                  onEditingComplete: () {
                    FocusScope.of(context).requestFocus(focusNodeNameCard);
                  },
                  keyboardType: TextInputType.number,
                  validator: (numero) {
                    if (numero == "") {
                      return "O número do cartão é obrigatório";
                    }

                    if (numero.length < 16) {
                      return "Preencha o número do cartão corretamente, por favor";
                    }
                  },
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
                Text("Nome do cartão"),
                TextFormField(
                  controller: controllerNameCard,
                  focusNode: focusNodeNameCard,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (nome) {
                    if (nome == "") {
                      return "O campo nome é obrigatório";
                    }

                    if (nome.length < 6) {
                      return "Preencha o nome do cartão corretamente, por favor";
                    }
                  },
                  onEditingComplete: () {
                    FocusScope.of(context)
                        .requestFocus(focusNodeExpirationDate);
                  },
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Data de expiração",
                              textAlign: TextAlign.left,
                            ),
                            TextFormField(
                              focusNode: focusNodeExpirationDate,
                              controller: controllerExpirationDate,
                              keyboardType: TextInputType.number,
                              validator: (data) {
                                if (data == "") {
                                  return "A data de expiração é obrigatório.";
                                }

                                if (data.length < 4) {
                                  return "Preencha a data de expiração corretamente, por favor";
                                }
                              },
                              onEditingComplete: () {
                                setState(() {
                                  isFrontCard = false;
                                });

                                FocusScope.of(context)
                                    .requestFocus(focusNodeCvc);
                              },
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0)),
                                  isDense: true),
                            )
                          ],
                        )),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "CVV",
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
                              },
                              onEditingComplete: () {
                                setState(() {
                                  isFrontCard = true;
                                });

                                FocusScope.of(context)
                                    .requestFocus(focusNodeButton);
                              },
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0)),
                                  isDense: true),
                            )
                          ],
                        ))
                      ],
                    )),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "Escolha a bandeira",
                  textAlign: TextAlign.left,
                ),
                new DropdownButton<String>(
                  hint: Text("Escolha a bandeira"),
                  isExpanded: true,
                  style: TextStyle(color: Colors.black),
                  value: selectedFlag,
                  items: <String>['Mastercard', 'Visa', 'Outro']
                      .map((String value) {
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
                SizedBox(height: 16),
                Text(
                  "Tipo de pagamento",
                  textAlign: TextAlign.left,
                ),
                new DropdownButton<String>(
                  hint: Text("Tipo de pagamento"),
                  isExpanded: true,
                  style: TextStyle(color: Colors.black),
                  value: selectedTypePurchase,
                  items: <String>['Crédito', 'Débito']
                      .map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                  onChanged: (s) {
                    setState(() {
                      selectedTypePurchase = s;
                    });
                  },
                ),
                SizedBox(height: 20,),
                !isProcessingPayment
                    ? RaisedButton(
                        color: Theme.of(context).colorScheme.primary,
                        padding: EdgeInsets.symmetric(vertical: 5),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              isProcessingPayment = true;
                            });
                            
                            processPayment();

                            setState(() {
                              isProcessingPayment = false;
                            });
                          }
                        },
                        child: Text(
                          'Finalizar Compra',
                          style: TextStyle(fontSize: 24),
                        ),
                      )
                    : Loader()
              ],
            ),
          ),
        ));
  }

  void processPayment() {
    setState(() {
      isProcessingPayment = true;
    });

    //int amount = widget.valuePoints * 100;

    final CieloEcommerce cielo = CieloEcommerce(
        environment: Environment.PRODUCTION, // ambiente de desenvolvimento
        merchant: Merchant(
          //PRODUCTION
          merchantId: "c1c584a1-c29f-457e-983d-c1ab2b0f1e76",
          merchantKey: "9y8eRegquiKUrAE7ESKJFbveVc0QbEr8ZAFQV8hL"


          /*
          SANDBOX
          merchantId: "f66b23d6-ed67-49c7-8e6e-78d3a479b1c2",
          merchantKey: "ERJWBRHJPZACEVQLXCBMGCUYBPXWMEJCKZNOMZEJ",*/
        ));

    //Objeto de venda
    Sale sale = Sale(
        merchantOrderId: "124", // id único de sua venda
        customer: Customer(
            //objeto de dados do usuário
            name: "Comprador crédito simples"),
        payment: Payment(
            // objeto para de pagamento
            type: TypePayment.creditCard, //tipo de pagamento
            amount: 1, // valor da compra em centavos
            installments: 1, // número de parcelas
            softDescriptor:
                "Startgym", //descrição que aparecerá no extrato do usuário. Apenas 15 caracteres
            creditCard: CreditCard(
              //objeto de Cartão de crédito
              cardNumber: controllerCardNumber.value.text, //número do cartão
              holder: controllerNameCard
                  .value.text, //nome do usuário impresso no cartão
              expirationDate:
                  controllerExpirationDate.value.text, // data de expiração
              securityCode: controllerCvc.value.text, // código de segurança
              brand: selectedFlag == "Mastercard"
                  ? "Master"
                  : selectedFlag, // bandeira
            )));

    try {
        cielo.createSale(sale).then((response) {

        UserModel.of(context).activeUserPlan(widget.planDays);
        
        _formKey.currentState.dispose();

        _scaffoldKey.currentState.showSnackBar(SnackBar(
          duration: Duration(seconds: 5),
          backgroundColor: Colors.green,
          content: Text(
              "${response.payment.paymentId} Parabéns você você finalizou a compra. Agora você tem ${widget.planDays} dias para ir em qualquer academia cadastrada no nosso aplicativo."),
        ));

      });
    } catch (e) {
      print(e);

      _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 5),
        backgroundColor: Colors.red,
        content: Text(
          e,
          style: TextStyle(color: Colors.white),
        ),
      ));
    }

    setState(() {
      isProcessingPayment = false;
    });
  }
}
