import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/screens/verify_email_screen.dart';
import 'package:startgym/utils/checkbox_terms.dart';
import 'package:startgym/utils/slideRightRoute.dart';
import 'package:startgym/widgets/loader.dart';
import 'package:startgym/widgets/logo.dart';
import 'package:startgym/utils/validations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:random_string/random_string.dart' as random;

class AcademyRegisterScreen extends StatefulWidget {
  _AcademyRegisterScreenState createState() => _AcademyRegisterScreenState();
}

class _AcademyRegisterScreenState extends State<AcademyRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey globalKey = new GlobalKey();

  final _emailController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _passController = TextEditingController();
  final _passrepController = TextEditingController();
  bool isLoading = false;
  bool isObscurePass = true;
  bool isObscurePassRep = true;
  String academyId = random.randomString(10);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
        color: Colors.black,
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              centerTitle: true,
              title: const Text(
                "CADASTRAR",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.black,
            ),
            body: ScopedModelDescendant<UserModel>(
                builder: (context, child, model) {
              if (model.isLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              return Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(20.0),
                  children: <Widget>[
                    Logo(),
                    SizedBox(height: 10.0),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Email",
                      ),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (email) {
                        //Se email não for vazio então válida o email
                        if (email.isNotEmpty) {
                          String validacao = Validations.isEmail(email);
                          if (validacao.isNotEmpty) {
                            return "Esse email é inválido.";
                          }
                        } else {
                          return "O campo email é obrigatório";
                        }
                      },
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "CNPJ",
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: false,
                      maxLength: 14,
                      controller: _cnpjController,
                      validator: (cnpj) {
                        //USADO PARA TESTE
                        cnpj = "27865757000102";

                        if (cnpj.isNotEmpty) {
                          if (cnpj.length != 14) {
                            return "O CNPJ precisa ter 14 números.";
                          }
                        }
                      },
                    ),
                    SizedBox(
                      height: 0.0,
                    ),
                    Stack(
                      alignment: const Alignment(1.0, 1.0),
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Senha",
                          ),
                          keyboardType: TextInputType.text,
                          obscureText: isObscurePass,
                          controller: _passController,
                          validator: (pass) {
                            String validacao = Validations.validPassword(
                                pass, _passrepController.text);

                            if (pass.isNotEmpty) {
                              if (validacao.isNotEmpty) {
                                return "As senhas precisam ser iguais";
                              }
                            } else {
                              return "Você precisa preencher o campo senha.";
                            }
                          },
                        ),
                        IconButton(
                          iconSize: 16,
                          icon: isObscurePass
                              ? Icon(FontAwesomeIcons.eyeSlash)
                              : Icon(FontAwesomeIcons.eye),
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
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Stack(
                      alignment: const Alignment(1.0, 1.0),
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Repetir Senha",
                          ),
                          keyboardType: TextInputType.text,
                          obscureText: isObscurePassRep,
                          controller: _passrepController,
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
                          },
                        ),
                        IconButton(
                          iconSize: 16,
                          icon: isObscurePassRep
                              ? Icon(FontAwesomeIcons.eyeSlash)
                              : Icon(FontAwesomeIcons.eye),
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
                    SizedBox(height: 10.0),
                    CheckBoxTerms(),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                        alignment: Alignment.center,
                        child: isLoading
                            ? Loader()
                            : OutlineButton(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10.0),
                                child: Text(
                                  "CADASTRAR",
                                  style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                textColor: Colors.black,
                                color: Colors.white,
                                borderSide:
                                    BorderSide(width: 2.0, color: Colors.black),
                                onPressed: () async {
                                  //Valida o formulário se estiver ok continua
                                  if (_formKey.currentState.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    //Pega os dados do cnpj da academia
                                    Map<String, dynamic> academyData =
                                        await _populateAcademyUser(
                                            _cnpjController.text);

                                    if (academyData == null) {
                                      _scaffoldKey.currentState
                                          .showSnackBar(SnackBar(
                                        content: Text("Tente novamente"),
                                        backgroundColor: Colors.red,
                                      ));

                                      setState(() {
                                        isLoading = false;
                                      });

                                      return;
                                    }

                                    //Verifica se o email já existe
                                    bool existEmail = false;

                                    //Verifica se o email digitado já está sendo usado
                                    existEmail = await model.verifyEmailExists(
                                        academyData["email"],
                                        _passController.text);

                                    if (!existEmail) {
                                      model.signup(
                                          typeUser: "academia",
                                          pass: _passController.text,
                                          userData: academyData,
                                          onFail: _onFail,
                                          onSuccess: _onSuccess);

                                      setState(() {
                                        isLoading = false;
                                      });
                                    } else {
                                      _onFail(
                                          errMessage:
                                              "O email digitado já está sendo usado por outra pessoa.");
                                    }

                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
                              )),
                  ],
                ),
              );
            })));
  }

  void _onSuccess() async {

    await UserModel.of(context).loadCurrentUser();
    

    Navigator.pushReplacement(
      context,
      SlideRightRoute(widget: VerifyEmailScreen()),
    );
  }

  

  void _onFail({String errMessage}) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(errMessage != null
          ? errMessage
          : "Falha ao criar o usuário academia."),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 5),
    ));
  }

  Future<Map<String, double>> searchLatitudeLongitudeFromAddress(
      String parametroApi, String numero) async {
    Map<String, dynamic> resultApi;
    String api = "https://maps.googleapis.com/maps/api/geocode/json?" +
        "address=$parametroApi" +
        "&components=country:BR" +
        "&key=AIzaSyDDokdI8Bx239pPAoFcqPjdPyOe2-lArsw";

    try {
      Response response = await Dio().get(api);

      Future.delayed(Duration(milliseconds: 2));

      resultApi = response.data;

      return {
        "latitude": List.castFrom(resultApi['results']).elementAt(0)['geometry']
            ['location']['lat'],
        "longitude": List.castFrom(resultApi['results'])
            .elementAt(0)['geometry']['location']['lng']
      };
    } catch (e) {
      print(e);

      return null;
    }
  }

  Future<Map<String, dynamic>> _populateAcademyUser(String cnpj) async {
    Map<String, dynamic> resultado;

    await http.get('https://www.receitaws.com.br/v1/cnpj/$cnpj').then((result) {
      resultado = json.decode(result.body);
    });

    if (resultado["status"] != "OK") {
      return Map();
    } else {
      String paramApi = resultado['logradouro'].toString() +
          " " +
          resultado['numero'].toString() +
          ", " +
          resultado['municipio'] +
          ", " +
          resultado['cep'];
      Map<String, dynamic> latLng;

      latLng = await searchLatitudeLongitudeFromAddress(
          paramApi, resultado['numero']);

      if (latLng == null) {
        return null;
      }

      return {
        "nome": resultado["nome"],
        "telefone": resultado["telefone"],
        "bairro": resultado["bairro"],
        "logradouro": resultado["logradouro"],
        "numero": resultado["numero"],
        "cep": resultado["cep"],
        "municipio": resultado["municipio"],
        "fantasia": resultado["fantasia"],
        "cpnj": resultado["cnpj"],
        "email": _emailController.text,
        "latitude": latLng['latitude'],
        "longitude": latLng['longitude'],
        "academyCheckInCode": academyId,
        "academyValueSack": 0,
        "detailSaved": false,
        "firstLogin":false,
        "userType": "1",
      };
    }
  }
}
