import 'package:babsuni/datelist_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart';

class CheckOrderSchedule extends StatefulWidget {
  @override
  _CheckOrderScheduleState createState() => _CheckOrderScheduleState();
}

class _CheckOrderScheduleState extends State<CheckOrderSchedule>
    with TickerProviderStateMixin {
  Database databaseOrder;
  Database databaseUser;
  List _selectedEvents;
  AnimationController _animationController;
  CalendarController _calendarController;
  List<Map> queryDate;
  List<Map> queryAddr = [];
  Map<DateTime, List> list = Map();
  List<int> monthDay = [-1, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  List<List<Map>> queryResult = [];
  Future<void> _openDB() async {
    String dbPath = join(await getDatabasesPath(), 'test1.db');
    databaseUser = await openDatabase(dbPath, onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE IF NOT EXISTS user_info (id INTEGER PRIMARY KEY, name TEXT, phone TEXT, kakao TEXT, address TEXT, password TEXT, remark TEXT, remain INTEGER)');
    }, version: 1);
  }

  Future<void> _openDB2() async {
    String dbPath = join(await getDatabasesPath(), 'test2.db');
    databaseOrder = await openDatabase(dbPath, onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE IF NOT EXISTS order_info (id INTEGER, date TEXT, content TEXT, time TEXT, FOREIGN KEY (id) REFERENCES user_info(id))');
    }, version: 1);
    queryDB();
  }

  void queryDB() async {
    queryDate = await databaseOrder.rawQuery('SELECT date,id FROM order_info ');
    for (int i = 0; i < queryDate.length; ++i) {
      queryAddr = await databaseUser.rawQuery(
          'SELECT address FROM user_info WHERE id = ?', [queryDate[i]['id']]);
      queryResult.add(queryAddr);
    }
    var now = DateTime.now().toString();
    var nowDate = DateTime.now();
    for (int i = 0; i < queryDate.length; ++i) {
      var month = getExtractMonth(queryDate[i]['date'].toString());
      var day = getExtractDay(queryDate[i]['date'].toString());
      var curMonth = getExtractMonth(now);
      var curDay = getExtractDay(now);

      if (curMonth > month) {
        if (list.containsKey(
            nowDate.subtract(Duration(days: monthDay[month] - day + curDay)))) {
          list.update(
              nowDate.subtract(Duration(days: monthDay[month] - day + curDay)),
              (value) {
            value.add('t');
            return value;
          });
        } else {
          list[nowDate.subtract(
              Duration(days: monthDay[month] - day + curDay))] = ['t'];
        }
      } else if (curMonth < month) {
        if (list.containsKey(
            nowDate.add(Duration(days: monthDay[curMonth] - curDay + day)))) {
          list.update(
              nowDate.add(Duration(days: monthDay[curMonth] - curDay + day)),
              (value) {
            value.add('t');
            return value;
          });
        } else {
          list[nowDate.add(Duration(days: monthDay[curMonth] - curDay + day))] =
              ['t'];
        }
      } else {
        if (curDay > day) {
          if (list
              .containsKey(nowDate.subtract(Duration(days: curDay - day)))) {
            list.update(nowDate.subtract(Duration(days: curDay - day)),
                (value) {
              value.add('t');
              return value;
            });
          } else {
            list[nowDate.subtract(Duration(days: curDay - day))] = ['t'];
          }
        } else {
          if (list.containsKey(nowDate.add(Duration(days: day - curDay)))) {
            list.update(nowDate.add(Duration(days: day - curDay)), (value) {
              value.add('t');
              return value;
            });
          } else {
            list[nowDate.add(Duration(days: day - curDay))] = ['t'];
          }
        }
      }
    }
    _selectedEvents = list[nowDate] ?? [];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _openDB();
    _openDB2();
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    // print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    // print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    // print('CALLBACK: _onCalendarCreated');
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            Text(
              '밥수니반찬 주문 스케줄 조회',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 10),),
            _buildTableCalendarWithBuilders(),
            const SizedBox(height: 40.0),
            FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: size.width * 0.4,
                  height: 60,
                  alignment: Alignment.center,
                  child: Text(
                    '이전',
                    textScaleFactor: 1.4,
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.cyan)),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      rowHeight: 80,
      onHeaderTapped: (value) {
        DatePicker.showDatePicker(
          this.context,
          showTitleActions: true,
          minTime: DateTime(2016, 1, 1),
          maxTime: DateTime(2050, 12, 31),
          onChanged: (date) {
            _calendarController.setSelectedDay(date);
          },
          currentTime: DateTime.now(),
          locale: LocaleType.ko,
          onConfirm: (date) {
            setState(() {
              _calendarController.setSelectedDay(date);
            });
          },
        );
      },
      locale: 'ko_KR',
      calendarController: _calendarController,
      events: list,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: const {
        CalendarFormat.month: '',
        CalendarFormat.week: '',
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
        holidayStyle: TextStyle().copyWith(color: Colors.blue[800]),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
      ),
      headerStyle: HeaderStyle(
          centerHeaderTitle: true,
          formatButtonVisible: false,
          titleTextStyle:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          decoration: BoxDecoration(
              color: Colors.cyanAccent,
              border: Border.all(color: Colors.black, width: 1)),
          headerMargin: EdgeInsets.symmetric(vertical: 10)),
      builders: CalendarBuilders(
        dayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(0.5),
            padding: const EdgeInsets.only(top: 10.0, left: 1.0),
            width: 100,
            height: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.cyan, width: 2)),
            child: Column(
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle().copyWith(fontSize: 14.0),
                ),
                Text(
                  getShortAddress(date.month, date.day),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 8),
                )
              ],
            ),
          );
        },
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(0.5),
              padding: const EdgeInsets.only(top: 10.0, left: 1.0),
              color: Colors.deepOrange[300],
              width: 100,
              height: 100,
              child: Column(
                children: [
                  Text(
                    '${date.day}',
                    style: TextStyle().copyWith(fontSize: 14.0),
                  ),
                  Text(
                    getShortAddress(date.month, date.day),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 8),
                  )
                ],
              ),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(0.5),
            padding: const EdgeInsets.only(top: 10.0, left: 1.0),
            color: Colors.amber[400],
            width: 100,
            height: 100,
            child: Column(
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle().copyWith(fontSize: 14.0),
                ),
                Text(
                  getShortAddress(date.month, date.day),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 8),
                )
              ],
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];
          if (events.isNotEmpty) {
            // print(events);
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }
          return children;
        },
      ),
      onDaySelected: (date, events, holidays) {
        print(events);
        _onDaySelected(date, events, holidays);
        _animationController.forward(from: 0.0);
        Navigator.push(this.context, MaterialPageRoute(builder: (ctx) {
          return CurrentDateListPage(
            date: date.toString(),
          );
        }));
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
            ? Colors.brown[500]
            : _calendarController.isToday(date)
                ? Colors.brown[300]
                : Colors.blue[400],
      ),
      width: 20.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  int getExtractDay(String ymd) {
    return int.parse(ymd.substring(8, 10));
  }

  int getExtractMonth(String ymd) {
    return ymd.substring(5, 6).compareTo('0') == 0
        ? int.parse(ymd.substring(6, 7))
        : int.parse(ymd.substring(5, 7));
  }

  String getShortAddress(int month, int day) {
    String m = '';
    int count = 0;
    try {
      for (int i = 0; i < queryDate.length; ++i) {
        if (count == 3) return m;
        if (day == getExtractDay(queryDate[i]['date']) &&
            month == getExtractMonth(queryDate[i]['date'])) {
          m += queryResult[i][0]['address'].toString().split(' ')[3] +
              ' ' +
              queryResult[i][0]['address'].toString().split(' ')[4];
          m += '\n';
          count++;
        }
      }
      return m;
    } catch (e) {}
    return '';
  }
}
