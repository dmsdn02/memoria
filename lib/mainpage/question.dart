import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'calendar.dart';
import '../add/mypage.dart';

class QuestionPage extends StatefulWidget {
  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  TextEditingController _answerController = TextEditingController();
  int _currentQuestionIndex = 0;
  List<String> _questions = [
    '함께 먹었던 음식 중 가장 맛있었던 음식은?',
    '가장 기억에 남는 여행지는 어디인가요?',
    '가족과 함께 즐겼던 취미는 무엇인가요?',
    '친구들과의 가장 즐거웠던 순간은 언제인가요?',
    '연인과 함께한 최고의 데이트는 무엇이었나요?',
    '가족이 함께한 최고의 이벤트는 무엇인가요?',
    '친구들과 함께 보고 싶은 영화는 무엇인가요?',
    '연인과 함께 가고 싶은 여행지는 어디인가요?',
    '가족과 함께한 최고의 추억은 무엇인가요?',
    '친구들과 함께 도전해 보고 싶은 활동은 무엇인가요?'
  ];
  bool _hasAnsweredCurrentQuestion = false;
  bool _allGroupMembersAnswered = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _questions = [
        '함께 먹었던 음식 중 가장 맛있었던 음식은?',
        '가장 기억에 남는 여행지는 어디인가요?',
        '가족과 함께 즐겼던 취미는 무엇인가요?',
        '친구들과의 가장 즐거웠던 순간은 언제인가요?',
        '연인과 함께한 최고의 데이트는 무엇이었나요?',
        '가족이 함께한 최고의 이벤트는 무엇인가요?',
        '친구들과 함께 보고 싶은 영화는 무엇인가요?',
        '연인과 함께 가고 싶은 여행지는 어디인가요?',
        '가족과 함께한 최고의 추억은 무엇인가요?',
        '친구들과 함께 도전해 보고 싶은 활동은 무엇인가요?'
      ];
    });
  }

  Future<void> _submitAnswer(String answer) async {
    try {
      await FirebaseFirestore.instance.collection('answers').add({
        'questionIndex': _currentQuestionIndex,
        'answer': answer,
        'userId': '사용자ID', // 실제 사용자 ID를 여기에 넣으세요
        'groupId': '그룹ID',  // 실제 그룹 ID를 여기에 넣으세요
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        _hasAnsweredCurrentQuestion = true;
      });
      _checkAllGroupMembersAnswered();
    } catch (error) {
      print('답변을 제출하는 데 실패했습니다: $error');
    }
  }

  Future<void> _checkAllGroupMembersAnswered() async {
    try {
      QuerySnapshot groupAnswersSnapshot = await FirebaseFirestore.instance
          .collection('answers')
          .where('questionIndex', isEqualTo: _currentQuestionIndex)
          .where('groupId', isEqualTo: '그룹ID') // 실제 그룹 ID를 여기에 넣으세요
          .get();
      // 그룹원 수와 답변 수를 비교해서 모든 그룹원이 답변했는지 확인
      int groupMemberCount = 5; // 실제 그룹원 수를 여기에 넣으세요
      if (groupAnswersSnapshot.docs.length >= groupMemberCount) {
        setState(() {
          _allGroupMembersAnswered = true;
          if (_currentQuestionIndex < _questions.length - 1) {
            _currentQuestionIndex++;
            _answerController.clear();
            _hasAnsweredCurrentQuestion = false;
            _allGroupMembersAnswered = false;
          }
        });
      } else {
        setState(() {
          _allGroupMembersAnswered = false;
        });
      }
    } catch (error) {
      print('모든 그룹원의 답변을 확인하는 데 실패했습니다: $error');
    }
  }

  Future<List<String>> _loadFriendsAnswers(int questionIndex) async {
    try {
      QuerySnapshot answerSnapshot = await FirebaseFirestore.instance
          .collection('answers')
          .where('questionIndex', isEqualTo: questionIndex)
          .where('groupId', isEqualTo: '그룹ID') // 실제 그룹 ID를 여기에 넣으세요
          .get();
      return answerSnapshot.docs.map((doc) => doc['answer'] as String).toList();
    } catch (error) {
      print('친구들의 답변을 불러오는 데 실패했습니다: $error');
      return [];
    }
  }

  void _showFriendsAnswersDialog() async {
    if (!_hasAnsweredCurrentQuestion) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
          title: Text('알림'),
    content: Text('답변을 완료해야 친구의 답변을 볼 수 있습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('확인'),
              ),
            ],
          ));
          return;
          }

          List<String> friendsAnswers =
          await _loadFriendsAnswers(_currentQuestionIndex); // 현재 질문 인덱스 전달
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('친구들의 답변'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: friendsAnswers.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                    ),
                    child: Text(friendsAnswers[index]),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('닫기'),
            ),
          ],
        ),
      );
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('오늘의 질문'),
        automaticallyImplyLeading: false, // 뒤로가기 버튼 숨기기
        backgroundColor: Colors.white, // 상단 앱바 색상을 흰색으로 설정
        iconTheme: IconThemeData(color: Colors.black), // 아이콘 색상을 검정색으로 설정
      ),
      backgroundColor: Colors.white, // 바탕색을 흰색으로 설정
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단에 질문 아이콘
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.question_answer, size: 48.0),
              ],
            ),
            SizedBox(height: 20),
            // 오늘의 질문 또는 알림 메시지
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                _allGroupMembersAnswered
                    ? '모든 그룹원이 답변을 완료했습니다. 다음 질문으로 넘어갑니다.'
                    : _hasAnsweredCurrentQuestion
                    ? '아직 답변을 하지 않은 그룹원이 있습니다! 모든 그룹원 답변 시 다음 질문으로 넘어갑니다.'
                    : _questions[_currentQuestionIndex],
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            SizedBox(height: 20),
            // 답변 입력란
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                labelText: '답변',
                border: OutlineInputBorder(),
              ),
              maxLines: null, // 다중 라인 입력을 위해 null로 설정
            ),
            SizedBox(height: 20),
            // 답변 전송 버튼
            ElevatedButton(
              onPressed: () {
                String answer = _answerController.text.trim();
                if (answer.isNotEmpty) {
                  _submitAnswer(answer);
                }
              },
              child: Text('전송'),
            ),
            SizedBox(height: 20),
            // 친구의 답변 보기 버튼
            ElevatedButton(
              onPressed: _showFriendsAnswersDialog,
              child: Text('친구의 답변 보기'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Navigator.push(
            //context,
            //MaterialPageRoute(builder: (context) => CalendarPage()),
          //);
        },
        child: Icon(Icons.home),
        backgroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.question_answer),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuestionPage()),
                );
              },
            ),
            SizedBox(width: 40), // 플러스 아이콘 공간
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
