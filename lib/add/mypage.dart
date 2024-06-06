import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../friends/create_group.dart';
import '../friends/f_list.dart';
import '../mainpage/calendar.dart';
import '../add/myrecord.dart'; // 수정된 부분

import 'groupProvider.dart';
import 'setting.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userName = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _getUserName();
  }

  Future<void> _getUserName() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(user.uid).get();
        setState(() {
          userName = userSnapshot['name'];
          userEmail = userSnapshot['email'];
        });
      }
    } catch (e) {
      print('Failed to get user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingPage()),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: () {
                        // 프로필 수정 기능
                      },
                      child: Text(
                        "프로필 수정",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.book),
                            onPressed: () {
                              // 나의 기록 기능
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MyRecordPage()),
                              );
                            },
                          ),
                          Text("나의 기록"),
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.people),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => FriendListPage()),
                              );
                            },
                          ),
                          Text("친구 목록"),
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.archive),
                            onPressed: () {
                              // 보관함 기능
                            },
                          ),
                          Text("보관함"),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "나의 그룹",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 0.0),
              child: SingleChildScrollView(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('groups').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final groupDocs = snapshot.data!.docs;

                    return Wrap(
                      spacing: 1.0,
                      children: groupDocs.map((groupDoc) {
                        final groupCreatorEmail = groupDoc['groupCreator']['email'];
                        final groupName = groupDoc['groupName'];
                        final imageUrls = groupDoc['imageUrls'] != null ? List<String>.from(groupDoc['imageUrls']) : [];

                        if (groupCreatorEmail == userEmail) {
                          return Container(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 24.0,
                              child: Card(
                                color: Colors.blue[50],
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      if (imageUrls.isNotEmpty)
                                        SizedBox(
                                          height: 110,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: imageUrls.length,
                                            itemBuilder: (context, imgIndex) {
                                              return Padding(
                                                padding: const EdgeInsets.all(9.0),
                                                child: Image.network(
                                                  imageUrls[imgIndex],
                                                  height: 130,
                                                  width: 130,
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null) {
                                                      return child;
                                                    }
                                                    return Center(
                                                      child: CircularProgressIndicator(
                                                        value: loadingProgress.expectedTotalBytes != null
                                                            ? loadingProgress.cumulativeBytesLoaded /
                                                            loadingProgress.expectedTotalBytes!
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
                                      GestureDetector(
                                        onTap: () {
                                          context.read<GroupProvider>().selectGroup(groupDoc.id, groupName);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CalendarPage(groupId: groupDoc.id, groupName: groupName),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 0.0),
                                          child: Text(
                                            groupName,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return SizedBox();
                        }
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.add, color: Colors.black),
                  SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateGroupPage()),
                      );
                    },
                    child: Text(
                      "그룹 생성하기",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String selectedGroupName = context.read<GroupProvider>().selectedGroupName;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CalendarPage(groupName: selectedGroupName, groupId: '',),
            ),
          );
        },
        child: Icon(Icons.home),
        backgroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.question_answer),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuestionAnswerPage()),
                );
              },
            ),
            SizedBox(width: 40),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionAnswerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Question & Answer"),
      ),
      body: Center(
        child: Text("This is the Question & Answer page."),
      ),
    );
  }
}
