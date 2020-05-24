import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'covidMetro.dart';
import 'covidState.dart';
import 'covidCounty.dart';
import 'screenData.dart';
import 'package:http/http.dart' as http;

class IP_info{
  final String IP;
  final String city;
  final String ZIP;
  final String st_code;
  final String state_name;
  final String country_code;
  final String country_name;

  IP_info({this.IP, this.city, this.st_code,this.ZIP,this.state_name,this.country_code,this.country_name});

  factory IP_info.fromJson(Map<String, dynamic> json){
    return IP_info(
      IP:json['ip'],
      ZIP:json['zip'],
      city:json['city'],
      country_code:json['country_code'],
      st_code:json['region_code'],
      country_name:json['country_name'],
      state_name:json['region_name'],
    );
  }
  @override
  String toString() {
    return 'Your current location { IP : $IP , ZIP : $ZIP, City :$city , State: $st_code,Country: $country_code }';
  }
}

class Place{
  final String ZIP;
  final String county;
  final String msa;

  Place({this.ZIP, this.county, this.msa});

  factory Place.fromJson(Map<String, dynamic> json){
    return Place(
      ZIP:json['ZIP'],
      county:json['county'],
      msa:json['msa'],
    );
  }
  @override
  String toString() {
    return 'Your current location { County: $county, MSA : $msa  }';
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

 // final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  String _zip;
  String _city;
  String _county;
  String _state;
  String _state_name;
  String _msa;
  ScreenData _args;
  String _currentAddress = "not known";
  bool _isLoading = false;
  IP_info ip_info;

  @override
  void initState() {
      _isLoading=true;
      //_getCurrentLocation();
     _getPublicIP();
  }

_getPublicIP() async {
    try {
      const url = 'http://api.ipstack.com/check?access_key=59d1a13ca47d85f624da51aec4b53449&format=1';
      final response = await http.get(url);
      if (response.statusCode == 200) {
        ip_info =  IP_info.fromJson(json.decode(response.body));
        setState(() {
          _zip = "${ip_info.ZIP}";
          _city = "${ip_info.city}";
          _state = "${ip_info.st_code}";
          _state_name = "${ip_info.state_name}";

          _currentAddress ="${ip_info.city}, ${ip_info.st_code} ${ip_info.ZIP}, ${ip_info.country_code}";
        });

        List<Place> uszip = await fetchPlace();

        Place _currentArea = uszip.firstWhere((i) => i.ZIP == _zip);
        setState(() {
          _county = "${_currentArea.county}";
          _msa = "${_currentArea.msa}";
          _isLoading = false;
          _args=ScreenData(_county,_state,_msa,_state_name);
        });
      }
      else {
        // The request failed with a non-200 code
        print(response.statusCode);
        print(response.body);
      }
    } catch (e) {
      print(e);
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

