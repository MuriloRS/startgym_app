import 'package:flutter/material.dart';
import 'package:startgym/widgets/logo.dart';

class CustomSliverAppbar extends StatelessWidget {


  @override
  SliverAppBar build(BuildContext context) {
    return SliverAppBar(  
      floating: true,
      snap: true,
      backgroundColor: Colors.black,
      elevation: 0.0,
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: Logo(),
        )
      ],
    );
  }
}
