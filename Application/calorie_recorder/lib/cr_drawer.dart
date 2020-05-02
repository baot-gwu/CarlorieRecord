import 'package:flutter/material.dart';
import 'package:calorierecorder/app.dart';
import 'package:calorierecorder/today.dart';
import 'package:calorierecorder/history.dart';

class CalorieRecorderDrawer extends StatefulWidget {
  @override
  _CalorieRecorderDrawerStatus createState() => _CalorieRecorderDrawerStatus();
}

class _CalorieRecorderDrawerStatus extends State<CalorieRecorderDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: (globalUsername == null)
                ? Text('Click the avatar to Login')
                : Text(globalUsername),
            accountEmail: (globalUserEmail == null)
                ? Text('Please login to get the account information')
                : Text(globalUserEmail),
            currentAccountPicture: SizedBox(
              child: Image.asset('assets/images/avatar.png'),
              width: 90.0,
              height: 90.0,
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: ExactAssetImage('assets/images/background.jpg'),
              ),
            ),
          ),
          ListTile(
            title: Text('Today'),
            leading: Icon(Icons.today),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => TodayPage(date: DateTime.now())));
            },
          ),
          ListTile(
              title: Text('History'),
              leading: Icon(Icons.history),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HistoryPage()));
              })
        ],
      ),
    );
  }
}
