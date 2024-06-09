import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'FriendListDialog.dart';
import 'FriendRequestDialog.dart';

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
    if (_currentUser == null) {
      return; // 사용자가 로그인되어 있지 않으면 아무 작업도 수행하지 않음
    }
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
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return; // 사용자가 로그인되어 있지 않으면 에러 메시지를 표시하고 함수 종료
    }
    try {
      final friendQuery = await _firestore.collection('users').where('email', isEqualTo: friendEmail).get();
      if (friendQuery.docs.isNotEmpty) {
        final friendDoc = friendQuery.docs.first;
        final friendData = friendDoc.data();

        final friendInfo = {'name': friendData['name'], 'email': friendEmail};

        // 상대방에게 받은 요청 추가
        await _firestore.collection('friendRequests').doc(friendEmail).collection('received').add({
          'name': _currentUser!.displayName,
          'email': _currentUser!.email,
        });

        // 나에게 보낸 요청 추가
        await _firestore.collection('friendRequests').doc(_currentUser!.email).collection('sent').add({
          'name': friendData['name'],
          'email': friendEmail,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('친구 요청을 보냈습니다.')),
        );
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
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('친구 삭제'),
          content: Text('선택한 친구를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // 취소 버튼
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // 확인 버튼
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        // 친구 목록에서 해당 친구의 정보를 가져옴
        final friend = _friends.firstWhere((friend) => friend['email'] == email);

        setState(() {
          _friends.removeWhere((friend) => friend['email'] == email);
        });

        await _firestore.collection('friends').doc(_currentUser!.uid).update({
          'friends': FieldValue.arrayRemove([friend]), // friend 객체를 전달하여 삭제
        });
      } catch (e) {
        print('Error removing friend: $e');
      }
    }
  }

  Future<void> _copyEmailToClipboard(String email) async {
    await Clipboard.setData(ClipboardData(text: email));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('이메일이 복사되었습니다.')),
    );
  }

  Future<void> _editFriendName(String friendEmail) async {
    String? newFriendName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String currentName = _friends.firstWhere((friend) => friend['email'] == friendEmail)['name'];
        TextEditingController _nameController = TextEditingController(text: currentName);
        return AlertDialog(
          title: Text('친구 이름 변경'),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: '새로운 이름'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 취소 버튼
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, _nameController.text); // 확인 버튼
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );

    if (newFriendName != null && newFriendName.isNotEmpty) {
      await _updateFriendName(friendEmail, newFriendName);
    }
  }

  Future<void> _updateFriendName(String friendEmail, String newFriendName) async {
    try {
      setState(() {
        _friends.firstWhere((friend) => friend['email'] == friendEmail)['name'] = newFriendName;
      });

      await _firestore.collection('friends').doc(_currentUser!.uid).update({
        'friends': _friends,
      });
    } catch (e) {
      print('Error updating friend name: $e');
    }
  }

  void _showRequestDialog(String requestType) {
    showDialog(
      context: context,
      builder: (context) => FriendRequestDialog(
        requestType: requestType,
        onRequestProcessed: _loadFriends, // 친구 목록 업데이트 함수 전달
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('친구 목록'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), // 테두리 색상 및 두께 설정
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFADD8E6), // 버튼 배경색 변경
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // 버튼 모서리를 둥글게 만듭니다.
                        ),
                      ),
                      onPressed: () => _showRequestDialog('sent'),
                      child: Text(
                        '보낸 요청',
                        style: TextStyle(color: Colors.black), // 글씨 색상 변경
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0), // 버튼 사이에 여유 공간 추가
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), // 테두리 색상 및 두께 설정
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFC5D3), // 버튼 배경색 변경
                        padding: EdgeInsets.symmetric(vertical: 15), // 높이 설정
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // 버튼 모서리를 둥글게 만듭니다.
                        ),
                      ),
                      onPressed: () => _showRequestDialog('received'),
                      child: Text(
                        '받은 요청',
                        style: TextStyle(color: Colors.black), // 글씨 색상 변경
                      ),
                    ),
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
                        title: Row(
                          children: [
                            Text(friend['name']),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () async {
                                await _editFriendName(friend['email']);
                              },
                            ),
                          ],
                        ),
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
