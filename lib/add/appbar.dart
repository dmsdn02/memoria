import 'package:flutter/material.dart';
import '../mainpage/calendar.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final List<Widget> bottomItems;

  const CustomAppBar({
    required this.title,
    required this.actions,
    required this.bottomItems,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          SizedBox(width: 8.0), // title과 아이콘 사이의 간격
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarPage()),
              );
            },
          ),
        ],
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: Divider(color: Colors.grey), // 회색 구분선
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
