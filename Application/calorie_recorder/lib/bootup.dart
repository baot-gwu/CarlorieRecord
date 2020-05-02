import 'dart:ui';
import 'package:calorierecorder/app.dart';
import 'package:flutter/material.dart';
import 'package:calorierecorder/colors.dart';
import 'dart:async';
import 'package:calorierecorder/utils.dart';
import 'package:intl/intl.dart';

class BootUpPage extends StatefulWidget {
  @override
  _BootUpPageState createState() => new _BootUpPageState();
}

class _BootUpPageState extends State<BootUpPage> {
  int count = 0;
  Timer _timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BootupBackgroundColor,
      body: Center(
        child: Container(
          child: Image.asset('assets/images/slash.png', fit: BoxFit.cover),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initFunction();
    _timer = new Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {});
      if (count <= 0) {
        _timer.cancel();
//        debugPrint(MediaQuery.of(context).size.toString());
        Navigator.popUntil(context, ModalRoute.withName('/'));
      } else {
        count--;
      }
    });
  }

  void initFunction() async {
    todayDate = DateFormat('yyyyMMdd').format(DateTime.now()).toString();
    await loadTodayData();
  }
}
