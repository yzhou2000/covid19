import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'covidMetro.dart';
import 'covidState.dart';
import 'covidCounty.dart';
import 'screenData.dart';

class Place{
  final String ZIP;
  final String county;
  final String st_code;
  final String msa;
  final String state_name;

  Place({this.ZIP, this.county, this.st_code,this.msa,this.state_name});

  factory Place.fromJson(Map<String, dynamic> json){
    return Place(
      ZIP:json['ZIP'],
      county:json['county'],
      st_code:json['st_code'],
      msa:json['msa'],
      state_name:json['state'],
    );
  }
  @override
  String toString() {
    return 'Your current location { County: $county,State: $st_code, MSA : $msa  State_name : $state_name}';
  }
}

void main() {
  runApp(MaterialApp(
      title: 'Covid 19 cases near you',
      home: MyApp()
  ),
  );
}


class MyApp extends StatefulWidget{
  @override
  State<StatefulWidget> createState()  => MyAppState();
}


class MyAppState extends State<MyApp> {

  final Geolocator geolocator = Geolocator()
    ..forceAndroidLocationManager;
  String _zip;
  String _city;
  String _county;
  String _state;
  String _state_name;
  String _msa;
  ScreenData _args;
  Position _currentPosition;
  String _currentAddress = "not known";
  bool _isLoading = false;


  @override
  void initState() {
      _isLoading=true;
      _getCurrentLocation();
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e.toString());
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      Placemark place = p[0];
      setState(() {
        _zip = "${place.postalCode}";
        _city = "${place.locality}";
        _currentAddress ="${place.locality}, ${place.postalCode}, ${place.country}";
      });

      List<Place> uszip = await fetchPlace();

      Place _currentArea = uszip.firstWhere((i) => i.ZIP == _zip);
      setState(() {
        _county = "${_currentArea.county}";
        _msa = "${_currentArea.msa}";
        _state = "${_currentArea.st_code}";
        _state_name = "${_currentArea.state_name}";
        _isLoading = false;
         _args=ScreenData(_county,_state,_msa,_state_name);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<Place>> fetchPlace() async {
    //_getCurrentLocation();
    String data = await DefaultAssetBundle.of(context).loadString(
        "jsons/Place.json");
    // print(data);
    final parsed = jsonDecode(data).cast<Map<String, dynamic>>();
    List<Place> responseList = parsed.map<Place>((json) => Place.fromJson(json)).toList();
    return responseList.toList();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(title: Text('The COVID-19 Cases Near You'),    ),
          body: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                color: Colors.white,
                ),
              child: _isLoading? Center(
                        child: Column(children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10,),
                          Text("Loading your location infomation ...", style: TextStyle(color: Colors.blueAccent),),
                            ]
                          )
                         )
                          : new Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center ,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget> [
                                     Text('You are in $_city $_state, which is in $_county County ',
                                       style: TextStyle(
                                         fontWeight: FontWeight.bold,),
                                        ),
                                     SizedBox(height: 100,),
                                     RaisedButton(
                                       onPressed: () {
                                         Navigator.push(context,
                                           MaterialPageRoute(builder: (context) => CovidCountysList(),
                                                 settings: RouteSettings(
                                               arguments: _args,
                                             ),
                                              )
                                         );
                                       },
                                       child: Text("Check COVID-19 cases in $_county County",
                                         style: TextStyle(fontSize: 14.0,),),
                                     ),
                                   SizedBox(height: 10,),
                                    RaisedButton(
                                      onPressed: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (context) => CovidStatesList(),
                                              settings: RouteSettings(
                                                arguments: _args,
                                              ),
                                            )
                                        );
                                      },
                                      child: Text("Check COVID-19 cases in $_state state",
                                        style: TextStyle(fontSize: 14.0,),),
                                    ),
                                    SizedBox(height: 10,),
                                    RaisedButton(
                                      onPressed: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (context) => CovidMetrosList(),
                                        settings: RouteSettings(
                                        arguments: _args,
                                        ),
                                        )
                                        );
                                      },
                                      child: Text("Check COVID-19 cases in $_msa metra area",
                                        style: TextStyle(fontSize: 14.0,),),
                                    ),
                              ],
                              ),
                            )
                   );
               }
}

