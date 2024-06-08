import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendRequestDialog extends StatelessWidget {
  final String requestType;
  final Function() onRequestProcessed;

  FriendRequestDialog({required this.requestType, required this.onRequestProcessed});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> _loadRequests() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final querySnapshot = await _firestore
          .collection('friend_requests')
          .where(requestType == 'sent' ? 'senderId' : 'receiverId', isEqualTo: currentUser.uid)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = {
          'id': doc.id,
          'status': doc['status'],
          'email': requestType == 'sent' ? doc['receiverEmail'] : doc['senderEmail'],
          'senderEmail': doc['senderEmail'],
        };
        return data;
      }).toList();
    }
    return [];
  }

  Future<void> _acceptRequest(BuildContext context, String requestId, String userEmail) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        final currentUserId = currentUser.uid;

        // 요청 상태 업데이트
        await _firestore.collection('friend_requests').doc(requestId).update({
          'status': 'accepted',
        });

        // 현재 사용자 정보 가져오기
        var currentUserDoc = await _firestore.collection('users').doc(currentUserId).get();
        var currentUserData = currentUserDoc.data();
        var currentUserName = currentUserData?['name'] ?? 'No Name';

        // 상대방 정보 가져오기
        var friendQuerySnapshot = await _firestore.collection('users').where('email', isEqualTo: userEmail).get();
        if (friendQuerySnapshot.docs.isNotEmpty) {
          var friendDoc = friendQuerySnapshot.docs.first;
          var friendUserId = friendDoc.id;
          var friendData = friendDoc.data();
          var friendName = friendData?['name'] ?? 'No Name';

          // 친구로 추가
          await _firestore.collection('friends').doc(friendUserId).set({
            'friends': FieldValue.arrayUnion([
              {'email': currentUser.email, 'name': currentUserName},
            ]),
          }, SetOptions(merge: true));

          await _firestore.collection('friends').doc(currentUserId).set({
            'friends': FieldValue.arrayUnion([
              {'email': userEmail, 'name': friendName},
            ]),
          }, SetOptions(merge: true));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('친구 요청을 수락했습니다.')),
          );
          // 친구 요청을 수락하면 친구 목록을 업데이트
          onRequestProcessed(); // 콜백 호출
        }
      } catch (e) {
        print('Error accepting friend request: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('친구 요청 수락 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  Future<void> _declineRequest(BuildContext context, String requestId) async {
    try {
      await _firestore.collection('friend_requests').doc(requestId).update({'status': 'declined'});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('친구 요청을 거절했습니다.')),
      );
    } catch (e) {
      print('Error declining friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('친구 요청 거절 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(requestType == 'sent' ? '보낸 요청' : '받은 요청'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadRequests(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('오류가 발생했습니다. ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('요청이 없습니다.'));
            } else {
              final requests = snapshot.data!;
              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return ListTile(
                    title: Text(
                      request['email'],
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('상태: ${request['status']}'),
                    trailing: requestType == 'received' && request['status'] == 'pending'
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () async {
                            await _acceptRequest(context, request['id'], request['email']);
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () async {
                            await _declineRequest(context, request['id']);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    )
                        : null,
                  );
                },
              );
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('닫기'),
        ),
      ],
    );
  }
}
