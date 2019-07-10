import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WarningConnectivity extends StatelessWidget {
  final VoidCallback reloadScreen;
  WarningConnectivity(this.reloadScreen);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[400],
      child: Opacity(
        opacity: 1,
        child: Center(
            child: Container(
            
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(2.0, 4.0),
                  blurRadius: 8.0,
                ),
              ]),
          width: 270,
          height: 140,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Text("Sem conexão, conecte-se a uma rede, por favor :)",
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  softWrap: true,
                  style: TextStyle(decoration: TextDecoration.none, fontSize: 16, color: Colors.black87)),
              SizedBox(
                height: 10,
              ),
              FlatButton(
                color: Colors.blue[700],
                textColor: Colors.white,
                child: Text(
                  "Atualizar",
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  reloadScreen();
                },
              )
            ],
          ),
        )),
      ),
    );
  }
}
