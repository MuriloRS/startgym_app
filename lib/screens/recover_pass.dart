import 'package:flutter/material.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/utils/validations.dart';

class RecoverPass extends StatefulWidget {
  _RecoverPassState createState() => _RecoverPassState();
}

class _RecoverPassState extends State<RecoverPass> {
  final _emailController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
            children: <Widget>[
              Text("Digite seu email para recuperar sua senha",
                  style: TextStyle(fontSize: 16.0),
                  textAlign: TextAlign.left,),
              SizedBox(height: 10.0,),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(hintText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 15.0),
              FlatButton(
                child: Text("Recuperar senha"),
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
                onPressed: () {
                  if (_emailController.text == "") {
                    _onFail(errMessage: "Preencha o campo email");
                    return;
                  }

                  String validationEmail =
                      Validations.isEmail(_emailController.text);

                  if (validationEmail != "") {
                    _onFail(errMessage: validationEmail);
                    return;
                  }

                  bool existsEmail = false;

                  UserModel.of(context).verifyEmailExists(_emailController.text,"").then((value){
                    existsEmail = value;
                  });

                  if(existsEmail){
                    _onFail(errMessage: "Email não encontrado no nosso banco de dados");
                    return;
                  }

                  UserModel.of(context).recoverPass(_emailController.text);

                  _emailController.text = "";

                  _onSuccess();
                },
              )
            ],
          ),
        ));
  }

  void _onSuccess() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Enviamos um email para vocês alterar a sua senha.'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 5),
    ));

    Navigator.of(context).pop();
  }

  void _onFail({String errMessage}) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(errMessage),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }
}
