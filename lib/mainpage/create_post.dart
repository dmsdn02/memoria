import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _postController = TextEditingController();
  List<String> _selectedFriends = []; // 선택된 친구 목록

  @override
  void initState() {
    super.initState();
    // 오늘 날짜를 기본값으로 설정
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _postController.dispose();
    super.dispose();
  }

  void _submitPost() {
    String title = _titleController.text;
    String date = _dateController.text;
    String postContent = _postController.text;
    // 여기서 포스트를 전송하거나 저장하는 로직을 추가할 수 있습니다.
    // 예를 들어, 서버에 포스트를 업로드하거나 로컬 데이터베이스에 저장할 수 있습니다.
    print('Submitted post: $title, $date, $postContent, Friends: $_selectedFriends');
    // 페이지를 닫습니다. (pop)
    Navigator.pop(context);
  }
  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // 현재 날짜를 초기값으로 설정
      firstDate: DateTime(2000), // 선택 가능한 시작 날짜
      lastDate: DateTime(2101), // 선택 가능한 마지막 날짜
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('추억작성'),
        centerTitle: true, //가운데정렬
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  '제목',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(width: 8.0),
                Container(
                  width: deviceWidth * 0.8, // 네모칸의 너비
                  height: 50, // 네모칸의 높이
                  decoration: BoxDecoration(
                    color: Colors.white, // 네모칸의 배경색
                    border: Border.all(
                      color: Colors.grey, // 테두리 색상
                    ),
                    borderRadius: BorderRadius.circular(8.0), // 모서리 설정
                  ),
                  alignment: Alignment.center, // 내용의 정렬
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: ' 제목을 입력하세요.', // 네모칸 안에 힌트 텍스트
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Text(
                  '날짜',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      //hintText: '날짜를 선택하세요',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: _selectDate,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.0),
            // 추억친구 선택 (여기에는 원하는 방법으로 추억친구를 선택하는 UI를 추가해야 합니다.)
            // 예를 들어, 친구 목록에서 친구를 선택하는 다이얼로그 등을 사용할 수 있습니다.
            // 이 예시에서는 단순히 선택된 친구 목록을 보여주는 텍스트 필드를 사용합니다.
            Row(
              children: [
                Text(
                  '추억친구',
              style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
                ),
              ],
            ),

            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: deviceWidth * 0.9, // 네모칸의 너비
                  height: 300, // 네모칸의 높이
                  decoration: BoxDecoration(
                    color: Colors.white, // 네모칸의 배경색
                    border: Border.all(
                      color: Colors.grey, // 테두리 색상
                    ),
                    borderRadius: BorderRadius.circular(8.0), // 모서리 설정
                  ),
                  alignment: Alignment.topLeft,
                  // 내용의 정렬
                  child: TextField(
                    controller: _postController,
                    maxLines: null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: ' 추억을 기록하세요', // 네모칸 안에 힌트 텍스트
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE4728D), // 버튼 배경색
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20), // 버튼 패딩
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // 버튼 모서리
                ),
              ),
              child: Text(
                '완료',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
