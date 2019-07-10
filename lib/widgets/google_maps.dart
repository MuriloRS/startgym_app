import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:startgym/screens/academy_checkin.dart';
import 'package:startgym/utils/slideRightRoute.dart';

import 'loader.dart';

class GoogleMaps extends StatefulWidget {
  final List result;
  final Map<dynamic, dynamic> userData;
  final PageController _pageController;

  GoogleMaps(this.result, this._pageController, this.userData);

  _GoogleMapsState createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> listMarkers = List();
    List result = widget.result;
    Completer<GoogleMapController> _controller = Completer();
    final CameraPosition _initialPosition = CameraPosition(
        bearing: 0,

        zoom: 15,
        target: new LatLng(
            result.elementAt(0)["latitude"], result.elementAt(0)["longitude"]));

    if (result != null) {
      //Percorre o resultado que traz as coordenadas das academias cadastradas no serviço
      //E adiciona marcas para cada uma delas no mapa
      for (int i = 1; i < (result.length); i++) {
        listMarkers.add(
          new Marker(
            position: new LatLng(result.elementAt(i)["latitude"],
                result.elementAt(i)["longitude"]),
            markerId: MarkerId(i.toString()),
            infoWindow: InfoWindow(
              title: i != 0 ? result.elementAt(i)['name'].toString() : "Você",
              onTap: () {
                if (i > 0) {
                  Navigator.push(
                    context,
                    SlideRightRoute(
                        widget: AcademyCheckin(result.elementAt(i),
                            widget.userData, widget._pageController)),
                  );
                }
              },
            ),
            icon: BitmapDescriptor.defaultMarker,
          ),
        );
      }

      return SafeArea(
        child: GoogleMap(
        myLocationEnabled: true,
        compassEnabled: false,
        rotateGesturesEnabled: false,
        mapType: MapType.normal,
        initialCameraPosition: _initialPosition,
        markers: listMarkers.toSet(),
        onMapCreated: (GoogleMapController controller) {
          setState(() {});

          _controller.complete(controller);
        },
      ),
      );
    } else {
      return Container();
    }
  }
}
