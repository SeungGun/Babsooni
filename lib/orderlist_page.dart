import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // pdf 파일에 들어갈 위젯들에 대한 것 그것을 pw로 접근하겠다
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CheckOrderListPage extends StatefulWidget {
  @override
  _CheckOrderListPageState createState() => _CheckOrderListPageState();
}

class _CheckOrderListPageState extends State<CheckOrderListPage> {
  Database databaseUser;
  Database databaseOrder;
  TextEditingController _nameStream = TextEditingController();
  TextEditingController _phoneStream = TextEditingController();
  TextEditingController _kakaoStream = TextEditingController();
  TextEditingController _addressStream = TextEditingController();
  int _sortColumnIndex;
  bool _sortAsc = true;
  bool _sortDateAsc = true;
  List<DataRow> list;
  String user_id = '';
  String remain_count = '-';
  List<DataRow> dataList = [];
  List<DataRow> orderList = [];
  int selected = -1;
  var alertContext;
  int listNum;
  List<List> overflowList = [];
  @override
  void initState() {
    _openDB();
    _openDB2();
    super.initState();
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
          child: Column(children: [
        Padding(padding: EdgeInsets.symmetric(vertical: 25)),
        Text(
          '밥수니반찬 주문 내역 조회',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        Row(
          children: [
            Padding(padding: EdgeInsets.only(left: size.width * 0.015)),
            Container(
                width: 80,
                height: 60,
                alignment: Alignment.center,
                child: Text('입금자'),
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.cyan))),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.015),
            ),
            Container(
                width: 130,
                height: 60,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(padding: EdgeInsets.only(left: 5)),
                    Container(
                      width: 80,
                      height: 60,
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.only(bottom: 3),
                      child: TextField(
                        controller: _nameStream,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    Container(
                        width: 35,
                        height: 35,
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(top: 3),
                            color: Colors.blue,
                            icon: Icon(Icons.search),
                            onPressed: () async {
                              dataList.clear();
                              List<Map> list = await databaseUser.rawQuery(
                                  'SELECT * FROM user_info WHERE name = ?',
                                  [_nameStream.text.toString()]);
                              getData(list, context);
                              showSearchList(context);
                            }),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.cyan))),
                    Padding(padding: EdgeInsets.only(right: 5))
                  ],
                ),
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.cyan))),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.03),
            ),
            Container(
                width: 80,
                height: 60,
                alignment: Alignment.center,
                child: Text('고객번호'),
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.cyan))),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.015),
            ),
            Container(
                width: 80,
                height: 60,
                alignment: Alignment.center,
                child: Text(user_id),
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.cyan))),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
        ),
        Row(
          children: [
            Padding(padding: EdgeInsets.only(left: size.width * 0.015)),
            Container(
                width: 80,
                height: 70,
                alignment: Alignment.center,
                child: Text('전화번호'),
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.cyan))),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.015),
            ),
            Container(
                width: 130,
                height: 70,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(padding: EdgeInsets.only(left: 5)),
                    Container(
                      width: 80,
                      height: 60,
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.only(bottom: 3),
                      child: TextField(
                        controller: _phoneStream,
                        style: TextStyle(fontSize: 11),
                        maxLines: 3,
                        minLines: 1,
                      ),
                    ),
                    Container(
                        width: 35,
                        height: 35,
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(top: 3),
                            color: Colors.blue,
                            icon: Icon(Icons.search),
                            onPressed: () async {
                              dataList.clear();
                              List<Map> list = await databaseUser.rawQuery(
                                  'SELECT * FROM user_info WHERE phone = ?',
                                  [_phoneStream.text.toString()]);
                              getData(list, context);
                              showSearchList(context);
                            }),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.cyan))),
                    Padding(padding: EdgeInsets.only(right: 5))
                  ],
                ),
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.cyan))),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.015),
            ),
            Container(
                width: 60,
                height: 70,
                alignment: Alignment.center,
                child: Text('카톡'),
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.cyan))),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.01),
            ),
            Container(
                width: 110,
                height: 70,
                alignment: Alignment.center,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.only(bottom: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(padding: EdgeInsets.only(left: 5)),
                      Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.only(bottom: 3),
                        child: TextField(
                          controller: _kakaoStream,
                          style: TextStyle(fontSize: 12),
                          maxLines: 4,
                          minLines: 1,
                        ),
                      ),
                      Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(top: 3),
                              color: Colors.blue,
                              icon: Icon(Icons.search),
                              onPressed: () async {
                                dataList.clear();
                                List<Map> list = await databaseUser.rawQuery(
                                    'SELECT * FROM user_info WHERE kakao = ?',
                                    [_kakaoStream.text.toString()]);
                                getData(list, context);
                                showSearchList(context);
                              }),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1, color: Colors.cyan))),
                      Padding(padding: EdgeInsets.only(right: 5))
                    ],
                  ),
                ),
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.cyan))),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
        ),
        Row(
          children: [
            Padding(padding: EdgeInsets.only(left: size.width * 0.015)),
            Container(
                width: 85,
                height: 85,
                alignment: Alignment.center,
                child: Text('배송주소'),
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.cyan))),
            Padding(padding: EdgeInsets.only(left: size.width * 0.015)),
            Row(
              children: [
                Container(
                    width: 265,
                    height: 85,
                    alignment: Alignment.center,
                    child: TextFormField(
                      controller: _addressStream,
                      style: TextStyle(fontSize: 15),
                      maxLines: 5,
                      minLines: 1,
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.cyan))),
                Container(
                    width: 40,
                    height: 85,
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () async {

                        dataList.clear();
                        List<Map> list = await databaseUser.rawQuery(
                            'SELECT * FROM user_info WHERE address = ?',
                            [_addressStream.text.toString()]);
                        getData(list, context);
                        showSearchList(context);
                      },
                      icon: Icon(Icons.search),
                      color: Colors.cyan,
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.cyan))),
              ],
            )
          ],
        ),
        Divider(
          thickness: 2,
          indent: 10,
          endIndent: 10,
          color: Colors.cyan,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(left: size.width * 0.015)),
            Container(
                width: 80,
                height: 60,
                alignment: Alignment.center,
                child: Text('주문 내역'),
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.cyan))),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.015),
            ),
          ],
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              DataTable(
                  sortAscending: _sortAsc,
                  sortColumnIndex: _sortColumnIndex,
                  headingRowColor:
                      MaterialStateProperty.resolveWith<Color>((states) {
                    return Colors.lightBlue[100];
                  }),
                  columnSpacing: 40,
                  showBottomBorder: true,
                  columns: [
                    DataColumn(
                      label: Text('No.'),
                    ),
                    DataColumn(
                        label: Text('날짜'),
                        onSort: (columnIndex, sortAscending) {
                          setState(() {
                            if (columnIndex == _sortColumnIndex) {
                              _sortAsc = _sortDateAsc = sortAscending;
                            } else {
                              _sortColumnIndex = columnIndex;
                              _sortAsc = _sortDateAsc;
                            }
                            orderList.sort((a, b) => a.cells[1].child
                                .toString()
                                .compareTo(b.cells[1].child.toString()));
                            if (!_sortAsc) {
                              orderList = orderList.reversed.toList();
                            }
                          });
                        }),
                    DataColumn(label: Text('주문내역')),
                    DataColumn(label: Text('배달 시간'))
                  ],
                  rows: orderList)
            ],
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.015),
            ),
            Container(
                width: 80,
                height: 50,
                alignment: Alignment.center,
                child: Text('잔여횟수'),
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.cyan))),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.015),
            ),
            Container(
                width: 80,
                height: 50,
                alignment: Alignment.center,
                child: Text(remain_count),
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.cyan))),
          ],
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
          Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
          FlatButton(
              onPressed: () async {
                try {

                  final doc = pw.Document();
                  print(listNum);
                  for(int i=0; i<listNum; ++i) {
                    var mFuture = await printList(i);

                    doc.addPage(pw.MultiPage(
                      theme: pw.ThemeData.withFont(
                          base: pw.Font.ttf(await rootBundle
                              .load('fonts/NanumGothic-Regular.ttf'))),
                      pageFormat: PdfPageFormat.a4,
                      build: (pw.Context context) {
                        return [pw.Column(children: [
                          pw.Row(children: [
                            pw.Text(DateTime.now().toString().substring(
                                0, DateTime.now().toString().indexOf('.')))
                          ], mainAxisAlignment: pw.MainAxisAlignment.end),
                          pw.Row(children: [
                            pw.Text('고객번호 : '),
                            pw.Text(user_id.toString())
                          ]),
                          pw.Padding(
                              padding: pw.EdgeInsets.symmetric(vertical: 8)),
                          pw.Row(children: [
                            pw.Text('입금자 : '),
                            pw.Text(_nameStream.text.toString())
                          ]),
                          pw.Padding(
                              padding: pw.EdgeInsets.symmetric(vertical: 8)),
                          pw.Row(children: [
                            pw.Text('전화번호 : '),
                            pw.Text(_phoneStream.text.toString())
                          ]),
                          pw.Padding(
                              padding: pw.EdgeInsets.symmetric(vertical: 8)),
                          pw.Row(children: [
                            pw.Text('배송 주소 : '),
                            pw.Text(_addressStream.text.toString())
                          ]),
                          pw.Padding(
                              padding: pw.EdgeInsets.symmetric(vertical: 10)),
                          pw.Table(
                            children: mFuture,
                            border: pw.TableBorder.all(
                                width: 1, color: PdfColors.black),
                            defaultVerticalAlignment:
                            pw.TableCellVerticalAlignment.middle,
                            defaultColumnWidth: pw.IntrinsicColumnWidth(),
                          )
                        ])
                        ];
                      },
                    ));
                  }
                  final output = await getApplicationDocumentsDirectory();
                  final file = File('${output.path}/babsuni.pdf');
                  await file.writeAsBytes(await doc.save());
                  var addr = getSplitAddress();
                  await Printing.layoutPdf(
                    name: '$user_id $addr',
                    onLayout: (PdfPageFormat format) async {
                      return await doc.save();
                    },
                  );
                } catch (e) {
                  print(e.toString());
                  showAlert(context, '에러 발생');
                }
              },
              child: Container(
                width: 80,
                height: 60,
                alignment: Alignment.center,
                child: Text(
                  '출력',
                  textScaleFactor: 1.4,
                ),
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.cyan)),
              )),
        ])
      ])),
    )));
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
                        overflowList.clear();
                        Navigator.pop(ctx);
                      },
                      child: Text('이전')),
                ],
              );
            },
          );
        });
  }

  void showAlert(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (ctx) {
          Future.delayed(Duration(milliseconds: 800), () {
            Navigator.pop(ctx);
            Navigator.pop(context);
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
              user_id = query[i]['id'].toString();
              _phoneStream.value = TextEditingValue(text: query[i]['phone']);
              _nameStream.value = TextEditingValue(text: query[i]['name']);
              _kakaoStream.value = TextEditingValue(text: query[i]['kakao']);
              _addressStream.value =
                  TextEditingValue(text: query[i]['address']);
              remain_count = query[i]['remain'].toString();
              searchOrderList(query, i);
              Navigator.pop(alertContext);
              dataList.clear();
              overflowList.clear();
            });
          }));
    }

  }

  void searchOrderList(List<Map> query, int index) async {
    overflowList.clear();
    orderList.clear();
    List<Map> order_list = await databaseOrder.rawQuery(
        'SELECT date, content, time FROM order_info WHERE id = ?',
        [query[index]['id']]);
    getOrderList(order_list);
  }

  void getOrderList(List<Map> query) {

    for (int i = 0; i < query.length; ++i) {
      orderList.add(DataRow(cells: [
        DataCell(Text((i + 1).toString())),
        DataCell(Text(query[i]['date'])),
        DataCell(Text(query[i]['content'])),
        DataCell(Text(query[i]['time']))
      ]));
    }
    listNum = orderList.length ~/ 11 + 1;
    print(listNum);
    int count = 0;
    if(orderList.length > 11){
      for(int i=0; i<listNum; ++i){
        List<DataRow> tmp = [];
        for(int j=0; j<11; ++j){
          if(count >= orderList.length) break;
          tmp.add(orderList[j + i *11]);
          count++;
        }
        overflowList.add(tmp);
      }
    }
    else {
      List<DataRow> tmp = [];
      for (int i = 0; i < orderList.length; ++i) {
        tmp.add(orderList[i]);
      }
      overflowList.add(tmp);
    }
  }

  Future<List<pw.TableRow>> printList(int index) async {
    return dataToWrite(index);
  }

  List<pw.TableRow> dataToWrite(int index) {
    List<pw.TableRow> list = [];
    list.add(pw.TableRow(children: [
      pw.Padding(
          child:
              pw.Text('No.', style: pw.TextStyle(fontSize: 11), softWrap: true),
          padding: pw.EdgeInsets.only(left: 5, top: 8, right: 5, bottom: 8)),
      pw.Padding(
          child:
              pw.Text('날짜', style: pw.TextStyle(fontSize: 11), softWrap: true),
          padding: pw.EdgeInsets.only(left: 5, top: 8, right: 5, bottom: 8)),
      pw.Padding(
          child: pw.Text('주문내역',
              style: pw.TextStyle(fontSize: 11), softWrap: true),
          padding: pw.EdgeInsets.only(left: 5, top: 8, right: 5, bottom: 8)),
      pw.Padding(
          child: pw.Text('배송시간',
              style: pw.TextStyle(fontSize: 11), softWrap: true),
          padding: pw.EdgeInsets.only(left: 5, top: 8, right: 5, bottom: 8)),
    ]));
    for (int i = 0; i < overflowList[index].length; ++i) {
      String tmp = '';
      List<pw.Widget> row = [];
      for (int j = 0; j < overflowList[index][i].cells.length; ++j) {
        var t = overflowList[index][i].cells[j].child as Text;
        tmp = t.data.toString();

        row.add(pw.Padding(
            child:
                pw.Text(tmp, style: pw.TextStyle(fontSize: 11), softWrap: true),
            padding: pw.EdgeInsets.only(left: 5, top: 8, right: 5, bottom: 8)));
      }
      var a = pw.TableRow(
        children: row,
      );
      list.add(a);
    }
    return list;
  }
  String getSplitAddress(){
    String result = '';
    String tmp = _addressStream.text.toString();
    var split = tmp.split(' ');
    for(int i=3; i<split.length; ++i){
      result += split[i] + ' ';
    }
    return result;
  }
}
