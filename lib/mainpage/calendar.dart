import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memoria/mainpage/question.dart';
import 'package:provider/provider.dart';
import '../add/mypage.dart';
import '../add/setting.dart';
import 'feed.dart';
import 'package:memoria/add/groupProvider.dart';
import 'create_post.dart';
import 'package:memoria/add/setting.dart';

class CalendarPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  CalendarPage({required this.groupId, required this.groupName});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime selectedDate = DateTime.now();
  DateTime today = DateTime.now();
  late Future<Map<int, bool>> calendarData;

  @override
  void initState() {
    super.initState();
    calendarData = _generateCalendar();
  }

  @override
  Widget build(BuildContext context) {
    String currentYearMonth = DateFormat('yyyy년 MM월').format(selectedDate);
    String groupName = widget.groupName.isNotEmpty ? widget.groupName : "그룹을 선택하세요";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(groupName),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // 알림 기능
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingPage()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Colors.grey),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                SizedBox(width: 10),
                Text(
                  groupName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentYearMonth,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    _selectDate(context);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<int, bool>>(
              future: calendarData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // 로딩 중이면 로딩 표시기 반환
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}')); // 에러가 발생하면 에러 텍스트 반환
                } else {
                  return _buildCalendar(snapshot.data!); // 데이터가 준비되면 해당 데이터를 사용하여 캘린더 빌드
                }
              },
            ),
          ),
        ],
      ),
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
                  MaterialPageRoute(
                    builder: (context) => QuestionPage(groupId: widget.groupId, userId: ''), // 수정된 부분
                  ),
                );
                // 질문 및 답변 기능
              },
            ),
            SizedBox(width: 40),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyPage()),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget _buildCalendar(Map<int, bool> calendarData) {
    List<String> weekDays = ['일', '월', '화', '수', '목', '금', '토'];

    int daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    List<Widget> gridContent = [];

    gridContent.addAll(
      weekDays.map(
            (day) => Center(
          child: Text(day, style: TextStyle(fontSize: 18)),
        ),
      ),
    );

    DateTime firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    int startWeekday = (firstDayOfMonth.weekday) % 7;

    for (int i = 0; i < startWeekday; i++) {
      gridContent.add(Container());
    }

    for (int i = 1; i <= daysInMonth; i++) {
      bool isToday = (i == today.day && selectedDate.month == today.month && selectedDate.year == today.year);
      bool? hasPost = calendarData[i]; // 해당 날짜에 게시물이 있는지 확인

      gridContent.add(
          GestureDetector(
              onTap: () {
                DateTime currentDay = DateTime(selectedDate.year, selectedDate.month, i);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostsByDatePage(initialDate: currentDay, groupId: widget.groupId),
                  ),
                );
              },
              child: Container(
              color: hasPost != null && hasPost ? Colors.white.withOpacity(0.5) : Colors.white, // 항상 흰 배경색으로 유지하도록 변경
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud, color: hasPost != null && hasPost ? Color(0xFFFFC5D3) : Color(0xFFADD8E6)), // 게시물이 있는 날짜면 구름 색상을 핑크로 변경
              // 게시물이 있는 날짜면 구름 색상 변경
              Text(
                i.toString(),
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
              ),
          ),
      );

    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 7,
        children: gridContent,
      ),
    );
  }
  Future<Map<int, bool>> _generateCalendar() async {
    Map<int, bool> calendarData = {};

    int daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    String selectedGroupId = context.read<GroupProvider>().selectedGroupId;

    for (int i = 1; i <= daysInMonth; i++) {
      DateTime currentDay = DateTime(selectedDate.year, selectedDate.month, i);
      bool hasPost = await checkIfDayHasPost(selectedGroupId, currentDay);
      calendarData[i] = hasPost;
    }

    return calendarData;
  }
  Future<bool> checkIfDayHasPost(String groupId, DateTime date) async {
    // 게시물이 있는지 확인하는 쿼리
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('groupId', isEqualTo: groupId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(date)) // 수정된 부분
        .where('timestamp', isLessThan: Timestamp.fromDate(date.add(Duration(days: 1)))) // 수정된 부분
        .get();

    // 쿼리 결과에서 해당 그룹 및 날짜에 게시물이 있는지 확인
    return querySnapshot.docs.isNotEmpty;
  }

}
