import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Page'),
        backgroundColor: Colors.blue, // 원하는 색상으로 변경 가능
      ),
      body: Container(
        color: Colors.white, // 하얀 배경
        child: Center(
          child: Text(
            'Calendar Page Content',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 원하는 동작을 추가하세요.
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue, // 원하는 색상으로 변경 가능
      ),
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CalendarPage(),
    );
  }
}
