import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/screens/login_screen.dart';
import 'package:startgym/tiles/drawer_tile.dart';
import 'package:startgym/widgets/loader.dart';

class AcademyDrawer extends StatelessWidget {
  final PageController pageController;

  AcademyDrawer(this.pageController);

  @override
  Widget build(BuildContext context) {
    return Drawer(child:
        ScopedModelDescendant<UserModel>(builder: (contex, child, model) {
      String nomeAcademia = model.isLoggedIn() ? model.userData["name"] : "";
      nomeAcademia = nomeAcademia != ""
          ? nomeAcademia.substring(0, nomeAcademia.length)
          : "";

      return model.firebaseUser != null
          ? Column(
              children: <Widget>[
                Container(
                    color: Colors.black,
                    height: 160.0,
                    padding: EdgeInsets.symmetric(horizontal: 10),
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
                        SizedBox(height: 25.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              nomeAcademia,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Color.fromRGBO(220, 220, 220, 1)),
                              maxLines: 3,
                              softWrap: true,
                            ),
                          ],
                        )
                      ],
                    )),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  child: Column(
                    children: <Widget>[
                      DrawerTile(
                          FontAwesomeIcons.home, "Início", pageController, 0),
                      DrawerTile(
                          FontAwesomeIcons.list, "Detalhes", pageController, 1),
                      DrawerTile(Icons.email, "Contato", pageController, 2),
                      DrawerTile(FontAwesomeIcons.cogs, "Estatísticas",
                          pageController, 3),
                      DrawerTile(FontAwesomeIcons.userCircle, "Conta",
                          pageController, 4),
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
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => LoginScreen()));
                      },
                    ),
                  ),
                )
              ],
            )
          : Loader();
    }));
  }
}
