import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/screens/academy_home_screen.dart';
import 'package:startgym/screens/home_screen.dart';
import 'package:startgym/screens/login_screen.dart';
import 'package:startgym/screens/verify_email_screen.dart';
import 'package:startgym/utils/listenConnectivity.dart';

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

    ListenConnectivity.startListen(context);

    widget.auth.currentUser().then((userId) {
      setState(() {
        authStatus =
            userId != null ? AuthStatus.signedIn : AuthStatus.notSignedIn;
      });
    });

    /*OneSignal.shared.init("7e68d92a-4e88-44f8-a75c-c988f0ab7e75", iOSSettings: {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.inAppLaunchUrl: true
    });*/
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return new LoginScreen();
      case AuthStatus.signedIn:
        return FutureBuilder<List<dynamic>>(
          future: Future.wait(
            [
              UserModel.of(context).auth.currentUser(),
              UserModel.of(context).loadCurrentUser(),
            ],
          ),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState.index == ConnectionState.none.index ||
                snapshot.connectionState.index ==
                    ConnectionState.waiting.index) {
              return Container();
            } else {
              if (snapshot.data.elementAt(0).isEmailVerified) {
                
                UserModel.of(context).saveOnesignalId();

                if (UserModel.of(context).userData["userType"] == "1") {
                  return new AcademyHomeScreen();
                } else {
                  return new HomeScreen();
                }
              } else {
                return new VerifyEmailScreen();
              }
            }
          },
        );

        break;
      default:
        return Container();
    }
  }
}
