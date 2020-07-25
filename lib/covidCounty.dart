import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'screenData.dart';
import 'package:charts_flutter/flutter.dart' as charts;

/* Covid County level information */
class CovidCounty {
  final String casedate;
  final int cases;
  final int deaths;
  final int newCases;
  final int newDeaths;
  final String county;
  final String state_name;

  CovidCounty({this.casedate,this.county,this.state_name, this.cases,this.deaths, this.newCases, this.newDeaths});

  factory CovidCounty.fromJson(Map<String, dynamic> json) {
    return CovidCounty(
      casedate: json['date'],
      county:json['county'],
      state_name:json['state'],
      cases: json['cases'],
      deaths: json['deaths'],
      newCases:json['new cases'],
      newDeaths:json['new deaths'],
    );
  }

}

class CountyHome extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    final ScreenData screenargs= ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Covid Statistics in ${screenargs.county} County'),
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
                                MaterialPageRoute(builder: (context) => CovidCountysList(),
                                  settings: RouteSettings(
                                    arguments: ScreenData(screenargs.county, screenargs.state, screenargs.msa, screenargs.state_name),
                                  ),
                                )
                            );
                          },
                          child: Text("New Cases in ${screenargs.county} county",
                            style: TextStyle(fontSize: 14.0,),),
                        ),
                        SizedBox(height: 10,),
                        RaisedButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => CovidCountyDeaths(),
                                  settings: RouteSettings(
                                    arguments: ScreenData(screenargs.county, screenargs.state, screenargs.msa, screenargs.state_name),
                                  ),
                                )
                            );
                          },
                          child: Text("New Deaths in ${screenargs.county} county",
                            style: TextStyle(fontSize: 14.0,),),
                        ),
                        SizedBox(height: 10,),
                        RaisedButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => CovidCountysallDeaths(),
                                  settings: RouteSettings(
                                    arguments: ScreenData(screenargs.county, screenargs.state, screenargs.msa, screenargs.state_name),
                                  ),
                                )
                            );
                          },
                          child: Text("All Deaths in ${screenargs.county} county",
                            style: TextStyle(fontSize: 14.0,),),
                        ),
                      ],
                    ),
                  );
                }))); 
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
                List<charts.Series<CovidCounty, String>> series = [
      charts.Series(
          id: "New Cases in ${screenargs.county} County",
          data: covidCases,
          domainFn: (CovidCounty series, _) => series.casedate,
          measureFn: (CovidCounty series, _) => series.newCases,

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
                "New Cases in ${screenargs.county} county",
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
class CovidCountyDeaths extends StatelessWidget {
  List<CovidCounty> covidCases ;

  //CovidCountysList(this._arg});
  CovidCountyDeaths({Key key, @required this.covidCases}) : super(key: key);

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
                List<charts.Series<CovidCounty, String>> series = [
      charts.Series(
          id: "New Deaths in ${screenargs.county} County",
          data: covidCases,
          domainFn: (CovidCounty series, _) => series.casedate,
          measureFn: (CovidCounty series, _) => series.newDeaths,

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
                "New Deaths in ${screenargs.county} County",
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
class CovidCountysallDeaths extends StatelessWidget {
  List<CovidCounty> covidCases ;

  //CovidCountysList(this._arg});
  CovidCountysallDeaths({Key key, @required this.covidCases}) : super(key: key);

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
                List<charts.Series<CovidCounty, String>> series = [
      charts.Series(
          id: "All Deaths in ${screenargs.county} county",
          data: covidCases,
          domainFn: (CovidCounty series, _) => series.casedate,
          measureFn: (CovidCounty series, _) => series.deaths,

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
                "All Deaths in ${screenargs.county} county",
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
    (covid.county == _county && DateTime.parse(covid.casedate).isAfter(DateTime.now().add(Duration(days: -15))))).toList();
    returnList.sort((b,a) => b.casedate.compareTo(a.casedate));
    return returnList;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Covid County Cases');
  }
}

