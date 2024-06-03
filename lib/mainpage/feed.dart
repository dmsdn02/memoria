import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PostsByDatePage extends StatelessWidget {
  final DateTime selectedDate;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PostsByDatePage({required this.selectedDate});

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

              return Card(
                margin: EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text(post['title']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Text(post['date']),
                      SizedBox(height: 8.0),
                      Text(post['content']),
                    ],
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
