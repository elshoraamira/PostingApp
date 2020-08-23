import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'main.dart';

class CommentsPage extends StatefulWidget {
  final String docID;
  CommentsPage({Key key, this.docID}) : super(key: key);
  @override
  createState() => CommentsPageState(documID: docID);
}

class CommentsPageState extends State<CommentsPage> {
  final String documID; //el document elle etdas 3al comment button bta3ha
  CommentsPageState({Key key, this.documID});
  TextEditingController commentController = new TextEditingController();

  CollectionReference commentsRef =
      FirebaseFirestore.instance.collection('Comments');
  String commentValue = '';
  Future<void> submitComment() {
    return commentsRef
        .add({
          'timestamp': DateTime.now(),
          'commentContent': commentValue,
          'postID': documID,
        })
        .then((value) => print("Comment Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Stream commentsStream = FirebaseFirestore.instance
      .collection('Comments')
      .orderBy('timestamp', descending: true)
      .snapshots();

  Widget buildCommentsList() {
    return Container(
        child: StreamBuilder<QuerySnapshot>(
      stream: commentsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }
        return new ListView(
          children: snapshot.data.docs.map((DocumentSnapshot document) {
            if (document.data()['postID'] == documID) {
              return buildCommentItem(document.data()['commentContent']);
            } else {
              return Container();
            }
          }).toList(),
        );
      },
    ));
  }

  Widget buildCommentItem(String comment) {
    return ListTile(
      title: Text(comment),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comments"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: buildCommentsList()),
          TextField(
            controller: commentController,
            onSubmitted: (String submittedComment) {
              commentValue = submittedComment;
              submitComment();
              commentController.clear();
            },
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(20.0),
                hintText: "Your comment goes here"),
          )
        ],
      ),
    );
  }
}
