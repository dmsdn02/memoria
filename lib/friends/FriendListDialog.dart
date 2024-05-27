import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendListDialog extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('친구 추가'),
      content: TextField(
        controller: _emailController,
        decoration: InputDecoration(hintText: '친구의 이메일을 입력하세요'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('취소'),
        ),
        ElevatedButton(
          onPressed: () async {
            String friendEmail = _emailController.text.trim();
            if (friendEmail.isNotEmpty) {
              var userQuery = await _firestore.collection('users').where('email', isEqualTo: friendEmail).get();
              if (userQuery.docs.isNotEmpty) {
                Navigator.of(context).pop(friendEmail);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('해당 이메일로 등록된 사용자를 찾을 수 없습니다.')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('이메일을 입력하세요.')),
              );
            }
          },
          child: Text('추가'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    // super.dispose(); // 이 줄을 제거합니다.
  }
}
