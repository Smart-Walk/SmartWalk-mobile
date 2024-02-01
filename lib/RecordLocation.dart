import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:wifi_scan/wifi_scan.dart';

import 'LiveTracking.dart';

class RecordLocation extends StatelessWidget {
  const RecordLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.only(top: 25),
        child: GameGrid(),
      ),
    );
  }
}

class GameGrid extends StatefulWidget {
  @override
  _GameGridState createState() => _GameGridState();
}

class _GameGridState extends State<GameGrid> {
  final int rows = 70;
  final int columns = 25;
  final double cellSize = 15.0;
  int selectedGrid = -1;
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  String selectedSSID = "";
  int selectedSignal = 0;
  bool deleteMode = false;
  List<int> selectedTiles = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _updateTilesList() async {
    if (deleteMode) {
      final response = await http.post(
        Uri.parse('http://192.168.1.46:8000/api/update_blocked'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"tiles": selectedTiles}),
      );

      if (response.statusCode == 200) {
        print("Server update successful");
      } else {
        print("Error updating server: ${response.statusCode}");
      }
    }
  }

  void kShowSnackBar(BuildContext context, String message) {
    if (kDebugMode) print(message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _startScan(BuildContext context) async {
    final can = await WiFiScan.instance.canStartScan();
    if (can != CanStartScan.yes) {
      if (mounted) kShowSnackBar(context, "Cannot start scan: $can");
      return;
    }

    final result = await WiFiScan.instance.startScan();
    if (mounted) kShowSnackBar(context, "startScan: $result");
    setState(() => accessPoints = <WiFiAccessPoint>[]);
  }

  Future<bool> _canGetScannedResults(BuildContext context) async {
    final can = await WiFiScan.instance.canGetScannedResults();
    // if can-not, then show error
    if (can != CanGetScannedResults.yes) {
      if (mounted) kShowSnackBar(context, "Cannot get scanned results: $can");
      accessPoints = <WiFiAccessPoint>[];
      return false;
    }
    return true;
  }

  Future<void> _getScannedResults(BuildContext context) async {
    if (await _canGetScannedResults(context)) {
      final results = await WiFiScan.instance.getScannedResults();
      // final amritaConnectAccessPoints = results.where((ap) => ap.ssid == "AMRITA-Connect").toList();
      final amritaConnectAccessPoints = results;

      final jsonData = {
        "location": selectedGrid,
        "access_points": {
          for (int i = 0; i < amritaConnectAccessPoints.length; i++)
            '${amritaConnectAccessPoints[i].ssid} ${amritaConnectAccessPoints[i].bssid}':
                amritaConnectAccessPoints[i].level,
        }
      };

      showPopup(jsonData);
      setState(() => accessPoints = results);
    }
  }

  Future<http.Response> learnLocation() {
    const points = ['Priya 2', 'Galaxy M218670', 'Galaxy M31E1CB'];

    // Filter the access points based on SSID
    Map<String, int> filteredAccessPoints = {};
    for (int i = 0; i < accessPoints.length; i++) {
      String ssidBssidKey = '${accessPoints[i].ssid} ${accessPoints[i].bssid}';
      if (points.contains(accessPoints[i].ssid)) {
        filteredAccessPoints[ssidBssidKey] = accessPoints[i].level;
      }
    }

    return http.post(
      Uri.parse('http://192.168.1.46:8000/api/learn'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "location": selectedGrid.toString(),
        "access_points": filteredAccessPoints,
      }),
    );
  }

  void showPopup(Map<String, Object> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("WiFi Information"),
          content: Text("Wifi data: \n$data"),
          actions: [
            TextButton(
              onPressed: () async {
                final response = await learnLocation();
                if (response.statusCode == 200) {
                  Navigator.of(context).pop();
                } else {
                  print("Error: ${response.statusCode}");
                  kShowSnackBar(context, "Failed to learn location");
                }
              },
              child: Text("Learn"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _toggleSelectedGrid(int gridNumber) {
    setState(() {
      if (selectedTiles.contains(gridNumber)) {
        selectedTiles.remove(gridNumber);
      } else {
        selectedTiles.add(gridNumber);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(28, 30, 45, 1),
    ));
    return Scaffold(
      backgroundColor: Color.fromRGBO(28, 30, 45, 1),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(28, 30, 45, 1),
            border: Border.all(color: Color.fromRGBO(28, 30, 45, 1), width: 0),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LiveTrack()),
                        );
                      },
                      child: Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Floor Plan",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          "1st floor",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w300,
                          ),
                        )
                      ],
                    ),
                    Switch(value: false, onChanged: (value) => {null})
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(
          top: 30,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black,
                      Colors.black,
                      Colors.transparent
                    ],
                    stops: [0.0, 0.09, 0.5, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: InteractiveViewer(
                  constrained: false,
                  boundaryMargin: EdgeInsets.all(100),
                  child: Container(
                    height: 1000,
                    width: 380,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(28, 30, 45, 1),
                      image: DecorationImage(
                        image: AssetImage("assets/images/hostel2.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Column(
                      children: List.generate(
                        rows,
                        (row) => Expanded(
                          child: Row(
                            children: List.generate(
                              columns,
                              (col) {
                                final gridNumber = row * columns + col;
                                return GestureDetector(
                                  onTap: () async {
                                    if (deleteMode) {
                                      _toggleSelectedGrid(gridNumber);
                                    } else {
                                      setState(() {
                                        if (selectedGrid != gridNumber) {
                                          selectedGrid = gridNumber;
                                        } else {
                                          selectedGrid = -1;
                                        }
                                      });

                                      await _updateTilesList();
                                    }
                                  },
                                  child: GridTile(
                                    child: Container(
                                      width: cellSize,
                                      height: cellSize,
                                      decoration: BoxDecoration(
                                        border: deleteMode
                                            ? Border.all(width: 0)
                                            : null,
                                        color: deleteMode &&
                                                selectedTiles
                                                    .contains(gridNumber)
                                            ? Colors.green
                                            : null,
                                      ),
                                      child: Center(
                                        child: selectedGrid == gridNumber
                                            ? Icon(
                                                Icons.location_on,
                                                size: 12,
                                                color: Colors.white,
                                              )
                                            : Text(""),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(17, 18, 28, 1),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, right: 35, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Selected Grid:",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            selectedGrid.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.w200,
                                fontSize: 20,
                                color: Colors.white),
                          )
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            deleteMode = !deleteMode;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: deleteMode
                                ? Colors.lightGreen
                                : Color.fromRGBO(28, 30, 45, 1),
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: InkWell(
                          onTap: () async {
                            if (deleteMode) {
                              await _updateTilesList();
                            } else {
                              _startScan(context);
                              _getScannedResults(context);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 15, right: 15, top: 10, bottom: 10),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Color.fromRGBO(28, 30, 45, 1),
                            ),
                            child: Text(
                              "Learn",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Align(
// alignment: Alignment.bottomCenter,
// child: Padding(
// padding: const EdgeInsets.only(bottom: 16.0),
// child: FloatingActionButton(
// backgroundColor: Colors.brown,
// onPressed: () {
// _startScan(context);
// _getScannedResults(context);
// },
// child: Icon(Icons.wifi),
// ),
// ),
// ),
