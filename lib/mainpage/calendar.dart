import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  Widget build(BuildContext context) {
    String currentYearMonth = DateFormat('yyyy년 MM월').format(selectedDate);
    String groupName = widget.groupName.isNotEmpty ? widget.groupName : "(그룹명)";

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
            child: _buildCalendar(),
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

  Widget _buildCalendar() {
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
      DateTime currentDay = DateTime(selectedDate.year, selectedDate.month, i);
      gridContent.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostsByDatePage(initialDate: currentDay, groupId: widget.groupId), // 변경된 부분
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud, color: Color(0xFFADD8E6)),
              Text(
                i.toString(),
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
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
}
