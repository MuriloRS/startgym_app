import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class Localization {
  Map<String, double> currentLocation = new Map();
  Location location = Location();
  String erro;
  static Map fetchPostApi = Map();

  Future<Map<String, double>> getInitialLocation() async {
    Map<String, double> myLocation;

    try {
      myLocation = await location.getLocation();
      return myLocation;
    } catch (ex) {
      print(ex.toString());

      return null;
    }
  }

  Future<Map<String, double>> getStartingLocation() async {
    currentLocation['latitude'] = 0.0;
    currentLocation['longitude'] = 0.0;

    location.onLocationChanged().listen((actualLocation) {
      currentLocation = actualLocation;
    });

    return null;
  }

  Future<List> getLocationsAcademyNearBy() async {
    Map userLocation = await this.getInitialLocation();
    double userLatitude = userLocation['latitude'];
    double userLongitude = userLocation['longitude'];

    //API para localização de endereços através de coordenadas geográficas.
    String api =
        "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=$userLatitude,$userLongitude&";

    //Chave para usar a api
    String googleKey = "AIzaSyDDokdI8Bx239pPAoFcqPjdPyOe2-lArsw";

    double academyLatitude;
    double academyLongitude;
    api += "destinations=";

    List<Map> listCoordinates = new List();
    listCoordinates.add({'latitude': userLatitude, 'longitude': userLongitude});

    //Busca todas as academias
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection("userAcademy")
        .where("detailSaved", isEqualTo: true)
        .getDocuments();

    if (querySnapshot.documents.length > 0) {
      querySnapshot.documents.forEach((document) {
        var coordinate = Map();

        coordinate["latitude"] = document["latitude"];
        coordinate["longitude"] = document["longitude"];
        coordinate["fantasia"] = document["fantasia"];
        coordinate["points"] = document["points"];
        coordinate["name"] = document["name"];
        coordinate["documentId"] = document.documentID;
        coordinate["valueSack"] = document["academyValueSack"];
        coordinate["academyCheckInCode"] = document["academyCheckInCode"];

        listCoordinates.add(coordinate);

        academyLatitude = document['latitude'];
        academyLongitude = document['longitude'];

        //Faz uma busca da distância entre as coordenadas da academia e do usuário logado
        api += "$academyLatitude,$academyLongitude||";
      });
    } else {
      List<Map> listReturn = List();
      listReturn.add({"semAcademias": true});
      return listReturn;
    }
    //Para cada academia encontrada adiciona um mapa de coordenada a lista de academias

    api = api.substring(0, api.length - 3);
    api += "&key=$googleKey";

    Map consultApi;

    if (Localization.fetchPostApi.isEmpty) {
      consultApi = await fetchPost(api);
      Localization.fetchPostApi = consultApi;
    } else {
      consultApi = Localization.fetchPostApi;
    }

    return setCoordinates(consultApi, listCoordinates);
  }

  /*
   * Adiciona ao resultado da api as coordenadas de cada academy
   */
  List setCoordinates(Map consultApi, List listCoordinates) {
    List listHelp = consultApi["rows"];
    listHelp = listHelp.elementAt(0)["elements"];
    List<Map> returnAcademysList = List();
    int indexAcademy = 0;

    for (var i = 0; i < (listCoordinates.length); i++) {
      if (i == 0) {
        returnAcademysList.add({
          "latitude": listCoordinates.elementAt(i)["latitude"],
          "longitude": listCoordinates.elementAt(i)["longitude"],
        });
      } else {
        returnAcademysList.add({
          "distance": convertMilesToKm(
              listHelp.elementAt(indexAcademy)["distance"]["text"]),
          "duration": listHelp.elementAt(indexAcademy)["duration"]["text"],
          "latitude": listCoordinates.elementAt(i)["latitude"],
          "longitude": listCoordinates.elementAt(i)["longitude"],
          "points": listCoordinates.elementAt(i)["points"],
          "fantasia": listCoordinates.elementAt(i)["fantasia"],
          "name": listCoordinates.elementAt(i)["name"],
          "documentId": listCoordinates.elementAt(i)["documentId"],
          "valueSack": listCoordinates.elementAt(i)["valueSack"],
          "academyCheckInCode":
              listCoordinates.elementAt(i)["academyCheckInCode"]
        });

        indexAcademy++;
      }
    }

    return returnAcademysList;
  }

  Future<Map> fetchPost(api) async {
    final dynamic response = await http.get(api);

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      return json.decode(response.body);
    }

    return null;
  }

  double convertMilesToKm(String distance) {
    double value = double.parse(distance.split(" ")[0]);

    return value / 0.62137;
  }
}
