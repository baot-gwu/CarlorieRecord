import 'package:flutter/material.dart';
import 'dart:async';
import 'package:calorierecorder/cr_drawer.dart';
import 'package:calorierecorder/utils.dart';
import 'package:calorierecorder/app.dart';
import 'package:calorierecorder/record.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:calorierecorder/history.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class HomeBody extends StatefulWidget {
  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Calorie Recorder!'),
      ),
      drawer: new CalorieRecorderDrawer(),
      body: new HomeBody(),
    );
  }
}

class _HomeBodyState extends State<HomeBody> {
  Timer _timer;
  double _lastTodayCalorie = 0.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:
          ListView(padding: EdgeInsets.symmetric(horizontal: 24.0), children: <
              Widget>[
        SizedBox(height: 40.0),
        Column(
          children: <Widget>[
            Text('Today\'s calorie intake',
                style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0)),
            SizedBox(height: 20.0),
            CircularPercentIndicator(
              radius: 180.0,
              lineWidth: 15.0,
              animation: true,
              percent: percentLimiter(todayCalorie),
              center: new Text(
                '${todayCalorie.toString()} /\n${targetCalorie.toString()}\nkCals',
                style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              footer: new Text(
                (todayCalorie / targetCalorie < 1.0)
                    ? 'Calorie intake in control'
                    : 'Be ware of Calorie intake!',
                style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor:
                  (todayCalorie > targetCalorie) ? Colors.blue : Colors.black26,
              progressColor: dynamicProgressIndicatorColor(),
            ),
          ],
        ),
        SizedBox(height: 40.0),
        SizedBox(
          width: double.infinity,
          child: RaisedButton(
            child: Text('Record Now'),
            onPressed: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new RecordPage()));
            },
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: RaisedButton(
            child: Text('Check History'),
            onPressed: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new HistoryPage()));
            },
          ),
        ),
      ]),
    );
  }

  @override
  void initState() {
    super.initState();
    _lastTodayCalorie = todayCalorie;
    _timer = new Timer.periodic(const Duration(seconds: 5), (timer) {
      if (todayCalorie != _lastTodayCalorie) {
        setState(() {
          _lastTodayCalorie = todayCalorie;
        });
      }
    });
    _timer = _timer;
  }
}
