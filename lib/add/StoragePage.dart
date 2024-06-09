import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../mainpage/post_detail.dart';
import 'groupProvider.dart';

class StoragePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GroupProvider groupProvider = Provider.of<GroupProvider>(context);
    String selectedGroupId = groupProvider.selectedGroupId;

    return Scaffold(
      appBar: AppBar(
        title: Text('좋아요 게시물'),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60), // 간격 더 띄우기
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '선택된 그룹: ${groupProvider.selectedGroupName}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8), // 간격 추가
                Divider(), // 그룹과 게시물 간의 구분선 추가
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('likes')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('좋아요한 게시물이 없습니다.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var likeDoc = snapshot.data!.docs[index];
              var postId = likeDoc['postId'];
              var groupId = likeDoc['groupId'];

              // 선택된 그룹의 게시물만 표시
              if (groupId == selectedGroupId) {
                return Column(
                  children: [
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('posts').doc(postId).get(),
                      builder: (context, postSnapshot) {
                        if (!postSnapshot.hasData) {
                          return ListTile(title: Text('게시물이 삭제되었습니다.'));
                        }

                        var post = postSnapshot.data!;
                        var title = post['title'] ?? 'No Title';
                        var content = post['content'] ?? 'No Content';
                        var timestamp = post['timestamp'] != null ? (post['timestamp'] as Timestamp).toDate() : DateTime.now();
                        var username = post['username'] ?? 'Unknown User'; // 작성자 이름 추가

                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8), // 간격 추가
                              Row(
                                children: [
                                  Text(
                                    '작성자: $username', // 작성자 이름 표시
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  SizedBox(width: 25), // 간격 추가
                                  Text(
                                    DateFormat('yyyy-MM-dd HH:mm').format(timestamp),
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8), // 간격 추가
                              Text(
                                content,
                                style: TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.favorite, color: Colors.red), // 하트 색상 변경
                            onPressed: () async {
                              _showDeleteConfirmationDialog(context, postId); // 삭제 확인 대화상자 표시
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetailPage(post: post),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    Divider(), // 게시물 간의 구분선 추가
                    SizedBox(height: 16), // 게시물과 게시물 간의 간격 조정
                  ],
                );
              } else {
                return SizedBox(); // 선택된 그룹과 일치하지 않는 경우 공백 위젯 반환
              }
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('보관함에서 삭제'),
          content: Text('이 게시물을 보관함에서 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                await _toggleLike(postId); // 좋아요 토글 메소드 호출
                Navigator.pop(context);
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleLike(String postId) async {
    var likeDocSnapshot = await FirebaseFirestore.instance
        .collection('likes')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('postId', isEqualTo: postId)
        .limit(1)
        .get();

    if (likeDocSnapshot.docs.isNotEmpty) {
      // 좋아요한 경우 좋아요 취소
      await likeDocSnapshot.docs.first.reference.delete();

      // Firebase에서도 좋아요 삭제
      await FirebaseFirestore.instance.collection('likes').doc(likeDocSnapshot.docs.first.id).delete();
    }
  }
}
