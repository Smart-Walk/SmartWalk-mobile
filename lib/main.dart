import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: GameGrid(),
        ),
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
      print(results[0].bssid);
      setState(() => accessPoints = results);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      child: Scaffold(
        body: Container(
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
                              _startScan(context);
                              _getScannedResults(context);
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
                              color:
                              selectedGrid == gridNumber ? Colors.green : null,
                            ),
                            child: Center(
                              child: Text(
                                ".",
                              ),
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
    );
  }
}
