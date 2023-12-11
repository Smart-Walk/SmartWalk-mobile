import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';

class LiveTrack extends StatelessWidget {
  const LiveTrack({super.key});

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
  final int rows = 50;
  final int columns = 25;
  final double cellSize = 15.0;
  int selectedGrid = -1;
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  String selectedSSID = "";
  int selectedSignal = 0;

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
            '${amritaConnectAccessPoints[i].ssid} ${amritaConnectAccessPoints[i].bssid}': amritaConnectAccessPoints[i].level,
        }
      };

      showPopup(jsonData);
      setState(() => accessPoints = results);
    }
  }

  void showPopup(Map<String, Object>  data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("WiFi Information"),
          content: Text("Wifi data: \n$data"),
          actions: [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          InteractiveViewer(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/hostel.png"),
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
                            onTap: () {
                              setState(() {
                                if (selectedGrid != gridNumber) {
                                  selectedGrid = gridNumber;
                                } else {
                                  // If the same grid is tapped again, deselect it.
                                  selectedGrid = -1;
                                }
                              });
                            },
                            child: GridTile(
                              child: Container(
                                width: cellSize,
                                height: cellSize,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 0.1,
                                  ),
                                  color: selectedGrid == gridNumber
                                      ? Colors.green
                                      : null,
                                ),
                                child: Center(
                                  child: Text("."),
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton(
                backgroundColor: Colors.brown,
                onPressed: () {
                  _startScan(context);
                  _getScannedResults(context);
                },
                child: Icon(Icons.wifi),
              ),
            ),
          ),
        ],
      ),
    );
  }
}