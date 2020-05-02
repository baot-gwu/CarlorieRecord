import 'package:calorierecorder/app.dart';
import 'package:calorierecorder/utils.dart';
import 'package:flutter/material.dart';
import 'package:calorierecorder/colors.dart';
import 'package:calorierecorder/ml.dart';

class RecordPage extends StatefulWidget {
  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final _foodController = new TextEditingController();
  final _weightController = new TextEditingController();
  final _calorieController = new TextEditingController();
  final _typeController = new TextEditingController();
  TimeOfDay picked = TimeOfDay.now();

  Future<Null> _selectTime(BuildContext context) async {
    picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    setState(() {});
  }

  Future<Null> _saveData() async{
    Map<String, dynamic> newRecord = {
      'time': '${(picked.hour < 10)? '0${picked.hour}' : picked.hour}:${(picked.minute < 10)? '0${picked.minute}' : picked.minute}',
      'food': (_foodController.text.isEmpty) ? 'Some Food' : _foodController.text,
      'weight': (_weightController.text.isEmpty) ? '0g' : '${_foodController.text}g',
      'type': (_typeController.text.isEmpty) ? 'General' : _typeController.text,
      'calorie': (_calorieController.text.isEmpty) ? 0.0 : double.parse(_calorieController.text)
    };
    todayRecords.add(newRecord);
    saveTodayData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record'),
      ),
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            AccentColorOverride(
              color: gwuBlue,
              child: TextField(
                controller: _foodController,
                maxLength: 50,
                decoration: InputDecoration(
                  labelText: 'Food Name',
                ),
              ),
            ),
            AccentColorOverride(
              color: gwuBlue,
              child: TextField(
                controller: _weightController,
                maxLength: 50,
                decoration: InputDecoration(
                  labelText: 'Food Weight',
                ),
              ),
            ),
            AccentColorOverride(
              color: gwuBlue,
              child: TextField(
                controller: _calorieController,
                maxLength: 50,
                decoration: InputDecoration(
                  labelText: 'Food Total Calorie',
                ),
              ),
            ),
            Divider(),
            SizedBox(
              height: 10.0,
            ),
            AccentColorOverride(
              color: gwuBlue,
              child: TextField(
                controller: _typeController,
                maxLength: 50,
                decoration: InputDecoration(
                  labelText: 'Food Type',
                ),
              ),
            ),
            RaisedButton(
              child: Text('Select Time'),
              onPressed: () {
                _selectTime(context);
              },
            ),
            RaisedButton(
              child: Text('AI Scan'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => ScanPage()));
              },
            ),
            Divider(),
            SizedBox(
              height: 10.0,
            ),
            SizedBox(
              width: double.infinity, // match_parent
              child: RaisedButton(
                child: Text('Add Another'),
                onPressed: () {
                  _saveData();
                  _calorieController.clear();
                  _typeController.clear();
                  _weightController.clear();
                  _foodController.clear();
                  picked = TimeOfDay.now();
                },
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            SizedBox(
              width: double.infinity, // match_parent
              child: RaisedButton(
                child: Text('Save'),
                onPressed: () {
                  _saveData();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
