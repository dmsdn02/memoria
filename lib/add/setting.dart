import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          leading: IconButton( // 왼쪽에 뒤로가기 버튼 추가
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(); // 뒤로가기 기능 추가
            },
          ),
        ),
        body: SettingsBody(),
      ),
    );
  }
}

class SettingsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        SettingItem(
          title: '계정',
          icon: Icons.account_circle, // 계정 아이콘 추가
          onTap: () {
            // Handle Wi-Fi settings
          },
        ),
        SubSettingItem(
          title: '비밀번호 변경',
          onTap: () {
            // Handle Wi-Fi Name settings
          },
        ),
        SubSettingItem(
          title: '로그아웃',
          onTap: () {
            // Handle Wi-Fi Password settings
          },
        ),
        SubSettingItem(
          title: '계정탈퇴',
          onTap: () {
            // Handle Wi-Fi Password settings
          },
        ),
        SettingItem(
          title: '알림',
          icon: Icons.notifications, // 알림 아이콘 추가
          onTap: () {
            // Handle Bluetooth settings
          },
        ),
        SubSettingItem(
          title: '알림설정',
          isSwitch: true, // 스위치 버튼 추가
          onTap: () {
            // Handle Bluetooth Devices settings
          },
        ),
        // Add more settings as needed
      ],
    );
  }
}

class SettingItem extends StatelessWidget {
  final String title;
  final IconData? icon; // 아이콘 추가
  final Function onTap;

  const SettingItem({
    Key? key,
    required this.title,
    this.icon, // 아이콘 추가
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey[50], // SettingItem의 배경색
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.black, // SettingItem의 아이콘 색상
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black, // SettingItem의 텍스트 색상
          ),
        ),
        onTap: () {
          if (onTap != null) {
            onTap();
          }
        },
      ),
    );
  }
}

class SubSettingItem extends StatelessWidget {
  final String title;
  final Function onTap;
  final bool? isSwitch; // 스위치 버튼 추가

  const SubSettingItem({
    Key? key,
    required this.title,
    required this.onTap,
    this.isSwitch, // 스위치 버튼 추가
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // SubSettingItem의 배경색 (하얀색)
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.black, // SubSettingItem의 텍스트 색상 (검은색)
                ),
              ),
            ),
            if (isSwitch != null && isSwitch!) // 스위치 버튼 추가
              Switch(
                value: true, // 예시로 기본값은 true
                onChanged: (value) {
                  // Handle switch change
                },
              ),
          ],
        ),
        onTap: () {
          if (onTap != null) {
            onTap();
          }
        },
      ),
    );
  }
}
