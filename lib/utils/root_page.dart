import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/screens/academy_home_screen.dart';
import 'package:startgym/screens/home_screen.dart';
import 'package:startgym/screens/login_screen.dart';
import 'package:startgym/screens/verify_email_screen.dart';

class RootPage extends StatefulWidget {
  final UserModel auth = UserModel();

  _RootPageState createState() => _RootPageState();
}

enum AuthStatus {
  notSignedIn,
  signedIn,
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notSignedIn;
  String userType = "";

  @override
  initState() {
    super.initState();

    widget.auth.currentUser().then((userId) {
      setState(() {
        authStatus =
            userId != null ? AuthStatus.signedIn : AuthStatus.notSignedIn;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return new LoginScreen();
      case AuthStatus.signedIn:
        return FutureBuilder(
          future: UserModel.of(context).auth.currentUser(),
          builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
            if (snapshot.connectionState.index == ConnectionState.done.index ||
                snapshot.connectionState.index ==
                    ConnectionState.active.index) {
              return FutureBuilder(
                future: UserModel.of(context).loadCurrentUser(),
                builder: (context, AsyncSnapshot<void> snapshotUser) {

                  if (snapshotUser.connectionState.index ==
                          ConnectionState.done.index ||
                      snapshotUser.connectionState.index ==
                          ConnectionState.active.index) {

                    if (snapshot.data.isEmailVerified) {

                      if (UserModel.of(context).userData["userType"] == "1") {
                        return new AcademyHomeScreen();
                      } else {
                        return new HomeScreen();
                      }
                      
                    } else {
                      return new VerifyEmailScreen();
                    }

                  }
                  return Container();
                },
              );
            }
            return Container();
          },
        );

        break;
      default:
        return Container();
    }

    //return LoginScreen();
  }
}
