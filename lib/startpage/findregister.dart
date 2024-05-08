import 'package:flutter/material.dart';

class FindRegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Register Page'),
        backgroundColor: Colors.blue, // 원하는 색상으로 변경 가능
      ),
      body: Center(
        child: Text(
          'Find Register Page Content',
          style: TextStyle(fontSize: 18, color: Colors.black),
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
      home: FindRegisterPage(),
    );
  }
}
