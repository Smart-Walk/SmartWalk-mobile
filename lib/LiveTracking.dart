import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:wifi_scan/wifi_scan.dart';

import 'RecordLocation.dart';

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

class _GameGridState extends State<GameGrid> with TickerProviderStateMixin{
  final int rows = 70;
  final int columns = 25;
  final double cellSize = 15.0;
  int selectedGrid = -1;
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  String selectedSSID = "";
  int selectedSignal = 0;
  int count =0;
  late Timer _timer;
  late TransformationController _controller;
  bool initial = true;
  late Map<int, List<int>> adjacencyList;
  List<int> shortestPath = [];
  late List<int> blockedTiles;
  int startPath = 82;
  int endPath = 82;


  @override
  void initState() {
    super.initState();
    _controller = TransformationController();

    _fetchBlockedTiles().then((tiles) {
      blockedTiles = tiles;

      _startScan(context);
      _getScannedResults(context);

      adjacencyList = createAdjacencyList(rows, columns, blockedTiles);
      shortestPath = dijkstra(adjacencyList, startPath, endPath);


      _timer = Timer.periodic(Duration(seconds: 2), (timer) {
        _startScan(context);
        _getScannedResults(context);

        predictLocation({
          "access_points": {
            for (int i = 0; i < accessPoints.length; i++)
              '${accessPoints[i].ssid} ${accessPoints[i].bssid}': accessPoints[i].level,
          }
        }).then((response) {
          if (response.statusCode == 200) {
            final jsonResponse = jsonDecode(response.body);
            print(jsonResponse);
            String location = jsonResponse['location'];
            String numberPart = location.split('/')[1].split('.')[0];

            // Converting the extracted string to an integer
            final newSelectedGrid = int.parse(numberPart);
            setState(() {
              selectedGrid = newSelectedGrid;
              if (selectedGrid != -1 && initial) {
                _zoomToSelectedGrid();
                initial = false;
              }
            });
          } else {
            print("Error: ${response.statusCode}");
          }
        });
      });
    });
  }


  Future<http.Response> predictLocation(Map<String, Object> data) {
    return http.post(
      Uri.parse('http://192.168.24.94:8000/api/predict'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
  }

  Future<List<int>> _fetchBlockedTiles() async {
    final url = Uri.parse('http://192.168.1.46:8000/api/get_blocked');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> blockedTilesData = responseData['data']['tiles'];

        final blockedTiles = List<int>.from(blockedTilesData);

        return blockedTiles;
      } else {
        print("Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      // Handle exceptions
      print("Exception: $e");
      return [];
    }
  }


  @override
  void dispose() {
    // Dispose the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
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
      return;
    }

    final result = await WiFiScan.instance.startScan();
    setState(() => accessPoints = <WiFiAccessPoint>[]);
  }

  Future<bool> _canGetScannedResults(BuildContext context) async {
    final can = await WiFiScan.instance.canGetScannedResults();
    if (can != CanGetScannedResults.yes) {
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

  void _zoomToSelectedGrid() {
    // Calculate the position of the selected grid and zoom in accordingly
    final row = selectedGrid ~/ columns;
    final col = selectedGrid % columns;
    final offset = Offset(col * cellSize, row * cellSize);

    // Calculate rotation angle (in radians)
    final rotationAngle = -0.1; // Adjust the angle based on your preference

    // Create an AnimationController
    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500), // Adjust the duration as needed
    );

    // Create Tweens for translation, scaling, and rotation
    final translationTween = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-offset.dx, -offset.dy),
    );

    final scaleTween = Tween<double>(
      begin: 1.0,
      end: 2.0, // Adjust the scale factor based on your preference
    );

    final rotationTween = Tween<double>(
      begin: 0.0,
      end: rotationAngle,
    );

    // Create a CurvedAnimation for smooth easing
    final curvedAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut, // Use your preferred easing curve
    );

    controller.addListener(() {
      final translation = translationTween.evaluate(curvedAnimation);
      final scale = scaleTween.evaluate(curvedAnimation);
      final rotation = rotationTween.evaluate(curvedAnimation);

      _controller.value = Matrix4.identity()
        ..translate(translation.dx, translation.dy)
        ..scale(scale);
        // ..rotateZ(rotation);
    });

    // Start the animation
    controller.forward();

    // Dispose of the controller when done
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });
  }
  Map<int, List<int>> createAdjacencyList(int rows, int columns, List<int> blockedTiles) {
    Map<int, List<int>> adjacencyList = {};

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        int currentTile = row * columns + col;
        List<int> neighbors = [];

        if (!blockedTiles.contains(currentTile)) {
          // Add neighbors only if the current tile is not blocked
          if (row > 0 && !blockedTiles.contains((row - 1) * columns + col)) {
            neighbors.add((row - 1) * columns + col);
          }
          if (row < rows - 1 && !blockedTiles.contains((row + 1) * columns + col)) {
            neighbors.add((row + 1) * columns + col);
          }
          if (col > 0 && !blockedTiles.contains(row * columns + col - 1)) {
            neighbors.add(row * columns + col - 1);
          }
          if (col < columns - 1 && !blockedTiles.contains(row * columns + col + 1)) {
            neighbors.add(row * columns + col + 1);
          }

          adjacencyList[currentTile] = neighbors;
        }
      }
    }

    return adjacencyList;
  }

  List<int> dijkstra(Map<int, List<int>> adjacencyList, int start, int end) {
    List<int> distances = List.filled(rows * columns, 999999);
    List<int> previous = List.filled(rows * columns, -1);
    Set<int> visited = Set<int>();

    distances[start] = 0;

    while (visited.length < rows * columns) {
      int current = -1;
      int minDistance = 999999;

      for (int node in adjacencyList.keys) {
        if (!visited.contains(node) && distances[node] < minDistance) {
          current = node;
          minDistance = distances[node];
        }
      }

      if (current == -1) break;

      for (int neighbor in adjacencyList[current]!) {
        int distance = distances[current] + 1;
        if (distance < distances[neighbor]) {
          distances[neighbor] = distance;
          previous[neighbor] = current;
        }
      }

      visited.add(current);
    }

    List<int> path = [];
    int current = end;
    while (current != -1) {
      path.insert(0, current);
      current = previous[current];
    }

    return path;
  }




  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(28, 30, 45, 1),
    ));

    if (shortestPath == []) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

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
                          MaterialPageRoute(builder: (context) => RecordLocation()),
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
        padding: EdgeInsets.only(top: 30),
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
                  transformationController: _controller,
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
                                bool inShortestPath = shortestPath.contains(gridNumber);

                                return GridTile(
                                  child: Container(
                                    width: cellSize,
                                    height: cellSize,
                                    decoration: BoxDecoration(
                                      // border: Border.all(width: 1),
                                    ),
                                    child: Center(
                                      child: selectedGrid == gridNumber
                                          ? Icon(
                                        Icons.my_location,
                                        size: 12,
                                        color: Colors.white,
                                      ) : inShortestPath ? Container(
                                        height: 8,
                                        width: 8,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(50)),
                                          color: Colors.blue
                                        ),
                                      )
                                          : Text(""),
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
                            "Current location:",
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: InkWell(
                          onTap: () {
                            showBottomSheet(context: context,shape: const RoundedRectangleBorder( // <-- SEE HERE
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(25.0),
                              ),
                            ), backgroundColor:Color.fromRGBO(17, 18, 28, 1), builder: (BuildContext context) {
                              return SizedBox(
                                height: 300,
                                child: Center(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20 ,left: 25, right: 20),
                                      child: Text("Starting location", style: TextStyle(color: Colors.white, fontSize: 16),),
                                    ),
                                    Container(
                                      height: 70,
                                      padding: EdgeInsets.only(top:10, left: 20, right: 20),
                                      child: DropdownButtonFormField(
                                        value: startPath,
                                        style: TextStyle(
                                          color: Colors.grey
                                        ),
                                        dropdownColor: Color.fromRGBO(28, 30, 45, 1),
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(40),
                                            borderSide: const BorderSide(color: Colors.grey,width: 1),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(40),
                                            borderSide: const BorderSide(color: Colors.grey,width: 1),
                                          )
                                        ),
                                        onChanged: (value){
                                          setState(() {
                                            startPath = value!;
                                          });
                                        },
                                        items: [
                                          DropdownMenuItem(
                                            child: Text('n101'),
                                            value: 82,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('n102'),
                                            value: 232,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('n103'),
                                            value: 357,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('n104'),
                                            value: 507,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('n105'),
                                            value: 657,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('n106'),
                                            value: 1082,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('n107'),
                                            value: 1232,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('n108'),
                                            value: 1382,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('n109'),
                                            value: 1507,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('n110'),
                                            value: 1657,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('s101'),
                                            value: 93,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('s102'),
                                            value: 243,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('s103'),
                                            value: 393,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('s104'),
                                            value: 518,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('s105'),
                                            value: 668,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('s106'),
                                            value: 1093,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('s107'),
                                            value: 1243,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('s108'),
                                            value: 1393,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('s109'),
                                            value: 1518,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('s110'),
                                            value: 1668,
                                          ),
                                        ],

                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20 ,left: 25, right: 20),
                                      child: Text("Destination", style: TextStyle(color: Colors.white, fontSize: 16),),
                                    ),
                                    Container(
                                      height: 70,
                                      padding: EdgeInsets.only(top:10, left: 20, right: 20),
                                      child: DropdownButtonFormField(
                                        value: endPath,
                                        style: TextStyle(
                                            color: Colors.grey
                                        ),
                                        dropdownColor: Color.fromRGBO(28, 30, 45, 1),
                                        decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(40),
                                              borderSide: const BorderSide(color: Colors.grey,width: 1),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(40),
                                              borderSide: const BorderSide(color: Colors.grey,width: 1),
                                            )
                                        ),
                                        onChanged: (value){
                                          setState(() {
                                            endPath = value!;
                                          });
                                        },
                                        items: [
                                          DropdownMenuItem(
                                            child: Text('n101'),
                                            value: 82,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('n102'),
                                            value: 232,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('n103'),
                                            value: 357,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('n104'),
                                            value: 507,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('n105'),
                                            value: 657,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('n106'),
                                            value: 1082,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('n107'),
                                            value: 1232,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('n108'),
                                            value: 1382,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('n109'),
                                            value: 1507,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('n110'),
                                            value: 1657,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('s101'),
                                            value: 93,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('s102'),
                                            value: 243,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('s103'),
                                            value: 393,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('s104'),
                                            value: 518,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('s105'),
                                            value: 668,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('s106'),
                                            value: 1093,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('s107'),
                                            value: 1243,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('s108'),
                                            value: 1393,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('s109'),
                                            value: 1518,
                                          ),
                                          DropdownMenuItem(
                                            child: Text('s110'),
                                            value: 1668,
                                          ),
                                        ],

                                      ),
                                    ),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 10.0, top: 10),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              shortestPath = dijkstra(adjacencyList, startPath, endPath);
                                              Navigator.pop(context);
                                            });
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
                                              "Confirm",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w200,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )),
                              );
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.all(Radius.circular(50)),
                              color: Color.fromRGBO(28, 30, 45, 1),
                            ),
                            child: Icon(Icons.fork_right, color: Colors.white,),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: InkWell(
                          onTap: () {
                            _controller.value = Matrix4.identity();
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
                              "Center",
                              style: TextStyle(
                                fontSize: 14,
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