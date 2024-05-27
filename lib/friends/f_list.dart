import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendListPage extends StatefulWidget {
  @override
  _FriendListPageState createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _currentUser;
  List<Map<String, dynamic>> _friends = [];

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _loadFriends();
    }
  }

  Future<void> _loadFriends() async {
    try {
      final userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data.containsKey('friends')) {
          setState(() {
            _friends = List<Map<String, dynamic>>.from(data['friends']);
          });
        }
      }
    } catch (e) {
      print('Error loading friends: $e');
    }
  }

  Future<void> _addFriend(String friendEmail) async {
    try {
      final friendQuery = await _firestore.collection('users').where('email', isEqualTo: friendEmail).get();
      if (friendQuery.docs.isNotEmpty) {
        final friendDoc = friendQuery.docs.first;
        final friendData = friendDoc.data();

        setState(() {
          _friends.add({'name': friendData['name'], 'email': friendEmail});
        });

        await _firestore.collection('users').doc(_currentUser!.uid).update({
          'friends': _friends,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('해당 이메일로 등록된 사용자를 찾을 수 없습니다.')),
        );
      }
    } catch (e) {
      print('Error adding friend: $e');
    }
  }

  Future<void> _removeFriend(String email) async {
    try {
      setState(() {
        _friends.removeWhere((friend) => friend['email'] == email);
      });

      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'friends': _friends,
      });
    } catch (e) {
      print('Error removing friend: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('친구 목록'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final friendEmail = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return FriendListDialog();
                },
              );
              if (friendEmail != null && friendEmail.isNotEmpty) {
                await _addFriend(friendEmail);
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          return ListTile(
            title: Text(friend['name']),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await _removeFriend(friend['email']);
              },
            ),
          );
        },
      ),
    );
  }
}

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
  }
}
