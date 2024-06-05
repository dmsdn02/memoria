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

      var friendsDoc = await _firestore.collection('friends').doc(currentUserId).get();
      if (friendsDoc.exists) {
        var friendsData = friendsDoc.data();
        if (friendsData != null && friendsData['friends'] != null) {
          List<dynamic> friendsList = friendsData['friends'];
          bool alreadyFriend = friendsList.any((friend) => friend['email'] == friendEmail);
          if (alreadyFriend) {
            setState(() {
              _emailErrorText = '이미 추가된 친구입니다.';
            });
            return;
          }
        }
      }

      DocumentReference friendsDocRef = _firestore.collection('friends').doc(currentUserId);
      await friendsDocRef.update({
        'friends': FieldValue.arrayUnion([{'email': friendEmail, 'name': friendName}]),
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
