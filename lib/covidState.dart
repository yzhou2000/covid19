import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'screenData.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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
class StateHome extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    final ScreenData screenargs= ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Covid Statistics in ${screenargs.state}'),
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
                                MaterialPageRoute(builder: (context) => CovidStatesList(),
                                  settings: RouteSettings(
                                    arguments: ScreenData(screenargs.county, screenargs.state, screenargs.msa, screenargs.state_name),
                                  ),
                                )
                            );
                          },
                          child: Text("New Cases in ${screenargs.state}",
                            style: TextStyle(fontSize: 14.0,),),
                        ),
                        SizedBox(height: 10,),
                        RaisedButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => CovidStatesDeath(),
                                  settings: RouteSettings(
                                    arguments: ScreenData(screenargs.county, screenargs.state, screenargs.msa, screenargs.state_name),
                                  ),
                                )
                            );
                          },
                          child: Text("New Deaths in ${screenargs.state}",
                            style: TextStyle(fontSize: 14.0,),),
                        ),
                        SizedBox(height: 10,),
                        RaisedButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => CovidStatesAllDeaths(),
                                  settings: RouteSettings(
                                    arguments: ScreenData(screenargs.county, screenargs.state, screenargs.msa, screenargs.state_name),
                                  ),
                                )
                            );
                          },
                          child: Text("View All Deaths in ${screenargs.state}",
                            style: TextStyle(fontSize: 14.0,),),
                        ),
                      ],
                    ),
                  );
                }))); 
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
                 List<charts.Series<CovidState, String>> series = [
      charts.Series(
          id: "New Cases in ${screenargs.county} County",
          data: covidCases,
          domainFn: (CovidState series, _) => series.casedate,
          measureFn: (CovidState series, _) => series.newCases,

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
                "New Cases in ${screenargs.state}",
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
class CovidStatesAllDeaths extends StatelessWidget {
  List<CovidState> covidCases ;


  CovidStatesAllDeaths({Key key, @required this.covidCases}) : super(key: key);

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
                 List<charts.Series<CovidState, String>> series = [
      charts.Series(
          id: "New Cases in ${screenargs.county} County",
          data: covidCases,
          domainFn: (CovidState series, _) => series.casedate,
          measureFn: (CovidState series, _) => series.deaths,

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
                "All Deaths in ${screenargs.state}",
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
class CovidStatesDeath extends StatelessWidget {
  List<CovidState> covidCases ;


  CovidStatesDeath({Key key, @required this.covidCases}) : super(key: key);

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
                 List<charts.Series<CovidState, String>> series = [
      charts.Series(
          id: "New Cases in ${screenargs.county} County",
          data: covidCases,
          domainFn: (CovidState series, _) => series.casedate,
          measureFn: (CovidState series, _) => series.newDeaths,

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
                "New Deaths in ${screenargs.state}",
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
