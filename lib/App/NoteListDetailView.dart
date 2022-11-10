import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:collection/collection.dart';


class NoteListDetail extends StatefulWidget {
  NoteListDetail({super.key, this.notes, this.index});

  final AsyncSnapshot<QuerySnapshot<Object?>>? notes;
  final int? index;

  @override
  _NoteListDetail createState() => _NoteListDetail();
}

class _NoteListDetail extends State<NoteListDetail> {
  FirebaseStorage storage = FirebaseStorage.instance;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  List<String>? images;

  bool? pinned;
  String? dropdownValue;

  static List<String> backgroundColors = [
    "White",
    "Light Green",
    "Light Blue",
    "Purple Accent",
    "Green Accent",
    "Cyan Accent",
    "Amber",
    "Orange",
    "Pink Accent",
    "Teal Accent",
  ];

  Future<void> _upload(String inputSource) async {
    final picker = ImagePicker();
    XFile? pickedImage;
    try {
      pickedImage = await picker.pickImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920);

      final String fileName = path.basename(pickedImage!.path);
      File imageFile = File(pickedImage.path);

      try {
        // Uploading the selected image with some custom meta data
        await storage.ref(fileName).putFile(
            imageFile,
            SettableMetadata(customMetadata: {
              'uploaded_by': 'BlackStar',
              'description': 'Test Upload...'
            }));
        String imageURL = await storage.ref(fileName).getDownloadURL();
        // storage.ref(fileName).getDownloadURL()
        // Refresh the UI
        setState(() {
          print(imageURL);
          if (widget.index == null) {
            images = [imageURL];
          } else {
            Map<String, dynamic> updateNotes = new Map<String,dynamic>();
            List<String> pictures = List<String>.from(widget.notes!.data!.docs[widget.index ?? 0]["pictures"]);

            updateNotes["title"] = titleController.text;
            updateNotes["description"] = descriptionController.text;
            updateNotes["pin"] = pinned;
            updateNotes["color"] = backgroundColors.indexOf(dropdownValue!);
            pictures.add(imageURL);
            updateNotes["pictures"] = pictures;

            FirebaseFirestore.instance
                .collection("note")
                .doc(widget.notes?.data?.docs[widget.index!].id)
                .update(updateNotes)
                .whenComplete((){
              Navigator.of(context).pop();
            });
          }
        });
      } on FirebaseException catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AsyncSnapshot<QuerySnapshot<Object?>>? notes = widget.notes;
    int? index = widget.index;

    titleController = TextEditingController(text: notes?.data?.docs[index ?? 0]["title"]);
    descriptionController = TextEditingController(text: notes?.data?.docs[index ?? 0]["description"]);

    pinned = pinned ?? notes?.data?.docs[index ?? 0]["pin"] ?? false;

    if (index != null) {
      dropdownValue = dropdownValue ?? backgroundColors[notes?.data?.docs[index ?? 0]["color"]] ?? "White";
    } else {
      dropdownValue = dropdownValue ?? "White";
    }

    return AlertDialog(
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text( index != null ? "Update" : "Add"),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text("Title: ", textAlign: TextAlign.start,),
            ),
            TextField(
              controller: titleController,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text("Description: "),
            ),
            TextField(
              controller: descriptionController,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 10,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text("Background Color: "),
            ),
            DropdownButton(
              // Initial Value
              value: dropdownValue,
              // Down Arrow Icon
              icon: const Icon(Icons.keyboard_arrow_down),

              // Array list of items
              items: backgroundColors.map((String items) {
                return DropdownMenuItem(
                  value: items,
                  child: Text(items),
                );
              }).toList(),
              // After selecting the desired option,it will
              // change button value to selected value
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
            ),
            CheckboxListTile(
              title: Text("Pin"),
              value: pinned,
              onChanged: (bool? newValue) {
                setState(() {
                  pinned = newValue!;
                });
              },
            ),
            Text( "Images"),
            SizedBox(
                    height: 100,
                    width: double.maxFinite,
                    child: ListView(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children:
                        ( (images != null && images!.isNotEmpty) || ((notes?.data?.docs[index ?? 0]["pictures"] != null) &&
                            (List<String>.from(notes!.data!.docs[index ?? 0]["pictures"])).whereNot((item) => ["", null, false, 0].contains(item)).isNotEmpty)) ?

                        (images ?? List<String>.from(notes!.data!.docs[index ?? 0]["pictures"])).map<Widget>((String imageURL) {
                          return Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: SizedBox(
                                  height: 80,
                                  width: 80,
                                  child: Image.network(imageURL),
                                  ),
                                ),
                              ]);
                        }).toList()
                            :
                        [
                          ElevatedButton(
                            onPressed: () => _upload('gallery'),//() {  },
                            child: Text("Add Image"),
                          ),
                        ]
                    ),
            ),
            Visibility (
              maintainSize: false,
              visible: ( (images != null && images!.isNotEmpty) || (notes?.data?.docs[index ?? 0]["pictures"] != null) && (List<String>.from(notes!.data!.docs[index ?? 0]["pictures"])).whereNot((item) => ["", null, false, 0].contains(item)).isNotEmpty) ,
              child:
              ElevatedButton(
                onPressed: () => _upload('gallery'),//() {  },
                child: Text("Add Image"),
              ),

            ),
          ],
        )
      ),

      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            if (index == null) {
              Map<String, dynamic> newNote = new Map<String,dynamic>();
              newNote["title"] = titleController.text;
              newNote["description"] = descriptionController.text;
              newNote["pin"] = pinned;
              newNote["color"] = backgroundColors.indexOf(dropdownValue!);
              newNote["pictures"] = images;

              FirebaseFirestore.instance
                  .collection("note")
                  .add(newNote)
                  .whenComplete((){
                Navigator.of(context).pop();
              } );
            } else {
              Map<String, dynamic> updateNotes = new Map<String,dynamic>();
              updateNotes["title"] = titleController.text;
              updateNotes["description"] = descriptionController.text;
              updateNotes["pin"] = pinned;
              updateNotes["color"] = backgroundColors.indexOf(dropdownValue!);

              FirebaseFirestore.instance
                  .collection("note")
                  .doc(notes?.data?.docs[index!].id)
                  .update(updateNotes)
                  .whenComplete((){
                Navigator.of(context).pop();
              });
            }
          },
          child: Text(index != null ? "update" : "save", style: const TextStyle(color: Colors.white),),
        ),
      ],
    );
  }
}