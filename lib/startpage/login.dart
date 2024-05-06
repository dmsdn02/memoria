import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'login.dart'; // login.dart 파일 import

void main() {
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
      ),
      body: Padding(
        padding: EdgeInsets.all(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: '이메일',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: '비밀번호',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20.0),

            SizedBox(
              width: 260.0, // 버튼의 너비 설정
              height: 50.0, // 버튼의 높이 설정
              child: ElevatedButton(
                onPressed: () {
                  // 여기에 로그인 처리 코드를 작성하세요.
                  String email = emailController.text;
                  String password = passwordController.text;
                  // 예: 실제로는 여기에 서버로의 로그인 요청이 들어갈 것입니다.
                  print('Email: $email, Password: $password');

                  // 로그인 버튼을 눌렀을 때 그룹선택? 페이지로 이동하고, 이전 페이지는 스택에서 제거
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0), // 버튼의 내부 패딩 조절
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // 버튼의 모서리를 둥글게 만듦
                  ),
                  backgroundColor: Color(0xFFE4728D), // 버튼의 배경색 변경
                  elevation: 5.0, // 버튼의 그림자 높이 설정
                ),
                child: Text(
                  '로그인',
                  style: TextStyle(
                    fontSize: 18.0, // 버튼 텍스트의 크기 설정
                    fontWeight: FontWeight.bold, // 버튼 텍스트의 굵기 설정
                    color: Colors.white, // 버튼 텍스트의 색상 설정
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0), // 텍스트 버튼과 로그인 버튼 사이의 간격 조절

            // 비밀번호 찾기 텍스트 버튼
            TextButton(
              onPressed: () {
                // 여기에 비밀번호 찾기 기능을 수행하는 코드를 작성하세요.
                print('비밀번호 찾기');
              },
              child: Text(
                '비밀번호를 잊으셨나요?',
                style: TextStyle(
                  color: Colors.blue, // 텍스트 색상 변경
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
