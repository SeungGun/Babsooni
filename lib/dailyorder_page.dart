import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:some_calendar/some_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

enum Existence { Y, N } // 라디오 버튼 유무에 대한 enum value

class DailyOrderRegisterPage extends StatefulWidget {
  @override
  _DailyOrderRegisterPageState createState() => _DailyOrderRegisterPageState();
}

class _DailyOrderRegisterPageState extends State<DailyOrderRegisterPage> {
  Database databaseUser;
  Database databaseOrder;
  Existence _existence = Existence.N;

  TextEditingController _nameStream = TextEditingController();
  TextEditingController _phoneStream = TextEditingController();
  TextEditingController _kakaoStream = TextEditingController();
  TextEditingController _addressStream = TextEditingController();
  TextEditingController _orderContentStream = TextEditingController();

  String _selectedDate = DateTime.now()
      .toString()
      .substring(0, DateTime.now().toString().indexOf(' '));
  String initialId = '';
  String initialPassword = '';
  String initialRemark = '';
  int initialRemain = -1;
  int selected = -1;
  bool _selectMode = true; // true면 단일 선택, false면 복수 선택

  var _selectedValue = '오전 12시';
  var alertContext;
  var _selectedPreCount = '0';

  final List<String> _timeList = ['오전 12시', '오후 4시', '오후 6시'];
  List<String> prePayList = [];
  List<DataRow> dataList = [];
  List<DateTime> _selectedDates = [];


  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    Intl.systemLocale = 'ko_KR';
    _openDB();
    _openDB2();
    for (int i = 0; i <= 100; ++i) {
      prePayList.add(i.toString());
    }
  }

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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(padding: EdgeInsets.symmetric(vertical: 25)),
                Text(
                  '밥수니반찬 일일 주문 등록',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                // -------------------- 상단 ---------------------------------
                Row(
                  children: [
                    Padding(padding: EdgeInsets.only(left: size.width * 0.03)),
                    Container(
                      width: size.width * 0.2,
                      height: 60,
                      alignment: Alignment.center,
                      child: Text('주문일자'),
                      decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.cyan)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.015),
                    ),
                    Container(
                        width: size.width * 0.35,
                        height: 60,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: size.width * 0.4 * 0.6,
                              height: 60,
                              alignment: Alignment.center,
                              child: Text(
                                _selectedDate.trim(),
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            Container(
                              width: size.width * 0.4 * 0.2,
                              height: 70,
                              child: IconButton(
                                  color: Colors.blue,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                  ),
                                  onPressed: () {
                                    chooseSelectMode();
                                    // Future<DateTime> selectedDate =
                                    //     showDatePicker(
                                    //   context: context,
                                    //   initialDate: DateTime.now(), // 초깃값
                                    //   firstDate: DateTime(2016), // 시작일
                                    //   lastDate: DateTime(2050), // 마지막일
                                    //   builder:
                                    //       (BuildContext context, Widget child) {
                                    //     return Theme(
                                    //       data: ThemeData.light(), // 밝은테마
                                    //       child: child,
                                    //     );
                                    //   },
                                    // );
                                    // selectedDate.then((dateTime) {
                                    //   setState(() {
                                    //     _selectedDate = dateTime
                                    //         .toString()
                                    //         .substring(
                                    //             0,
                                    //             dateTime
                                    //                 .toString()
                                    //                 .indexOf(' '))
                                    //         .trim();
                                    //   });
                                    // });
                                  }),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.02),
                    ),
                    Container(
                        width: size.width * 0.2,
                        height: 60,
                        alignment: Alignment.center,
                        child: Text('잔여횟수'),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.015),
                    ),
                    Container(
                        width: size.width * 0.15,
                        height: 60,
                        alignment: Alignment.center,
                        child: Text(
                            initialRemain < 0 ? '-회' : '$initialRemain회',
                            style: TextStyle(fontSize: 14)),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                  ],
                ),
                // ----------------------- 첫번째 행 -------------------------------------
                Divider(
                  thickness: 2,
                  endIndent: 5,
                  indent: 12,
                  color: Colors.cyan,
                ),
                Row(
                  children: [
                    Padding(padding: EdgeInsets.only(left: size.width * 0.03)),
                    Container(
                      width: size.width * 0.2,
                      height: 60,
                      alignment: Alignment.center,
                      child: Text('입금자'),
                      decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.cyan)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.015),
                    ),
                    Container(
                        width: size.width * 0.35,
                        height: 60,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(padding: EdgeInsets.only(left: 5)),
                            Container(
                              width: size.width * 0.4 * 0.5,
                              height: 60,
                              alignment: Alignment.bottomCenter,
                              padding: EdgeInsets.only(bottom: 3),
                              child: TextField(
                                controller: _nameStream,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            Container(
                                width: size.width * 0.4 * 0.2,
                                height: 35,
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(top: 3),
                                    color: Colors.blue,
                                    icon: Icon(Icons.search),
                                    onPressed: () async {
                                      dataList.clear();
                                      List<Map> list =
                                          await databaseUser.rawQuery(
                                        "SELECT * FROM user_info WHERE name LIKE '%${_nameStream.text.toString()}%'",
                                      );
                                      getData(list, context);
                                      showSearchList(context);
                                    }),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.cyan))),
                            Padding(padding: EdgeInsets.only(right: 3))
                          ],
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.02),
                    ),
                    Container(
                        width: size.width * 0.2,
                        height: 60,
                        alignment: Alignment.center,
                        child: Text('고객번호'),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.015),
                    ),
                    Container(
                        width: size.width * 0.16,
                        height: 60,
                        alignment: Alignment.center,
                        child: Text(initialId),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                  ],
                ),
                // ---------------------- 두번째 행 -------------------
                Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                Row(
                  children: [
                    Padding(padding: EdgeInsets.only(left: size.width * 0.03)),
                    Container(
                      width: size.width * 0.2,
                      height: 60,
                      alignment: Alignment.center,
                      child: Text('전화번호'),
                      decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.cyan)),
                    ),
                    Padding(padding: EdgeInsets.only(left: size.width * 0.015)),
                    Container(
                        width: size.width * 0.35,
                        height: 60,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(padding: EdgeInsets.only(left: 5)),
                            Container(
                                alignment: Alignment.bottomCenter,
                                padding: EdgeInsets.only(bottom: 3),
                                width: size.width * 0.4 * 0.5,
                                height: 60,
                                child: TextField(
                                  controller: _phoneStream,
                                  style: TextStyle(fontSize: 11),
                                  maxLines: 3,
                                  minLines: 1,
                                )),
                            Container(
                                width: size.width * 0.4 * 0.2,
                                height: 35,
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(top: 3),
                                    color: Colors.blue,
                                    icon: Icon(Icons.search),
                                    onPressed: () async {
                                      dataList.clear();
                                      List<Map> list =
                                          await databaseUser.rawQuery(
                                        "SELECT * FROM user_info WHERE phone LIKE '%${_phoneStream.text.toString()}%'",
                                      );
                                      getData(list, context);
                                      showSearchList(context);
                                    }),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.cyan))),
                            Padding(padding: EdgeInsets.only(right: 3))
                          ],
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                    Padding(padding: EdgeInsets.only(left: size.width * 0.02)),
                    Container(
                        width: size.width * 0.15,
                        height: 60,
                        alignment: Alignment.center,
                        child: Text('카톡'),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                    Padding(padding: EdgeInsets.only(left: size.width * 0.015)),
                    Container(
                        width: size.width * 0.212,
                        height: 60,
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Container(
                              width: size.width * 0.2 * 0.67,
                              height: 60,
                              child: TextField(
                                controller: _kakaoStream,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            Container(
                                width: size.width * 0.2 * 0.3,
                                height: 30,
                                padding: EdgeInsets.only(bottom: 10),
                                child: IconButton(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(top: 3),
                                    color: Colors.blue,
                                    icon: Icon(
                                      Icons.search,
                                    ),
                                    onPressed: () async {
                                      dataList.clear();
                                      List<Map> list =
                                          await databaseUser.rawQuery(
                                        "SELECT * FROM user_info WHERE kakao LIKE '%${_kakaoStream.text.toString()}%'",
                                      );
                                      getData(list, context);
                                      showSearchList(context);
                                    }),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.cyan))),
                          ],
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                  ],
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 5)),

                Row(
                  children: [
                    Padding(padding: EdgeInsets.only(left: size.width * 0.03)),
                    Container(
                        width: size.width * 0.2,
                        height: 85,
                        alignment: Alignment.center,
                        child: Text('배송주소'),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                    Padding(padding: EdgeInsets.only(left: size.width * 0.015)),
                    Row(
                      children: [
                        Container(
                            width: size.width * 0.65,
                            height: 85,
                            alignment: Alignment.center,
                            child: TextFormField(
                              controller: _addressStream,
                              style: TextStyle(fontSize: 15),
                              maxLines: 5,
                              minLines: 1,
                            ),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 2, color: Colors.cyan))),
                        Container(
                            width: size.width * 0.1,
                            height: 85,
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () async {
                                dataList.clear();
                                List<Map> list = await databaseUser.rawQuery(
                                  "SELECT * FROM user_info WHERE address LIKE '%${_addressStream.text.toString()}%'",
                                );
                                getData(list, context);
                                showSearchList(context);
                              },
                              icon: Icon(Icons.search),
                              color: Colors.cyan,
                            ),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 2, color: Colors.cyan))),
                      ],
                    )
                  ],
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                Row(
                  children: [
                    Padding(padding: EdgeInsets.only(left: size.width * 0.03)),
                    Container(
                      width: size.width * 0.2,
                      height: 60,
                      alignment: Alignment.center,
                      child: Text('현관비번'),
                      decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.cyan)),
                    ),
                    Padding(padding: EdgeInsets.only(left: size.width * 0.015)),
                    Container(
                        width: size.width * 0.25,
                        height: 60,
                        alignment: Alignment.center,
                        child: Text(initialPassword),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                    Padding(padding: EdgeInsets.only(left: size.width * 0.02)),
                    Container(
                        width: size.width * 0.2,
                        height: 60,
                        alignment: Alignment.center,
                        child: Text('비고'),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                    Padding(padding: EdgeInsets.only(left: size.width * 0.015)),
                    Container(
                        width: size.width * 0.26,
                        height: 60,
                        alignment: Alignment.center,
                        child: Text(initialRemark),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                  ],
                ),
                Divider(
                  thickness: 2,
                  endIndent: 10,
                  indent: 10,
                  color: Colors.cyan,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: EdgeInsets.only(left: size.width * 0.03)),
                    Container(
                      width: size.width * 0.2,
                      height: 60,
                      alignment: Alignment.center,
                      child: Text('주문내역'),
                      decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.cyan)),
                    ),
                    Padding(padding: EdgeInsets.only(left: size.width * 0.015)),
                    Container(
                      width: size.width * 0.73,
                      height: 115,
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.only(bottom: 5),
                      child: TextField(
                        controller: _orderContentStream,
                        maxLines: 10,
                        minLines: 1,
                      ),
                      decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.cyan)),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 5)),

                Row(
                  children: [
                    Padding(padding: EdgeInsets.only(left: size.width * 0.03)),
                    Container(
                      width: size.width * 0.2,
                      height: 60,
                      alignment: Alignment.center,
                      child: Text('선결제'),
                      decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.cyan)),
                    ),
                    Radio(
                      groupValue: _existence,
                      value: Existence.Y,
                      onChanged: (value) {
                        setState(() {
                          _existence = value;
                        });
                      },
                    ),
                    Text('유'),
                    Radio(
                      groupValue: _existence,
                      value: Existence.N,
                      onChanged: (value) {
                        setState(() {
                          _existence = value;
                        });
                      },
                    ),
                    Text('무'),
                    Padding(padding: EdgeInsets.only(left: size.width * 0.03)),
                    Container(
                        width: size.width * 0.15,
                        height: 60,
                        alignment: Alignment.center,
                        child: Text('횟수'),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                    Padding(padding: EdgeInsets.only(left: size.width * 0.015)),
                    Container(
                        width: size.width * 0.22,
                        height: 60,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        child: FlatButton(
                          child: Text(_selectedPreCount.toString()),
                          onPressed: () {
                            if (_existence == Existence.Y) {
                              showMaterialScrollPicker(
                                  title: '선결제 횟수',
                                  headerColor: Colors.cyan,
                                  context: context,
                                  items: prePayList,
                                  selectedItem: _selectedPreCount,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPreCount = value;
                                    });
                                  });
                            } else {
                              dataStoreDialog(context, '선결제 허용이 \n선택되지 않았습니다.',
                                  pageFinish: false);
                            }
                          },
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: EdgeInsets.only(left: size.width * 0.03)),
                    Container(
                      width: size.width * 0.2,
                      height: 60,
                      alignment: Alignment.center,
                      child: Text('배달 시간'),
                      decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.cyan)),
                    ),
                    Padding(padding: EdgeInsets.only(left: size.width * 0.015)),
                    Container(
                      width: size.width * 0.73,
                      height: 60,
                      alignment: Alignment.center,
                      child: DropdownButton(
                          isExpanded: true,
                          iconSize: 50,
                          value: _selectedValue,
                          items: _timeList.map(
                            (value) {
                              return DropdownMenuItem(
                                child: Text(value),
                                value: value,
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedValue = value;
                            });
                          }),
                      decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.cyan)),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 7)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 80,
                          height: 60,
                          alignment: Alignment.center,
                          child: Text(
                            '이전',
                            textScaleFactor: 1.4,
                          ),
                          decoration: BoxDecoration(
                              border: Border.all(width: 2, color: Colors.cyan)),
                        )),
                    FlatButton(
                        // 저장 버튼
                        onPressed: () async {
                          if (_nameStream.text.toString().isEmpty ||
                              _phoneStream.text.toString().isEmpty ||
                              _orderContentStream.text.toString().isEmpty ||
                              _addressStream.text.toString().isEmpty) {
                            dataStoreDialog(context, '저장 실패! \n 입력을 확인하세요.',
                                pageFinish: false);
                            return;
                          }
                          try {
                            if (_existence == Existence.Y) {
                              if(_selectMode) {
                                await databaseOrder.transaction((txn) async {
                                  await txn.rawInsert(
                                      'INSERT INTO order_info(id, date, content, time) VALUES(?,?,?,?)',
                                      [
                                        initialId,
                                        _selectedDate,
                                        _orderContentStream.text,
                                        _selectedValue
                                      ]);
                                });
                              }
                              else{
                                for(int i=0; i<_selectedDates.length; ++i){
                                  await databaseOrder.transaction((txn) async{
                                    await txn.rawInsert(
                                      'INSERT INTO order_info(id,date, content, time) VALUES(?,?,?,?)',
                                      [
                                        initialId,
                                        _selectedDates[i].toString().substring(0, _selectedDates[i].toString().indexOf(' ')).trim(),
                                        _orderContentStream.text,
                                        _selectedValue
                                      ]
                                    );
                                  });
                                }
                              }
                              List<Map> preResult = await databaseUser.rawQuery(
                                  'SELECT remain FROM user_info WHERE id =?',
                                  [initialId]);
                              await databaseUser.transaction((txn) async {
                                await txn.rawUpdate(
                                    'UPDATE user_info SET remain = ? WHERE id = ?',
                                    [
                                      preResult[0]['remain'] +
                                          int.parse(_selectedPreCount) -
                                          (_selectMode ? 1 : _selectedDates.length) as int,
                                      initialId
                                    ]);
                              });
                            }
                            else {
                              if(_selectMode) {
                                await databaseOrder.transaction((txn) async {
                                  await txn.rawInsert(
                                      'INSERT INTO order_info(id, date, content, time) VALUES(?,?,?,?)',
                                      [
                                        initialId,
                                        _selectedDate,
                                        _orderContentStream.text,
                                        _selectedValue
                                      ]);
                                });
                              }
                              else{
                                for(int i=0; i<_selectedDates.length; ++i){
                                  await databaseOrder.transaction((txn) async{
                                    await txn.rawInsert(
                                        'INSERT INTO order_info(id,date, content, time) VALUES(?,?,?,?)',
                                        [
                                          initialId,
                                          _selectedDates[i].toString().substring(0, _selectedDates[i].toString().indexOf(' ')).trim(),
                                          _orderContentStream.text,
                                          _selectedValue
                                        ]
                                    );
                                  });
                                }
                              }
                              List<Map> preResult = await databaseUser.rawQuery(
                                  'SELECT remain FROM user_info WHERE id =?',
                                  [initialId]);
                              int value = preResult[0]['remain'] < 1
                                  ? 0
                                  : preResult[0]['remain'] - (_selectMode ? 1 : _selectedDates.length) as int;
                              await databaseUser.transaction((txn) async {
                                await txn.rawUpdate(
                                    'UPDATE user_info SET remain = ? WHERE id = ?',
                                    [value, initialId]);
                              });
                            }
                            dataStoreDialog(context, '저장되었습니다.',
                                pageFinish: true);
                          } catch (e) {
                            dataStoreDialog(context, '에러 발생\n재시도 바람',
                                pageFinish: true);
                            print(e);
                          }
                        },
                        child: Container(
                            width: 80,
                            height: 60,
                            alignment: Alignment.center,
                            child: Text(
                              '저장',
                              textScaleFactor: 1.4,
                            ),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 2, color: Colors.cyan)))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showSearchList(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) {
          alertContext = ctx;
          return StatefulBuilder(
            builder: (ctx, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                title: Center(child: Text('밥수니 반찬 DB 검색 결과')),
                content: SingleChildScrollView(
                    scrollDirection: Axis.horizontal, child: buildDataTable()),
                actions: [
                  FlatButton(
                      onPressed: () {
                        dataList.clear();
                        Navigator.pop(ctx);
                      },
                      child: Text('이전')),
                ],
              );
            },
          );
        });
  }

  Widget buildDataTable() {
    return DataTable(
      showCheckboxColumn: false,
      dataRowHeight: 50,
      headingRowColor: MaterialStateProperty.resolveWith<Color>((states) {
        return Colors.cyanAccent;
      }),
      showBottomBorder: true,
      columnSpacing: 15,
      columns: [
        DataColumn(label: Text('고객번호')),
        DataColumn(label: Text('입금자')),
        DataColumn(label: Text('전화번호')),
        DataColumn(label: Text('카톡 닉네임')),
        DataColumn(label: Text('배송 주소')),
        DataColumn(label: Text('현관 비번')),
        DataColumn(label: Text('비고'))
      ],
      rows: dataList,
    );
  }

  void getData(List<Map> query, BuildContext context) {
    for (int i = 0; i < query.length; ++i) {
      dataList.add(DataRow(
          cells: [
            DataCell(Text(query[i]['id'].toString())),
            DataCell(Text(query[i]['name'])),
            DataCell(Text(query[i]['phone'])),
            DataCell(Text(query[i]['kakao'])),
            DataCell(Text(query[i]['address'])),
            DataCell(Text(query[i]['password'])),
            DataCell(Text(query[i]['remark'])),
          ],
          onSelectChanged: (value) {
            setState(() {
              selected = i;
              initialId = query[i]['id'].toString();
              _phoneStream.value = TextEditingValue(text: query[i]['phone']);
              _nameStream.value = TextEditingValue(text: query[i]['name']);
              _kakaoStream.value = TextEditingValue(text: query[i]['kakao']);
              _addressStream.value =
                  TextEditingValue(text: query[i]['address']);
              initialRemain = query[i]['remain'];
              initialPassword = query[i]['password'];
              initialRemark = query[i]['remark'];
              Navigator.pop(alertContext);
              dataList.clear();
            });
          }));
    }
  }

  void dataStoreDialog(BuildContext context, String message,
      {@required bool pageFinish}) {
    showDialog(
        context: context,
        builder: (ctx) {
          Future.delayed(Duration(milliseconds: 700), () {
            Navigator.pop(ctx);
            if (pageFinish) Navigator.pop(context);
          });
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            content: Container(
                width: 20,
                height: 50,
                alignment: Alignment.center,
                child: Text(
                  message,
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
          );
        });
  }

  void chooseSelectMode() {
    showDialog(
        context: this.context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Text('날짜 선택 유형'),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                    color: Colors.cyanAccent,
                    child: Text('단일 선택'),
                    onPressed: () {
                      _selectMode = true;
                      Navigator.pop(ctx);
                      Future<DateTime> selectedDate = showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now(), // 초깃값
                        firstDate: DateTime(2016), // 시작일
                        lastDate: DateTime(2050), // 마지막일
                        builder: (BuildContext context, Widget child) {
                          return Theme(
                            data: ThemeData.light(), // 밝은테마
                            child: child,
                          );
                        },
                      );
                      selectedDate.then((dateTime) {
                        setState(() {
                          try {
                            _selectedDate = dateTime
                                .toString()
                                .substring(0, dateTime.toString().indexOf(' '))
                                .trim();
                          }
                          catch(e){

                          }
                        });
                      });
                    }),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                ),
                RaisedButton(
                    color: Colors.cyanAccent,
                    child: Text('복수 선택'),
                    onPressed: () {
                      _selectMode = false;
                      Navigator.pop(ctx);

                      showDialog(
                        context: ctx,
                        builder: (_) => SomeCalendar(
                          mode: SomeMode.Multi,
                          primaryColor: Colors.cyan,
                          startDate: DateTime(2016),
                          lastDate: DateTime(2050),
                          isWithoutDialog: false,
                          selectedDates: _selectedDates,
                          labels: Labels(dialogDone: '확인', dialogCancel: '취소'),
                          done: (date) {
                            setState(() {
                              _selectedDates = date;
                              print(_selectedDates);
                            });
                          },
                        ),
                      );
                    }),
              ],
            ),
          );
        });
  }
}
