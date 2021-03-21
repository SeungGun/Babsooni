import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NewOrdererRegisterPage extends StatefulWidget {
  @override
  _NewOrdererRegisterPageState createState() => _NewOrdererRegisterPageState();
}

class _NewOrdererRegisterPageState extends State<NewOrdererRegisterPage> {
  Database database;
  int id_val;
  TextEditingController _nameStream = TextEditingController();
  TextEditingController _cellphoneStream = TextEditingController();
  TextEditingController _kakaoStream = TextEditingController();
  TextEditingController _addressStream = TextEditingController();
  TextEditingController _passwordStream = TextEditingController();
  TextEditingController _remarkStream = TextEditingController();

  @override
  void initState(){
    super.initState();
    _openDB();
  }
  Future<void> _openDB() async{
    String dbPath = join(await getDatabasesPath(), 'test1.db');
    database = await openDatabase(dbPath, onCreate: (db, version){
      return db.execute('CREATE TABLE IF NOT EXISTS user_info (id INTEGER PRIMARY KEY, name TEXT, phone TEXT, kakao TEXT, address TEXT, password TEXT, remark TEXT, remain INTEGER)');
    }, version: 1);
    currentUserNumber();
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
            // 입력칸에서 포커스가 사라졌을 경우 키보드 unfocus 상태로 전환하기
          },
          child: SingleChildScrollView(
            /** 키보드가 올라오는 상황에서 아래 화면들이 짤리면 스크롤 되서 볼 수 있는게 대부분이지만 flutter는 그렇지 않다.
             * 그래서 이 SingleChildScrollView 위젯을 사용하면 위와 같은 기능이 가능하게 된다.
             **/
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                ),
                Text(
                  '밥수니반찬 신규 주문자 등록',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.025),
                    ),
                    textSpaceArchitecture(
                        title: '고객번호', width: size.width * 0.3),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.05),
                    ),
                    Container(
                        width: size.width * 0.6,
                        height: 55,
                        alignment: Alignment.center,
                        child: Text(id_val.toString() == null ? '' : id_val.toString()),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                    Padding(
                      padding: EdgeInsets.only(right: size.width * 0.025),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                ),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  thickness: 2,
                  color: Colors.cyan,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.025),
                    ),
                    textSpaceArchitecture(
                        title: '입금자', width: size.width * 0.3),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.05),
                    ),
                    Container(
                        width: size.width * 0.6,
                        height: 55,
                        alignment: Alignment.center,
                        child: TextField(
                          style: TextStyle(fontSize: 15),
                          controller: _nameStream,
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                    Padding(
                      padding: EdgeInsets.only(right: size.width * 0.025),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.025),
                    ),
                    textSpaceArchitecture(
                        title: '전화번호', width: size.width * 0.3),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.05),
                    ),
                    Container(
                        width: size.width * 0.6,
                        height: 55,
                        alignment: Alignment.center,
                        child: TextField(
                          style: TextStyle(fontSize: 15),
                          controller: _cellphoneStream,
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                    Padding(
                      padding: EdgeInsets.only(right: size.width * 0.025),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.025),
                    ),
                    textSpaceArchitecture(
                        title: '카톡닉네임', width: size.width * 0.3),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.05),
                    ),
                    Container(
                        width: size.width * 0.6,
                        height: 55,
                        alignment: Alignment.center,
                        child: TextField(
                          style: TextStyle(fontSize: 15),
                          controller: _kakaoStream,
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                    Padding(
                      padding: EdgeInsets.only(right: size.width * 0.025),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.025),
                    ),
                    textSpaceArchitecture(
                        title: '배송주소', width: size.width * 0.3),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.05),
                    ),
                    Container(
                        width: size.width * 0.6,
                        height: 90,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(2),
                        child: TextField(
                          minLines: 1,
                          maxLines: 6,
                          style: TextStyle(fontSize: 15),
                          controller: _addressStream,
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                    Padding(
                      padding: EdgeInsets.only(right: size.width * 0.025),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.025),
                    ),
                    textSpaceArchitecture(
                        title: '현관비번', width: size.width * 0.3),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.05),
                    ),
                    Container(
                        width: size.width * 0.6,
                        height: 55,
                        alignment: Alignment.center,
                        child: TextField(
                          style: TextStyle(fontSize: 15),
                          controller: _passwordStream,
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                    Padding(
                      padding: EdgeInsets.only(right: size.width * 0.025),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.025),
                    ),
                    textSpaceArchitecture(title: '비고', width: size.width * 0.3),
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.05),
                    ),
                    Container(
                        width: size.width * 0.6,
                        height: 55,
                        alignment: Alignment.center,
                        child: TextField(
                          style: TextStyle(fontSize: 15),
                          controller: _remarkStream,
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.cyan))),
                    Padding(
                      padding: EdgeInsets.only(right: size.width * 0.025),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: size.width * 0.25,
                          height: 55,
                          alignment: Alignment.center,
                          child: Text(
                            '이전',
                            textScaleFactor: 1.4,
                          ),
                          decoration: BoxDecoration(
                              border: Border.all(width: 2, color: Colors.cyan)),
                        )),
                    FlatButton(
                        onPressed: () async {
                          if(_nameStream.text.isEmpty || _cellphoneStream.text.isEmpty || _addressStream.text.isEmpty){
                            dataStoreDialog(context, '저장 실패! \n입력을 확인하세요.');
                          }
                          else {
                            try {
                              await database.transaction((txn) async {
                                int id = await txn.rawInsert(
                                    'INSERT INTO user_info(name, phone, kakao, address, password, remark, remain) VALUES(?,?,?,?,?,?,?)',
                                    [
                                      _nameStream.text,
                                      _cellphoneStream.text,
                                      _kakaoStream.text.toString().isEmpty ? '' : _kakaoStream.text.toString(),
                                      _addressStream.text,
                                      _passwordStream.text.toString().isEmpty ? '' : _passwordStream.text.toString(),
                                      _remarkStream.text,
                                      0
                                    ]
                                );
                              });
                              dataStoreDialog(context, '저장되었습니다. ');
                              currentUserNumber();
                            }
                            catch(e){
                              dataStoreDialog(context, '에러 발생\n 재시도 바람 ');
                            }
                          }
                        },
                        child: Container(
                            width: size.width * 0.25,
                            height: 55,
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

  Widget textSpaceArchitecture(
      {@required String title, @required double width}) {
    return Container(
        width: width,
        height: 55,
        alignment: Alignment.center,
        child: Text(
          '$title',
          textScaleFactor: 1.5,
        ),
        decoration:
            BoxDecoration(border: Border.all(width: 2, color: Colors.cyan)));
  }

  void dataStoreDialog(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (ctx) {
          Future.delayed(Duration(milliseconds: 700), (){
            Navigator.pop(ctx);
            Navigator.pop(context);
          });
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            content: Container(width:20,height:50,alignment:Alignment.center,child: Text(message,style: TextStyle(fontWeight: FontWeight.bold),)),
          );
        });
  }
  Future<void> currentUserNumber() async{
    if(database == null){
      return;
    }
    id_val = Sqflite.firstIntValue(await database.rawQuery('SELECT COUNT(*) FROM user_info')) + 1;
    setState(() {
    });
  }
}
