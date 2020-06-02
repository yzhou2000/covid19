import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'screenData.dart';


/* Covid State level information */
class CovidState {
  final String casedate;
  final int cases;
  final int deaths;
  final int newCases;
  final int newDeaths;
  final String state_name;

  CovidState({this.casedate,this.state_name, this.cases,this.deaths, this.newCases, this.newDeaths});

  factory CovidState.fromJson(Map<String, dynamic> json) {
    return CovidState(
      casedate: json['date'],
      state_name:json['state'],
      cases: json['cases'],
      deaths: json['deaths'],
      newCases:json['new cases'],
      newDeaths:json['new deaths'],
   );
  }
}

class CovidStatesList extends StatelessWidget {
  List<CovidState> covidCases ;


  CovidStatesList({Key key, @required this.covidCases}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final ScreenData screenargs= ModalRoute.of(context).settings.arguments;
    return
      new Scaffold(
          appBar: AppBar(title: Text("${screenargs.state} Covid status"),),
          body:   FutureBuilder<List<CovidState>>(
              future: fetchCovidState(http.Client(), screenargs.state_name),
              builder: (context, snapshot) {
                if(snapshot.connectionState != ConnectionState.done) {
                  return Center(child: CircularProgressIndicator());
                }
                if(snapshot.hasError) {
                  return     Text("${snapshot.error}"); }
                covidCases= snapshot.data ?? [];
                return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: covidCases.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 50,
                        child: Center(child:  Text( 'As of ' + covidCases[index].casedate + ',' + covidCases[index].state_name + ' state has ' + covidCases[index].newCases.toString() + ' new cases and ' + covidCases[index].newDeaths.toString() + ' new deaths')),
                      );
                    }
                );
              }
          )
      );
  }
}

Future<List<CovidState>> fetchCovidState(http.Client client, String _state_name) async {
  String link = "https://raw.githubusercontent.com/yzhou2000/covid_json/master/us_states_covid.json";

  final response = await client.get(link);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    // print(response.body);
    List<CovidState> responseList = parsed.map<CovidState>((json) =>
        CovidState.fromJson(json)).toList();
    List<CovidState> returnList = responseList.where((covid) =>
    (covid.state_name == _state_name && DateTime.parse(covid.casedate).isAfter(DateTime.now().add(Duration(days: -15))))).toList();
    returnList.sort((a,b) => b.casedate.compareTo(a.casedate));
    return returnList;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Covid County Cases');
  }
}
