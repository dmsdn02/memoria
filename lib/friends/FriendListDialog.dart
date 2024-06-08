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
  String? _emailErrorText;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _addFriend(BuildContext context) async {
    String friendEmail = _emailController.text.trim();
    if (friendEmail.isEmpty) {
      setState(() {
        _emailErrorText = '이메일을 입력하세요.';
      });
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(friendEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('유효한 이메일 주소를 입력하세요.')),
      );
      return;
    }

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사용자가 로그인되어 있지 않습니다.')),
        );
        return;
      }

      String currentUserId = currentUser.uid;
      String currentUserName = '';

      // Firestore에서 현재 사용자의 이름 가져오기
      DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(currentUserId).get();
      if (userSnapshot.exists) {
        currentUserName = userSnapshot.get('name') ?? 'No Name';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('현재 사용자 정보를 찾을 수 없습니다.')),
        );
        return;
      }

      var userQuery = await _firestore.collection('users').where('email', isEqualTo: friendEmail).get();
      if (userQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('해당 이메일로 등록된 사용자를 찾을 수 없습니다.')),
        );
        return;
      }

      DocumentSnapshot friendSnapshot = userQuery.docs.first;
      String friendUserId = friendSnapshot.id;
      String friendName = friendSnapshot['name'];

      // 중복 여부 확인
      var duplicateQuery = await _firestore
          .collection('friend_requests')
          .where('senderEmail', isEqualTo: currentUser.email)
          .where('receiverEmail', isEqualTo: friendEmail)
          .get();

      if (duplicateQuery.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미 해당 이메일로 요청을 보냈습니다.')),
        );
        return;
      }

      // 친구 추가 요청을 보내기
      await _firestore.collection('friend_requests').add({
        'senderId': currentUserId,
        'senderName': currentUserName,
        'senderEmail': currentUser.email,
        'receiverId': friendUserId,
        'receiverEmail': friendEmail,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop(friendEmail);
    } catch (e) {
      print('Error adding friend: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('친구 추가 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('친구 추가'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: '친구의 이메일을 입력하세요',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          if (_emailErrorText != null)
            Text(
              _emailErrorText!,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            _addFriend(context);
          },
          child: Text('추가'),
        ),
      ],
    );
  }
}

