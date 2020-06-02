import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'covidMetro.dart';
import 'covidState.dart';
import 'covidCounty.dart';
import 'screenData.dart';
import 'package:http/http.dart' as http;

class IP_info{
  final String city;
  final String ZIP;
  final String state_name;
  final String country_code;
  final String country_name;

  IP_info({this.city, this.ZIP,this.state_name,this.country_code,this.country_name});

  factory IP_info.fromJson(Map<String, dynamic> json){
    return IP_info(
      ZIP:json['postal'],
      city:json['city'],
      country_code:json['country_code'],
      country_name:json['country_name'],
      state_name:json['state'],
    );
  }
  @override
  String toString() {
    return 'Your current location { ZIP : $ZIP, City :$city , State: $state_name,Country: $country_code }';
  }
}

class Place{
  final String ZIP;
  final String county;
  final String msa;
  final String st_code;
  final String st_name;

  Place({this.ZIP, this.county, this.msa, this.st_code,this.st_name});

  factory Place.fromJson(Map<String, dynamic> json){
    return Place(
      ZIP:json['ZIP'],
      county:json['county'],
      msa:json['msa'],
      st_code:json['st_code'],
      st_name:json['state'],
    );
  }
  @override
  String toString() {
    return 'Your current location { County: $county, MSA : $msa, ST_Code : $st_code, ST_name : $st_name }';
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
  Future<Place> futurePlace;
  IP_info ip_info;
  ScreenData _args;

  @override
  void initState() {
    super.initState();
    futurePlace = fetchLocation(http.Client());
  }

  Future<Place> fetchLocation(http.Client client ) async {
    String url = 'https://geolocation-db.com/json/';
    final response = await client.get(url);
    List<Place> uszip = await fetchMSA();
    if (response.statusCode == 200) {
      ip_info = IP_info.fromJson(json.decode(response.body));
      return uszip.firstWhere((i) => i.ZIP == ip_info.ZIP);
    }
    else {
      throw Exception('Failed to load IP Address');
    }
  }

  Future<List<Place>> fetchMSA() async {
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
          body: Center(
            child: FutureBuilder<Place>(
              future: futurePlace,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: new Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center ,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget> [
                        Text('Here is some COVID-19 case infomation in ${snapshot.data.county } county, ${snapshot.data.st_code}, and ${snapshot.data.msa} metro area',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,),
                        ),
                        SizedBox(height: 100,),
                        RaisedButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => CovidCountysList(),
                                  settings: RouteSettings(
                                    arguments: ScreenData(snapshot.data.county, snapshot.data.st_code, snapshot.data.msa, snapshot.data.st_name),
                                  ),
                                )
                            );
                          },
                          child: Text("Check COVID-19 cases in ${snapshot.data.county} County",
                            style: TextStyle(fontSize: 14.0,),),
                        ),
                        SizedBox(height: 10,),
                        RaisedButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => CovidStatesList(),
                                  settings: RouteSettings(
                                    arguments: ScreenData(snapshot.data.county, snapshot.data.st_code, snapshot.data.msa, snapshot.data.st_name),
                                  ),
                                )
                            );
                          },
                          child: Text("Check COVID-19 cases in ${snapshot.data.st_code} state",
                            style: TextStyle(fontSize: 14.0,),),
                        ),
                        SizedBox(height: 10,),
                        RaisedButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => CovidMetrosList(),
                                  settings: RouteSettings(
                                    arguments: ScreenData(snapshot.data.county, snapshot.data.st_code, snapshot.data.msa, snapshot.data.st_name),
                                  ),
                                )
                            );
                          },
                          child: Text("Check COVID-19 cases in ${snapshot.data.msa} metra area",
                            style: TextStyle(fontSize: 14.0,),),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                }
                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
            ),
      ),
    );
  }
}

