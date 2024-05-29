import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class FriendListDialog extends StatefulWidget {
  final List<Map<String, dynamic>> friends;
  final Set<Map<String, dynamic>> selectedFriends;

  FriendListDialog({required this.friends, required this.selectedFriends});

  @override
  _FriendListDialogState createState() => _FriendListDialogState();
}

class _FriendListDialogState extends State<FriendListDialog> {
  Set<Map<String, dynamic>> _selectedFriends = {};

  @override
  void initState() {
    super.initState();
    _selectedFriends = Set.from(widget.selectedFriends);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('친구 추가'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.friends.map((friend) {
            return CheckboxListTile(
              title: Text(friend['name']),
              value: _selectedFriends.contains(friend),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedFriends.add(friend);
                  } else {
                    _selectedFriends.remove(friend);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          child: Text('취소'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('추가'),
          onPressed: () {
            Navigator.of(context).pop(_selectedFriends);
          },
        ),
      ],
    );
  }
}




class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _currentUser;
  List<Map<String, dynamic>> _friends = [];
  Set<Map<String, dynamic>> _selectedFriends = {};

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
      print('친구 목록을 불러오는 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('그룹 생성'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                '그룹 이름',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              maxLength: 6,
              inputFormatters: [LengthLimitingTextInputFormatter(6)],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '그룹원 추가',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    final selectedFriends = await showDialog<Set<Map<String, dynamic>>>(
                      context: context,
                      builder: (BuildContext context) {
                        return FriendListDialog(
                          friends: _friends,
                          selectedFriends: _selectedFriends,
                        );
                      },
                    );
                    if (selectedFriends != null) {
                      setState(() {
                        _selectedFriends = selectedFriends;
                      });
                    }
                  },
                  child: Container(
                    width: 100,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(0, 0.5),
                        ),
                      ],
                    ),
                    child: Icon(Icons.add_circle_outline_rounded),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: _selectedFriends.map((friend) {
                  return ListTile(
                    title: Text(friend['name']),
                    subtitle: Text(friend['email']),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              '대표사진',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Stack(
              alignment: Alignment.topLeft,
              children: [
                Container(
                  width: 500,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 0.1),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.photo,
                    size: 80,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () {
                      // 대표사진 변경 로직 추가
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),


            ElevatedButton(
              onPressed: () {
                // 그룹 생성 버튼 클릭 시 동작
              },
              child: Text(
                '그룹생성',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFFC5D3)),
                minimumSize: MaterialStateProperty.all(Size(200, 50)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
