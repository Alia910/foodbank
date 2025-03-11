import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapPage extends StatefulWidget {
  final String town;
  final LatLng coordinates;

  const MapPage({required this.town, required this.coordinates, super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = {};
  List<Map<String, dynamic>> foodBanks = [];

  @override
  void initState() {
    super.initState();
    _fetchFoodBanks();
  }

  // Fetch food bank data from Firebase
  Future<void> _fetchFoodBanks() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('foodBanks')
          .where('town', isEqualTo: widget.town)
          .get();

      if (snapshot.docs.isEmpty) {
        print("No food banks found for ${widget.town}");
      }

      foodBanks = snapshot.docs.map((doc) {
        var data = doc.data();
        if (data['coordinates'] == null ||
            data['coordinates']['latitude'] == null ||
            data['coordinates']['longitude'] == null) {
          print("Invalid coordinates for ${data['name']}");
          return null; // Ignore invalid data
        }
        return {
          'name': data['name'],
          'coordinates': LatLng(
            data['coordinates']['latitude'],
            data['coordinates']['longitude'],
          ),
          'address': data['address'] ?? 'No address available',
          'details': data['details'] ?? 'No details available',
          'operatingHours': data['operatingHours'] ?? 'Unknown',
        };
      }).whereType<Map<String, dynamic>>().toList();

      _addMarkers();
    } catch (e) {
      print("Error fetching food banks: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching food banks: $e")),
        );
      }
    }
  }

  // Add markers for food banks
  void _addMarkers() {
    Set<Marker> newMarkers = {};
    for (var foodBank in foodBanks) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(foodBank['name']),
          position: foodBank['coordinates'],
          infoWindow: InfoWindow(
            title: foodBank['name'],
            snippet: "Tap for details",
            onTap: () => _onMarkerTapped(foodBank),
          ),
        ),
      );
    }

    setState(() {
      markers = newMarkers;
    });

    if (markers.isNotEmpty) {
      _moveCameraToFitMarkers();
    }
  }

  // Move camera to fit all markers
  Future<void> _moveCameraToFitMarkers() async {
    if (markers.isEmpty) return;

    LatLngBounds bounds = _calculateBounds(markers);

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  // Calculate LatLngBounds for markers
  LatLngBounds _calculateBounds(Set<Marker> markers) {
    double minLat = markers.first.position.latitude;
    double maxLat = markers.first.position.latitude;
    double minLng = markers.first.position.longitude;
    double maxLng = markers.first.position.longitude;

    for (var marker in markers) {
      minLat = min(minLat, marker.position.latitude);
      maxLat = max(maxLat, marker.position.latitude);
      minLng = min(minLng, marker.position.longitude);
      maxLng = max(maxLng, marker.position.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  // Handle marker tap
  void _onMarkerTapped(Map<String, dynamic> foodBank) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(foodBank['name']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Address: ${foodBank['address']}'),
              const SizedBox(height: 10),
              Text('Details: ${foodBank['details']}'),
              const SizedBox(height: 10),
              Text('Operating Hours: ${foodBank['operatingHours']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Find the nearest food bank
  Future<void> findNearestFoodBank() async {
    try {
      Position userPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (foodBanks.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No food banks found.")),
          );
        }
        return;
      }

      Map<String, dynamic>? nearestFoodBank;
      double closestDistance = double.infinity;

      for (var foodBank in foodBanks) {
        double distance = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          foodBank['coordinates'].latitude,
          foodBank['coordinates'].longitude,
        );

        if (distance < closestDistance) {
          closestDistance = distance;
          nearestFoodBank = foodBank;
        }
      }

      if (nearestFoodBank == null) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Nearest food bank: ${nearestFoodBank['name']}"),
          ),
        );
      }

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(nearestFoodBank['coordinates'], 15.0),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error finding nearest food bank: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff083c81),
        title: Text(
          "Food Banks in ${widget.town}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          _controller.complete(controller);
        },
        initialCameraPosition: CameraPosition(
          target: widget.coordinates,
          zoom: 14,
        ),
        markers: markers,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60.0, right: 255.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: findNearestFoodBank,
              backgroundColor: const Color(0xFF083C81),
              tooltip: "Find Nearest Food Bank",
              child: const Icon(Icons.location_searching, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF083C81), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Nearest Food Bank',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF083C81),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
