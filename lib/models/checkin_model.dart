import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class CheckinModel extends Model {
  static CheckinModel of(BuildContext context) =>
      ScopedModel.of<CheckinModel>(context);

  @override
  void addListener(VoidCallback listener) async {
    super.addListener(listener);
  }

  Future<void> newCheckin(
      {@required String academyId,
      @required String client,
      @required String clientName}) async {
    //ADICIONA O CHECKIN PARA A ACADEMIA
    await Firestore.instance
        .collection("userAcademy")
        .document(academyId)
        .collection("checkins")
        .add({
      "clientId": client,
      "time": Timestamp.now(),
      "viewed": false,
      "name": clientName
    });
  }

  /*
   * VERIFICA SE O USUÁRIO POSSUI A COLEÇÃO NUMBERCHECKINS QUE ARMAZENA
   * QUANTOS E ONDE O USUÁRIO FEZ CHECK IN
   * SE JÁ HOUVER A COLECAO RETORNA O DOCUMENTO QUE TEM O NÚMERO DE CHECKINS DA ACADEMIA ATUAL
   */
  Future<dynamic> _verifyCheckinsAcademy(academyId, clientId) async {
    QuerySnapshot snapshot = await Firestore.instance
        .collection("userAcademy")
        .document(academyId)
        .collection("numberCheckins")
        .where("clientId", isEqualTo: clientId)
        .getDocuments();

    if (snapshot.documents.length > 0) {
      return snapshot.documents.elementAt(0).data["nCheckin"];
    } else {
      return -1;
    }
  }

  Future<void> updateCheckinsAcademy(
      {@required String academyId, @required String clientId, }) async {
    dynamic nCheckins = await _verifyCheckinsAcademy(academyId, clientId);

    int newNcheckins = 0;
    if (nCheckins is int) {
      if (int.parse(nCheckins.toString()) > -1) {
        newNcheckins++;

        //PEGA O ID DO DOCUMENTO PARA FAZER UPDATE DO NÚMERO DE CHECKINS DESSA ACADEMIA
        QuerySnapshot snapshot = await Firestore.instance
            .collection("userAcademy")
            .document(academyId)
            .collection("numberCheckins")
            .where("clientId", isEqualTo: clientId)
            .getDocuments();

        newNcheckins = snapshot.documents.elementAt(0).data["nCheckin"] + 1;

        //ATUALIZA O NÚMERO DE CHECKINS QUE UM USUÁRIO FEZ EM UMA ACADEMIA
        await Firestore.instance
            .collection("userAcademy")
            .document(academyId)
            .collection("numberCheckins")
            .document(snapshot.documents.elementAt(0).documentID)
            .updateData({'nCheckin': newNcheckins, 'clientId': clientId});
      } else {
        newNcheckins = 1;

        //Adiciona documento para controlar o número de checkins em uma determinada academia
        await Firestore.instance
            .collection("userAcademy")
            .document(academyId)
            .collection("numberCheckins")
            .add({
          'clientId': clientId,
          'nCheckin': newNcheckins,
          
        });
      }
    }
  }
}
