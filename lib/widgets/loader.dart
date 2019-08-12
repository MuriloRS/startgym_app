import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  double size = 0;

  Loader({this.size});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        radius: size != 0 ? 18 : size,
        backgroundColor: Colors.transparent,
        child: CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          strokeWidth: 4.0,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.green[600]),
        ));
  }
}
