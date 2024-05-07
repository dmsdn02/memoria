import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String email = "";
  String password = "";
  String confirmPassword = "";
  String name = "";
  String userNickname = "";
  String gender = "";

  bool isRegistered = false;
  bool showErrorMessage = false;
  bool emailVerified = false;

  void _register() async {
    setState(() {
      showErrorMessage = true;
    });

    try {
      if (email.isEmpty ||
          password.isEmpty ||
          confirmPassword.isEmpty ||
          name.isEmpty ||
          userNickname.isEmpty ||
          gender.isEmpty) {
        print("정보를 입력해주세요.");
        setState(() {
          isRegistered = false;
        });
        return;
      }

      if (password != confirmPassword) {
        print("비밀번호와 비밀번호 확인이 일치하지 않습니다.");
        return;
      }

      // 사용자에게 이메일 인증 메일 전송
      await _sendEmailVerification();

      setState(() {
        isRegistered = true;
      });
    } catch (e) {
      print("회원가입 실패: $e");
    }
  }

  Future<void> _sendEmailVerification() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Firestore에 사용자 정보 저장
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'name': name,
          'userNickname': userNickname,
          'gender': gender,
        });

        // 사용자에게 이메일 인증 메일 전송
        await user.sendEmailVerification();
        print('이메일 인증 메일이 전송되었습니다. 이메일을 확인해주세요.');
      }
    } catch (e) {
      print('이메일 인증 메일 전송 실패: $e');
    }
  }

  Future<void> _checkEmailVerification() async {
    User? user = _auth.currentUser;

    try {
      await user?.reload();
      user = _auth.currentUser;

      if (user != null && user.emailVerified) {
        print('이메일이 인증되었습니다.');
        // TODO: 여기에 로그인 로직을 추가하면 됩니다.
      } else {
        print('이메일이 아직 인증되지 않았습니다.');
      }
    } catch (e) {
      print('이메일 인증 상태 확인 실패: $e');
    }
  }

  void checkNicknameAvailability(String nickname) async {
    // 여기에서 비동기적인 작업 수행 (파이어베이스 데이터베이스 등에서 중복 확인)
    await Future.delayed(Duration(seconds: 2));
    print('Nickname $nickname is available!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        backgroundColor: Color(0xFFF6E690),
      ),
      backgroundColor: Color(0xFFF6E690),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 80.0),
                Text('회원가입', style: TextStyle(fontSize: 27.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 23.0),
                Container(
                  width: 320,
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: '이메일',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[400]),
                                ),
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                                onChanged: (value) {
                                  email = value;
                                },
                              ),
                            ),
                          ],
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
                          decoration: InputDecoration(
                            labelText: '비밀번호',
                            filled: true,
                            fillColor: Colors.white,
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
                          ),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          obscureText: true,
                          onChanged: (value) {
                            password = value;
                          },
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
                          decoration: InputDecoration(
                            labelText: '비밀번호 확인',
                            filled: true,
                            fillColor: Colors.white,
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
                          ),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          obscureText: true,
                          onChanged: (value) {
                            confirmPassword = value;
                          },
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
                          decoration: InputDecoration(
                            labelText: '이름',
                            filled: true,
                            fillColor: Colors.white,
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.person_outline, color: Colors.grey[400]),
                          ),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          onChanged: (value) {
                            name = value;
                          },
                        ),
                      ),
                      Container(
                        height: 0.8,
                        width: double.infinity,
                        color: Colors.grey[300],
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: '닉네임',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.account_circle, color: Colors.grey[400]),
                                ),
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                                onChanged: (value) {
                                  userNickname = value;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 0.8,
                        width: double.infinity,
                        color: Colors.grey[300],
                      ),
                      Container(
                        height: 50.0,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.male_outlined, color: Colors.grey[400]),
                            Icon(Icons.female_outlined, color: Colors.grey[400]),
                            SizedBox(width: 30),
                            Radio(
                              value: "남",
                              groupValue: gender,
                              onChanged: (value) {
                                setState(() {
                                  gender = value.toString();
                                });
                              },
                            ),
                            Text(
                              "남",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(width: 20),
                            Radio(
                              value: "여",
                              groupValue: gender,
                              onChanged: (value) {
                                setState(() {
                                  gender = value.toString();
                                });
                              },
                            ),
                            Text(
                              "여",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  width: 310,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      _register();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFF1B4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2, // 그림자 추가
                    ),
                    child: Text(
                      '가입하기',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                showErrorMessage && !isRegistered && email.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty && name.isNotEmpty && userNickname.isNotEmpty && gender.isNotEmpty
                    ? SizedBox(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.brown, fontSize: 17),
                      children: [
                        TextSpan(
                          text: '  가입이 완료되었습니다.\n',
                        ),
                        TextSpan(
                          text: '이메일을 확인하고 로그인 페이지로 이동하기',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : SizedBox.shrink(),
                !isRegistered &&
                    showErrorMessage &&
                    (email.isEmpty ||
                        password.isEmpty ||
                        confirmPassword.isEmpty ||
                        name.isEmpty ||
                        userNickname.isEmpty ||
                        gender.isEmpty)
                    ? SizedBox(
                  child: Text(
                    '정보를 입력하세요.',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}