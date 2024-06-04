import 'package:flutter/material.dart';
import '../friends/create_group.dart';
import '../friends/f_list.dart';
import '../mainpage/calendar.dart';
import 'setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userName = '';

  @override
  void initState() {
    super.initState();
    _getUserName();
  }

  Future<void> _getUserName() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(user.uid).get();
        setState(() {
          userName = userSnapshot['name'];
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
    body: Column(
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
    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Text(
    "나의 그룹",
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    ),
    Container(
    margin: EdgeInsets.symmetric(horizontal: 16.0),
    child: Column(
    children: [
    Container(
    padding: EdgeInsets.all(16.0),
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
    MaterialPageRoute(builder: (context) => CreateGroupPage()),
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
    Container(
    padding: EdgeInsets.all(16.0),

    child: StreamBuilder<QuerySnapshot>(
    stream: _firestore.collection('groups').snapshots(),
    builder: (context, snapshot) {
    if (!snapshot.hasData) {
    return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
    shrinkWrap: true, // 추가: ListView의 높이를 제한
    itemCount: snapshot.data!.docs.length,
    itemBuilder: (context, index) {
    var post = snapshot.data!.docs[index];
    var imageUrls = post['imageUrls'] != null
    ? List<String>.from(post['imageUrls'])
        : []; // 이미지 URL 목록

    return Card(
    margin: EdgeInsets.all(10.0),
    child: ListTile(
    title: Text(post['groupName']),
    subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    if (imageUrls.isNotEmpty)
    SizedBox(
    height: 50, // 기본 이미지 높이
    child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: imageUrls.length,
    itemBuilder: (context, imgIndex) {
    return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Image.network(
    imageUrls[imgIndex],
    height: 50, // 기본 이미지 높이
    width: 50, // 기본 이미지 너비
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
    ],
    ),
    ),
    );
    },
    );
    },
    ),
    ),
    ],
    ),
    ),
    ],
    ),
    floatingActionButton: FloatingActionButton(
    onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => CalendarPage()),
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
            SizedBox(width: 40), // 플러스 아이콘 공간
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                // MyPage로 이동 (현재 페이지)
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
