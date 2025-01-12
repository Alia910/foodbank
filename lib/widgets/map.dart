import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:collection/collection.dart';

class MapPage extends StatefulWidget {
  final String town;
  final LatLng coordinates;

  const MapPage({required this.town, required this.coordinates, super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;

  // Marker set to hold all markers
  Set<Marker> markers = {};

  // Polylines to draw the route
  //Set<Polyline> polylines = {};

  // Data structure to hold food banks per town with operating hours
  final Map<String, List<Map<String, dynamic>>> foodBanks = {
    'Tapah Road': [
      {
        'name': 'Food Bank Siswa',
        'coordinates': const LatLng(4.1776975900038575, 101.2188015888143),
        'address': 'UiTM Cawangan Perak, Kampus Tapah, Tapah Road, 35400 Tapah Road, Perak',
        'details': 'This food bank provides free food to those in need.',
        'operatingHours': 'Mon - Fri: 8:00 AM - 6:00 PM',
      },
      {
        'name': 'Food Bank 1',
        'coordinates': const LatLng(4.173575670432285, 101.1915848844633),
        'address': '123 Tapah Road, Tapah',
        'details': 'Offering food and essentials for families in need.',
        'operatingHours': 'Mon - Fri: 9:00 AM - 5:00 PM',
      },
    ],
    'Bidor': [
      {
        'name': 'Masjid Abu Hurairah',
        'coordinates': const LatLng(4.135919312888688, 101.27890483677633),
        'address': 'Jalan Tapah, 35500 Bidor, Perak',
        'details': 'A community food bank supporting the Bidor region.',
        'operatingHours': 'Mon - Fri: 10:00 AM - 4:00 PM',
      },
    ],
    'Sungkai': [
      {
        'name': 'Food Bank 4',
        'coordinates': const LatLng(4.0167, 101.3167),
        'address': '101 Sungkai Road, Sungkai',
        'details': 'Providing food and emergency aid to Sungkai residents.',
        'operatingHours': 'Tue - Sun: 9:00 AM - 5:00 PM',
      },
    ],
    'Chenderiang': [
      {
        'name': 'Food Bank 5',
        'coordinates': const LatLng(4.2500, 101.2500),
        'address': '102 Chenderiang Road, Chenderiang',
        'details': 'A local food bank helping the Chenderiang community.',
        'operatingHours': 'Mon - Fri: 9:30 AM - 3:30 PM',
      },
    ],
    'Temoh': [
      {
        'name': 'Food Bank 6',
        'coordinates': const LatLng(4.3000, 101.2333),
        'address': '103 Temoh Road, Temoh',
        'details': 'Serving the people of Temoh with free food and support.',
        'operatingHours': 'Mon - Sat: 7:00 AM - 5:00 PM',
      },
    ],
  };

  @override
  void initState() {
    super.initState();

    // Add markers only for the selected town
    _addMarkersForTown(widget.town);
  }

  // Function to add markers for the selected town
  void _addMarkersForTown(String town) {
    markers.clear(); // Clear existing markers

    if (foodBanks.containsKey(town)) {
      for (var foodBank in foodBanks[town]!) {
        markers.add(
          Marker(
            markerId: MarkerId(foodBank['name']),
            position: foodBank['coordinates'],
            infoWindow: InfoWindow(
              title: foodBank['name'],
              snippet: "Click for more details", // Display snippet text as clickable
              onTap: () {
                _onMarkerTapped(foodBank);
              },
            ),
            onTap: () {
              // No action on marker tap
            },
          ),
        );
      }
    }
  }

  // Function to handle marker tap event
  void _onMarkerTapped(Map<String, dynamic> foodBank) {
    // Show dialog with more details including operating hours
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
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Function to calculate the nearest food bank using Dijkstra's Algorithm
  Future<void> findNearestFoodBank() async {
    try {
      Position userPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Create a list of nodes (locations)
      List<Node> nodes = [
        Node('User', LatLng(userPosition.latitude, userPosition.longitude)),
        ...foodBanks[widget.town]!.map((foodBank) {
          return Node(foodBank['name'], foodBank['coordinates']);
        }).toList(),
      ];

      // Create edges (distances between locations)
      List<Edge> edges = [];
      for (int i = 0; i < nodes.length; i++) {
        for (int j = i + 1; j < nodes.length; j++) {
          double distance = Geolocator.distanceBetween(
            nodes[i].position.latitude,
            nodes[i].position.longitude,
            nodes[j].position.latitude,
            nodes[j].position.longitude,
          );
          edges.add(Edge(nodes[i], nodes[j], distance));
          edges.add(Edge(nodes[j], nodes[i], distance));  // Bidirectional edge
        }
      }

      // Run Dijkstra's algorithm
      Dijkstra dijkstra = Dijkstra(nodes, edges);
      Map<Node, double> distances = dijkstra.calculateShortestPaths(nodes[0]);

      // Find the nearest food bank (excluding the user)
      Node nearestFoodBank = nodes.skip(1).reduce((a, b) => distances[a]! < distances[b]! ? a : b);

      // Display the result (nearest food bank)
      double nearestDistance = distances[nearestFoodBank]!;
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          nearestFoodBank.position,
          15.0, // Zoom level
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Nearest food bank: ${nearestFoodBank.name} (${(nearestDistance / 1000).toStringAsFixed(2)} km away)."),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error finding nearest food bank: $e")),
      );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.location_searching, color: Colors.white),
            onPressed: findNearestFoodBank,
            tooltip: "Find Nearest Food Bank",
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: widget.coordinates,
          zoom: 10, // Adjusted zoom level for a better map view
        ),
        markers: markers,
        //polylines: polylines,
      ),
    );
  }
}

class Node {
  final String name;
  final LatLng position;

  Node(this.name, this.position);
}

class Edge {
  final Node from;
  final Node to;
  final double distance;

  Edge(this.from, this.to, this.distance);
}

class Dijkstra {
  final List<Node> nodes;
  final List<Edge> edges;

  Dijkstra(this.nodes, this.edges);

  Map<Node, double> calculateShortestPaths(Node start) {
    // Initialize the distances
    Map<Node, double> distances = {for (var node in nodes) node: double.infinity};
    distances[start] = 0;

    // Min-heap priority queue
    PriorityQueue<Node> queue = PriorityQueue<Node>((a, b) => distances[a]!.compareTo(distances[b]!));
    queue.add(start);

    // Track the shortest path
    Map<Node, Node?> previousNodes = {for (var node in nodes) node: null};

    while (queue.isNotEmpty) {
      Node currentNode = queue.removeFirst();

      // Visit each neighboring node
      for (Edge edge in edges) {
        if (edge.from == currentNode) {
          Node neighbor = edge.to;
          double newDistance = distances[currentNode]! + edge.distance;

          // If a shorter path to the neighbor is found, update the distance and queue
          if (newDistance < distances[neighbor]!) {
            distances[neighbor] = newDistance;
            previousNodes[neighbor] = currentNode;
            queue.add(neighbor);
          }
        }
      }
    }

    return distances;
  }
}
