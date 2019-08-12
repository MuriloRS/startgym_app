import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/screens/academy_home_screen.dart';
import 'package:startgym/screens/home_screen.dart';
import 'package:startgym/screens/recover_pass.dart';
import 'package:startgym/screens/register_screen.dart';
import 'package:startgym/utils/email.dart';
import 'package:startgym/utils/slideRightRoute.dart';
import 'package:startgym/widgets/loader.dart';
import 'package:startgym/widgets/logo.dart';
import 'package:startgym/utils/validations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isObscurePass = true;
  var focusNode = new FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white10,
        padding: EdgeInsets.fromLTRB(0, 25.0, 0, 0),
        child: Scaffold(
            key: _scaffoldKey,
            appBar: null,
            body: ScopedModelDescendant<UserModel>(
                builder: (context, child, model) {
              if (model.isLoading) {
                return Center(
                  child: Container(
                    child: Loader(),
                  ),
                );
              } else {
                return Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.all(16.0),
                    children: <Widget>[
                      Logo(),
                      SizedBox(height: 10.0),
                      Text(
                        "startgym",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        focusNode: focusNode,
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (email) {
                          if (email.isEmpty) {
                            return "Preencha o email";
                          }

                          String validationEmail = Validations.isEmail(email);

                          if (validationEmail.isNotEmpty) {
                            return validationEmail;
                          }

                          return null;
                        },
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Stack(
                          alignment: const Alignment(1.0, 1.0),
                          children: <Widget>[
                            TextFormField(
                              controller: _passController,
                              decoration: InputDecoration(
                                labelText: "Senha",
                              ),
                              keyboardType: TextInputType.text,
                              obscureText: isObscurePass,
                              validator: (password) {
                                if (password.isEmpty) {
                                  return "Preencha o campo senha";
                                }

                                if (password.length < 6) {
                                  return "A senha precisa ter no mínimo 6 caracteres";
                                }

                                return null;
                              },
                            ),
                            IconButton(
                              iconSize: 16,
                              icon: isObscurePass
                                  ? Icon(FontAwesomeIcons.eye)
                                  : Icon(FontAwesomeIcons.eyeSlash),
                              onPressed: () {
                                setState(() {
                                  if (isObscurePass) {
                                    isObscurePass = false;
                                  } else {
                                    isObscurePass = true;
                                  }
                                });
                              },
                            )
                          ]),
                      SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: _isLoading
                            ? Loader()
                            : RaisedButton(
                                color: Colors.black,
                                textColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30.0, vertical: 12.0),
                                child: Text(
                                  "ENTRAR",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState.validate()) {
                                    setState(() {
                                      _isLoading = true;
                                    });

                                    model
                                        .verifyEmailExists(
                                            _emailController.text,
                                            _passController.text)
                                        .then((result) {
                                      if (result) {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());

                                        model.signin(
                                            email: _emailController.text,
                                            senha: _passController.text,
                                            context: context,
                                            onSuccess: _onSuccess,
                                            onFail: _onFail);
                                      } else {
                                        _onFail(
                                            errMessage:
                                                "O email ou a senha estão incorretos.");
                                      }
                                    });

                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }),
                      ),
                      FlatButton(
                        child: const Text(
                          "Esqueceu sua senha?",
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 14.0,
                              color: Colors.black87),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => RecoverPass()));
                        },
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                      ),
                      SizedBox(height: 15.0),
                      Container(
                        child: FlatButton(
                          child: Text(
                            "Entrar com Facebook",
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                          onPressed: () async {
                            FirebaseUser user = await initiateFacebookLogin();

                            Map<String, dynamic> userData = {
                              "name": user.displayName,
                              "email": user.email,
                              "userType": "0",
                              "lastCheckin": "",
                              "planActive": false,
                              "planExpires": "",
                              "cards": [],
                              "idCard": ""
                            };

                            model.firebaseUser = user;
                            model.loadCurrentUser();

                            model.saveUserDataFromGoogleLogin(
                                userData, user.uid);

                            _onSuccess();
                          },
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 12.0),
                          color: Color.fromRGBO(59, 89, 152, 1),
                          textColor: Colors.white,
                        ),
                        width: 220.0,
                      ),
                      SizedBox(height: 15.0),
                      Container(
                        child: FlatButton(
                          child: Text(
                            "Entrar com Google",
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                          onPressed: () {
                            _handleSignIn().then((FirebaseUser user) {
                              Map<String, dynamic> userData = {
                                "name": user.displayName,
                                "email": user.email,
                                "userType": "0",
                                "lastCheckin": "",
                                "planActive": false,
                                "planExpires": "",
                                "cards": [],
                                "idCard": ""
                              };

                              model.firebaseUser = user;
                              model.loadCurrentUser();

                              model.saveUserDataFromGoogleLogin(
                                  userData, user.uid);

                              _onSuccess();
                            }).catchError((e) => print(e));
                          },
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 12.0),
                          color: Color.fromRGBO(223, 74, 50, 1.0),
                          textColor: Colors.white,
                        ),
                        width: 220.0,
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              "Não possui uma conta?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14.0, color: Colors.grey[600]),
                            ),
                            FlatButton(
                              child: const Text(
                                "Cadastre-se",
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 16.0,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  SlideRightRoute(widget: RegisterScreen()),
                                );
                              },
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }
            })));
  }

  void _onSuccess() {
    Map dadosUsuario = UserModel.of(context).userData;

    if (dadosUsuario["userType"] == "0") {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()));
    } else if (dadosUsuario["userType"] == "1") {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AcademyHomeScreen()));
    }
  }

  void _onFail({String errMessage}) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(errMessage != "" ? errMessage : "Falha ao fazer o login."),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 4),
    ));
  }

  Future<FirebaseUser> _handleSignIn() async {
    FirebaseUser user;
    try {
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      user = await _auth.signInWithCredential(credential);
    } catch (e) {
      
    }

    return user;
  }

  Future<FirebaseUser> initiateFacebookLogin() async {
    var facebookLogin = FacebookLogin();
    var facebookLoginResult =
        await facebookLogin.logInWithReadPermissions(['email']);

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");

        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");

        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");

        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${facebookLoginResult.accessToken.token}');

        dynamic result = json.decode(graphResponse.body);

        final AuthCredential credential = FacebookAuthProvider.getCredential(
          accessToken: facebookLoginResult.accessToken.token,
        );

        FirebaseUser user =
            await UserModel.of(context).auth.signInWithCredential(credential);

        return user;
        break;
    }

    return null;
  }

}
