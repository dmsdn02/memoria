import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'FriendListDialog.dart';

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
      final userDoc = await _firestore.collection('friends').doc(_currentUser!.uid).get();
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

        await _firestore.collection('friends').doc(_currentUser!.uid).update({
          'friends': FieldValue.arrayUnion([{'name': friendData['name'], 'email': friendEmail}]),
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

      await _firestore.collection('friends').doc(_currentUser!.uid).update({
        'friends': FieldValue.arrayRemove([{'email': email}]),
      });
    } catch (e) {
      print('Error removing friend: $e');
    }
  }

  Future<void> _copyEmailToClipboard(String email) async {
    await Clipboard.setData(ClipboardData(text: email));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('이메일이 복사되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('친구 목록'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '나의 이메일: ${_currentUser?.email ?? ''}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy),
                          onPressed: () {
                            if (_currentUser != null) {
                              _copyEmailToClipboard(_currentUser!.email!);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.userGroup, color: Colors.black, size: 20.0),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.black, size: 25.0),
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
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: _friends.isNotEmpty
                  ? ListView.builder(
                itemCount: _friends.length,
                itemBuilder: (context, index) {
                  final friend = _friends[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        title: Text(friend['name']),
                        subtitle: Text(friend['email']),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            await _removeFriend(friend['email']);
                          },
                        ),
                      ),
                    ),
                  );
                },
              )
                  : Center(
                child: Text('친구 목록이 비었습니다.'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
