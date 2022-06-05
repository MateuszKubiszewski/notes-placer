import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapTab extends StatefulWidget {
  static const title = 'Nearby notes';
  static const icon = Icon(Icons.map);
  static const defaultLatitude = 37.7786;
  static const defaultLongitude = -122.4375;

  const MapTab({super.key, this.androidDrawer});

  final Widget? androidDrawer;

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final Completer<GoogleMapController> mapController = Completer();

  double latitude = MapTab.defaultLatitude;
  double longitude = MapTab.defaultLongitude;

  @override
  void initState() {
    super.initState();
    getMyLocationData();
  }
  
  void getMyLocationData() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    latitude = locationData.latitude == null ? MapTab.defaultLatitude : locationData.latitude!.toDouble();
    longitude = locationData.longitude == null ? MapTab.defaultLongitude : locationData.longitude!.toDouble();
    
    location.onLocationChanged.listen((LocationData currentLocation) {
      latitude = currentLocation.latitude == null ? MapTab.defaultLatitude : locationData.latitude!.toDouble();
      longitude = currentLocation.longitude == null ? MapTab.defaultLongitude : locationData.longitude!.toDouble();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(MapTab.title)
      ),
      drawer: widget.androidDrawer,
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 12,
        )
      )
    );
  }
}
