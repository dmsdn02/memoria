import 'package:flutter/material.dart';
import 'package:memoria/startpage/register.dart';
import 'login.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 키보드 숨기기
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            height: screenHeight,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // "Memoria" 제목
                    Center( // 가운데 정렬
                      child: Text(
                        'Memoria',
                        style: TextStyle(
                          fontSize: 33,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // 소제목
                    Center(
                      child: Text(
                        '우리의 하루를 계획, 기록, 공유까지 한 번에',
                        style: TextStyle(
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.1),
                    // 로그인 버튼
                    Center( // 가운데 정렬
                      child: Container(
                        width: screenWidth * 0.7,
                        height: 55.0,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            backgroundColor: Color(0xFFE4728D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                          },
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
                    SizedBox(height: screenHeight * 0.02),
                    // 회원가입 버튼
                    Center( // 가운데 정렬
                      child: Container(
                        width: screenWidth * 0.7,
                        height: 55.0,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            backgroundColor: Color(0xFFFFC5D3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegisterPage()),
                            );
                          },
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
    );
  }
}
