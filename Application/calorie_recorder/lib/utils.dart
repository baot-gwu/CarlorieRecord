import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:calorierecorder/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' show json;
import 'package:universal_html/prefer_universal/html.dart' as html;
import 'package:intl/intl.dart';


saveTodayData() async {
  if (todayDate != DateFormat('yyyyMMdd').format(DateTime.now()).toString()) {
    saveSomeDayData(todayDate, todayCalorie, todayRecords);
    todayDate = DateFormat('yyyyMMdd').format(DateTime.now()).toString();
    todayCalorie = 0.0;
    todayRecords = [];
  } else {
    if (kIsWeb) {
      html.window.localStorage['$todayDate-total'] = reCalculateCalorieValue(todayRecords).toString();
      html.window.localStorage['$todayDate-list'] = objectToJsonString(todayRecords);
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('$todayDate-total', reCalculateCalorieValue(todayRecords));
      await prefs.setString('$todayDate-list', objectToJsonString(todayRecords));
    }
  }

  loadTodayData();
}

loadTodayData() async {
  todayCalorie = await getDouble('$todayDate-total') ?? 0.0;
  todayRecords = stringJsonToObject(await getString('$todayDate-list') ?? '[]');
}

saveSomeDayData(String date, double calorieValue, List records) async {
  debugPrint('$date $calorieValue ${records.toString()}');
  if (kIsWeb) {
    html.window.localStorage['$date-total'] = calorieValue.toString();
    html.window.localStorage['$date-list'] = objectToJsonString(records);
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$date-total', calorieValue);
    await prefs.setString('$date-list', objectToJsonString(records));
  }
}

Future<Map<String, dynamic>> loadSomeDayData(String date) async {
  Map<String, dynamic> data = {};
  data['calorieValue'] = await getDouble('$date-total') ?? 0.0;
  data['records'] = stringJsonToObject(await getString('$date-list') ?? '[]');
  return data;
}

Future<String> getString(keyword) async {
  var result;
  if (kIsWeb) {
    result = html.window.localStorage[keyword];
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    result = prefs.getString(keyword);
  }

  return result;
}

Future<int> getInt(keyword) async {
  var result;
  if (kIsWeb) {
    result = int.parse(html.window.localStorage[keyword]);
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    result = prefs.getInt(keyword);
  }
  return result;
}

Future<bool> getBool(keyword) async {
  var result;
  if (kIsWeb) {
    result = (html.window.localStorage[keyword] == "true") ? true : false;
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    result = prefs.getBool(keyword);
  }
  return result;
}

Future<double> getDouble(keyword) async {
  var result;
  if (kIsWeb) {
    result = double.parse(html.window.localStorage[keyword]);
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    result = prefs.getDouble(keyword);
  }
  return result;
}

Future<List<String>> getList(keyword) async {
  var result;
  if (kIsWeb) {
    result = html.window.localStorage[keyword];
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    result = prefs.getStringList(keyword);
  }
  return result;
}

saveInt(key, value) async {
  if (kIsWeb) {
    html.window.localStorage[key] = value.toString();
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }
}

saveString(key, value) async {
  if (kIsWeb) {
    html.window.localStorage[key] = value.toString();
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }
}

saveBool(key, value) async {
  if (kIsWeb) {
    html.window.localStorage[key] = value.toString();
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }
}

saveDouble(key, value) async {
  if (kIsWeb) {
    html.window.localStorage[key] = value.toString();
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble(key, value);
  }
}

saveList(key, value) async {
  if (kIsWeb) {
    html.window.localStorage[key] = value.toString();
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, value);
  }
}

MaterialColor dynamicProgressIndicatorColor() {
  if (todayCalorie / targetCalorie < 0.8)
    return Colors.green;
  else if (todayCalorie / targetCalorie < 1.0)
    return Colors.yellow;
  else
    return Colors.red;
}

MaterialColor dynamicProgressIndicatorColorWithValue(calorieValue) {
  if (calorieValue / targetCalorie < 0.8)
    return Colors.green;
  else if (todayCalorie / targetCalorie < 1.0)
    return Colors.yellow;
  else
    return Colors.red;
}

double percentLimiter(calorieValue) {
  return (calorieValue / targetCalorie) % 1.0;
/*  if (calorieValue / targetCalorie > 1.0) return 1.0;
  else return calorieValue / targetCalorie;*/
}

List<Map<String, dynamic>> stringJsonToObject(String jsonString) {
  List tempData = json.decode(jsonString);
  List<Map<String, dynamic>> data = [];
  tempData.forEach((element) {
    data.add(element);
  });

  return data;
}

String objectToJsonString(List data) {
  String dataString = json.encode(data);
  return dataString;
}

double reCalculateCalorieValue(List<Map<String, dynamic>> records) {
  double value = 0.0;
  records.forEach((element) {
    value += element['calorie'];
  });
  return value;
}