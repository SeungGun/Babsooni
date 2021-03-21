import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CurrentDateListPage extends StatefulWidget {
  CurrentDateListPage({Key key, this.date}) : super(key: key);
  final String date;
  @override
  _CurrentDateListPageState createState() => _CurrentDateListPageState();
}

class _CurrentDateListPageState extends State<CurrentDateListPage> {
  Database databaseUser;
  Database databaseOrder;
  List<TableRow> dataList = [];
  List<List<Map>> queryResult = [];
  List<List> overflowList = [];
  int listNum;
  List<String> menuList = [];
  Map<String, int> menuPair = Map();
  List<TableRow> titleContainList = [];
  @override
  void initState() {
    super.initState();
    _openDB();
    _openDB2();
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
    getQuery();
  }

  void getQuery() async {
    List<Map> query = await databaseOrder.rawQuery(
        'SELECT id, content FROM order_info WHERE date = ?',
        [widget.date.substring(0, widget.date.indexOf(' '))]);

    titleContainList.add(TableRow(children: [
      Container(
        color: Colors.cyanAccent,
        child: Padding(
          padding: const EdgeInsets.only(left:10,top:15,bottom:15,right:10),
          child: Text('No.'),
        ),
      ),
      Container(
        color: Colors.cyanAccent,
        child: Padding(
          padding: const EdgeInsets.only(left:10,top:15,bottom:15,right:10),
          child: Text('입금자'),
        ),
      ),
      Container(
        color: Colors.cyanAccent,
        child: Padding(
          padding: const EdgeInsets.only(left:10,top:15,bottom:15,right:10),
          child: Text('카톡'),
        ),
      ),
      Container(
        color: Colors.cyanAccent,
        child: Padding(
          padding: const EdgeInsets.only(left:10,top:15,bottom:15,right:10),
          child: Text('배달주소'),
        ),
      ),
      Container(
        color: Colors.cyanAccent,
        child: Padding(
          padding: const EdgeInsets.only(left:10,top:15,bottom:15,right:10),
          child: Text('주문내역'),
        ),
      ),
      Container(
        color: Colors.cyanAccent,
        child: Padding(
          padding: const EdgeInsets.only(left:10,top:15,bottom:15,right:10),
          child: Text('현관비번'),
        ),
      ),
      Container(
        color: Colors.cyanAccent,
        child: Padding(
          padding: const EdgeInsets.only(left:10,top:15,bottom:15,right:10),
          child: Text('비고'),
        ),
      )
    ]));
    for (int i = 0; i < query.length; ++i) {
      List<Map> query2 = await databaseUser.rawQuery(
          'SELECT name, kakao, address, password, remark FROM user_info WHERE id=?',
          [query[i]['id']]);
      queryResult.add(query2);
      menuList.add(query[i]['content'].toString());
      dataList.add(TableRow(children: [
        Padding(
          padding: const EdgeInsets.only(left:10,top:15,bottom:15,right:10),
          child: Text((i + 1).toString()),
        ),
        Padding(
          padding: const EdgeInsets.only(left:10,top:15,bottom:15,right:10),
          child: Text(queryResult[i][0]['name'].toString()),
        ),
        Padding(
          padding: const EdgeInsets.only(left:10,top:15,bottom:15,right:10),
          child: Text(queryResult[i][0]['kakao'].toString()),
        ),
        Padding(
          padding: const EdgeInsets.only(left:10,top:15,bottom:15,right:10),
          child: Text(queryResult[i][0]['address'].toString()),
        ),
        Padding(
          padding: const EdgeInsets.only(left:10,top:15,bottom:15,right:10),
          child: Text(query[i]['content'].toString()),
        ),
        Padding(
          padding: const EdgeInsets.only(left:10,top:15,bottom:15,right:10),
          child: Text(queryResult[i][0]['password'].toString()),
        ),
        Padding(
          padding: const EdgeInsets.only(left:10,top:15,bottom:15,right:10),
          child: Text(queryResult[i][0]['remark'].toString()),
        )
      ]));
      setState(() {});
    }
    titleContainList.addAll(dataList);

    listNum = dataList.length ~/ 14 + 1;
    int count = 0;
    if (dataList.length > 14) {
      for (int i = 0; i < listNum; ++i) {
        List<TableRow> tmp = [];
        for (int j = 0; j < 14; ++j) {
          if (count >= dataList.length) break;
          tmp.add(dataList[j + i * 14]);
          count++;
        }
        overflowList.add(tmp);
      }
    } else {
      List<TableRow> tmp = [];
      for (int i = 0; i < dataList.length; ++i) {
        tmp.add(dataList[i]);
      }
      overflowList.add(tmp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, bottom: 5, top: 5),
                  child: Text(
                    widget.date.substring(0, widget.date.indexOf(' ')) +
                        ' 주문 리스트',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                Table(
                  children: titleContainList,
                  defaultColumnWidth: IntrinsicColumnWidth(),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: TableBorder.all(color: Colors.cyan, width: 3),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                Row(children: [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 20)),
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
                          for (int i = 0; i < listNum; ++i) {
                            var mFuture = await printList(i);
                            doc.addPage(pw.MultiPage(
                              theme: pw.ThemeData.withFont(
                                  base: pw.Font.ttf(await rootBundle
                                      .load('fonts/NanumGothic-Regular.ttf'))),
                              pageFormat: PdfPageFormat.a4,
                              build: (pw.Context context) {
                                return [
                                  pw.Column(children: [
                                    pw.Row(
                                        children: [
                                          pw.Text(DateTime.now()
                                              .toString()
                                              .substring(
                                                  0,
                                                  DateTime.now()
                                                      .toString()
                                                      .indexOf('.')))
                                        ],
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.end),
                                    pw.Row(children: [
                                      pw.Text(
                                          widget.date.substring(
                                              0, widget.date.indexOf(' ')),
                                          style: pw.TextStyle(fontSize: 20)),
                                      pw.Text(' 주문 리스트',
                                          style: pw.TextStyle(fontSize: 20))
                                    ]),
                                    pw.Padding(
                                        padding: pw.EdgeInsets.symmetric(
                                            vertical: 10)),
                                    pw.Table(
                                      children: mFuture,
                                      border: pw.TableBorder.all(
                                          width: 1, color: PdfColors.black),
                                      defaultVerticalAlignment:
                                          pw.TableCellVerticalAlignment.middle,
                                      defaultColumnWidth:
                                          pw.IntrinsicColumnWidth(),
                                    ),
                                    pw.Padding(
                                        padding: pw.EdgeInsets.symmetric(
                                            vertical: 5)),
                                    pw.Row(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.center,
                                        children: [
                                          pw.Text('- ${i + 1} -',
                                              style: pw.TextStyle(fontSize: 9))
                                        ])
                                  ])
                                ];
                              },
                            ));
                          }
                          final output =
                              await getApplicationDocumentsDirectory();
                          final file = File('${output.path}/babsuni.pdf');
                          await file.writeAsBytes(await doc.save());
                          await Printing.layoutPdf(
                            name:
                                '${widget.date.substring(0, widget.date.indexOf(' '))}자 주문 리스트',
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
                  FlatButton(
                      onPressed: () {
                        print(menuList.length);
                        print(menuList[0].split('\n'));
                        calTotalMenu();
                        print(menuPair);
                      },
                      child: Container(
                        width: 100,
                        height: 60,
                        alignment: Alignment.center,
                        child: Text(
                          '메뉴 Total',
                          textScaleFactor: 1.4,
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan)),
                      )),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<pw.TableRow>> printList(int index) async {
    return dataToWrite(index);
  }

  List<pw.TableRow> dataToWrite(int index) {
    List<pw.TableRow> list = [];
    list.add(pw.TableRow(children: [
      pw.Padding(
          child:
              pw.Text('No.', style: pw.TextStyle(fontSize: 9), softWrap: true),
          padding: pw.EdgeInsets.only(left: 5, top: 8, right: 5, bottom: 8)),
      pw.Padding(
          child:
              pw.Text('입금자', style: pw.TextStyle(fontSize: 9), softWrap: true),
          padding: pw.EdgeInsets.only(left: 7, top: 8, right: 10, bottom: 8)),
      pw.Padding(
          child:
              pw.Text('카톡', style: pw.TextStyle(fontSize: 9), softWrap: true),
          padding: pw.EdgeInsets.only(left: 5, top: 8, right: 3, bottom: 8)),
      pw.Padding(
          child:
              pw.Text('배달주소', style: pw.TextStyle(fontSize: 9), softWrap: true),
          padding: pw.EdgeInsets.only(left: 5, top: 8, right: 5, bottom: 8)),
      pw.Padding(
          child:
              pw.Text('주문내역', style: pw.TextStyle(fontSize: 9), softWrap: true),
          padding: pw.EdgeInsets.only(left: 5, top: 8, right: 5, bottom: 8)),
      pw.Padding(
          child:
              pw.Text('현관비번', style: pw.TextStyle(fontSize: 9), softWrap: true),
          padding: pw.EdgeInsets.only(left: 7, top: 8, right: 8, bottom: 8)),
      pw.Padding(
          child:
              pw.Text('비고', style: pw.TextStyle(fontSize: 9), softWrap: true),
          padding: pw.EdgeInsets.only(left: 5, top: 8, right: 5, bottom: 8)),
    ]));
    for (int i = 0; i < overflowList[index].length; ++i) {
      String tmp = '';
      List<pw.Widget> row = [];
      var temp = overflowList[index][i] as TableRow;
      for (int j = 0; j < temp.children.length; ++j) {
        var t = temp.children[j] as Padding;
        var k = t.child as Text;
        tmp = k.data.toString();
        if (j == 1 || j == 3 || j == 4) {
          row.add(pw.Padding(
              child: pw.Text(tmp,
                  style: pw.TextStyle(fontSize: j == 1 ? 7 : j + 4.0),
                  softWrap: true),
              padding: pw.EdgeInsets.only(
                  left: 5, top: 10, right: j == 3 ? 1 : 5, bottom: 13)));
        } else {
          row.add(pw.Padding(
              child: pw.Text(tmp,
                  style: pw.TextStyle(fontSize: 8), softWrap: true),
              padding: pw.EdgeInsets.only(
                  left: j == 5 ? 3 : 5, top: 10, right: 5, bottom: 13)));
        }
      }
      var a = pw.TableRow(children: row,);
      list.add(a);
    }
    return list;
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

  void calTotalMenu() {
    for (int i = 0; i < menuList.length; ++i) {
      var splitList = menuList[i].split('\n');
      for (int j = 0; j < splitList.length; ++j) {
        var innerSplit = splitList[j].split(' ');
        int basic = 1;
        try {
          basic = int.parse(innerSplit[1]);
          print(basic);
        } catch (e) {
          basic = 1;
        }
        if (menuPair.containsKey(innerSplit[0])) {
          menuPair.update(innerSplit[0], (value) => value + basic);
        } else {
          menuPair[innerSplit[0]] = basic;
        }
      }
    }
    List<DataRow> tmp = [];
    menuPair.forEach((key, value) {
      tmp.add(DataRow(
          cells: [DataCell(Text(key)), DataCell(Text(value.toString()))]));
    });
    showMenuTotalList(this.context, tmp);
  }

  void showMenuTotalList(BuildContext context, List<DataRow> row) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            title: Center(
                child: Text(
              '${widget.date.substring(0, widget.date.indexOf(' '))}일자 토탈 메뉴',
              style: TextStyle(fontSize: 15),
            )),
            content: SingleChildScrollView(
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    showBottomBorder: true,
                    columnSpacing: 80,
                    headingRowColor:
                        MaterialStateProperty.resolveWith((states) {
                      return Colors.cyan;
                    }),
                    columns: [
                      DataColumn(label: Text('메뉴')),
                      DataColumn(label: Text('개수'))
                    ],
                    rows: row,
                  )),
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    dataList.clear();
                    Navigator.pop(ctx);
                  },
                  child: Text('이전')),
            ],
          );
        });
  }
}
