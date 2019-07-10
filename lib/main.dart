import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:startgym/tabs/buy_daily_tab.dart';
import 'package:startgym/utils/root_page.dart';
import 'package:startgym/models/user_model.dart';

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
            theme: ThemeData(
              fontFamily: 'Oswald', 
              textTheme: TextTheme(
                subtitle: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontSize: 22),
                title: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 26.0),
              ),
              primaryColor: Colors.black,
              accentColor: Color.fromRGBO(227, 0, 0, 1),
              buttonColor: Color.fromRGBO(25, 149, 25, 1),
              colorScheme: ColorScheme.dark(primary: Colors.blue[700]),
              backgroundColor: Colors.white,
            ),
            routes: {
              '/buyScreen': (context)=> Material(child:BuyDailyTab())
            },
            home: RootPage()));
  }
}



class AfterSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RootPage();
  }
}
