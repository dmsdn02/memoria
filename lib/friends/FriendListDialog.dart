import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendListDialog extends StatefulWidget {
  @override
  _FriendListDialogState createState() => _FriendListDialogState();
}

class _FriendListDialogState extends State<FriendListDialog> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _addFriend(BuildContext context) async {
    String friendEmail = _emailController.text.trim();
    if (friendEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이메일을 입력하세요.')),
      );
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(friendEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('유효한 이메일 주소를 입력하세요.')),
      );
      return;
    }

    try {
      // 현재 사용자 가져오기
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사용자가 로그인되어 있지 않습니다.')),
        );
        return;
      }

      // 현재 사용자의 UID 가져오기
      String currentUserId = currentUser.uid;
      print('Current User ID: $currentUserId');

      // 친구의 이메일로 사용자 찾기
      var userQuery = await _firestore.collection('users').where('email', isEqualTo: friendEmail).get();
      if (userQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('해당 이메일로 등록된 사용자를 찾을 수 없습니다.')),
        );
        return;
      }

      // 친구가 존재하는 경우
      DocumentSnapshot friendSnapshot = userQuery.docs.first;
      String friendUserId = friendSnapshot.id;
      String friendName = friendSnapshot['name'];
      print('Friend User ID: $friendUserId');

      // friends 컬렉션에 현재 사용자의 친구 목록 문서 생성/업데이트
      await _firestore.collection('friends').doc(currentUserId).set({
        'friends': FieldValue.arrayUnion([
          {'uid': friendUserId, 'email': friendEmail, 'name': friendName}
        ]),
      }, SetOptions(merge: true));

      Navigator.of(context).pop(friendEmail);
    } catch (e) {
      print('Error adding friend: $e');
      if (e is FirebaseException) {
        print('Firebase Error Code: ${e.code}');
        print('Firebase Error Message: ${e.message}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('친구 추가 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('친구 추가'),
      content: TextField(
        controller: _emailController,
        decoration: InputDecoration(hintText: '친구의 이메일을 입력하세요'),
        keyboardType: TextInputType.emailAddress,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('취소'),
        ),
        ElevatedButton(
          onPressed: () => _addFriend(context),
          child: Text('추가'),
        ),
      ],
    );
  }
}
