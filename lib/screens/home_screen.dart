import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/tabs/buy_daily_tab.dart';
import 'package:startgym/tabs/home_tab.dart';
import 'package:startgym/tabs/report_error_screen.dart';
import 'package:startgym/tabs/send_invite_tab.dart';
import 'package:startgym/widgets/custom_drawer.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _pageController = PageController();

    return ScopedModelDescendant<UserModel>(
      builder: (context, builder, model) {
        return Container(
          color: Colors.white,
          child: PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              Scaffold(
                body: HomeTab(_pageController),
                drawer: CustomDrawer(_pageController),
              ),
              Scaffold(
                body: BuyDailyTab(),
                drawer: CustomDrawer(_pageController),
              ),
              Scaffold(
                body: ReportErrorScreen(),
                drawer: CustomDrawer(_pageController),
              ),
              Scaffold(
                body: SendInviteTab(),
                drawer: CustomDrawer(_pageController),
              ),
            ],
          ),
        );
      },
    );
  }
}
