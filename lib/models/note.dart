import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String ownerId;
  final String creatorId;
  final String title;
  final String text;
  final bool visible;
  final GeoPoint location;

  const Note({
     required this.ownerId,
     required this.creatorId,
     required this.title,
     required this.text,
     required this.visible,
     required this.location
  });

  factory Note.fromDocument(DocumentSnapshot document) {
    return Note(
      ownerId: document['ownerId'],
      creatorId: document['creatorId'],
      title: document['title'],
      text: document['text'],
      visible: document['visible'],
      location: document['location'],
    );
  }

  bool checkLatAndLongMaxDistance(double? currentLatitude, double? currentLongitude, double maximalDistance) {
    if (currentLatitude == null || currentLongitude == null) {
      return false;
    }

    bool isLatitudeCloseEnough = (location.latitude - currentLatitude).abs() < maximalDistance;
    bool isLongitudeCloseEnough = (location.longitude - currentLongitude).abs() < maximalDistance;
    return isLatitudeCloseEnough && isLongitudeCloseEnough;
  }
}
