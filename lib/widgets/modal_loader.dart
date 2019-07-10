import 'package:flutter/material.dart';

class ModalLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        new Opacity(
          opacity: 1,
          child: const ModalBarrier(dismissible: false, color: Colors.white),
        ),
        new Center(
          child: new CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
      ],
    );
  }
}
