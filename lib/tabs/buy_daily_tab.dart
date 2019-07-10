import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:startgym/widgets/loader.dart';
import 'package:startgym/widgets/payment_daily_process.dart';
import 'package:startgym/widgets/sliver_appbar.dart';

class BuyDailyTab extends StatefulWidget {
  _BuyDailyTabState createState() => _BuyDailyTabState();
}

class _BuyDailyTabState extends State<BuyDailyTab>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
                            bottomSheetCardCredit(context, 30, 75);
                          }),
                      SizedBox(height: 16),
                      /*InkWell(
                    child: Container(
                        decoration: borderPackages,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("BIMESTRAL", style: styleDailyPackages),
                            Text(
                              "PREÇO: R\$ 140,00",
                              style: stylePricePackages,
                            )
                          ],
                        )),
                    onTap: () {
                      bottomSheetCardCredit(context, 60, 140);
                    },
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    child: Container(
                        decoration: borderPackages,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("TRIMESTRAL", style: styleDailyPackages),
                            Text(
                              "PREÇO: R\$ 200,00",
                              style: stylePricePackages,
                            )
                          ],
                        )),
                    onTap: () {
                      bottomSheetCardCredit(context, 90, 200);
                    },
                  )*/
                    ],
                  ),
                )),
              ])
        : Loader();
  }

  void bottomSheetCardCredit(BuildContext context, planDays, valuePoints) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PaymentDailyProcess(planDays, valuePoints)));
  }
}


/***** */