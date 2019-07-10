import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      foregroundColor: Colors.black,
      backgroundColor: Colors.black,
      radius: 24.0,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Image.asset("images/logo.png"),
      ),
    );
  }
}
