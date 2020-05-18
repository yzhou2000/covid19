/* Covid Metro level information */
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'screenData.dart';


class CovidMetro {
  final String casedate;
  final int confirmed;
  final int deaths;
  final String msa;

  CovidMetro({this.casedate,this.msa, this.confirmed,this.deaths});

  factory CovidMetro.fromJson(Map<String, dynamic> json) {
    return CovidMetro(
      casedate: json['date'],
      msa:json['msa'],
      confirmed: json['cases'],
      deaths: json['deaths'],
    );
  }
  @override
  String toString() {
    return 'Your current covid case info { Metro: $msa, casedate : $casedate , confirmed case : $confirmed, deaths :$deaths }';
  }
}

class CovidMetrosList extends StatelessWidget {
  List<CovidMetro> covidCases ;


  CovidMetrosList({Key key, @required this.covidCases}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final ScreenData screenargs= ModalRoute.of(context).settings.arguments;
    return
      new Scaffold(
          appBar: AppBar(title: Text("${screenargs.msa} Metro Covid status"),),
          body:   FutureBuilder<List<CovidMetro>>(
              future: fetchCovidMetro(http.Client(), screenargs.msa),
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
                        child: Center(child:  Text( 'As of ' + covidCases[index].casedate + ' ,' + covidCases[index].msa + ' metro has ' + covidCases[index].confirmed.toString() + ' cases, and ' + covidCases[index].deaths.toString() + ' deaths')),
                      );
                    }
                );
              }
          )
      );
  }
}

Future<List<CovidMetro>> fetchCovidMetro(http.Client client, String _msa) async {
  String link = "https://raw.githubusercontent.com/yzhou2000/covid_json/master/us_msa_covid.json";

  final response = await client.get(link);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    // print(response.body);
    List<CovidMetro> responseList = parsed.map<CovidMetro>((json) =>
        CovidMetro.fromJson(json)).toList();
    List<CovidMetro> returnList = responseList.where((covid) =>
    (covid.msa == _msa && DateTime.parse(covid.casedate).isAfter(
        DateTime.now().add(Duration(days: -9))))).toList();
    returnList.sort((a, b) => b.casedate.compareTo(a.casedate));
    return returnList;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Covid County Cases');
  }
}