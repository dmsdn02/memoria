import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:memoria/mainpage/calendar.dart';
import 'package:memoria/startpage/start.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDfgNlHLcVHsbZOAqzBGqi9ngqF6XZddZs",
      authDomain: "memoria-7b14d.firebaseapp.com",
      projectId: "memoria-7b14d",
      //storageBucket: "codemate-b0880.appspot.com",
      messagingSenderId: "699450401533",
      appId: "1:699450401533:android:b8dc59f10d244f7bb01494",
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StartPage(), // 클래스 이름과 경로 확인
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
    );
  }
}
