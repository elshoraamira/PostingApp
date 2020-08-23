import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';
import 'package:like_button/like_button.dart';
import 'newPostPopUp.dart';
import 'comments.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Posts',
            textAlign: TextAlign.center,
          ),
          //leading: Container(),
        ),
        body: ListPage(),
        floatingActionButton: FloatingActionButton.extended(
          tooltip: 'New post',
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Container(
                      color: Colors.blue,
                      child: Text(
                        'New post',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    titleTextStyle: TextStyle(
                      //backgroundColor: Colors.cyan,
                      fontSize: 25.0,
                    ),
                    content: newPostDialogue(context),
                  );
                });
          },
          icon: Icon(Icons.add),
          label: Text("New Post"),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  Stream postsStream = FirebaseFirestore.instance
      .collection('Posts')
      .orderBy('timestamp', descending: true)
      .snapshots();

  // Future getPosts() async {
  //   QuerySnapshot qn = await FirebaseFirestore.instance
  //       .collection('Posts')
  //       .orderBy('timestamp', descending: true)
  //       .get();

  //   return qn.docs;
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: StreamBuilder<QuerySnapshot>(
      stream: postsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }
        return new ListView(
          children: snapshot.data.docs.map((DocumentSnapshot document) {
            return new Column(
              children: <Widget>[
                Card(
                  elevation: 5,
                  child: Container(
                    height: 150,
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: 100.0,
                          width: 50.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(5),
                                topLeft: Radius.circular(5),
                              ),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                      "https://cdn2.iconfinder.com/data/icons/person-gender-hairstyle-clothes-variations/48/Female-Side-comb-O-neck-512.png"))),
                        ),
                        SingleChildScrollView(
                          child: Container(
                            height: 100,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 2, 0, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Amira ElShora',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 3, 0, 2),
                                    child: Container(
                                      width: 260,
                                      child: Text(
                                        '${document.data()['postContent']}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    LikeButton(
                      padding: EdgeInsets.fromLTRB(100, 0, 0, 0),
                      size: 30.0,
                      animationDuration: Duration(milliseconds: 0),
                      likeBuilder: (bool isLiked) {
                        return Icon(
                          Icons.thumb_up,
                          color: isLiked ? Colors.blue : Colors.grey,
                          size: 30.0,
                        );
                      },
                      likeCount: document.data()['likesCount'],
                    ),
                    new GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    // ignore: deprecated_member_use
                                    CommentsPage(docID: document.documentID)));
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(135, 0, 0, 0),
                        child: Row(
                          children: <Widget>[
                            new Icon(
                              Icons.chat_bubble_outline,
                              size: 30,
                              color: Colors.grey,
                            ),
                            // 0 == 0
                            //     ? new Text(
                            //         '0',
                            //         style: TextStyle(color: Colors.grey),
                            //       )
                            //     : Text(
                            //         '1',
                            //         style: TextStyle(color: Colors.grey),
                            //       ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            );
          }).toList(),
        );
      },
    ));
  }
}
