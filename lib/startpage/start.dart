import 'package:flutter/material.dart';
import 'package:memoria/main.dart';
import 'package:memoria/startpage/register.dart';

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



                        // 로그인 버튼
                        Container(
                          padding: EdgeInsets.fromLTRB(screenWidth * 0.1, screenHeight * 0.02, screenWidth * 0.1, 0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              surfaceTintColor: Colors.transparent,
                              elevation: 5,
                              backgroundColor: Color(0xFFE4728D),
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
                              backgroundColor: Color(0xFFFFC5D3),
                              shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0)),
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                            ),
                            onPressed: () {
                              // 회원가입 버튼 클릭 이벤트
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RegisterPage()), //회원가입 페이지로 이동
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
