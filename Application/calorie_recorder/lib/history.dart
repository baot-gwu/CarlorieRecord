import 'package:calorierecorder/app.dart';
import 'package:calorierecorder/today.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:calorierecorder/utils.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:date_utils/date_utils.dart' as lastDayTool;

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _currentMonth = DateFormat.yMMM().format(DateTime.now());
  DateTime _currentDate = DateTime.now();
  DateTime _targetDateTime = DateTime.now();
  CalendarCarousel _calendarCarousel;
  List<DateTime> loadedMonths = [];
//  Map<String, Map<String, dynamic>> allDetails = {};

  @override
  Widget build(BuildContext context) {
    _calendarCarousel = CalendarCarousel<Event>(
      todayBorderColor: dynamicProgressIndicatorColorWithValue(todayCalorie),
      onDayPressed: (DateTime date, List<Event> events) {
        this.setState(() => {_currentDate = date});
        events.forEach((event) => {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => new TodayPage(date: event.date))
          )
        });
      },
      daysHaveCircularBorder: true,
      showOnlyCurrentMonthDate: false,
      thisMonthDayBorderColor: Colors.transparent,
      weekFormat: false,
      markedDatesMap: _markedDateMap,
      height: 420.0,
      targetDateTime: _targetDateTime,
      customGridViewPhysics: NeverScrollableScrollPhysics(),
      markedDateCustomShapeBorder:
          CircleBorder(side: BorderSide(color: Colors.transparent)),
      minSelectedDate: _currentDate.subtract(Duration(days: 360)),
      maxSelectedDate: _currentDate.add(Duration(days: 360)),
      markedDateCustomTextStyle: TextStyle(
        fontSize: 18,
        color: Colors.blue,
      ),
      showHeader: false,
      todayTextStyle: TextStyle(
        color: Colors.blue,
      ),
       markedDateShowIcon: true,
      // markedDateIconMaxShown: 2,
       markedDateIconBuilder: (event) {
         return event.icon;
       },
      // markedDateMoreShowTotal:
      //     true,
      todayButtonColor: Colors.transparent,
//      selectedDayTextStyle: TextStyle(
//        color: Colors.yellow,
//      ),
      prevDaysTextStyle: TextStyle(
        fontSize: 16,
        color: Colors.pinkAccent,
      ),
      inactiveDaysTextStyle: TextStyle(
        color: Colors.tealAccent,
        fontSize: 16,
      ),
      onCalendarChanged: (DateTime date) {
        this.setState(() {
          _targetDateTime = date;
          _currentMonth = DateFormat.yMMM().format(_targetDateTime);
          updateCalendar(_targetDateTime.month.toString(), _targetDateTime.year.toString());
        });
      },
      markedDateIconMargin: 0.0,
      onDayLongPressed: (DateTime date) {
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                  top: 30.0,
                  bottom: 16.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: new Row(
                  children: <Widget>[
                    Expanded(
                        child: Text(
                      _currentMonth,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                    )),
                    FlatButton(
                      child: Text('PREV'),
                      onPressed: () {
                        setState(() {
                          _targetDateTime = DateTime(
                              _targetDateTime.year, _targetDateTime.month - 1);
                          _currentMonth =
                              DateFormat.yMMM().format(_targetDateTime);
                          updateCalendar(_targetDateTime.month.toString(), _targetDateTime.year.toString());
                        });
                      },
                    ),
                    FlatButton(
                      child: Text('NEXT'),
                      onPressed: () {
                        setState(() {
                          _targetDateTime = DateTime(
                              _targetDateTime.year, _targetDateTime.month + 1);
                          _currentMonth =
                              DateFormat.yMMM().format(_targetDateTime);
                          updateCalendar(_targetDateTime.month.toString(), _targetDateTime.year.toString());
                        });
                      },
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                child: _calendarCarousel,
              ),
              //
            ],
          ),
        ),
      ),
    );
  }

  Widget _eventIcon(double calorieValue) {
    return CircularPercentIndicator(
      radius: 27.0,
      lineWidth: 2.0,
      percent: percentLimiter(calorieValue),
//      center: dynamicIcon(percentLimiter(calorieValue)),
      progressColor: dynamicProgressIndicatorColorWithValue(calorieValue),
    );
  }

  Icon dynamicIcon(double percent) {
    Icon returnIcon;
    double iconSize = 20.0;
    if (percent == 0.0) {
      returnIcon = Icon(
        Icons.cancel,
        size: iconSize,
        color: Colors.grey,
      );
    } else if (percent < 0.8) {
      returnIcon = Icon(
        Icons.check_circle,
        size: iconSize,
        color: Colors.green,
      );
    } else if (percent <= 1.0) {
      returnIcon = Icon(
        Icons.check_circle,
        size: iconSize,
        color: Colors.yellow,
      );
    } else {
      returnIcon = Icon(
        Icons.warning,
        size: iconSize,
        color: Colors.red,
      );
    }

    return returnIcon;
  }

  EventList<Event> _markedDateMap = EventList<Event>();

  Future updateCalendar(String month, String year) async {
    final DateTime _date = new DateTime(int.parse(year), int.parse(month));
    if (!loadedMonths.contains(_date)) {
      loadedMonths.add(_date);
      List daysInMonth = List.generate(lastDayTool.Utils.lastDayOfMonth(_date).day, (index) => index + 1);
      for (int i = 1; i <= daysInMonth.length; i++) {
        final calorieDetail =
        await loadSomeDayData('$year${(month.length < 2) ? '0$month' : month}${(i < 10) ? '0$i' : i}');
//        allDetails['$year${(month.length < 2) ? '0$month' : month}${(i < 10) ? '0$i' : i}'] = calorieDetail['records'];
        try {
          _markedDateMap.add(
              DateTime(int.parse(year), int.parse(month), i),
              Event(
                date: DateTime(int.parse(year), int.parse(month), i),
                icon: _eventIcon(calorieDetail['calorieValue']),
              ));
        } catch (e) {}
      }
      setState(() {

      });
    }
  }

  @override
  void initState() {
    super.initState();
    updateCalendar(
        DateTime.now().month.toString(), DateTime.now().year.toString());
  }
}
