import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:memoria/friends/f_list.dart';
import 'package:memoria/mainpage/calendar.dart';
import 'package:memoria/startpage/start.dart';
import 'package:provider/provider.dart';

import 'add/groupProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'memoria',
    options: FirebaseOptions(
      apiKey: "AIzaSyDs79bHVta-IL6eGjnEK_Wg4ysbj08c37Q",
      authDomain: "memoria-f5d67.firebaseapp.com",
      projectId: "memoria-f5d67",
      storageBucket: "memoria-f5d67.appspot.com",
      messagingSenderId: "646927978499",
      appId: "1:646927978499:android:5ca91b788854dfb0cb7e36",
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GroupProvider()),
      ],
      child: MyApp(),
    ),
  );
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