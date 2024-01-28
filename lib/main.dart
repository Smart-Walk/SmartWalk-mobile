import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:label_marker/label_marker.dart';
import 'package:tilemap/LiveTracking.dart';
import 'dart:math' as math;

import 'RecordLocation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  LatLng intialLocation = const LatLng(9.093669688025656, 76.49028041373133);
  late GoogleMapController _controller;
  Set<Marker> markers = {};
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  PolygonId? tappedPolygonId;
  String tappedTitle = "";

  @override
  void initState() {
    addCustomIcon();
    super.initState();
  }
  void addCustomIcon(){
    BitmapDescriptor.fromAssetImage(ImageConfiguration(), "assets/icons/marker.svg").then((icon) => setState(() {
      markerIcon = icon;
    }));
  }

  Future<void> onMapCreated(GoogleMapController controller)  async {
    _controller = controller;
    String value = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');
    _controller.setMapStyle(value);

    markers
        .addLabelMarker(LabelMarker(
      label: "Amrita School of Engineering",
      markerId: MarkerId("1"),
      position: LatLng(9.093997204172979, 76.49180323814511),
      backgroundColor: Colors.grey.shade800,
    ));

    markers
        .addLabelMarker(LabelMarker(
      label: "Amrita School of Business",
      markerId: MarkerId("2"),
      position: LatLng(9.092931218607774, 76.48973318238512),
      backgroundColor: Colors.grey.shade800,
    ));
    markers
        .addLabelMarker(LabelMarker(
      label: "Amrita Center for International programs",
      markerId: MarkerId("3"),
      position: LatLng(9.092574344132895, 76.4900651671446),
      backgroundColor: Colors.grey.shade800,
    ));
    markers
        .addLabelMarker(LabelMarker(
      label: "Amrita School of Biotechnology",
      markerId: MarkerId("4"),
      position: LatLng(9.092265223215069, 76.48964701630631),
      backgroundColor: Colors.grey.shade800,
    ));
    markers
        .addLabelMarker(LabelMarker(
      label: "Anugraham",
      markerId: MarkerId("5"),
      position: LatLng(9.100212730341644, 76.48981154475742),
      backgroundColor: Colors.grey.shade800,
    ));
    markers
        .addLabelMarker(LabelMarker(
      label: "Prasadam",
      markerId: MarkerId("6"),
      position: LatLng(9.099794045405288, 76.48984871588355),
      backgroundColor: Colors.grey.shade800,
    ));
    markers
        .addLabelMarker(LabelMarker(
      label: "Pranavam",
      markerId: MarkerId("7"),
      position: LatLng(9.09941691114551, 76.4898937257887),
      backgroundColor: Colors.grey.shade800,
    ));
    markers
        .addLabelMarker(LabelMarker(
      label: "Shivam",
      markerId: MarkerId("8"),
      position: LatLng(9.09846962926002, 76.49000560745272),
      backgroundColor: Colors.grey.shade800,
    ));
    markers
        .addLabelMarker(LabelMarker(
      label: "Kailasam",
      markerId: MarkerId("9"),
      position: LatLng(9.098131857963367, 76.49001975348887),
      backgroundColor: Colors.grey.shade800,
    ));
    markers
        .addLabelMarker(LabelMarker(
      label: "Ashokam",
      markerId: MarkerId("10"),
      position: LatLng(9.099427497634801, 76.49035510949479),
      backgroundColor: Colors.grey.shade800,
    ))
        .then(
          (value) {
        setState(() {});
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(28, 30, 45, 1),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(

              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: onMapCreated,
              initialCameraPosition: CameraPosition(
                target: intialLocation,
                zoom: 15.6746,
              ),
              markers: markers,
              polygons: {
                Polygon(
                  polygonId: const PolygonId("1"),
                  consumeTapEvents: true,
                  strokeColor: tappedPolygonId == PolygonId("1") ? Colors.green.shade700: Colors.grey.shade800,
                  fillColor: Colors.grey.shade900,
                  strokeWidth: 3,
                  onTap: () {
                    setState(() {
                      tappedPolygonId = PolygonId("1");
                      tappedTitle = "Amrita School of Engineering";
                    });
                  },
                  points: const [
                    LatLng(9.094177609184115, 76.49086957618724),
                    LatLng(9.094263748424622, 76.4913810969475),
                    LatLng(9.094489715743284, 76.49137567355088),
                    LatLng(9.094498604504667, 76.49148755543236),
                    LatLng(9.094659873235278, 76.49150684564754),
                    LatLng(9.094667492066911, 76.49174475570663),
                    LatLng(9.094336065590245, 76.4918193429442),
                    LatLng(9.094417754601233, 76.49270417775308),
                    LatLng(9.093468913477714, 76.49283106537592),
                    LatLng(9.093468913477714, 76.49283106537592),
                    LatLng(9.093300771407787, 76.49098631042314),
                  ],
                ),
                Polygon(
                  polygonId: const PolygonId("2"),
                  strokeColor: tappedPolygonId == PolygonId("2") ? Colors.green.shade700: Colors.grey.shade800,
                  fillColor: Colors.grey.shade900,
                  consumeTapEvents: true,
                  strokeWidth: 3,
                  onTap: () {
                    setState(() {
                      tappedPolygonId = PolygonId("2");
                      tappedTitle = "Amrita School of Business";
                    });
                  },
                  points: const [
                    LatLng(9.093015251209119, 76.48954209935864),
                    LatLng(9.093088085004748, 76.48987201126904),
                    LatLng(9.092845084790683, 76.48992498474108),
                    LatLng(9.092825221085997, 76.48983378959824),
                    LatLng(9.09278615566094, 76.48983848344662),
                    LatLng(9.09276298130904, 76.48973991227238),
                    LatLng(9.092798073980985, 76.48972381902885),
                    LatLng(9.092772913212963, 76.48960311965723),
                  ],
                ),
                Polygon(
                  polygonId: const PolygonId("3"),
                  strokeColor: tappedPolygonId == PolygonId("3") ? Colors.green.shade700: Colors.grey.shade800,
                  fillColor: Colors.grey.shade900,
                  consumeTapEvents: true,
                  strokeWidth: 3,
                  onTap: () {
                    setState(() {
                      tappedPolygonId = PolygonId("3");
                      tappedTitle = "Amrita Center for International programs";

                    });
                  },
                  points: const [
                    LatLng(9.092672180110426, 76.48987477206133),
                    LatLng(9.092739716936439, 76.49016713305386),
                    LatLng(9.092463610056756, 76.4902375408628),
                    LatLng(9.092433814481739, 76.49011281808204),
                    LatLng(9.092412626451807, 76.4900886781918),
                    LatLng(9.092380182260614, 76.49007526713822),
                    LatLng(9.092366939768565, 76.49000485916737),
                    LatLng(9.092428517551367, 76.48992640458938),
                  ],
                ),
                Polygon(
                  polygonId: const PolygonId("4"),
                  strokeColor: tappedPolygonId == PolygonId("4") ? Colors.green.shade700: Colors.grey.shade800,
                  fillColor: Colors.grey.shade900,
                  consumeTapEvents: true,
                  strokeWidth: 3,
                  onTap: () {
                    setState(() {
                      tappedPolygonId = PolygonId("4");
                      tappedTitle = "Amrita School of Biotechnology";

                    });
                  },
                  points: const [
                    LatLng(9.09236219570375, 76.48941256567169),
                    LatLng(9.092169516770038, 76.48946956262861),
                    LatLng(9.092224473147803, 76.48979209834887),
                    LatLng(9.092286713107418, 76.48977801679762),
                    LatLng(9.092279429725378, 76.48975722965278),
                    LatLng(9.092330413517834, 76.48974784195953),
                    LatLng(9.092323792266523, 76.48971632597006),
                    LatLng(9.092354250116761, 76.48970760880961),
                    LatLng(9.092327765100517, 76.48951448964681),
                    LatLng(9.092380073133365, 76.48949705529019),
                  ],
                ),
                Polygon(
                  polygonId: const PolygonId("5"),
                  strokeColor: tappedPolygonId == PolygonId("5") ? Colors.green.shade700: Colors.grey.shade800,
                  fillColor: Colors.grey.shade900,
                  consumeTapEvents: true,
                  strokeWidth: 3,
                  onTap: () {
                    setState(() {
                      tappedPolygonId = PolygonId("5");
                      tappedTitle = "Anugraham hostel";

                    });
                  },
                  points: const [
                    LatLng(9.100312081102064, 76.48955617527955),
                    LatLng(9.100347172940992, 76.49006244292032),
                    LatLng(9.100260436135756, 76.49006646608784),
                    LatLng(9.100241235008165, 76.48984451293484),
                    LatLng(9.100213426279542, 76.48984518346577),
                    LatLng(9.100229978933026, 76.49007786545054),
                    LatLng(9.100120730305244, 76.490089264695),
                    LatLng(9.100082328076937, 76.48956690415929),
                    LatLng(9.100182969159587, 76.48955349309645),
                    LatLng(9.100198197720422, 76.48977611652687),
                    LatLng(9.1002253443338, 76.48977410488371),
                    LatLng(9.100212764220682, 76.48956221027356),
                  ],
                ),

                Polygon(
                  polygonId: const PolygonId("6"),
                  strokeColor: tappedPolygonId == PolygonId("6") ? Colors.green.shade700: Colors.grey.shade800,
                  fillColor: Colors.grey.shade900,
                  consumeTapEvents: true,
                  strokeWidth: 3,
                  onTap: () {
                    setState(() {
                      tappedPolygonId = PolygonId("6");
                      tappedTitle = "Prasadam hostel";
                    });
                  },
                  points: const [
                    LatLng(9.099912827244488, 76.489556175297),
                    LatLng(9.099952553840538, 76.49011206344952),
                    LatLng(9.099857209539675, 76.4901207805217),
                    LatLng(9.099837346357262, 76.48988206372118),
                    LatLng(9.099785701551264, 76.48988407535393),
                    LatLng(9.09980092992114, 76.49012212156532),
                    LatLng(9.099693667561244, 76.49013419142184),
                    LatLng(9.099655265338948, 76.48958567966893),
                    LatLng(9.099747961152381, 76.48957696247261),
                    LatLng(9.099767824536587, 76.48981702012398),
                    LatLng(9.099818807228946, 76.48981165572133),
                    LatLng(9.09980490285368, 76.48956086920317),
                  ],
                ),

                Polygon(
                  polygonId: const PolygonId("7"),
                  consumeTapEvents: true,
                  onTap: () {
                    setState(() {
                      tappedPolygonId = PolygonId("7");
                      tappedTitle = "Pranavam hostel";
                    });
             },
                  strokeColor: tappedPolygonId == PolygonId("7") ? Colors.green.shade700: Colors.grey.shade800,
                  fillColor: Colors.grey.shade900,
                  strokeWidth: 3,
                  points: const [
                    LatLng(9.099527074281005, 76.48961009959693),
                    LatLng(9.099564914848619, 76.49016744983014),
                    LatLng(9.099472780852427, 76.49017244836013),
                    LatLng(9.09945139279134, 76.48993667834681),
                    LatLng(9.099397922192749, 76.48993834453428),
                    LatLng(9.099410261358651, 76.49017661382864),
                    LatLng(9.099309901113978, 76.4901849448101),
                    LatLng(9.099273705926661, 76.48964342403335),
                    LatLng(9.099360081502732, 76.48963176049034),
                    LatLng(9.0993806471077, 76.48987252892083),
                    LatLng(9.099436585577505, 76.4898683633973),
                    LatLng(9.099420133089588, 76.4896209300569),
                  ],
                ),

                Polygon(
                  polygonId: const PolygonId("8"),
                  strokeColor: tappedPolygonId == PolygonId("8") ? Colors.green.shade700: Colors.grey.shade800,
                  fillColor: Colors.grey.shade900,
                  consumeTapEvents: true,
                  strokeWidth: 3,
                  onTap: () {
                    setState(() {
                      tappedPolygonId = PolygonId("8");
                      tappedTitle = "Shivam hostel";
                    });
                  },
                  points: const [
                    LatLng(9.09857682533519, 76.48970172266225),
                    LatLng(9.098616685091935, 76.49025962760284),
                    LatLng(9.098519590267028, 76.49026997816556),
                    LatLng(9.098499149445384, 76.49003708644685),
                    LatLng(9.098444980786562, 76.49004122668762),
                    LatLng(9.098461333382808, 76.49027515343361),
                    LatLng(9.098358106284076, 76.49028239878255),
                    LatLng(9.098318246694987, 76.4897358801035),
                    LatLng(9.098413297329882, 76.48971621371291),
                    LatLng(9.098436804430166, 76.48996152603097),
                    LatLng(9.098477686431531, 76.48996152605994),
                    LatLng(9.098465421876076, 76.48971621370639),
                  ],
                ),

                Polygon(
                  polygonId: const PolygonId("9"),
                  strokeColor: tappedPolygonId == PolygonId("9") ? Colors.green.shade700: Colors.grey.shade800,
                  fillColor: Colors.grey.shade900,
                  consumeTapEvents: true,
                  strokeWidth: 3,
                  onTap: () {
                    setState(() {
                      tappedPolygonId = PolygonId("9");
                      tappedTitle = "Kailasam hostel";
                    });
                  },
                  points: const [
                    LatLng(9.09824057090604, 76.48971207344145),
                    LatLng(9.09827838636168, 76.49028032851231),
                    LatLng(9.09817822540905, 76.49029067911832),
                    LatLng(9.098160850864556, 76.49006089284063),
                    LatLng(9.098112814508465, 76.49006089280682),
                    LatLng(9.098118946483114, 76.49028964397351),
                    LatLng(9.098017763469509, 76.49028964386636),
                    LatLng(9.098002433145593, 76.48998947275359),
                    LatLng(9.098157193855585, 76.48997772252362),
                    LatLng(9.098155869653677, 76.48988585687728),
                    LatLng(9.098110845774528, 76.48988585687172),
                    LatLng(9.09810819731243, 76.48978728572244),
                    LatLng(9.098152559075023, 76.48978125074954),
                    LatLng(9.098151896944023, 76.48972224216239),
                  ],
                ),

                Polygon(
                  polygonId: const PolygonId("10"),
                  strokeColor: tappedPolygonId == PolygonId("10") ? Colors.green.shade700: Colors.grey.shade800,
                  fillColor: Colors.grey.shade900,
                  consumeTapEvents: true,
                  strokeWidth: 3,
                  onTap: () {
                    setState(() {
                      tappedPolygonId = PolygonId("10");
                      tappedTitle = "Ashokam hostel";
                    });
                  },
                  points: const [
                    LatLng(9.099725987554146, 76.49025982476094),
                    LatLng(9.099044672507826, 76.49032151536946),
                    LatLng(9.099053279859582, 76.49044824977928),
                    LatLng(9.0991042626749, 76.49044154430281),
                    LatLng(9.099116842780093, 76.4904972001969),
                    LatLng(9.099171798278823, 76.49048781250727),
                    LatLng(9.099173122562823, 76.49043483883165),
                    LatLng(9.099745188910003, 76.49038722988358),
                    LatLng(9.099742540462923, 76.49036376051542),
                    LatLng(9.09977961884894, 76.49036241945258),
                    LatLng(9.09977564618277, 76.49029536412377),
                    LatLng(9.099730622433238, 76.49029938740351),
                  ],
                ),
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            color: Color.fromRGBO(27, 27, 28, 1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text("Your Location", style: TextStyle(color: Colors.white, fontSize: 18), ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.lightBlue.shade900,
                            borderRadius: BorderRadius.all(Radius.circular(50))
                          ),
                          child: Transform.rotate( angle: 30 * math.pi / 100,child: Icon(Icons.navigation, color: Colors.white,)),
                        ),
                         Padding(
                           padding: const EdgeInsets.only(left: 10.0),
                           child: Text(tappedTitle, style: TextStyle(color: Colors.white),),
                         ),

                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.lightBlue.shade900,
                          borderRadius: BorderRadius.all(Radius.circular(50))
                      ),
                      child: Icon(Icons.close, color: Colors.white,),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      child: InkWell(
                    onTap: () {
              Navigator.push(
               context,
                 MaterialPageRoute(builder: (context) => RecordLocation()),
             );
              },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.lightBlue.shade900,
                              borderRadius: BorderRadius.all(Radius.circular(50))
                          ),
                          child: Center(child: Text("Confirm Location", style: TextStyle(color: Colors.white),)),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color.fromRGBO(28, 30, 45, 1),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color.fromRGBO(17, 18, 28, 1),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => LiveTrack()),
//                 );
//               },
//               child: Text("Live tracking"),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color.fromRGBO(17, 18, 28, 1),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => RecordLocation()),
//                 );
//               },
//               child: Text("Record locations"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }