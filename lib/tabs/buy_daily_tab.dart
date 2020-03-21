import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mercado_pago/mercado_pago.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/screens/new_credit_card_screen.dart';
import 'package:startgym/utils/alerts.dart';
import 'package:startgym/widgets/dialog_cards.dart';
import 'package:startgym/widgets/loader.dart';
import 'package:startgym/screens/payment_daily_process.dart';
import 'package:startgym/widgets/sliver_appbar.dart';

class BuyDailyTab extends StatefulWidget {
  _BuyDailyTabState createState() => _BuyDailyTabState();
}

class _BuyDailyTabState extends State<BuyDailyTab>
    with SingleTickerProviderStateMixin {
  void reloadScreen() {
    setState(() {
      isLoading = true;
    });
  }

  String packageChosen = "";
  bool isLoading = false;
  bool isProcessingPayment = false;
  bool isCardSelected = false;

  TextEditingController numCartaoController = new TextEditingController();
  TextEditingController dataExpiracaoController = new TextEditingController();
  TextEditingController cvcController = new TextEditingController();

  BoxDecoration borderPackages = BoxDecoration(
    border: new Border.all(color: Colors.grey[400], style: BorderStyle.solid),
    borderRadius: BorderRadius.all(Radius.circular(5)),
    color: Colors.white,
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: Colors.grey,
        offset: Offset(2.0, 4.0),
        blurRadius: 5.0,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    TextStyle styleDailyPackages = TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).accentColor);

    TextStyle stylePricePackages =
        TextStyle(fontSize: 24, fontWeight: FontWeight.bold);

    return !isLoading
        ? CustomScrollView(
            physics: NeverScrollableScrollPhysics(),
            slivers: <Widget>[
                CustomSliverAppbar(),
                SliverFillRemaining(
                    child: FutureBuilder(
                  future: searchCardsUser(),
                  builder: (context, AsyncSnapshot<MercadoObject> snapshot) {
                    if (snapshot.connectionState.index ==
                            ConnectionState.none.index ||
                        snapshot.connectionState.index ==
                            ConnectionState.waiting.index) {
                      return Loader();
                    } else {
                      return Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: <Widget>[
                            Text("Escolha um dos pacotes",
                                style: Theme.of(context).textTheme.title),
                            SizedBox(
                              height: 25,
                            ),
                            InkWell(
                                child: Container(
                                    decoration: borderPackages,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 25),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text("MENSAL",
                                            style: styleDailyPackages),
                                        Text(
                                          "PREÇO: R\$ 99,00",
                                          style: stylePricePackages,
                                        )
                                      ],
                                    )),
                                onTap: () {
                                  showCreditCards(context, 30, snapshot.data);
                                }),
                            SizedBox(height: 16),
                          ],
                        ),
                      );
                    }
                  },
                )),
              ])
        : Loader();
  }

  void showCreditCards(
      BuildContext context, planDays, MercadoObject userCards) async {
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: false,
        backgroundColor: Colors.grey[200],
        builder: (builder) {
          return SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Escolha o tipo de pagamento",
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      RaisedButton(
                        color: Colors.white,
                        onPressed: () {
                          Navigator.pop(context);

                          _showUserRegisteredCards(userCards);
                        },
                        padding: EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(FontAwesomeIcons.creditCard,
                                color: Colors.grey[800]),
                            SizedBox(
                              width: 20,
                            ),
                            Text("Cartão de Crédito",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 17))
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      RaisedButton(
                        color: Colors.white,
                        onPressed: () {
                          Navigator.pop(context);

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PaymentDailyProcess(30, 2)));
                        },
                        padding: EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset("images/boleto.png"),
                            SizedBox(
                              width: 20,
                            ),
                            Text("Boleto Bancário",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 17))
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                    ],
                  )));
        });
  }

  void _showUserRegisteredCards(MercadoObject userCards) {
    Alerts al = new Alerts();

    List<Widget> cards = _buildCreditCardUser(userCards);

    showDialog(
        context: context,
        builder: (_) {
          return Container(
              width: 250,
              height: 350,
              child: StatefulBuilder(builder: (context, setState) {
                return AlertDialog(
                  content: Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 10),
                      Container(
                          height: (cards.length * 60.0),
                          child: ListView.builder(
                            itemCount: cards.length,
                            itemBuilder: (context, index) {
                              return cards.elementAt(index);
                            },
                          )),
                      SizedBox(
                        height: 16,
                      ),
                      GestureDetector(
                        child: Container(
                          child: Center(
                              child: Icon(Icons.add,
                                  size: 34, color: Colors.green[600])),
                          decoration: new BoxDecoration(
                              border: Border.all(
                                  width: 1, color: Colors.green[600]),
                              color: Colors.white,
                              borderRadius: new BorderRadius.only(
                                  bottomLeft: const Radius.circular(40.0),
                                  bottomRight: const Radius.circular(40.0),
                                  topLeft: const Radius.circular(40.0),
                                  topRight: const Radius.circular(40.0))),
                          width: 35,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => NewCreditCardScreen()));
                        },
                      )
                    ],
                  )),
                  title: Text(
                    cards.length > 0
                        ? "Escolha um cartão"
                        : "Cadastre um cartão",
                    textAlign: TextAlign.center,
                  ),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text("Adicionar Cartão",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16)),
                      onPressed: isCardSelected ? () {} : null,
                      isDefaultAction: true,
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ],
                );
              }));
        });
  }

  List<Widget> _buildCreditCardUser(MercadoObject userCards) {
    LinkedHashMap<dynamic, dynamic> cards = userCards.data as LinkedHashMap;
    List<Widget> cardsList = new List();

    cards.forEach((k, v) {
      (v as List).forEach((card) {
        String lastDigits = card['last_four_digits'];
        Icon cardIcon = _getCardIcon(card['issuer']['name']);

        cardsList.add(GestureDetector(
          onTap: () {
            setState(() {
              isCardSelected = true;
            });
          },
          child: Card(
            elevation: 5,
            child: Container(
                padding: EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    cardIcon,
                    SizedBox(
                      width: 10,
                    ),
                    Text("**** **** **** $lastDigits")
                  ],
                )),
          ),
        ));
      });
    });

    return cardsList;
  }

  Icon _getCardIcon(cardType) {
    switch (cardType) {
      case "Mastercard":
        return Icon(
          FontAwesomeIcons.ccMastercard,
          size: 20,
        );
        break;
      case "Visa":
        return Icon(
          FontAwesomeIcons.ccVisa,
          color: Colors.lightBlue[900],
        );
        break;
      case "Hipercard":
        return Icon(
          FontAwesomeIcons.creditCard,
          color: Colors.black,
        );
        break;
      case "Elo":
        return Icon(
          FontAwesomeIcons.creditCard,
          color: Colors.black,
        );
        break;
      case 'American Express':
        return Icon(
          FontAwesomeIcons.ccAmex,
          color: Colors.blue[700],
        );
        break;
      default:
        return Icon(
          FontAwesomeIcons.creditCard,
          color: Colors.black,
        );
    }
  }

  Future<MercadoObject> searchCardsUser() async {
    DocumentSnapshot user = await Firestore.instance
        .collection("users")
        .document(UserModel.of(context).firebaseUser.uid)
        .get();

    if (user.data["idCard"] == null) {
      return null;
    }

    QuerySnapshot databaseCredentials =
        await Firestore.instance.collection("config").getDocuments();

    final credentials = MercadoCredentials(
        publicKey: databaseCredentials.documents
            .elementAt(0)
            .data["publicKeyProduction"],
        accessToken: databaseCredentials.documents
            .elementAt(0)
            .data["accessTokenProduction"]);

    MercadoPago mp = new MercadoPago(credentials);

    MercadoObject result = await mp.cardsFromUser(user: user.data["idCard"]);

    return result;
  }
}
