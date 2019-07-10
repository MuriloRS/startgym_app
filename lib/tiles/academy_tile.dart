import 'package:flutter/material.dart';
import 'package:startgym/screens/academy_checkin.dart';
import 'package:startgym/utils/slideRightRoute.dart';

class AcademyTile extends StatelessWidget {
  final Map dataAcademy;
  final dynamic dataMap;
  final dynamic userData;
  final PageController drawerController;

  AcademyTile({this.dataAcademy, this.dataMap, this.userData, this.drawerController});

  final TextStyle itemStyle =
      TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.grey[700]);

  @override
  Widget build(BuildContext context) {
    String fantasia = dataAcademy["fantasia"] == ""
        ? dataAcademy["name"]
        : dataAcademy["fantasia"].toString();

    double distance = dataAcademy["distance"];
    String distanceAsString = distance.toStringAsFixed(2);

    String nomeAcademia = fantasia;
    if (fantasia.contains(",")) {
      nomeAcademia = fantasia.split(",")[0];
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          SlideRightRoute(widget: AcademyCheckin(dataAcademy,userData, drawerController)),
        );
      },
      child: Card(
          elevation: 1.0,
          margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 7,
                  child: Text(
                    nomeAcademia,
                    softWrap: false,
                    style: itemStyle,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "$distanceAsString km",
                    style: itemStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
