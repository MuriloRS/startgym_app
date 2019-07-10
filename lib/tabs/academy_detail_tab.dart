import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:startgym/models/user_model.dart';
import 'package:startgym/utils/alerts.dart';
import 'package:startgym/widgets/loader.dart';
import 'package:startgym/widgets/modal_loader.dart';
import 'package:startgym/widgets/sliver_appbar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class AcademyDetailTab extends StatefulWidget {
  _AcademyDetailTabState createState() => _AcademyDetailTabState();
}

class _AcademyDetailTabState extends State<AcademyDetailTab> {
  List<Widget> listaImagens = [Image.asset("images/empty-photo.jpg")];
  bool isFirstImage = true;

  Map<String, bool> academyOptionals = {
    'Ar-condicionado': false,
    'Estacionamento': false,
    'Entrada Biométrica': false,
    'Aula de dança': false,
    'Vestiário com ducha': false,
    'Pagamento com cartão': false,
    'Cross-fit': false,
    'Refeitório': false,
  };

  TextStyle styleHorario = TextStyle(fontSize: 18, color: Colors.grey[700]);
  TextStyle styleChecklist = TextStyle(fontSize: 18, color: Colors.grey[700]);

  TextEditingController txtEndereco = new TextEditingController();
  TextEditingController txtEmail = new TextEditingController();
  TextEditingController txtCelular = new TextEditingController();

  TextEditingController txtHoraSemana = new TextEditingController();
  TextEditingController txtHoraSabado = new TextEditingController();
  TextEditingController txtHoraDomingo = new TextEditingController();
  TextEditingController txtHoraFeriado = new TextEditingController();
  TextEditingController txtObservacao = new TextEditingController();

  Alerts alerts = new Alerts();

  bool closeCard = false;
  bool isSavingData = false;
  bool isLoadingCarousel = false;
  int quantImages = 0;

  Map<String, dynamic> dataAcademyDetail;

  @override
  void initState() {
    super.initState();

    setState(() {
      isLoadingCarousel = true;
    });

    this.quantImages = searchAcademyImagesDetails();

    setState(() {
      isLoadingCarousel = false;
    });
  }

  void searchAcademyDetail() async {
    Firestore.instance
        .collection("userAcademy")
        .document(UserModel.of(context).firebaseUser.uid)
        .collection("details")
        .document("firstDetail")
        .get()
        .then((snapshot) {
      dataAcademyDetail = snapshot.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isSavingData
        ? ModalLoader()
        : CustomScrollView(
            slivers: <Widget>[
              CustomSliverAppbar(),
              SliverToBoxAdapter(
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          this.dataAcademyDetail != null &&
                                  this.dataAcademyDetail['firstImage'] &&
                                  closeCard
                              ? Card(
                                  elevation: 2,
                                  child: Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            "Os dados abaixo serão mostrados para os usuários que quiserem fazer checkin na sua academia.",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          FlatButton(
                                            color: Colors.grey[300],
                                            padding: EdgeInsets.all(0.0),
                                            textColor: Colors.black87,
                                            child: Text(
                                              "OK",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                closeCard = true;
                                              });
                                            },
                                          ),
                                        ],
                                      )))
                              : Container(),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                              "Imagens (" +
                                  (this.listaImagens.length > 0
                                      ? this.listaImagens.length.toString()
                                      : "0") +
                                  "/10)",
                              style: Theme.of(context).textTheme.subtitle,
                              textAlign: TextAlign.left),
                          !isLoadingCarousel
                              ? Container(
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 5,
                                      ),
                                      listaImagens.length == 0
                                          ? Image.asset(
                                              "images/empty-photo.jpg",
                                              height: 230,
                                            )
                                          : new CarouselSlider(
                                              items: listaImagens,
                                              viewportFraction: 0.9,
                                              initialPage: 0,
                                              aspectRatio: 0.9,
                                              height: 230,
                                              reverse: false,
                                              autoPlay: true,
                                              autoPlayCurve:
                                                  Curves.fastOutSlowIn,
                                            ),
                                    ],
                                  ),
                                )
                              : Container(
                                  child: Center(child: Loader()), height: 230),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                              child: FloatingActionButton(
                            backgroundColor: Theme.of(context).accentColor,
                            elevation: 2,
                            child: IconButton(
                              onPressed: () {
                                this.imagePicker(true);
                              },
                              icon: Icon(
                                Icons.file_upload,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {},
                          )),
                          SizedBox(
                            height: 25,
                          ),
                          Text(
                            "Informações de Contato",
                            style: Theme.of(context).textTheme.subtitle,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 17),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Endereço",
                                    textAlign: TextAlign.start,
                                    style: styleHorario,
                                  ),
                                  TextField(
                                    controller: txtEndereco,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 5),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(0)),
                                        isDense: true),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    "Email",
                                    style: styleHorario,
                                    textAlign: TextAlign.left,
                                  ),
                                  TextField(
                                      controller: txtEmail,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 5),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(0)),
                                          isDense: true)),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    "Telefone",
                                    style: styleHorario,
                                    textAlign: TextAlign.left,
                                  ),
                                  TextField(
                                      controller: txtCelular,
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 5),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(0)),
                                        isDense: true,
                                      )),
                                ],
                              )),
                          SizedBox(
                            height: 25,
                          ),
                          Text(
                            "Horários",
                            style: Theme.of(context).textTheme.subtitle,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Container(
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Text("Dias de semana:",
                                          style: styleHorario),
                                    
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text("Sábados:", style: styleHorario),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text("Domingos:", style: styleHorario),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text("Feriados:", style: styleHorario),
                                    SizedBox(
                                      height: 3,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: 200,
                                      child: TextField(
                                        keyboardType: TextInputType.datetime,
                                        controller: txtHoraSabado,
                                        decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 3, vertical: 0),
                                            hintText:
                                                "07:00 - 12:00 13:00 - 22:00",
                                            isDense: true,
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(0))),
                                      ),
                                    ),
                                    
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Container(
                                      width: 200,
                                      child: TextField(
                                        keyboardType: TextInputType.datetime,
                                        controller: txtHoraSabado,
                                        decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 3, vertical: 0),
                                            hintText:
                                                "07:00 - 12:00 13:00 - 22:00",
                                            isDense: true,
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(0))),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Container(
                                      width: 200,
                                      child: TextField(
                                        keyboardType: TextInputType.datetime,
                                        controller: txtHoraDomingo,
                                        decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 3, vertical: 0),
                                            hintText:
                                                "07:00 - 12:00 13:00 - 22:00",
                                            isDense: true,
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(0))),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Container(
                                      width: 200,
                                      child: TextField(
                                        keyboardType: TextInputType.datetime,
                                        controller: txtHoraFeriado,
                                        decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 3, vertical: 0),
                                            hintText:
                                                "07:00 - 12:00 13:00 - 22:00",
                                            isDense: true,
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(0))),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            width: 305,
                            child: TextField(
                              controller: txtObservacao,
                              maxLines: 3,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(5),
                                  hintText: "Observações",
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0))),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Text(
                            "Opcionais",
                            style: Theme.of(context).textTheme.subtitle,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 0,
                          ),
                          Container(
                              height: 420,
                              child: ListView(
                                  physics: NeverScrollableScrollPhysics(),
                                  children:
                                      academyOptionals.keys.map((String key) {
                                    return new CheckboxListTile(
                                      dense: true,
                                      title: new Text(
                                        key,
                                        style: styleChecklist,
                                      ),
                                      value: academyOptionals[key],
                                      onChanged: (bool value) {
                                        setState(() {
                                          academyOptionals[key] = value;
                                        });
                                      },
                                    );
                                  }).toList())),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: double.infinity,
                            child: RaisedButton(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 13),
                              color: Theme.of(context).accentColor,
                              elevation: 3,
                              textColor: Colors.white,
                              child: Text("Salvar",
                                  style: TextStyle(fontSize: 22)),
                              onPressed: () {
                                try {
                                  doSaveAcademyDetail();
                                } catch (e) {
                                  alerts.buildMaterialDialog(
                                      Text(e.toString()),
                                      [
                                        FlatButton(
                                          color: Colors.transparent,
                                          child: Text(
                                            "OK",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                      context);
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          )
                        ],
                      )))
            ],
          );
  }

  Future<bool> imagePicker(isImagePickerGaleria) async {
    setState(() {
      isLoadingCarousel = true;
    });

    if (this.isFirstImage) {
      this.listaImagens.clear();
      this.isFirstImage = false;
    }

    File selectedImage;

    if (isImagePickerGaleria) {
      selectedImage = await ImagePicker.pickImage(
        source: ImageSource.gallery,
      );

      updateFirstImageDatabase();
    }

    if (selectedImage != null) {
      var downloadUrl = await saveImage(selectedImage);

      if (downloadUrl != null) {
        setState(() {
          listaImagens.add(Image.network(downloadUrl));
        });
      }

      setState(() {
        isLoadingCarousel = false;
      });

      return true;
    }

    setState(() {
      isLoadingCarousel = false;
    });

    return false;
  }

  void updateFirstImageDatabase() async {
    this.dataAcademyDetail['firstImage'] = false;

    await Firestore.instance
        .collection("userAcademy")
        .document(UserModel.of(context).firebaseUser.uid)
        .collection("academyDetail")
        .document("firstDetail")
        .setData(this.dataAcademyDetail);
  }

  void showAlert() {
    alerts.buildCupertinoDialog(
        Text("O limite máximo de fotos é 10.",
            textAlign: TextAlign.center, style: TextStyle()),
        [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("OK",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.green,
                    fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
        context);
  }

  Future<dynamic> saveImage(File selectedImage) async {
    if (this.listaImagens.isNotEmpty && listaImagens.length == 10) {
      showAlert();

      return null;
    }

    if (this.isFirstImage) {
      this.listaImagens.clear();
    }

    String basename = path.basename(selectedImage.path);

    StorageReference ref =
        FirebaseStorage.instance.ref().child("imagens").child(basename);

    StorageUploadTask uploadTask = ref.putFile(selectedImage);

    String downloadUrl =
        await (await uploadTask.onComplete).ref.getDownloadURL();

    dataAcademyDetail
        .addAll({"Images" + (listaImagens.length + 1).toString(): downloadUrl});

    Firestore.instance
        .collection("userAcademy")
        .document(UserModel.of(context).firebaseUser.uid)
        .collection("academyDetail")
        .document("firstDetail")
        .setData(this.dataAcademyDetail, merge: true);

    return downloadUrl;
  }

  int searchAcademyImagesDetails() {
    setState(() {
      isLoadingCarousel = true;
    });

    FirebaseUser docUser = UserModel.of(context).firebaseUser;
    int qtdImages = 0;

    if (docUser != null) {
      Firestore.instance
          .collection("userAcademy")
          .document(docUser.uid)
          .collection("academyDetail")
          .document("firstDetail")
          .get()
          .then((snapshot) {
        if (!snapshot.data["firstImage"]) {
          this.isFirstImage = false;
          qtdImages = snapshot.data.values.length;
          this.listaImagens.clear();

          for (var i = 1; i <= qtdImages; i++) {
            if (snapshot.data["Images" + i.toString()] != null) {
              this
                  .listaImagens
                  .add(Image.network(snapshot.data["Images" + i.toString()]));
            }
          }

          populateScreen(snapshot.data);
        }

        this.dataAcademyDetail = snapshot.data;
      });

      setState(() {
        isLoadingCarousel = false;
      });
    }

    return this.listaImagens.length;
  }

  void doSaveAcademyDetail() {
    setState(() {
      isSavingData = true;
    });

    String endereco = txtEndereco.text;
    String telefone = txtCelular.text;
    String email = txtCelular.text;
    String observacao = txtObservacao.text;
    String horarioSemana = txtHoraSemana.text;
    String horarioSabado = txtHoraSabado.text;
    String horarioDomingo = txtHoraDomingo.text;
    String horarioFeriado = txtHoraFeriado.text;

    Map<String, dynamic> dataToInsert = {
      "address": endereco,
      "phone": telefone,
      "email": email,
      "observation": observacao,
      "horaryWeek": horarioSemana,
      "horarySaturday": horarioSabado,
      "horarySunday": horarioDomingo,
      "horaryHoliday": horarioFeriado,
      "optionals": this.academyOptionals.map((s, b) => new MapEntry(s, b))
    };

    Firestore.instance
        .collection("userAcademy")
        .document(UserModel.of(context).firebaseUser.uid)
        .setData({"detailSaved": true}, merge: true).whenComplete(() {
      Firestore.instance
          .collection("userAcademy")
          .document(UserModel.of(context).firebaseUser.uid)
          .collection("academyDetail")
          .document("firstDetail")
          .setData(dataToInsert, merge: true)
          .whenComplete(() {
        Future.delayed(Duration(seconds: 1)).whenComplete(() {
          setState(() {
            isSavingData = false;
          });

          alerts.buildCupertinoDialog(
              Text(
                "Os dados foram salvos com sucesso!",
                textAlign: TextAlign.center,
              ),
              [
                CupertinoDialogAction(
                  child: Text(
                    "OK",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, color: Colors.green),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
              context);
        });
      });
    });
  }

  void populateScreen(Map<String, dynamic> data) {
    txtEndereco.text = data["address"];
    txtEmail.text = data["email"];
    txtCelular.text = data["phone"];
    txtHoraSemana.text = data["horaryWeek"];
    txtHoraSabado.text = data["horarySaturday"];
    txtHoraDomingo.text = data["horarySunday"];
    txtHoraFeriado.text = data["horaryHoliday"];
    txtObservacao.text = data["observation"];

    this.academyOptionals.clear();
    Map<String, bool> newAcademyOptionals =
        new Map<String, bool>.from(data["optionals"]);
    setState(() {
      this.academyOptionals = newAcademyOptionals;
    });
  }
}
