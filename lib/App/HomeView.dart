import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'NoteListView.dart';
import 'NoteListDetailView.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // TextEditingController titleController = new TextEditingController();
  // TextEditingController descriptionController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Firestore Note"),
      ),
      body: NotesList(),
      // ADD (Create)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return NoteListDetail();
              }
          );
        } ,
        tooltip: 'Add Title',
        child: Icon(Icons.add),
      ),
    );
  }
}


class NotesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //TODO: Retrive all records in collection from Firestore
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('note').orderBy('pin', descending: true).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return Center(child: CircularProgressIndicator(),);
          default:
            return Row(children: <Widget>[NoteList(notes: snapshot)]);
        }
      },
    );
  }
}

extension ListGetExtension<T> on List<T> {
  T? tryGet(int index) =>
      index < 0 || index >= this.length ? null : this[index];
}