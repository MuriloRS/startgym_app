import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mercado_pago/mercado_pago.dart';
import 'package:startgym/models/user_model.dart';
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
                    child: Padding(
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
                                  Text("MENSAL", style: styleDailyPackages),
                                  Text(
                                    "PREÇO: R\$ 99,00",
                                    style: stylePricePackages,
                                  )
                                ],
                              )),
                          onTap: () {
                            showCreditCards(context, 30);
                          }),
                      SizedBox(height: 16),
                    ],
                  ),
                )),
              ])
        : Loader();
  }

  void showCreditCards(BuildContext context, planDays) {
/*
    searchCardsUser();
*/
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

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PaymentDailyProcess(30, 1)));
                        },
                        padding: EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset("images/master.png"),
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

  void searchCardsUser() async {
    DocumentSnapshot user = await Firestore.instance
        .collection("users")
        .document(UserModel.of(context).firebaseUser.uid)
        .get();

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

    if (result != null) {}
  }
}
