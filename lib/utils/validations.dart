import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class Validations extends Model {
  static String validationEmailPassword(
      TextEditingController email, TextEditingController password) {
    String mensagemRetorno = "";

    return mensagemRetorno;
  }

  static String validPassword(String password1, String password2) {
    String message = "";

    if (password1 == "" || password2 == "") {
      message = "Você precisa preecher o campo senha";

      return message;
    }
    if (password1 != password2) {
      message = "As senhas precisam ser iguais";

      return message;
    }

    if (password1.length < 6 || password2.length < 6) {
      message = "o campo senha precisa ter no mínimo 6 caracteres";

      return message;
    }

    return message;
  }

  static String isEmail(String em) {
    String message = "";
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    if (!regExp.hasMatch(em)) {
      message = "Esse e-mail não é válido";
    }

    return message;
  }

  static dynamic validCnpj(String cnpj) {
    //String api = "https://www.receitaws.com.br/v1/cnpj/$cnpj";

    return null;
  }


}
