import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'post_detail.dart';

class PostsByDatePage extends StatelessWidget {
  final DateTime selectedDate;
  final String groupId; // 그룹 ID 추가
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PostsByDatePage({required this.selectedDate, required this.groupId}); // 그룹 ID를 받는 생성자

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('$formattedDate 게시물'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection('posts')
            .where('date', isEqualTo: formattedDate)
            .where('groupId', isEqualTo: groupId) // 해당 그룹의 게시물만 필터링
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('해당 날짜에 게시물이 없습니다.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var post = snapshot.data!.docs[index];
              var imageUrls = post['imageUrls'] != null ? List<String>.from(post['imageUrls']) : []; // 이미지 URL 목록
              var username = post['username'] ?? 'Unknown User'; // 유저명
              var timestamp = post['timestamp'] != null ? DateFormat('HH:mm').format(post['timestamp'].toDate()) : 'Unknown Time'; // 작성 시간

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                username,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                timestamp,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            post['title'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8.0),
                          if (imageUrls.isNotEmpty)
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: imageUrls.length,
                                itemBuilder: (context, imgIndex) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.network(
                                      imageUrls[imgIndex],
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Text('이미지를 불러올 수 없습니다.');
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          SizedBox(height: 8.0),
                          Text(post['content']),
                          SizedBox(height: 8.0),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
