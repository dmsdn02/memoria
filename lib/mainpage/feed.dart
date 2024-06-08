import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'post_detail.dart';

class PostsByDatePage extends StatefulWidget {
  final DateTime initialDate;
  final String groupId;

  PostsByDatePage({required this.initialDate, required this.groupId});

  @override
  _PostsByDatePageState createState() => _PostsByDatePageState();
}

class _PostsByDatePageState extends State<PostsByDatePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late PageController _pageController;
  Map<String, List<DocumentSnapshot>> _postsByDate = {};
  bool _isLoading = false;
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate;
    _pageController = PageController(
      initialPage: _calculateInitialPage(), // Set initial page based on the difference in days
      viewportFraction: 1.0,
    );
    _loadPosts(_currentDate);
  }

  int _calculateInitialPage() {
    return DateTime.now().difference(widget.initialDate).inDays + 1;
  }

  Future<void> _loadPosts(DateTime date) async {
    setState(() {
      _isLoading = true;
    });

    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    if (_postsByDate.containsKey(formattedDate)) {
      setState(() {
        _isLoading = false;
      });
      return; // Do not reload if the date has already been loaded
    }

    QuerySnapshot snapshot = await _firestore
        .collection('posts')
        .where('date', isEqualTo: formattedDate)
        .where('groupId', isEqualTo: widget.groupId)
        .get();

    setState(() {
      _postsByDate[formattedDate] = snapshot.docs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${DateFormat('yyyy-MM-dd').format(_currentDate)} 게시물'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        reverse: true, // Allow swiping left to move to previous dates
        onPageChanged: (index) {
          // Calculate the new date based on the current date and the index
          DateTime newDate = widget.initialDate.add(Duration(days: _pageController.initialPage - index));
          setState(() {
            _currentDate = newDate;
          });
          _loadPosts(newDate);
        },
        itemBuilder: (context, pageIndex) {
          // Calculate the current date based on the initial date and the page index
          DateTime currentDate = widget.initialDate.add(Duration(days: _pageController.initialPage - pageIndex));
          String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
          List<DocumentSnapshot> posts = _postsByDate[formattedDate] ?? [];

          if (_isLoading && posts.isEmpty) {
            return Center(child: CircularProgressIndicator());
          } else if (posts.isEmpty) {
            return Center(child: Text('게시물이 없습니다.'));
          } else {
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, postIndex) {
                var post = posts[postIndex];
                var imageUrls = post['imageUrls'] != null ? List<String>.from(post['imageUrls']) : [];
                var username = post['username'] ?? 'Unknown User';
                var timestamp = post['timestamp'] != null ? DateFormat('HH:mm').format(post['timestamp'].toDate()) : 'Unknown Time';

                return GestureDetector(
                  onTap: () async {
                    var result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
                    );
                    if (result == 'deleted') {
                      setState(() {
                        _postsByDate[formattedDate]?.remove(post);
                      });
                    }
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
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
