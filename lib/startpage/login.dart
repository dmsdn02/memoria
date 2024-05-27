import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memoria/mainpage/calendar.dart';
import 'package:memoria/startpage/reset_password.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 23),
            Container(
              width: 320,
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: '이메일',
                        filled: true,
                        fillColor: Colors.white,
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.email, color: Colors.grey[400]),
                      ),
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    height: 0.8,
                    width: double.infinity,
                    color: Colors.grey[300],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                        filled: true,
                        fillColor: Colors.white,
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.lock, color: Colors.grey[400]),
                      ),
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 310,
              height: 45,
              child: ElevatedButton(
                onPressed: () async {
                  String enteredEmail = emailController.text;
                  String enteredPassword = passwordController.text;

                  try {
                    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
                      email: enteredEmail,
                      password: enteredPassword,
                    );

                    User? user = userCredential.user;

                    if (user != null) {
                      if (user.emailVerified) {
                        // 사용자 데이터 로드
                        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
                        if (userDoc.exists) {
                          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CalendarPage()),
                          );
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('이메일 인증 필요'),
                              content: Text('이메일을 확인하고 인증해주세요.'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('확인'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  } catch (e) {
                    print("로그인 실패: $e");

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('로그인 실패'),
                          content: Text('이메일 또는 비밀번호가 잘못되었습니다.'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('확인'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE4728D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    '로그인',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResetPassword()),
                );
              },
              child: Text(
                '비밀번호 찾기',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
