import 'package:babsuni/dailyorder_page.dart';
import 'package:babsuni/neworderer_page.dart';
import 'package:babsuni/orderlist_page.dart';
import 'package:babsuni/orderschedule_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  //List<Map> list = await db.rawQuery('SELECT * FROM test'); // 제네릭 Map 타입의 List 타입이라는 의미는 List의 데이터가 Map이라는 것 구조 -> [{a:b}, {c:d}] (콤마로 각각 리스트의 인덱스 구분)
  // 그리고 각각 List의 원소는 쿼리문 결과의 하나의 행(row)이다.
  runApp(BabsuniApp());
}

class BabsuniApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Main(),
      supportedLocales: [const Locale('ko', 'KR')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '밥수니반찬 주문 관리 시스템',
                style: TextStyle(fontSize: 25),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
              ),
              pageButton(context: context, titleText: '신규 주문자 등록', btnNum: 1),
              const Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              pageButton(context: context, titleText: '일일 주문 등록', btnNum: 2),
              const Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              pageButton(context: context, titleText: '주문 내역 조회', btnNum: 3),
              const Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              pageButton(context: context, titleText: '주문 스케줄 조회', btnNum: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget pageButton(
      {@required BuildContext context,
      @required String titleText,
      @required int btnNum}) {
    return FlatButton(
        onPressed: () {
          switch (btnNum) {
            case 1:
              _goNewOrderer(context);
              break;
            case 2:
              _goDailyOrder(context);
              break;
            case 3:
              _goOrderList(context);
              break;
            case 4:
              _goOrderSchedule(context);
              break;
          }
        },
        child: Container(
          decoration:
              BoxDecoration(border: Border.all(width: 2, color: Colors.cyan)),
          alignment: Alignment.center,
          width: 260,
          height: 70,
          child: Text(
            titleText,
            textScaleFactor: 1.5,
          ),
        ));
  }

  void _goNewOrderer(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
      return NewOrdererRegisterPage();
    }));
  }

  void _goDailyOrder(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
      return DailyOrderRegisterPage();
    }));
  }

  void _goOrderList(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
      return CheckOrderListPage();
    }));
  }

  void _goOrderSchedule(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
      return CheckOrderSchedule();
    }));
  }
}
