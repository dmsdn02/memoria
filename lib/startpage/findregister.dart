import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FindRegister(),
    );
  }
}

class FindRegister extends StatefulWidget {
  @override
  _FindRegisterState createState() => _FindRegisterState();
}

class _FindRegisterState extends State<FindRegister> {
  final TextEditingController emailController = TextEditingController();
  final RegExp emailRegExp = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );
  bool isEmailInvalid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100.0, left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 30,
                  color: Colors.black,
                ),
                SizedBox(width: 10),
                Text(
                  '비밀번호 찾기',
                  style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '회원정보에 등록한 이메일을 입력해주세요.\n등록한 이메일로 비밀번호 재설정 메일이 발송됩니다.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: '이메일',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        isEmailInvalid = !isEmailValid(value);
                      });
                    },
                  ),
                ),
                Visibility(
                  visible: isEmailInvalid,
                  child: Text(
                    '올바른 이메일 형식이 아닙니다.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    String email = emailController.text.trim();
                    if (isEmailValid(email)) {
                      // 올바른 이메일인 경우에만 이메일 전송
                      sendPasswordResetEmail(email);
                    }
                  },
                  child: Text(
                    '이메일 전송',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFFC5D3)),
                    minimumSize: MaterialStateProperty.all(Size(300, 50)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // 모서리의 반지름 설정
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool isEmailValid(String email) {
    return emailRegExp.hasMatch(email);
  }

  void sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // 비밀번호 재설정 이메일이 성공적으로 전송됨
      print('이메일 전송 성공');
      // 추가적인 UI 작업 또는 네비게이션 등을 수행할 수 있음
    } catch (e) {
      // 이메일 전송 실패
      print('이메일 전송 실패: $e');
      // 에러 메시지를 사용자에게 표시할 수 있음
    }
  }
}