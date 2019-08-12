import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/screens/academy_home_screen.dart';
import 'package:startgym/screens/home_screen.dart';
import 'package:startgym/widgets/loader.dart';
import 'package:startgym/widgets/logo.dart';

class VerifyEmailScreen extends StatefulWidget {
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final StreamController stream = new StreamController();

  @override
  void initState() {
    super.initState();

    stream.stream.listen((state) {
      if (state) {
        _redirectUserToHomeScreen();

        stream.sink.close();
      }
    });
  }

  @override
  void dispose() {
    stream.sink.close();
    stream.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (UserModel.of(context).firebaseUser.isEmailVerified) {
      _redirectUserToHomeScreen();
    }

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          actions: <Widget>[Logo()],
        ),
        body: FutureBuilder(
            future: _sendEmailVerification(context),
            builder: (context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState.index ==
                      ConnectionState.done.index ||
                  snapshot.connectionState.index ==
                      ConnectionState.active.index) {
                return Container(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Te enviamos um e-mail para você confirmar a sua conta",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CupertinoButton(
                          color: Colors.green,
                        
                            child: Text("Já confirmei minha conta",
                                style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              _reloadFirebaseUser()
                                  .then((bool isEmailVerified) {
                                if (isEmailVerified) {
                                  stream.sink.add(true);
                                } else {
                                  _scaffoldKey.currentState
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                      "Você ainda não verificou seu email.",
                                      style: TextStyle(color: Colors.grey[800]),
                                    ),
                                    backgroundColor: Colors.white,
                                    action: SnackBarAction(
                                      label: "Reenviar confirmação",
                                      textColor: Theme.of(context).accentColor,
                                      onPressed: () {
                                        _sendEmailVerification(context);
                                      },
                                    ),
                                  ));
                                }
                              });
                            }),
                        CupertinoButton(
                          
                          child: Text(
                            "Não recebi o email",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          color: Colors.transparent,
                          onPressed: () async {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text(
                                  "Te enviamos um email de confirmação de conta."),
                              backgroundColor: Theme.of(context).buttonColor,
                              duration: Duration(seconds: 5),
                            ));

                            await _sendEmailVerification(context);
                          },
                        ),
                      ],
                    )
                  ],
                ));
              } else {
                return Center(child: Loader());
              }
            }));
  }

  Future<bool> _reloadFirebaseUser() async {
    FirebaseUser user = await UserModel.of(context).auth.currentUser();

    await user.reload();

    user = await UserModel.of(context).auth.currentUser();

    return user.isEmailVerified;
  }

  Future<void> _sendEmailVerification(BuildContext context) async {
    await UserModel.of(context).sendEmailVerification();

    await UserModel.of(context).firebaseUser.reload();
  }

  void _redirectUserToHomeScreen() {
    if (UserModel.of(context).userData["userType"] == "0") {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()));
    } else if (UserModel.of(context).userData["userType"] == "1") {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AcademyHomeScreen()));
    }
  }
}
