import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:startgym/screens/new_credit_card_screen.dart';
import 'package:startgym/utils/alerts.dart';

class DialogCards extends StatefulWidget {
  final List cards;

  DialogCards(this.cards);

  @override
  _DialogCardsState createState() => _DialogCardsState();
}

class _DialogCardsState extends State<DialogCards> {
  bool isCardSelected = false;
  Alerts al = new Alerts();

  @override
  Widget build(BuildContext context) {

    
    return Container();
  }
}
