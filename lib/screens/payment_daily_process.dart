import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:startgym/widgets/payment_boleto_bancario.dart';
import 'package:startgym/widgets/payment_credit_card.dart';

class PaymentDailyProcess extends StatefulWidget {
  final int planDays;

  /**
   * TIPO 1 = CARTÃO DE CRÉDITO
   * TIPO 2 = BOLETO BANCÁRIO
   */
  final int typePayment;

  PaymentDailyProcess(this.planDays, this.typePayment);

  @override
  _PaymentDailyProcessState createState() => _PaymentDailyProcessState();
}

class _PaymentDailyProcessState extends State<PaymentDailyProcess> {
  @override
  void initState() {
    super.initState();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
          title: Text(
            "R\$ 99,00 - " + widget.planDays.toString() + " dias",
            style: TextStyle(color: Colors.black87, fontSize: 24),
          ),
        ),
        key: _scaffoldKey,
        body: widget.typePayment == 1
            ? PaymentCreditcard(null)
            : PaymentBoletoBancario());
  }

}
