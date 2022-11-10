import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'NoteListDetailView.dart';

class NoteList extends StatelessWidget {
  const NoteList({super.key, required this.notes});

  final AsyncSnapshot<QuerySnapshot<Object?>> notes;

  static List<Color> backgroundColors = [
    Colors.white,
    Colors.lightGreen.shade300,
    Colors.lightBlue.shade300,
    Colors.purpleAccent.shade100,
    Colors.greenAccent.shade400,
    Colors.cyanAccent.shade100,
    Colors.amber.shade300,
    Colors.orange.shade300,
    Colors.pinkAccent.shade100,
    Colors.tealAccent.shade100,
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StaggeredGridView.countBuilder(
        padding: EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
        ),
        itemCount: notes.data!.docs.length,
        staggeredTileBuilder: (index) =>
            StaggeredTile.fit(2),
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemBuilder: (context, index) {
          Random random = new Random();
          Color bg = backgroundColors[notes.data!.docs[index]['color']];
          return GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return NoteListDetail(notes: notes, index: index);
                  }
              );
            },
            child: Container(
              padding: EdgeInsets.only(
                bottom: 10,
                left: 10,
                right: 10,
              ),
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.red,
                  width: notes.data!.docs[index]['pin'] == true ? 4 : 0,
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.only(
                      top: 5,
                      right: 8,
                      left: 8,
                      bottom: 0,
                    ),
                    title: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      child: Text(
                        notes.data!.docs[index]['title'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      notes.data!.docs[index]['description'],
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    trailing: Visibility (
                      maintainSize: false,
                      visible: List<String>.from(notes!.data!.docs[index ?? 0]["pictures"]).first.isNotEmpty,
                      child: Padding(
                        padding: EdgeInsets.all(0),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: Image.network(List<String>.from(notes!.data!.docs[index ?? 0]["pictures"]).first),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}