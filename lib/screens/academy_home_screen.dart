import 'package:flutter/material.dart';
import 'package:startgym/tabs/academy_account_tab.dart';
import 'package:startgym/tabs/academy_detail_tab.dart';
import 'package:startgym/tabs/academy_home_tab.dart';
import 'package:startgym/tabs/academy_statistic_tab.dart';
import 'package:startgym/tabs/report_error_screen.dart';
import 'package:startgym/widgets/academy_drawer.dart';

class AcademyHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _pageController = PageController();

    

    return Container(
      color: Colors.white,
      child: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          Scaffold(
            body: AcademyHomeTab(_pageController),
            drawer: AcademyDrawer(_pageController),
          ),
          Scaffold(
            body: AcademyDetailTab(),
            drawer: AcademyDrawer(_pageController),
          ),
          Scaffold(
            body: ReportErrorScreen(),
            drawer: AcademyDrawer(_pageController),
          ),
          Scaffold(
            body: AcademyStatisticTab(),
            drawer: AcademyDrawer(_pageController),
          ),
          Scaffold(
            body: AcademyAccountTab(),
            drawer: AcademyDrawer(_pageController),
          ),
        ],
      ),
    );
  }
}
