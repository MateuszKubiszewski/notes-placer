import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'models/note.dart';
import 'services/location_service.dart';

class MapTab extends StatefulWidget {
  static const title = "Nearby notes";
  static const icon = Icon(Icons.map);
  static const defaultLatitude = 37.7786;
  static const defaultLongitude = -122.4375;
  static const zoom = 16.0;

  const MapTab({super.key, this.androidDrawer, required this.maximalDistance});

  final Widget? androidDrawer;
  final double maximalDistance;

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final Stream<QuerySnapshot> notesStream = FirebaseFirestore.instance.collection('notes').snapshots();
  final Completer<GoogleMapController> mapController = Completer();

  double? latitude = MapTab.defaultLatitude;
  double? longitude = MapTab.defaultLongitude;

  @override
  void initState() {
    super.initState();
    getMyLocationData();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
  
  void getMyLocationData() async {
    Location location = Location();
    if (! await LocationService.checkPermission(location)) {
      return;
    }

    LocationData locationData = await location.getLocation();
    latitude = locationData.latitude?.toDouble();
    longitude = locationData.longitude?.toDouble();
    
    location.onLocationChanged.listen((LocationData currentLocation) async {
      setState(() {
        latitude = locationData.latitude?.toDouble();
        longitude = locationData.longitude?.toDouble();
      });

      if (mapController.isCompleted) {
        if (latitude == null || longitude == null) {
          return;
        }

        var controller = await mapController.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(latitude!, longitude!),
            zoom: MapTab.zoom
          )
        ));
      }
    });
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    mapController.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: notesStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return Scaffold(
          appBar: AppBar(title: const Text(MapTab.title)),
          drawer: widget.androidDrawer,
          body: getMapTabBody((snapshot))
        );
      },
    );
  }

  Widget getMapTabBody(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (latitude == MapTab.defaultLatitude || longitude == MapTab.defaultLongitude) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return const Center(child: Text("Firestore error"));
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    var targetLatitude = latitude ?? MapTab.defaultLatitude;
    var targetLongitude = longitude ?? MapTab.defaultLongitude;
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(targetLatitude, targetLongitude),
        zoom: MapTab.zoom,
      ),
      markers: getMarkers(snapshot.data!.docs),
      myLocationEnabled: true,
    );
  }

  Set<Marker> getMarkers(List<QueryDocumentSnapshot<Object?>> notes) {
    var markers = <Marker>{};

    for (var document in notes) {
      Note note = Note.fromDocument(document);

      if (!note.visible) {
        continue;
      }

      markers.add(
        Marker(
          markerId: MarkerId(document.id),
          position: LatLng(note.location.latitude, note.location.longitude),
          infoWindow: InfoWindow(
            title: note.title,
            onTap: () {
              onMarkerInfoTap(note, document.id);
            }
          )
        )
      );
    }

    return markers;
  }

  void onMarkerInfoTap(Note note, String noteId) {
    showDialog(context: context, builder: (context) {
      return getNoteInformation(note, noteId);
    });
  }

  AlertDialog getNoteInformation(Note note, String noteId) {
    if (FirebaseAuth.instance.currentUser != null && note.creatorId == FirebaseAuth.instance.currentUser!.uid) {
      return AlertDialog(
        title: Text(note.title),
        content: Text(note.text),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
        ],
      );
    }
    if (FirebaseAuth.instance.currentUser == null && note.checkLatAndLongMaxDistance(latitude, longitude, widget.maximalDistance)) {
      return AlertDialog(
        title: Text(note.title),
        content: Text(note.text),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
        ],
      );
    }
    if (note.checkLatAndLongMaxDistance(latitude, longitude, widget.maximalDistance)) {
      return AlertDialog(
        title: Text(note.title),
        content: Text(note.text),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
          ElevatedButton(onPressed: () => onCollectPressed(note, noteId), child: const Text("Collect"))
        ],
      );
    }
    else {
      return AlertDialog(
        title: Text(note.title),
        content: const Text("To view the contents of a note you have to be near the note."),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
        ],
      );
    }
  }

  void onCollectPressed(Note note, String noteId) {
    final notesCollection = FirebaseFirestore.instance.collection("notes");
    final noteRef = notesCollection.doc(noteId);

    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      noteRef.update({ "ownerId": currentUser.uid, "visible": false });
    }
    else {
      noteRef.update({ "visible": false });
    }
    
    Navigator.pop(context);
  }
}
