import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'groupProvider.dart';
import 'package:intl/intl.dart';
import '../mainpage/post_detail.dart'; // 이동할 페이지에 대한 import 추가

class MyRecordPage extends StatefulWidget {
  @override
  _MyRecordPageState createState() => _MyRecordPageState();
}

class _MyRecordPageState extends State<MyRecordPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // GroupProvider 인스턴스 가져오기
    GroupProvider groupProvider = Provider.of<GroupProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('나의 기록'),
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
        stream: _firestore
            .collection('posts')
            .where('groupId', isEqualTo: groupProvider.selectedGroupId) // 선택된 그룹의 ID로 필터링
            .where('userId', isEqualTo: _auth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('게시물이 없습니다.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var post = snapshot.data!.docs[index];
              // 게시물을 표시하는 방식에 따라 UI 작성
              return Column(
                children: [
                  ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['title'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('yyyy-MM-dd').format(post['timestamp'].toDate()), // 작성 날짜 추가
                          style: TextStyle(fontSize: 12, color: Colors.grey), // 작성 날짜 스타일
                        ),
                      ],
                    ),
                    subtitle: Text(post['content']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailPage(post: post),
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.more_vert), // 점 세 개 아이콘
                      onPressed: () {
                        _showMenu(context, post);
                      },
                    ),
                  ),
                  Divider(), // 게시물 간의 구분선 추가
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showMenu(BuildContext context, DocumentSnapshot post) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('수정'),
                onTap: () {
                  Navigator.pop(context);
                  _editPost(context, post);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('삭제'),
                onTap: () {
                  Navigator.pop(context);
                  _deletePost(context, post.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editPost(BuildContext context, DocumentSnapshot post) {
    // 수정 기능 구현
  }

  void _deletePost(BuildContext context, String postId) {
    // 삭제 기능 구현
  }
}
