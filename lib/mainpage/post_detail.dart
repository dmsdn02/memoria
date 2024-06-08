import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PostDetailPage extends StatelessWidget {
  final DocumentSnapshot post;

  PostDetailPage({required this.post});

  @override
  Widget build(BuildContext context) {
    var imageUrls = post['imageUrls'] != null ? List<String>.from(post['imageUrls']) : []; // 이미지 URL 목록
    var username = post['username'] ?? 'Unknown User'; // 유저명
    var timestamp = post['timestamp'] != null ? DateFormat('HH:mm').format(post['timestamp'].toDate()) : 'Unknown Time'; // 작성 시간
    var title = post['title'] ?? 'No Title'; // 제목
    String content = post['content'];

    return Scaffold(
      appBar: AppBar(
        title: Text('게시물 상세'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      if (FirebaseAuth.instance.currentUser != null &&
                          FirebaseAuth.instance.currentUser!.uid == post['userId'])
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              // 수정 기능 구현
                            } else if (value == 'delete') {
                              await FirebaseFirestore.instance.collection('posts').doc(post.id).delete();
                              Navigator.pop(context, 'deleted');
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('수정'),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('삭제'),
                              ),
                            ];
                          },
                        ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  Text(
                    content,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CommentSection(postId: post.id),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentSection extends StatefulWidget {
  final String postId;

  CommentSection({required this.postId});

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  User? _currentUser;
  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        setState(() {
          _currentUsername = userDoc.data()!['name'];
        });
      }
    }
  }

  void _submitComment() {
    if (_commentController.text.isNotEmpty && _currentUser != null && _currentUsername != null) {
      FirebaseFirestore.instance.collection('comments').add({
        'postId': widget.postId,
        'comment': _commentController.text,
        'username': _currentUsername,
        'timestamp': Timestamp.now(),
      });
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _commentController,
          decoration: InputDecoration(
            labelText: '댓글 작성',
            suffixIcon: IconButton(
              icon: Icon(Icons.send),
              onPressed: _submitComment,
            ),
          ),
        ),
        SizedBox(height: 8.0),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('comments')
              .where('postId', isEqualTo: widget.postId)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            var comments = snapshot.data!.docs;
            if (comments.isEmpty) {
              return Text('댓글이 없습니다.');
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                var comment = comments[index];
                return ListTile(
                  title: Text(comment['comment']),
                  subtitle: Text('${comment['username']} - ${DateFormat('yyyy-MM-dd HH:mm').format(comment['timestamp'].toDate())}'),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
