import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:location/location.dart';

import 'models/note.dart';
import 'services/location_service.dart';

class AddNoteTab extends StatefulWidget {
  static const title = "Add a new note";
  static const icon = Icon(Icons.note_add);

  const AddNoteTab({super.key, required this.maximalDistance});

  final double maximalDistance;

  @override
  State<AddNoteTab> createState() => _AddNoteTabState();
}

class _AddNoteTabState extends State<AddNoteTab> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
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
        title: const Text(AddNoteTab.title),
      ),
      body: constructForm(context),
    );
  }

  Widget constructForm(BuildContext context) {
    return Column(
      children: <Widget> [
        FormBuilder(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            children: <Widget> [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: FormBuilderTextField(
                  name: "title",
                  decoration: const InputDecoration(
                    labelText: "Title",
                    hintText: "Your title will be visible from anywhere...",
                  ),
                  validator: FormBuilderValidators.required(),
                  keyboardType: TextInputType.text,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: FormBuilderTextField(
                  name: "text",
                  decoration: const InputDecoration(
                    labelText: "Content",
                    hintText: "Write the content of your note...",
                  ),
                  validator: FormBuilderValidators.required(),
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 3,
                  maxLines: 10
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: MaterialButton(
                  color: Theme.of(context).colorScheme.secondary,
                  child: const Text(
                    "Submit",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () { onAddNotePressed(); },
                ),
              )
            ]
          )
        ),
      ]
    );
  }

  void onAddNotePressed() async {
    if (_formKey.currentState == null) {
      return;
    }

    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    Location location = Location();
    if (! await LocationService.checkPermission(location)) {
      return;
    }

    LocationData currentLocation = await location.getLocation();
    if (currentLocation.latitude == null || currentLocation.longitude == null) {
      return;
    }

    final notesCollection = FirebaseFirestore.instance.collection("notes");

    var notes = await notesCollection.where("visible", isEqualTo: true).get();
    for (var document in notes.docs) {
      Note note = Note.fromDocument(document);
      if (note.checkLatAndLongMaxDistance(currentLocation.latitude, currentLocation.longitude, widget.maximalDistance)) {
        showSnackbar("You are too close to an existing note. Try adding the note in different location.");
        return;
      }
    }

    notesCollection.add({
      "creatorId": "",
      "ownerId": "",
      "title": _formKey.currentState!.fields["title"]!.value.toString(),
      "text": _formKey.currentState!.fields["text"]!.value.toString(),
      "visible": true,
      "location": GeoPoint(currentLocation.latitude!, currentLocation.longitude!)
    }).then(
      (response) => Navigator.pop(context),
      onError: (error) => showSnackbar("Something went wrong, please try once again.")
    );
  }

  void showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }
}