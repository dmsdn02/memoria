import 'package:flutter/material.dart';
import 'package:memoria/startpage/reset_password.dart'; // ResetPassword 페이지 import

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
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
            // Handle logout
          },
        ),
        SubSettingItem(
          title: '계정탈퇴',
          onTap: () {
            // Handle account deletion
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
