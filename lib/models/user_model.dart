import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:startgym/screens/academy_home_screen.dart';
import 'package:startgym/screens/home_screen.dart';
import 'package:startgym/screens/verify_email_screen.dart';

class UserModel extends Model {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUser firebaseUser;
  Map<String, dynamic> userData = Map();
  bool isLoading = false;
  String academyCheckIn;

  static UserModel of(BuildContext context) =>
      ScopedModel.of<UserModel>(context);

  @override
  void addListener(VoidCallback listener) async {
    super.addListener(listener);

    await loadCurrentUser();
  }

  //Método que faz o cadastro do usuário
  void signup(
      {@required String typeUser,
      @required Map<String, dynamic> userData,
      @required String pass,
      @required VoidCallback onSuccess,
      @required VoidCallback onFail}) {
    isLoading = true;
    notifyListeners();

    auth
        .createUserWithEmailAndPassword(
            email: userData["email"], password: pass)
        .then((user) async {
      //firebaseUser recebe o novo usuário logado
      this.firebaseUser = user;

      if (typeUser == "usuario") {
        await saveUserData(userData);
      } else if (typeUser == "academia") {
        await _saveAcademyData(userData);
      }

      onSuccess();

      isLoading = false;
      notifyListeners();
    }).catchError((err) {
      onFail();

      isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> verifyEmailExists(String email, String pass) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: pass);
      return true;
    } catch (e) {
      return false;
    }
  }

  //Salva os dados do usuário no banco
  Future<Null> saveUserData(Map<String, dynamic> userData) async {
    this.userData = userData;

    if (userData["userType"] == "0") {
      await Firestore.instance
          .collection("users")
          .document(firebaseUser.uid)
          .setData(userData);
    } else {
      await Firestore.instance
          .collection("userAcademy")
          .document(firebaseUser.uid)
          .setData(userData);
    }
  }

  Future<Null> saveUserDataFromGoogleLogin(
      Map<String, dynamic> userData) async {
    isLoading = true;
    this.userData = userData;

    await Firestore.instance
        .collection("users")
        .document(userData["id"])
        .setData(userData);

    isLoading = false;
    notifyListeners();
  }

  //Salva os dados do usuário no banco
  Future<Null> _saveAcademyData(Map<String, dynamic> userData) async {
    this.userData = userData;

    await Firestore.instance
        .collection("userAcademy")
        .document(firebaseUser.uid)
        .setData(userData);

    await Firestore.instance
        .collection("userAcademy")
        .document(firebaseUser.uid)
        .collection("academyDetail")
        .document("firstDetail")
        .setData({
      "firstImage": true,
      "optionals": {
        'Ar-condicionado': false,
        'Estacionamento': false,
        'Entrada Biométrica': false,
        'Aula de dança': false,
        'Vestiário com ducha': false,
        'Pagamento com cartão': false,
        'Cross-fit': false,
        'Refeitório': false,
      }
    });
  }

  //Método que faz o login do usuário
  void signin(
      {@required String email,
      @required String senha,
      @required BuildContext context,
      @required VoidCallback onSuccess,
      @required VoidCallback onFail}) {
    isLoading = true;
    notifyListeners();

    auth
        .signInWithEmailAndPassword(email: email, password: senha)
        .then((usuario) async {
      this.firebaseUser = usuario;

      await loadCurrentUser();

      if (this.firebaseUser.isEmailVerified) {
        if (this.userData["userType"] == "0") {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => HomeScreen()));
        } else if (this.userData["userType"] == "1") {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AcademyHomeScreen()));
        }
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => VerifyEmailScreen()));
      }

      isLoading = false;
      notifyListeners();
    }).catchError((err) {
      onFail();

      isLoading = false;

      notifyListeners();
    });
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await auth.currentUser();

    return user.sendEmailVerification();
  }

  //Envia requisição de nova senha
  void recoverPass(String email) {
    auth.sendPasswordResetEmail(email: email);
  }

  //Verifica se tem usuário logado
  bool isLoggedIn() {
    return this.firebaseUser != null;
  }

  //Faz o logout do usuário
  void signout() async {
    await auth.signOut();

    userData = Map();
    this.firebaseUser = null;
    //notifyListeners();
  }

  Future<String> currentUser() async {
    FirebaseUser user = await auth.currentUser();
    return user != null ? user.uid : null;
  }

  //Carrrega os dados do usuário logado para dentro de userData
  Future<Null> loadCurrentUser() async {
    if (this.firebaseUser == null) {
      this.firebaseUser = await auth.currentUser();
    }

    if (this.firebaseUser != null) {
      if (userData != null) {
        if (userData["name"] == null || userData.isEmpty == true) {
          DocumentSnapshot docUser;

          if (userData != null &&
              userData.isEmpty &&
              userData["userType"] != "1") {
            docUser = await Firestore.instance
                .collection("users")
                .document(firebaseUser.uid)
                .get();
          }

          if (docUser == null || docUser.data == null) {
            docUser = await Firestore.instance
                .collection("userAcademy")
                .document(firebaseUser.uid)
                .get();
          }
          this.userData = docUser.data;
        }
      }
    }

    notifyListeners();
  }

  void activeUserPlan(duration) async {
    
    this.userData["planActive"] = true;
    this.userData["planExpires"] = DateTime.now().add(Duration(days:duration));

    await saveUserData(this.userData);
  }
}
