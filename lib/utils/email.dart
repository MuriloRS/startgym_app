import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mailer2/mailer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:startgym/models/user_model.dart';

class Email {
  Future<dynamic> sendEmail(
      String bodyEmail, String sender, String recipient, String subject,
      {List<Attachment> attachment}) async {
    DocumentSnapshot emailConfig = await getEmailSettings();

    var options = new GmailSmtpOptions()
      ..username = emailConfig.data["username"]
      ..password = emailConfig.data["password"];
    // Note: if you have Google's "app specific passwords" enabled,
    // you need to use one of those here.

    // How you use and store passwords is up to you. Beware of storing passwords in plain.

    // Create our email transport.
    var emailTransport = new SmtpTransport(options);

    // Create our mail/envelope.
    var envelope = new Envelope()
      ..recipients.add(recipient)
      ..sender = sender
      ..subject = subject
      ..html = bodyEmail;

    if (attachment != null) {
      envelope.attachments = attachment;
    }

    // Email it.
    return emailTransport.send(envelope);
  }

  Future<DocumentSnapshot> getEmailSettings() async {
    return await Firestore.instance
        .collection("config")
        .document("generalConfig")
        .get();
  }

  Future<void> saveAndSendEmailToAcademy(
      String academyId, BuildContext context) async {
    try {
      ByteData byteData = await QrPainter(
        data: academyId,
        version: 5,
        emptyColor: Colors.white,
        color: Colors.black,
      ).toImageData(250);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);

      String body =
          "<h3>Bem-vindo ao startgym</h3><p></p> Para começar atualize seus dados básico para que os alunos tenham mais informações sobre sua academia.";

      await new Email().sendEmail(body, "murilo08inter@gmail.com",
          UserModel.of(context).userData["email"], "qr-code", attachment: [
        Attachment(file: new File('${tempDir.path}/image.png'))
      ]);
    } catch (e) {
      print(e);
    }
  }
}
