import "package:flutter/material.dart";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/screens/login_screen.dart';
import 'package:startgym/tiles/drawer_tile.dart';
import 'package:flutter/cupertino.dart';

class CustomDrawer extends StatelessWidget {
  final PageController pageController;

  CustomDrawer(this.pageController);

  @override
  Widget build(BuildContext context) {
    bool isPlanAtive = false;

    return Drawer(child:
        ScopedModelDescendant<UserModel>(builder: (contex, child, model) {
      isPlanAtive = model.isLoggedIn() && model.userData["planActive"];

      return Column(
        children: <Widget>[
          Container(
              color: Colors.black,
              height: 200.0,
              width: double.infinity,
              padding:
                  EdgeInsets.only(right: 25, left: 25, top: 25, bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "startgym",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 38.0,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30.0),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5,vertical: 3),
                    color: Theme.of(context).colorScheme.primary,
                      child: !isPlanAtive
                          ? Text(
                              "Nenhum plano ativo",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15),
                            )
                          : Text(
                              "Plano ativo até: ${model.userData['planExpiration']}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15),
                            )),
                ],
              )),
          Divider(
            height: 1,
            color: Colors.grey[400],
          ),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child: Column(
              children: <Widget>[
                DrawerTile(Icons.home, "Início", pageController, 0),
                DrawerTile(Icons.credit_card, "Planos", pageController, 1),
                DrawerTile(Icons.email, "Contato", pageController, 2),
                DrawerTile(Icons.send, "Enviar Convite", pageController, 3),
                DrawerTile(Icons.account_circle, "Conta", pageController, 4),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomRight,
              child: FlatButton(
                child: Text(
                  "Sair",
                  style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.underline),
                ),
                onPressed: () {
                  model.signout();

                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
              ),
            ),
          )
        ],
      );
    }));
  }
}
