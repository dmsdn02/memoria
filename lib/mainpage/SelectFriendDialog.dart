import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectFriendDialog extends StatefulWidget {
  @override
  _SelectFriendDialogState createState() => _SelectFriendDialogState();
}

class _SelectFriendDialogState extends State<SelectFriendDialog> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _friends = [];
  List<String> _selectedFriends = [];

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null && data.containsKey('friends')) {
            setState(() {
              _friends = List<Map<String, dynamic>>.from(data['friends']);
            });
          }
        }
      }
    } catch (e) {
      print('Error loading friends: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('친구 선택'),
      content: _friends.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Container(
        width: double.maxFinite,
        height: 400.0,
        child: ListView.builder(
          itemCount: _friends.length,
          itemBuilder: (context, index) {
            final friend = _friends[index];
            final isSelected = _selectedFriends.contains(friend['email']);
            return ListTile(
              title: Text(friend['name']),
              trailing: isSelected ? Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedFriends.remove(friend['email']);
                  } else {
                    _selectedFriends.add(friend['email']);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedFriends);
          },
          child: Text('확인'),
        ),
      ],
    );
  }
}
