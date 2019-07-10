import 'package:flutter/material.dart';

class CheckBoxTerms extends StatefulWidget {


  _CheckBoxTermsState createState() => _CheckBoxTermsState();
}

class _CheckBoxTermsState extends State<CheckBoxTerms> {
  
  bool checkValue  = false;
  
  @override
  Widget build(BuildContext context) {
    return Container();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Checkbox(
          value:checkValue,
          onChanged: (checked){
            setState(() {
                checkValue = checked;
            });
            
          }
        ),
        FlatButton(
          child: const Text("Li e aceito os termos e condições", textAlign: TextAlign.left,
                            style: TextStyle(
                              decoration: TextDecoration.underline, 
                              fontSize: 12.0, 
                              color: Colors.black,),),
          onPressed: (){
          },
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
      ],
    );
  }
}

