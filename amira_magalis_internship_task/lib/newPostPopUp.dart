import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

final _formKey = GlobalKey<FormState>();
TextEditingController postController = new TextEditingController();
CollectionReference posts = FirebaseFirestore.instance.collection('Posts');

String postValue = '';
Future<void> submitPost() {
  return posts
      .add({
        'timestamp': DateTime.now(),
        'postContent': postValue,
        'likesCount': 0,
      })
      .then((value) => print("Post Added"))
      .catchError((error) => print("Failed to add user: $error"));
}

@override
Widget newPostDialogue(BuildContext context) {
  return Container(
    child: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: TextFormField(
              controller: postController,
              validator: (String value) {
                if (value.isEmpty) {
                  return 'please enter some text';
                }
              },
              onChanged: (val) {
                postValue = val;
              },
              decoration: new InputDecoration(
                hintText: "What's on your mind?",
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(2.0),
            child: RaisedButton(
              child: Text(
                'Post',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
                textAlign: TextAlign.center,
              ),
              color: Colors.blue,
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  submitPost();
                  print('submitted');
                  Navigator.pop(context); //closes popup
                  postController.clear(); //clears textfield
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}
