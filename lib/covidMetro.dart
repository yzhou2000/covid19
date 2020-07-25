/* Covid Metro level information */
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'screenData.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class CovidMetro {
  final String casedate;
  final int cases;
  final int deaths;
  final int newCases;
  final int newDeaths;
  final String msa;

  CovidMetro({this.casedate,this.msa, this.cases,this.deaths, this.newCases, this.newDeaths});

  factory CovidMetro.fromJson(Map<String, dynamic> json) {
    return CovidMetro(
      casedate: json['date'],
      msa:json['msa'],
      cases: json['cases'],
      deaths: json['deaths'],
      newCases:json['new cases'],
      newDeaths:json['new deaths'],
    );
  }

}

class MetroHome extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    final ScreenData screenargs= ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Covid Statistics in ${screenargs.msa}'),
      ),
      body: Center(
        child: FutureBuilder(
              builder: (context, snapshot) {
                
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
                        Text('',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,),
                        ),
                        SizedBox(height: 100,),
                        RaisedButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => CovidMetroList(),
                                  settings: RouteSettings(
                                    arguments: ScreenData(screenargs.county, screenargs.state, screenargs.msa, screenargs.state_name),
                                  ),
                                )
                            );
                          },
                          child: Text("View New Covid Cases in ${screenargs.msa}",
                            style: TextStyle(fontSize: 14.0,),),
                        ),
                        SizedBox(height: 10,),
                        RaisedButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => CovidMetroDeaths(),
                                  settings: RouteSettings(
                                    arguments: ScreenData(screenargs.county, screenargs.state, screenargs.msa, screenargs.state_name),
                                  ),
                                )
                            );
                          },
                          child: Text("View New Deaths in ${screenargs.msa}",
                            style: TextStyle(fontSize: 14.0,),),
                        ),
                        SizedBox(height: 10,),
                        RaisedButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => CovidMetroallDeaths(),
                                  settings: RouteSettings(
                                    arguments: ScreenData(screenargs.county, screenargs.state, screenargs.msa, screenargs.state_name),
                                  ),
                                )
                            );
                          },
                          child: Text("View all Deaths in ${screenargs.msa}",
                            style: TextStyle(fontSize: 14.0,),),
                        ),
                      ],
                    ),
                  );
                }))); 
                }
                
}
class CovidMetroList extends StatelessWidget {
  List<CovidMetro> covidCases ;

  //CovidCountysList(this._arg});
  CovidMetroList({Key key, @required this.covidCases}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  
    final ScreenData screenargs= ModalRoute.of(context).settings.arguments;
    return
      new Scaffold(
          appBar: AppBar(title: Text("${screenargs.msa} County Covid status"),),
          body:   FutureBuilder<List<CovidMetro>>(
              future: fetchCovidMetro(http.Client(), screenargs.msa),
              builder: (context, snapshot) {
                if(snapshot.connectionState != ConnectionState.done) {
                  return Center(child: CircularProgressIndicator());
                }
                if(snapshot.hasError) {
                  return     Text("${snapshot.error}"); }
                covidCases= snapshot.data ?? [];
                List<charts.Series<CovidMetro, String>> series = [
      charts.Series(
          id: "New Cases in ${screenargs.msa} County",
          data: covidCases,
          domainFn: (CovidMetro series, _) => series.casedate,
          measureFn: (CovidMetro series, _) => series.newCases,

    )];

    return Container(
      height: 400,
      padding: EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                "New Cases in ${screenargs.msa}",
                style: Theme.of(context).textTheme.body2,
              ),
              Expanded(
                child: charts.BarChart(series, animate: true,
                domainAxis: charts.OrdinalAxisSpec(
                              renderSpec: charts.SmallTickRendererSpec(labelRotation: 60),
              )
              )
              )],
          ),
        ),
      ),
    );
              }));
          }
                      
                    }
class CovidMetroDeaths extends StatelessWidget {
  List<CovidMetro> covidCases ;

  //CovidMetrosList(this._arg});
  CovidMetroDeaths({Key key, @required this.covidCases}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  
    final ScreenData screenargs= ModalRoute.of(context).settings.arguments;
    return
      new Scaffold(
          appBar: AppBar(title: Text("${screenargs.msa}Covid status"),),
          body:   FutureBuilder<List<CovidMetro>>(
              future: fetchCovidMetro(http.Client(), screenargs.msa),
              builder: (context, snapshot) {
                if(snapshot.connectionState != ConnectionState.done) {
                  return Center(child: CircularProgressIndicator());
                }
                if(snapshot.hasError) {
                  return     Text("${snapshot.error}"); }
                covidCases= snapshot.data ?? [];
                List<charts.Series<CovidMetro, String>> series = [
      charts.Series(
          id: "New Deaths in ${screenargs.msa}",
          data: covidCases,
          domainFn: (CovidMetro series, _) => series.casedate,
          measureFn: (CovidMetro series, _) => series.newDeaths,

    )];

    return Container(
      height: 400,
      padding: EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                "New Deaths in ${screenargs.msa}",
                style: Theme.of(context).textTheme.body2,
              ),
              Expanded(
                child: charts.BarChart(series, animate: true,
                domainAxis: charts.OrdinalAxisSpec(
                              renderSpec: charts.SmallTickRendererSpec(labelRotation: 60),
              )
              )
              )],
          ),
        ),
      ),
    );
              }));
          }
                      
                    }
class CovidMetroallDeaths extends StatelessWidget {
  List<CovidMetro> covidCases ;

  //CovidMetrosList(this._arg});
  CovidMetroallDeaths({Key key, @required this.covidCases}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  
    final ScreenData screenargs= ModalRoute.of(context).settings.arguments;
    return
      new Scaffold(
          appBar: AppBar(title: Text("${screenargs.msa} Covid status"),),
          body:   FutureBuilder<List<CovidMetro>>(
              future: fetchCovidMetro(http.Client(), screenargs.msa),
              builder: (context, snapshot) {
                if(snapshot.connectionState != ConnectionState.done) {
                  return Center(child: CircularProgressIndicator());
                }
                if(snapshot.hasError) {
                  return     Text("${snapshot.error}"); }
                covidCases= snapshot.data ?? [];
                List<charts.Series<CovidMetro, String>> series = [
      charts.Series(
          id: "All Deaths in ${screenargs.msa}",
          data: covidCases,
          domainFn: (CovidMetro series, _) => series.casedate,
          measureFn: (CovidMetro series, _) => series.deaths,

    )];

    return Container(
      height: 400,
      padding: EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                "All Deaths in ${screenargs.msa}",
                style: Theme.of(context).textTheme.body2,
              ),
              Expanded(
                child: charts.BarChart(series, animate: true,
                domainAxis: charts.OrdinalAxisSpec(
                              renderSpec: charts.SmallTickRendererSpec(labelRotation: 60),
              )
              )
              )],
          ),
        ),
      ),
    );
              }));
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
        DateTime.now().add(Duration(days: -15))))).toList();
    returnList.sort((a, b) => b.casedate.compareTo(a.casedate));
    return returnList;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Covid Metro Cases');
  }
}