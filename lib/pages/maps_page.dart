import "package:flutter/material.dart";
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import "package:fbla_app_22/data/sample_destination.dart";

class MapsPage extends StatelessWidget {
  const MapsPage({Key? key}) : super(key: key);

  // This function creates a marker in the form of a red location dot icon with a size of 35
  // at the specified latitude and longitude coordinates (x and y).
  // The marker is anchored to the top of the map.
  Marker markerIcon(double x, double y) {
    return Marker(
      anchorPos: AnchorPos.align(AnchorAlign.top),
      point: LatLng(x, y),
      builder: (context) => Icon(
        FontAwesomeIcons.locationDot,
        size: 35,
        color: Colors.red.shade700,
      ),
    );
  }

  // This function returns a marker on a map with the specified text and at the given coordinates.
  // The marker is a row that contains the specified text with a red and bold font.
  // The marker is also anchored at a specific position on the screen.
  Marker markerText(String text, double x, double y) {
    return Marker(
      anchorPos: AnchorPos.exactly(Anchor(200, 0)),
      point: LatLng(x, y),
      width: 180,
      builder: (context) => Row(
        children: [
          Text(
            text,
            style: TextStyle(
              color: Colors.red.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  // The function returns a Scaffold that contains a FlutterMap widget.
  // The FlutterMap widget displays a map with bus routes marked using polylines,
  // and bus stops marked using markers with text. The map is from OpenStreetMap a
  // and the bus routes are defined using LatLng points.
  // The polylines have different colors and widths according to the routes they represent.
  // The function also sets the options for the map, including the TileLayerOptions and PolylineLayerOptions.
  // Finally, the function sets the app bar to display the title "Bus Routes".
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Bus Routes"),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(47.6485536, -122.0823183),
          minZoom: 10,
          zoom: 11.25,
          interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        nonRotatedChildren: [
          AttributionWidget(
            attributionBuilder: (context) => Container(
              color: Colors.white,
              child: const Text(
                "© OpenStreetMap",
              ),
            ),
          ),
        ],
        children: [
          TileLayerWidget(
            options: TileLayerOptions(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
          ),
          PolylineLayerWidget(
            options: PolylineLayerOptions(
              polylineCulling: false,
              polylines: [
                Polyline(
                  borderStrokeWidth: 5,
                  borderColor: Colors.blue,
                  points: [
                    for (int i = 0; i < route1.length; i++)
                      LatLng(
                        route1[i][1],
                        route1[i][0],
                      ),
                  ],
                  color: Colors.blue,
                ),
                Polyline(
                  borderStrokeWidth: 5,
                  borderColor: Colors.green,
                  points: [
                    for (int i = 0; i < route2.length; i++)
                      LatLng(
                        route2[i][1],
                        route2[i][0],
                      ),
                  ],
                  color: Colors.green,
                ),
                Polyline(
                  borderStrokeWidth: 5,
                  borderColor: Colors.orange,
                  points: [
                    for (int i = 0; i < route3.length; i++)
                      LatLng(
                        route3[i][1],
                        route3[i][0],
                      ),
                  ],
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          MarkerLayerWidget(
            options: MarkerLayerOptions(
              markers: [
                markerIcon(47.6485536, -122.0383183),
                markerText("Tesla STEM", 47.6485536, -122.0383183),
                markerIcon(47.67253112792969, -122.1812973022461),
                markerText("LW High", 47.67253112792969, -122.1812973022461),
                markerIcon(47.695438385009766, -122.10737609863281),
                markerText(
                    "Redmond High", 47.695438385009766, -122.10737609863281),
                markerIcon(47.61384201049805, -122.0321044921875),
                markerText(
                    "Eastlake High", 47.61384201049805, -122.0321044921875),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
