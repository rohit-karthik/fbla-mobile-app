import 'dart:async';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import "package:http/http.dart" as http;
import "package:flutter/material.dart";
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import "package:fbla_app_22/data/sample_destination.dart";
import "package:location/location.dart";

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> with TickerProviderStateMixin {
  late final AnimatedMapController _animatedMapController;

  // Create a marker that looks like a bus
  Marker markerBus(double x, double y, Color busColor) {
    // top down bus view
    return Marker(
      point: LatLng(x, y),
      builder: (context) => Icon(
        FontAwesomeIcons.busSimple,
        size: 22.5,
        color: busColor,
      ),
    );
  }

  double locBorderWidth = 1;

  // Google Maps style marker for user location
  Marker markerUser(double x, double y) {
    return Marker(
      width: 45,
      height: 45,
      point: LatLng(x, y),
      builder: (context) => Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue.shade700.withOpacity(0.35),
        ),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: Colors.white,
                width: locBorderWidth,
              ),
            ),
            child: Icon(
              FontAwesomeIcons.solidCircle,
              size: 10,
              color: Colors.blue.shade700,
            ),
          ),
        ),
      ),
    );
  }

  // Retrieve user location
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

  Location location = Location();
  double userLat = 0;
  double userLong = 0;

  List<double> routesLat = List<double>.filled(3, 0);
  List<double> routesLong = List<double>.filled(3, 0);

  final Map<int, List<List<double>>> routes = {
    0: route1,
    1: route2,
    2: route3,
  };

  void getUserLocation() {
    location.getLocation().then(
      (value) {
        setState(() {
          userLat = value.latitude!;
          userLong = value.longitude!;
          errorMsg = "";
          highSchoolLocation = "Select";
        });
      },
    ).catchError(
      (error) {
        setState(() {
          errorMsg =
              "Location services denied. Please enable location in settings to calculate distance to shuttle stations.";
        });
      },
    );
  }

  Map<int, int> curIndices = {
    0: 40,
    1: 40,
    2: 40,
  };

  Map<int, bool> addOrSubtract = {
    0: true,
    1: true,
    2: true,
  };

  void updateCurPosition(int routeNum) {
    routesLat[routeNum] = routes[routeNum]![curIndices[routeNum]!][1];
    routesLong[routeNum] = routes[routeNum]![curIndices[routeNum]!][0];

    if (mounted) setState(() {});

    if (addOrSubtract[routeNum]!) {
      curIndices[routeNum] = curIndices[routeNum]! + 1;
    } else {
      curIndices[routeNum] = curIndices[routeNum]! - 1;
    }

    if (userLat == 0 && userLong == 0) {
      curIndices[routeNum] = 40;
    }

    if (curIndices[routeNum]! >= routes[routeNum]!.length) {
      addOrSubtract[routeNum] = false;
      curIndices[routeNum] = curIndices[routeNum]! - 1;
    }

    if (curIndices[routeNum]! == 0) {
      addOrSubtract[routeNum] = true;
    }
  }

  Timer? myTimer;
  Timer? locWidthTimer;
  bool locWidthSubtractOrAdd = true;

  double roundTo(double value, double precision) =>
      (value * precision).round() / precision;

  @override
  void initState() {
    _animatedMapController = AnimatedMapController(vsync: this);
    myTimer = Timer.periodic(
      const Duration(milliseconds: 300),
      (timer) {
        updateCurPosition(0);
        updateCurPosition(1);
        updateCurPosition(2);
      },
    );
    locWidthTimer = Timer.periodic(
      const Duration(milliseconds: 7),
      (timer) {
        if (userLat == 0 && userLong == 0) return;

        if (roundTo(locBorderWidth, 8) == 1) {
          locWidthSubtractOrAdd = true;
        } else if (roundTo(locBorderWidth, 8) == 3) {
          locWidthSubtractOrAdd = false;
        }

        if (locWidthSubtractOrAdd) {
          locBorderWidth = locBorderWidth + 0.01;
        } else {
          locBorderWidth = locBorderWidth - 0.01;
        }

        setState(() {
          locBorderWidth = locBorderWidth;
        });
      },
    );
    getUserLocation();
    super.initState();
  }

  @override
  void dispose() {
    myTimer!.cancel();
    locWidthTimer!.cancel();
    _animatedMapController.dispose();
    super.dispose();
  }

  String highSchoolLocation = "Select";
  List locationPolyline = [];

  double routeDuration = 0;
  double routeDistanceKm = 0;
  double routeDistanceMi = 0;

  double containerHeight = 0;

  String errorMsg = "";

  void fetchPolyline() {
    if (userLat == 0 && userLong == 0) {
      if (errorMsg == "" ||
          errorMsg == "Location not found. Can't find route.") {
        setState(() {
          errorMsg = "Location not found. Can't find route.";
          highSchoolLocation = "Select";
        });
      }
      return;
    }

    // Send api request via curl 'http://router.project-osrm.org/route/v1/driving/ to get polyline from current location to high school
    double highSchoolLat = 0;
    double highSchoolLong = 0;

    switch (highSchoolLocation) {
      case "Select":
        setState(() {
          containerHeight = 0;
        });
        return;
      case "LW High":
        highSchoolLat = 47.67253112792969;
        highSchoolLong = -122.1812973022461;
        break;
      case "Redmond High":
        highSchoolLat = 47.695438385009766;
        highSchoolLong = -122.10737609863281;
        break;
      case "Eastlake High":
        highSchoolLat = 47.61384201049805;
        highSchoolLong = -122.0321044921875;
        break;
    }

    String url =
        "http://router.project-osrm.org/route/v1/driving/$userLong,$userLat;$highSchoolLong,$highSchoolLat?overview=full&continue_straight=false&geometries=geojson";

    http.get(Uri.parse(url)).then((response) {
      //print(response.body);
      Map resMap = jsonDecode(response.body);
      locationPolyline = resMap["routes"][0]["geometry"]["coordinates"];

      routeDuration = resMap["routes"][0]["duration"] / 60;
      routeDistanceKm = resMap["routes"][0]["distance"] / 1000;
      routeDistanceMi = routeDistanceKm * 0.621371;

      setState(() {});
    });

    double longDiff = highSchoolLong - userLong;
    double latDiff = highSchoolLat - userLat;
    // print(longDiff);
    // print(latDiff);
    // print(_animatedMapController.zoom);

    double zoom = 12;

    if (latDiff.abs() > longDiff.abs()) {
      if (latDiff.abs() * 100 > 25) {
        zoom = 10;
      } else if (latDiff.abs() * 100 < 25 && latDiff.abs() * 100 > 10) {
        zoom = 11;
      } else if (latDiff.abs() * 100 < 10 && latDiff.abs() * 100 > 5) {
        zoom = 11.5;
      } else {
        zoom = 12.5;
      }
    } else {
      if (longDiff.abs() * 100 > 25) {
        zoom = 10;
      } else if (longDiff.abs() * 100 < 25 && longDiff.abs() * 100 > 10) {
        zoom = 11;
      } else if (longDiff.abs() * 100 < 10 && longDiff.abs() * 100 > 5) {
        zoom = 12;
      } else {
        zoom = 13;
      }
    }

    if (longDiff.abs() < latDiff.abs()) {
      _animatedMapController.animateTo(
          dest: LatLng(
              (highSchoolLat + userLat) / 2, (highSchoolLong + userLong) / 2),
          zoom: zoom);
    } else {
      _animatedMapController.animateTo(
          dest: LatLng(
              (highSchoolLat + userLat) / 2, (highSchoolLong + userLong) / 2),
          zoom: zoom);
    }

    setState(() {
      containerHeight = 75;
    });
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
      body: Stack(
        children: [
          FlutterMap(
            mapController: _animatedMapController,
            options: MapOptions(
              center: LatLng(47.695438385009766, -122.10737609863281),
              minZoom: 9.5,
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
              // This widget displays the map from OpenStreetMap.
              TileLayer(
                urlTemplate:
                    'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=qhgJVzNXX7XoKFGh8vTD',
                userAgentPackageName: 'com.example.app',
              ),
              // This widget displays the bus routes using polylines.
              PolylineLayer(
                polylines: [
                  // Show the route for the 1st bus route.
                  Polyline(
                    borderStrokeWidth: 5,
                    borderColor: Colors.purple,
                    points: [
                      for (int i = 0; i < route1.length; i++)
                        LatLng(
                          route1[i][1],
                          route1[i][0],
                        ),
                    ],
                    color: Colors.purple,
                  ),
                  // Show the route for the 2nd bus route.
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
                  // Show the route for the 3rd bus route.
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
                  if (highSchoolLocation != "Select")
                    Polyline(
                      borderStrokeWidth: 5,
                      borderColor: Colors.blue,
                      points: [
                        for (int i = 0; i < locationPolyline.length; i++)
                          LatLng(
                            locationPolyline[i][1],
                            locationPolyline[i][0],
                          ),
                      ],
                      color: Colors.blue,
                    ),
                ],
              ),
              MarkerLayer(
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
              // Add a marker layer that moves along the bus route.
              MarkerLayer(
                markers: [
                  markerBus(routesLat[0], routesLong[0], Colors.purple[900]!),
                ],
              ),
              MarkerLayer(
                markers: [
                  markerBus(routesLat[1], routesLong[1], Colors.green[900]!),
                ],
              ),
              MarkerLayer(
                markers: [
                  markerBus(routesLat[2], routesLong[2], Colors.orange[900]!),
                ],
              ),
              MarkerLayer(
                markers: [markerUser(userLat, userLong)],
              ),
            ],
          ),
          // Text box at the center bottom of screen
          Positioned(
            top: 0,
            child: Padding(
              padding: const EdgeInsets.only(left: 35.0, right: 35.0, top: 50),
              child: Container(
                width: MediaQuery.of(context).size.width - 70,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 3),
                      )
                    ]),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      DropdownButtonHideUnderline(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 70,
                          child: DropdownButton(
                            items: const [
                              DropdownMenuItem(
                                value: "Select",
                                child: Text("Select"),
                              ),
                              DropdownMenuItem(
                                value: "LW High",
                                child: Text("LW High"),
                              ),
                              DropdownMenuItem(
                                value: "Redmond High",
                                child: Text("Redmond High"),
                              ),
                              DropdownMenuItem(
                                value: "Eastlake High",
                                child: Text("Eastlake High"),
                              ),
                            ],
                            hint: const Text("Where to?"),
                            value: (highSchoolLocation == "Select")
                                ? null
                                : highSchoolLocation,
                            onChanged: (value) {
                              setState(() {
                                highSchoolLocation = value.toString();
                              });
                              fetchPolyline();
                            },
                          ),
                        ),
                      ),
                      if (userLat == 0.0 && userLong == 0.0)
                        const Padding(padding: EdgeInsets.all(5)),
                      if ((userLat == 0.0 && userLong == 0.0) &&
                          errorMsg !=
                              "Location services denied. Please enable location in settings to calculate distance to shuttle stations.")
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Show circular progress indicator and text indicating "getting location" when location is being fetched.
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                            // Text
                            Padding(padding: EdgeInsets.all(5)),
                            Text("Getting location...")
                          ],
                        ),
                      if (userLat == 0.0 && userLong == 0.0 && errorMsg != "")
                        const Padding(padding: EdgeInsets.all(5)),
                      if (errorMsg != "")
                        Center(
                          child: Text(
                            errorMsg,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: AnimatedContainer(
              width: MediaQuery.of(context).size.width,
              duration: const Duration(milliseconds: 500),
              height: containerHeight,
              curve: Curves.fastOutSlowIn,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 3),
                    )
                  ]),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${routeDuration.round()} min ",
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w500,
                            fontSize: 22,
                            color: Colors.green[800],
                          ),
                        ),
                        Text(
                          "(${routeDistanceMi.round()} mi, best route)",
                          style: GoogleFonts.manrope(
                            fontSize: 22,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey[600]!,
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          highSchoolLocation = "Select";
                          setState(() {
                            containerHeight = 0;
                          });
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
