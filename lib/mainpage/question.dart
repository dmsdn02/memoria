import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'calendar.dart';
import '../add/mypage.dart';

class QuestionPage extends StatefulWidget {
  final String groupId;
  final String userId;

  QuestionPage({required this.groupId, required this.userId});

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  TextEditingController _answerController = TextEditingController();
  int _currentQuestionIndex = 0;
  List<Map<String, dynamic>> _questions = [
    {
      'question': '함께 먹었던 음식 중 가장 맛있었던 음식은?',
      'groupAnswers': [],
      'friendAnswers': []
    },
    {
      'question': '가장 기억에 남는 여행지는 어디인가요?',
      'groupAnswers': [],
      'friendAnswers': []
    },
    {
      'question': '가족과 함께 즐겼던 취미는 무엇인가요?',
      'groupAnswers': [],
      'friendAnswers': []
    },
    {
      'question': '친구들과의 가장 즐거웠던 순간은 언제인가요?',
      'groupAnswers': [],
      'friendAnswers': []
    },
    {
      'question': '연인과 함께한 최고의 데이트는 무엇이었나요?',
      'groupAnswers': [],
      'friendAnswers': []
    },
    {
      'question': '가족이 함께한 최고의 이벤트는 무엇인가요?',
      'groupAnswers': [],
      'friendAnswers': []
    },
    {
      'question': '친구들과 함께 보고 싶은 영화는 무엇인가요?',
      'groupAnswers': [],
      'friendAnswers': []
    },
    {
      'question': '연인과 함께 가고 싶은 여행지는 어디인가요?',
      'groupAnswers': [],
      'friendAnswers': []
    },
    {
      'question': '가족과 함께한 최고의 추억은 무엇인가요?',
      'groupAnswers': [],
      'friendAnswers': []
    },
    {
      'question': '친구들과 함께 도전해 보고 싶은 활동은 무엇인가요?',
      'groupAnswers': [],
      'friendAnswers': []
    },
  ];
  List<Map<String, dynamic>> _allChatItems = [];
  bool _hasAnsweredCurrentQuestion = false;
  bool _hasSubmittedCurrentAnswer = false;

  @override
  void initState() {
    super.initState();
    _initializeChatItems();
  }

  Future<void> _initializeChatItems() async {
    setState(() {
      _allChatItems.add({'type': 'question', 'content': _questions[_currentQuestionIndex]['question']});
    });
  }

  Future<void> _loadFriendsAnswers(int questionIndex) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('answers')
          .where('questionIndex', isEqualTo: questionIndex)
          .where('groupId', isEqualTo: widget.groupId)
          .get();

      List<String> friendAnswers = snapshot.docs
          .where((doc) => doc['userId'] != widget.userId) // 내 답변 제외
          .map((doc) => doc['answer'] as String)
          .toList();

      setState(() {
        for (var answer in friendAnswers) {
          _allChatItems.add({'type': 'answer', 'content': answer, 'isGroupAnswer': true});
        }
      });
    } catch (error) {
      print('친구 답변을 불러오는 데 실패했습니다: $error');
    }
  }

  Future<void> _submitAnswer(String answer) async {
    try {
      await FirebaseFirestore.instance.collection('answers').add({
        'questionIndex': _currentQuestionIndex,
        'answer': answer,
        'userId': widget.userId,
        'groupId': widget.groupId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        // 내 답변을 _allChatItems에 추가
        _allChatItems.add({'type': 'answer', 'content': answer, 'isGroupAnswer': false});
        _hasAnsweredCurrentQuestion = true;
        _hasSubmittedCurrentAnswer = true;
      });

      await _loadFriendsAnswers(_currentQuestionIndex);

      // 다음 질문으로 넘어가는 로직을 분리
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _allChatItems.add({'type': 'question', 'content': _questions[_currentQuestionIndex]['question']});
          _answerController.clear();
        });
      }
    } catch (error) {
      print('답변을 제출하는 데 실패했습니다: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('오늘의 질문'),
        automaticallyImplyLeading: false, // 뒤로가기 버튼 숨기기
        iconTheme: IconThemeData(color: Colors.black), // 아이콘 색
      ),
      backgroundColor: Colors.white, // 바탕색을 흰색으로 설정
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _allChatItems.length,
                itemBuilder: (context, index) {
                  var chatItem = _allChatItems[index];
                  if (chatItem['type'] == 'question') {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(12.0),
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          chatItem['content'],
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    );
                  } else {
                    return chatItem['isGroupAnswer']
                        ? Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(12.0),
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.green[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          chatItem['content'],
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    )
                        : Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.all(12.0),
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.blue[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          chatItem['content'],
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 홈 버튼이 눌렸을 때 수행할 작업을 여기에 작성하세요.
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
                  MaterialPageRoute(builder: (context) => QuestionPage(groupId: widget.groupId, userId: widget.userId)),
                );
              },
            ),
            SizedBox(width: 40),
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
