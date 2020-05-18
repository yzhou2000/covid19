import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'screenData.dart';

/* Covid County level information */
class CovidCounty {
  final String casedate;
  final int confirmed;
  final int deaths;
  final String county;
  final String state_name;

  CovidCounty({this.casedate,this.county,this.state_name, this.confirmed,this.deaths});

  factory CovidCounty.fromJson(Map<String, dynamic> json) {
    return CovidCounty(
      casedate: json['date'],
      county:json['county'],
      state_name:json['state'],
      confirmed: json['cases'],
      deaths: json['deaths'],
    );
  }
  @override
  String toString() {
    return 'Your current covid case info { County: $county,State: $state_name, casedate : $casedate , confirmed case : $confirmed, deaths :$deaths }';
  }
}

class CovidCountysList extends StatelessWidget {
  List<CovidCounty> covidCases ;

  //CovidCountysList(this._arg});
  CovidCountysList({Key key, @required this.covidCases}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final ScreenData screenargs= ModalRoute.of(context).settings.arguments;
    return
      new Scaffold(
          appBar: AppBar(title: Text("${screenargs.county} County Covid status"),),
          body:   FutureBuilder<List<CovidCounty>>(
              future: fetchCovidCounty(http.Client(), screenargs.state, screenargs.county),
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
                        child: Center(child:  Text( 'As of ' + covidCases[index].casedate + ' ,' + covidCases[index].county + ' county has ' + covidCases[index].confirmed.toString() + ' cases, and ' + covidCases[index].deaths.toString() + ' deaths')),
                      );
                    }
                );
              }
          )
      );
  }
}

Future<List<CovidCounty>> fetchCovidCounty(http.Client client, String _state, String _county) async {
  String link = "https://raw.githubusercontent.com/yzhou2000/covid_json/master/" +
      _state + ".json";

  final response = await client.get(link);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    // print(response.body);
    List<CovidCounty> responseList = parsed.map<CovidCounty>((json) =>
        CovidCounty.fromJson(json)).toList();
    List<CovidCounty> returnList = responseList.where((covid) =>
    (covid.county == _county && DateTime.parse(covid.casedate).isAfter(DateTime.now().add(Duration(days: -9))))).toList();
    returnList.sort((a,b) => b.casedate.compareTo(a.casedate));
    return returnList;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Covid County Cases');
  }
}

