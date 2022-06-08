import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'models/note.dart';

class CollectedNotesTab extends StatefulWidget {
  static const title = "Your notes";
  static const icon = Icon(Icons.notes);

  const CollectedNotesTab({super.key, required this.user});

  final User? user;

  @override
  State<CollectedNotesTab> createState() => _CollectedNotesTabState();
}

class _CollectedNotesTabState extends State<CollectedNotesTab> {
  List<Note> collectedNotes = [];
  bool isProcessing = true;

  @override
  void initState() {
    super.initState();

    if (widget.user == null) {
      setState(() { isProcessing = false; });
      return;
    }

    getNotes();
  }

  void getNotes() async {
    final notesCollection = FirebaseFirestore.instance.collection("notes");
    var notes = await notesCollection.where("ownerId", isEqualTo: widget.user!.uid).get();

    for (var document in notes.docs) {
      Note note = Note.fromDocument(document);
      collectedNotes.add(note);
    }
    
    setState(() {
      isProcessing = false;
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(CollectedNotesTab.title),
      ),
      body: constructForm(context),
    );
  }

  Widget constructForm(BuildContext context) {
    if (isProcessing) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Widget> children = [];
    for (Note note in collectedNotes) {
      children.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: ListTile(
          title: Text(note.title),
          onTap: () {
            showDialog(context: context, builder: (context) {
              return onNotePressed(note);
            });
          },
          shape: Border.all(color: Colors.green),
        )
      ));
    }

    return Column(
      children: children
    );
  }

  AlertDialog onNotePressed(Note note) {
    return AlertDialog(
      title: Text(note.title),
      content: Text(note.text),
      actions: [
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
      ],
    );
  }
}