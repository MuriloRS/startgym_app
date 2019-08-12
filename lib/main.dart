import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:startgym/tabs/buy_daily_tab.dart';
import 'package:startgym/utils/root_page.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/widgets/theme_data_startgym.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<UserModel>(
        model: UserModel(),
        child: MaterialApp(
            title: 'Startgym',
            debugShowCheckedModeBanner: false,
            color: Colors.black,
            theme: ThemeDataStartgym.buildThemeData(),
            routes: {'/buyScreen': (context) => Material(child: BuyDailyTab())},
            home: RootPage()));
  }
}

class AfterSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RootPage();
  }
}
