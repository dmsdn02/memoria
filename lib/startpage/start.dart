import 'package:flutter/material.dart';
import 'package:memoria/main.dart';

import 'login.dart';

class startPage extends StatefulWidget {
  const startPage({super.key});

  @override
  State<startPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<startPage> {
  // 상태 및 초기화
  late bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            // 키보드 숨기기
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                height: screenHeight,
                child: Center(
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, screenHeight * 0.2, 0, 0),
                          child: Image.asset(
                            'assets/image/splash/banner.png', // 배너 이미지
                            width: 200,
                            height: 100,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.08),

                        // 학번 입력 필드
                        Container(
                          padding: EdgeInsets.fromLTRB(screenWidth * 0.1, screenHeight * 0.02, screenWidth * 0.1, 0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[200], // 연한 회색 배경
                          ),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: '학번',
                              hintStyle: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                              prefixIcon: Icon(Icons.school, color: Colors.grey),
                            ),
                            onChanged: (text) {
                              // 학번 변경 이벤트
                            },
                          ),
                        ),
                        // 비밀번호 입력 필드
                        Container(
                          padding: EdgeInsets.fromLTRB(screenWidth * 0.1, screenHeight * 0.01, screenWidth * 0.1, 0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[200], // 연한 회색 배경
                          ),
                          child: TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: '비밀번호',
                              hintStyle: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                              prefixIcon: Icon(Icons.lock, color: Colors.grey),
                            ),
                            style: const TextStyle(fontSize: 15),
                            onChanged: (text) {
                              // 비밀번호 변경 이벤트
                            },
                          ),
                        ),
                        // 로그인 버튼
                        Container(
                          padding: EdgeInsets.fromLTRB(screenWidth * 0.1, screenHeight * 0.02, screenWidth * 0.1, 0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              surfaceTintColor: Colors.transparent,
                              elevation: 5,
                              backgroundColor: Color.fromARGB(255, 50, 113, 190),
                              shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0)),
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                            ),
                            onPressed: () {
                              // 로그인 버튼 클릭 이벤트
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()), //로그인 페이지로 이동
                              );
                            },
                            child: const Center(
                              child: Text(
                                '로그인',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // 회원가입 버튼
                        Container(
                          padding: EdgeInsets.fromLTRB(screenWidth * 0.1, screenHeight * 0.02, screenWidth * 0.1, 0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              surfaceTintColor: Colors.transparent,
                              elevation: 5,
                              backgroundColor: Colors.black,
                              shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0)),
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                            ),
                            onPressed: () {
                              // 회원가입 버튼 클릭 이벤트
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()), //회원가입 페이지로 이동
                              );
                            },
                            child: const Center(
                              child: Text(
                                '회원가입',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // 비밀번호 찾기 텍스트
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                              child: TextButton(
                                onPressed: () {
                                  // 비밀번호 찾기 클릭 이벤트
                                },
                                child: const Text(
                                  '비밀번호 찾기',
                                  style: TextStyle(
                                    color: Colors.indigo,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color(0xFF1976D2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // 로딩 화면 (스피너)


      ],
    );
  }
}
