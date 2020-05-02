import 'package:calorierecorder/utils.dart';
import 'package:flutter/material.dart';

class CalorieRecordList extends StatefulWidget {
  final String date;
  final bool isToday;
  final List<Map<String, dynamic>> records;

  const CalorieRecordList(
      {Key key,
      @required this.date,
      @required this.records,
      @required this.isToday})
      : assert(date != null),
        assert(records != null),
        assert(isToday != null),
        super(key: key);

  @override
  _CalorieRecordListState createState() => _CalorieRecordListState();
}

class _CalorieRecordListState extends State<CalorieRecordList> {
  String date;
  List<Map<String, dynamic>> records;
  bool isToday = false;
  List<RecordItem> _recordList;

  @override
  Widget build(BuildContext context) {
    records = widget.records;
    return SingleChildScrollView(
      child: Container(
        child: _buildRecordListWidgets(_recordList),
      ),
    );
  }

  Widget _buildRecordListWidgets(List<RecordItem> _recordList) {
    if (_recordList.isEmpty) _recordList = generateItems(records);
    setState(() {

    });
    return (_recordList.isEmpty)
        ? Center(child: Text('No Data'))
        : ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                _recordList[index].isExpanded = !isExpanded;
              });
            },
            children: _recordList.map<ExpansionPanel>((RecordItem item) {
              return ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                    title: Text(item.headerValue['display'].toString()),
                  );
                },
                body: (isToday)
                    ? ListTile(
                        title: Text(item.expandedValue['display1']),
                        subtitle: Text(item.expandedValue['display2']),
                        trailing: Icon(Icons.delete),
                        onTap: () {
                          setState(() {
                            records.removeAt(_recordList.indexOf(item));
                            _recordList.removeWhere(
                                (currentItem) => item == currentItem);
                            saveSomeDayData(date,
                                reCalculateCalorieValue(records), records);
                          });
                        })
                    : ListTile(
                        title: Text(item.expandedValue['display1']),
                        subtitle: Text(item.expandedValue['display2']),
                        trailing: Icon(Icons.delete),
                        onTap: () {
                          setState(() {

                          });
                        },
                      ),
                isExpanded: item.isExpanded,
              );
            }).toList(),
          );
  }

  @override
  void initState() {
    super.initState();
    date = widget.date;
    records = widget.records;
    isToday = widget.isToday;
    _recordList = generateItems(records);
  }
}

class RecordItem {
  RecordItem({
    this.expandedValue,
    this.headerValue,
    this.isExpanded = false,
  });

  Map expandedValue;
  Map headerValue;
  bool isExpanded;
}

List<RecordItem> generateItems(List<Map<String, dynamic>> records) {
  List<RecordItem> recordItemList = [];
  records.forEach((element) {
    if (!element.containsKey('null')) {
      recordItemList.add(RecordItem(
        headerValue: {
          'time': element['time'],
          'food': element['food'],
          'calorie': element['calorie'],
          'display':
              '${element['time']}: ${element['food']}(${element['calorie']} kCals)'
        },
        expandedValue: {
          'time': element['time'],
          'food': element['food'],
          'weight': element['weight'],
          'type': element['type'],
          'calorie': element['calorie'],
          'display1':
              '${element['food']} - ${element['weight']}(${element['calorie']} kCals)',
          'display2': '${element['type']}'
        },
      ));
    }
  });
  return recordItemList;
}
