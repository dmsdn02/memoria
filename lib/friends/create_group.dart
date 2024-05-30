import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

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

  File? _selectedImage;
  TextEditingController _groupNameController = TextEditingController();

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
              controller: _groupNameController,
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
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!)
                      : InkWell(
                    onTap: () {
                      _selectImage(context); // 사진 선택 함수 호출
                    },
                    child: Icon(
                      Icons.add_a_photo,
                      size: 80,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                _createGroup(); // 그룹 생성 함수 호출
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
                minimumSize: MaterialStateProperty.all<Size>(Size(200, 50)),
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

  // 사진 선택 함수
  void _selectImage(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        String? filePath = result.files.single.path;
        if (filePath != null) {
          setState(() {
            // _selectedImage = FileImage(File(filePath));
          });
        }
      }
    } catch (e) {
      print('이미지 선택 중 오류 발생: $e');
    }
  }

  // 그룹 생성 함수
  void _createGroup() async {
    try {
      if (_groupNameController.text.isNotEmpty && _selectedFriends.isNotEmpty) {
        // 그룹 생성 시 그룹 이름과 선택된 그룹원을 파이어스토어에 추가
        final newGroupRef = await _firestore.collection('groups').add({
          'groupName': _groupNameController.text,
          'groupMembers': _selectedFriends.toList(),
        });
        // 그룹 생성 완료 메시지 출력
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('그룹이 생성되었습니다.'),
        ));
        // 그룹 생성 후 필드 초기화
        _groupNameController.clear();
        setState(() {
          _selectedFriends.clear();
        });
      } else {
        // 그룹 이름이나 그룹원이 선택되지 않았을 때 에러 메시지 출력
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('그룹 이름과 그룹원을 선택해주세요.'),
        ));
      }

    } catch (e) {
      // 그룹 생성 중 오류 발생 시 에러 메시지 출력
      print('그룹 생성 중 오류 발생: $e');
    }
  }
}

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