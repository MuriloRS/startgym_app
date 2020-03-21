import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mercado_pago/mercado_pago.dart';
import 'package:startgym/models/user_model.dart';

class Payment {
  Future<MercadoCredentials> getMercadoPagoCredentials() async {
    QuerySnapshot databaseCredentials =
        await Firestore.instance.collection("config").getDocuments();

    //PEGA AS CREDENCIAS DE SANDBOX OU PRODUÇÃO DO BANCO
    return MercadoCredentials(
        publicKey: databaseCredentials.documents
            .elementAt(0)
            .data["publicKeyProduction"],
        accessToken: databaseCredentials.documents
            .elementAt(0)
            .data["accessTokenProduction"]);
  }

  Future<MercadoObject> doPaymentCreditCard(
      {@required String idAssociatedCard,
      @required String userEmail,
      @required String userId,
      @required String userCpf,
      @required String paymentMethod,
      @required double installments,
      @required MercadoPago mp}) async {
    return await mp.createPayment(
        cardToken: idAssociatedCard,
        description: "Plano 30 dias",
        email: userEmail,
        paymentMethod: paymentMethod,
        total: 99.0,
        userId: userId,
        installment: installments,
        cpf: userCpf);
  }

  Future<String> addNewCreditCard(
      {@required Map user,
      @required String nameCard,
      @required String cpf,
      @required BuildContext context,
      @required String cardNumber,
      @required String cvc,
      @required String expirationDate,
      @required MercadoPago mp}) async {
    //A PARTIR DO NOME DO CARTÃO PEGA O PRIMEIRO E ÚLTIMO NOME DO USUÁRIO
    Map nameUser = searchFirstAndLastNameUser(nameCard);

    //CRIA UM NOVO USUÁRIO NO MERCADO PAGO
    MercadoObject userObject = await mp.newUser(
        email: user["email"],
        firstname: nameUser['firstName'],
        lastName: nameUser['lastName'],
        cpf: cpf.replaceAll(".", "").replaceFirst("-", ""));

    //SALVA ESSE NOVO USUÁRIO NO BANCO
    String newUser = await saveNewUser(userObject, context);

    String idCard;
    String idAssociatedCard;
    MercadoObject associate;

    //SE NÃO CRIA UM NOVO CARTÃO MERCADO PAGO
    MercadoObject cardObject = await mp.newCard(
        card: cardNumber.replaceAll(" ", ""),
        docType: "CPF",
        docNumber: cpf.replaceAll(".", "").replaceFirst("-", ""),
        code: cvc,
        month: int.parse(expirationDate.split("/").elementAt(0)),
        year: "20" + expirationDate.split("/").elementAt(1),
        name: nameCard.toUpperCase());

    idCard = cardObject.data["id"];

    //ASSOCIA O CARTÃO COM O USUÁRIO
    associate = await mp.associateCardWithUser(card: idCard, user: newUser);

    //E SALVA NO BANCO
    await saveCardFromUser(associate, context);

    idAssociatedCard = associate.data['id'];

    return idCard;
  }

  Future<String> saveCardFromUser(MercadoObject cardAssociated, context) async {
    UserModel userId = UserModel.of(context);

    if (cardAssociated.isSuccessful) {
      List<dynamic> cards = new List();
      cards.add(cardAssociated.data["id"]);

      DocumentSnapshot snapshot = await Firestore.instance
          .collection("users")
          .document(userId.firebaseUser.uid)
          .get();

      (snapshot.data['cards'] as List).forEach((c) {
        if (c != cardAssociated.data['id']) {
          cards.add(c);
        }
      });

      await Firestore.instance
          .collection("users")
          .document(userId.firebaseUser.uid)
          .updateData({"cards": cards});

      return cardAssociated.data["id"];
    } else {
      DocumentSnapshot user = await Firestore.instance
          .collection("users")
          .document(userId.firebaseUser.uid)
          .get();

      return user.data["cards"];
    }
  }

  Map<String, dynamic> searchFirstAndLastNameUser(String nameComplete) {
    String firstName = nameComplete.split(" ").elementAt(0);
    String lastName =
        nameComplete.split(" ").elementAt(nameComplete.split(" ").length - 1);

    return {'firstName': firstName, 'lastName': lastName};
  }

  Future<String> saveNewUser(userObject, context) async {
    String userId;

    if (userObject.isSuccessful) {
      userId = userObject.data["id"];

      await Firestore.instance
          .collection("users")
          .document(UserModel.of(context).firebaseUser.uid)
          .updateData({"idCard": userObject.data["id"]});
    } else {
      await UserModel.of(context).loadCurrentUser();

      UserModel user = UserModel.of(context);

      userId = user.userData["idCard"];
    }

    return userId;
  }
}
