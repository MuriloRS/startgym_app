import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        backgroundColor: Colors.white,
        child: CircularProgressIndicator(
          backgroundColor: Colors.white,
          strokeWidth: 4.0,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.green[600]),
        ));
  }
}
