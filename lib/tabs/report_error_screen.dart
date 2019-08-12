import 'package:flutter/material.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/utils/email.dart';
import 'package:startgym/widgets/loader.dart';
import 'package:startgym/widgets/sliver_appbar.dart';

class ReportErrorScreen extends StatefulWidget {
  _ReportErrorScreenState createState() => _ReportErrorScreenState();
}

class _ReportErrorScreenState extends State<ReportErrorScreen> {
  @override
  void initState() {
    super.initState();
  }

  TextEditingController msgController = new TextEditingController();

  bool isLoading = false;
  bool isresultEmail = false;
  String resultEmail = "";
  Color resultEmailColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    ;

    return CustomScrollView(
        physics: NeverScrollableScrollPhysics(),
        slivers: <Widget>[
          CustomSliverAppbar(),
          SliverFillRemaining(
            child:  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Encontrou algum erro, tem alguma sugestão para fazer ou quer conversar com nossa equipe sobre algo? Mande uma mensagem para nós.",
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[800]),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        TextField(
                          maxLines: 4,
                          controller: msgController,
                          keyboardType: TextInputType.multiline,
                          maxLength: 4000,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0)),
                              isDense: true),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        !isLoading
                            ? RaisedButton(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.send,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Text(
                                      "Enviar",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 24),
                                    )
                                  ],
                                ),
                                color: Theme.of(context).colorScheme.primary,
                                onPressed: () {
                                  if (msgController.text != '') {
                                    _enviaEmail(msgController.text, context);
                                  }
                                },
                              )
                            : Loader(),
                      ],
                    )),
          ),
        ]);
  }

  void _enviaEmail(msg, BuildContext context) {
    setState(() {
      isLoading = true;
    });

    String bodyEmail =
        '<h4>Usuário: ${UserModel.of(context).userData['name']}</h4>' +
            '<h4>Email: ${UserModel.of(context).userData['email']} </h4>'
                '<p style="font-size:18px;">Mensagem: $msg</p>';
    String sender = UserModel.of(context).userData["email"];
    String subject = 'Contato Usuário';

    // Email it.
    new Email()
        .sendEmail(
            bodyEmail, sender, UserModel.of(context).userData["email"], subject)
        .then((envelope) {
      resultEmail =
          "A mensagem foi enviada com sucesso! Em breve te responderemos pelo seu email.";
      resultEmailColor = Colors.green;

      setState(() {
        isLoading = false;
      });

      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          resultEmail,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 5),
      ));
    }).catchError((e) {
      resultEmail = "Algo deu errado $e";
      resultEmailColor = Colors.red;

      setState(() {
        isLoading = false;
      });

      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          resultEmail,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 5),
      ));
    });

    msgController.clear();

    FocusScope.of(context).requestFocus(new FocusNode());
  }
}
