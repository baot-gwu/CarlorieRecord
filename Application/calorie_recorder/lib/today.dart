import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:calorierecorder/app.dart';
import 'package:calorierecorder/utils.dart';
import 'package:calorierecorder/calorie_record_list.dart';

class TodayPage extends StatefulWidget {
  final DateTime date;

  const TodayPage({Key key, @required this.date})
      : assert(date != null),
        super(key: key);

  @override
  _TodayPageState createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  DateTime date;
  double calorieValue = 0.0;
  List<Map<String, dynamic>> calorieRecords = [];
  bool isToday;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail of ${isToday ? 'Today' : DateFormat.yMMMMd('en_US').format(date).toString()}'),
      ),
      body: SafeArea(
        child: ListView(padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: [
            SizedBox(height: 40.0),
            Column(
              children: [
                Text('Calorie intake',
                    style:
            new TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0)),
                CircularPercentIndicator(
                  radius: 180.0,
                  lineWidth: 15.0,
                  animation: true,
                  percent: percentLimiter(calorieValue),
                  center: new Text(
                    '${calorieValue.toString()} kCals',
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                  footer: new Text(
                    (calorieValue / targetCalorie < 1.0)
                        ? 'Calorie intake in control'
                        : 'Calorie intake exceeded!',
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: (calorieValue > targetCalorie) ? Colors.blue : Colors.black26,
                  progressColor: dynamicProgressIndicatorColorWithValue(calorieValue),
                ),
              ],
            ),
            SizedBox(height: 40.0),
            Column(
              children: [
                Text('Calorie Intake History',
                    style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0)),
                SizedBox(height: 20.0),
                CalorieRecordList(date: DateFormat('yyyyMMdd').format(date).toString(), records: (calorieRecords.isEmpty)? [{'null': true}] : calorieRecords, isToday: isToday),
              ],
            ),
          ],
        ),
      )
    );
  }

  void initState() {
    date = widget.date;
    isToday = (DateFormat('yyyyMMdd').format(date).toString() == DateFormat('yyyyMMdd').format(DateTime.now()).toString());
    initFunction();
    super.initState();
  }

  void initFunction() async {
    if (isToday) {
      calorieValue = todayCalorie;
      calorieRecords = todayRecords;
    } else {
      Map<String, dynamic> storageData = await loadSomeDayData(DateFormat('yyyyMMdd').format(date).toString());
      calorieValue = storageData['calorieValue'];
      calorieRecords = storageData['records'];
      setState(() {

      });
    }
  }
}
