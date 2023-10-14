import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crud/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // firestore object
  final FirestoreService firestoreService = FirestoreService();

  // text controller
  final TextEditingController textController = TextEditingController();

  // open box to add note
  void openNoteBox(String? docID) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    if (docID == null) {
                      firestoreService.addNote(textController.text);
                    } else {
                      firestoreService.updateNote(docID, textController.text);
                    }

                    //   clear controller
                    textController.clear();

                    //   close box
                    Navigator.pop(context);
                  },
                  child: Text('ADD'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NOTES'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          //   if we have the data get all the data
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;
            return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                  //   get each indiviual doc
                  DocumentSnapshot document = notesList[index];
                  String docID = document.id;

                  // get notes from each  doc
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String noteText = data['note'];

                  //   display note
                  return ListTile(
                    title: Text(noteText),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            openNoteBox(docID);
                          },
                          icon: Icon(Icons.edit),
                        ),
                        IconButton(
                            onPressed: () {
                              firestoreService.deleteNote(docID);
                            },
                            icon: Icon(Icons.delete))
                      ],
                    ),
                  );
                });
          } else {
            return Text('no notes');
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openNoteBox(null);
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}
