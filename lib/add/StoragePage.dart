import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../mainpage/post_detail.dart';
import 'groupProvider.dart';
import 'package:memoria/mainpage/post_detail.dart'; // PostDetailPage를 사용한다고 가정합니다.

class StoragePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GroupProvider groupProvider = Provider.of<GroupProvider>(context);
    String selectedGroupId = groupProvider.selectedGroupId;

    return Scaffold(
      appBar: AppBar(
        title: Text('좋아요 게시물'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              '선택된 그룹: ${groupProvider.selectedGroupName}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('likes')
            .where('groupId', isEqualTo: selectedGroupId)
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('좋아요 누른 게시물이 없습니다.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var likeDoc = snapshot.data!.docs[index];
              var postId = likeDoc['postId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('posts').doc(postId).get(),
                builder: (context, postSnapshot) {
                  if (!postSnapshot.hasData) {
                    return ListTile(title: Text('Loading...'));
                  }

                  var post = postSnapshot.data!;
                  var title = post['title'] ?? 'No Title';
                  var content = post['content'] ?? 'No Content';
                  var timestamp = post['timestamp'] != null ? DateFormat('yyyy-MM-dd HH:mm').format(post['timestamp'].toDate()) : 'Unknown Time';

                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          timestamp,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    subtitle: Text(content),
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
              );
            },
          );
        },
      ),
    );
  }
}
