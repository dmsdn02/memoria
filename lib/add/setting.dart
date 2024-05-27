import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memoria/startpage/reset_password.dart';
import '../startpage/start.dart';
import 'delete_account.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SettingsBody(),
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
          icon: Icons.account_circle,
          onTap: () {
            // Handle account settings
          },
        ),
        SubSettingItem(
          title: '비밀번호 변경',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ResetPassword()),
            );
          },
        ),
        SubSettingItem(
          title: '로그아웃',
          onTap: () {
            _showLogoutDialog(context);
          },
        ),
        SubSettingItem(
          title: '계정탈퇴',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DeleteAccountPage()),
            );
          },
        ),
        SettingItem(
          title: '알림',
          icon: Icons.notifications,
          onTap: () {
            // Handle notification settings
          },
        ),
        SubSettingItem(
          title: '알림설정',
          isSwitch: true,
          onTap: () {
            // Handle notification settings
          },
        ),
        // Add more settings as needed
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그아웃'),
          content: Text('로그아웃 하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
            TextButton(
              child: Text('예'),
              onPressed: () async {
                await FirebaseAuth.instance.signOut(); // 로그아웃
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => StartPage()), // StartPage로 이동
                      (Route<dynamic> route) => false, // 모든 이전 경로를 제거하여 뒤로 가기를 방지
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class SettingItem extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Function onTap;

  const SettingItem({
    Key? key,
    required this.title,
    this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey[50],
      child: ListTile(
        leading: icon != null ? Icon(icon, color: Colors.black) : null,
        title: Text(
          title,
          style: TextStyle(color: Colors.black),
        ),
        onTap: () {
          onTap();
        },
      ),
    );
  }
}

class SubSettingItem extends StatelessWidget {
  final String title;
  final Function onTap;
  final bool? isSwitch;

  const SubSettingItem({
    Key? key,
    required this.title,
    required this.onTap,
    this.isSwitch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: Colors.black),
              ),
            ),
            if (isSwitch != null && isSwitch!)
              Switch(
                value: true,
                onChanged: (value) {
                  // Handle switch change
                },
              ),
          ],
        ),
        onTap: () {
          onTap();
        },
      ),
    );
  }
}
