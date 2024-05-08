import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime selectedDate = DateTime.now();
  DateTime today = DateTime.now();

  @override
  Widget build(BuildContext context) {
    String currentYearMonth = DateFormat('yyyy년 MM월').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Page'),
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
              // 설정 기능
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Colors.grey), // 회색 구분선
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white), // 프로필 아이콘
                ),
                SizedBox(width: 10),
                Text(
                  "사용자 이름", // 사용자 이름
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
                    _selectDate(context); // 날짜 선택 기능
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildCalendar(),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.question_answer),
              onPressed: () {
                // 질문 및 답변 기능
              },
            ),
            SizedBox(width: 40), // 플러스 아이콘 공간
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                // 사람 아이콘 기능
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 플러스 아이콘 기능
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

  Widget _buildCalendar() {
    List<String> weekDays = ['월', '화', '수', '목', '금', '토', '일'];
    int daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    List<Widget> gridContent = [];

    gridContent.addAll(weekDays.map((day) => Text(day, style: TextStyle(fontSize: 18))));

    for (int i = 1; i <= daysInMonth; i++) {
      bool isToday = (i == today.day); // 오늘 날짜 확인
      gridContent.add(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud, color: Color(0xFFADD8E6)), // 연한 하늘색
            Text(
              i.toString(),
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal, // 오늘은 진한 글씨
              ),
            ),
          ],
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
}
