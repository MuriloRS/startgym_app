import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/screens/academy_register_screen.dart';
import 'package:startgym/screens/verify_email_screen.dart';
import 'package:startgym/utils/slideRightRoute.dart';
import 'package:startgym/widgets/loader.dart';
import 'package:startgym/widgets/logo.dart';
import 'package:startgym/utils/validations.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterScreen extends StatefulWidget {
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _passSecController = TextEditingController();
  bool _isLoading = false;
  bool isObscurePass = true;
  bool isObscurePassRep = true;
  bool checkVal = false;

  var focusNode = new FocusNode();

  Widget buttonRegisterChild = Text(
    "CADASTRAR",
    style: TextStyle(
        fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "CADASTRAR",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.black,
        ),
        body:
            ScopedModelDescendant<UserModel>(builder: (context, child, model) {
          if (model.isLoading) {
            return Center(child:Loader());
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(20.0),
              children: <Widget>[
                Logo(),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Nome Completo*",
                  ),
                  keyboardType: TextInputType.emailAddress,
                  focusNode: focusNode,
                  validator: (name) {
                    if (name.length < 5 || name.isEmpty) {
                      return name.isEmpty
                          ? "Você precisa preencher o campo nome \n"
                          : "O nome precisa ter no mínimo 5 caracteres.\n";
                    }

                    return null;
                  },
                ),
                SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email*",
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (email) {
                    if (email.isNotEmpty) {
                      String validacao = Validations.isEmail(email);
                      if (validacao.isNotEmpty) {
                        return "Esse email é inválido.";
                      }
                    } else {
                      return "O campo email é obrigatório";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 10.0,
                ),
                Stack(alignment: const Alignment(1.0, 1.0), children: [
                  TextFormField(
                    controller: _passController,
                    decoration: InputDecoration(
                      labelText: "Senha*",
                    ),
                    validator: (pass) {
                      String validacao = Validations.validPassword(
                          pass, _passSecController.text);

                      if (pass.isNotEmpty) {
                        if (validacao.isNotEmpty) {
                          return "As senhas precisam ser iguais";
                        }
                      } else {
                        return "Você precisa preencher o campo senha.";
                      }

                      return null;
                    },
                    keyboardType: TextInputType.text,
                    obscureText: this.isObscurePass,
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
                Stack(
                  alignment: const Alignment(1.0, 1.0),
                  children: <Widget>[
                    TextFormField(
                      controller: _passSecController,
                      decoration: InputDecoration(
                        labelText: "Repetir Senha*",
                      ),
                      validator: (pass) {
                        String validacao = Validations.validPassword(
                            pass, _passController.text);

                        if (pass.isNotEmpty) {
                          if (validacao.isNotEmpty) {
                            validacao = validacao.replaceFirst(
                                "senha", "repetir senha");

                            return "As senhas precisam ser iguais";
                          }
                        } else {
                          return "Você precisa preencher o campo repetir senha";
                        }

                        return null;
                      },
                      keyboardType: TextInputType.text,
                      obscureText: isObscurePassRep,
                    ),
                    IconButton(
                      iconSize: 16,
                      icon: isObscurePassRep
                          ? Icon(FontAwesomeIcons.eye)
                          : Icon(FontAwesomeIcons.eyeSlash),
                      onPressed: () {
                        setState(() {
                          if (isObscurePassRep) {
                            isObscurePassRep = false;
                          } else {
                            isObscurePassRep = true;
                          }
                        });
                      },
                    )
                  ],
                ),
                SizedBox(
                  height: 15.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      child: Text("Termos e política de privacidade",
                          style: TextStyle(
                              color: Colors.grey[600],
                              decoration: TextDecoration.underline)),
                      onPressed: _showTermsAndPolitics,
                    ),
                    Checkbox(
                      value: checkVal,
                      onChanged: (bool value) {
                        setState(() {
                          checkVal = value;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 25.0,
                ),
                Container(
                    alignment: Alignment.center,
                    child: _isLoading
                        ? Loader()
                        : FlatButton(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            child: this.buttonRegisterChild,
                            color: Theme.of(context)
                                .buttonTheme
                                .colorScheme
                                .primary,
                            textColor: Colors.white,
                            onPressed: () {
                              //FAZ A VALIDAÇÃO DO FORMULÁRIO SE FOR TRUE OS CAMPOS ESTÃO CORRETOS
                              if (_formKey.currentState.validate()) {
                                setState(() {
                                  _isLoading = true;
                                });

                                if (!checkVal) {
                                  _scaffoldKey.currentState
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        "Você precisa concordar com os termos e condições"),
                                    backgroundColor: Colors.red,
                                  ));

                                  setState(() {
                                    _isLoading = false;
                                  });

                                  return;
                                }

                                bool existEmail = false;

                                //Verifica se o email digitado já está sendo usado
                                model
                                    .verifyEmailExists(_emailController.text,
                                        _passController.text)
                                    .then((bool value) {
                                  existEmail = value;
                                }).catchError((err) {
                                  print(err);
                                });

                                if (!existEmail) {
                                  //Monta o map do usuário
                                  Map<String, dynamic> userData = {
                                    "name": _nameController.text,
                                    "email": _emailController.text,
                                    "planActive": false,
                                    "lastCheckin": null,
                                    "userType": "0",
                                    "idCard": "",
                                    "cards": [],
                                  };

                                  model.signup(
                                    typeUser: "usuario",
                                    pass: _passController.text,
                                    userData: userData,
                                    onSuccess: _onSuccess,
                                    onFail: _onFail,
                                  );

                                  setState(() {
                                    _isLoading = true;
                                  });
                                } else {
                                  _onFail(
                                      errMessage:
                                          "Já existe um usuário cadastrado com esse email");
                                }
                              }
                            },
                          )),
                FlatButton(
                  child: Text("Registrar Academia",
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 15.0,
                          color: Color.fromRGBO(220, 0, 0, 0.6))),
                  onPressed: () {
                    Navigator.push(
                      context,
                      SlideRightRoute(widget: AcademyRegisterScreen()),
                    );
                  },
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                ),
              ],
            ),
          );
        }));
  }

  void _onSuccess() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Usuário criado com sucesso!"),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 4),
    ));

    Navigator.push(
      context,
      SlideRightRoute(widget: VerifyEmailScreen()),
    );
  }

  void _onFail({String errMessage}) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(errMessage != null ?? "Falha ao criar o usuário."),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }

  void _showTermsAndPolitics() async {
    const url = 'https://startgymappbr.wordpress.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
