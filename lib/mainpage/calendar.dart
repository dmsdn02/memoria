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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, //가운데 정렬
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white), // 프로필 아이콘
                ),
                SizedBox(width: 10),
                Text(
                  "(그룹명)",
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
    List<String> weekDays = ['일', '월', '화', '수', '목', '금', '토'];

    int daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    List<Widget> gridContent = [];

    // 요일을 가운데 정렬하여 출력
    gridContent.addAll(
      weekDays.map(
            (day) => Center(
          child: Text(day, style: TextStyle(fontSize: 18)),
        ),
      ),
    );

    // 첫 주에 빈 공간 추가 (해당 월의 시작 요일에 따라)
    DateTime firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    int startWeekday = (firstDayOfMonth.weekday) % 7;

    for (int i = 0; i < startWeekday; i++) {
      gridContent.add(Container()); // 빈 칸
    }

    // 날짜와 구름모양 아이콘 출력
    for (int i = 1; i <= daysInMonth; i++) {
      bool isToday = (i == today.day);
      gridContent.add(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud, color: Color(0xFFADD8E6)), // 연한 하늘색
            Text(
              i.toString(),
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 7, // 7개 요일
        children: gridContent,
      ),
    );
  }
}
