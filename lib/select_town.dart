import 'package:flutter/material.dart';
import 'package:foodbank/widgets/map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectTownPage extends StatefulWidget {
  const SelectTownPage({super.key});

  @override
  State<SelectTownPage> createState() => _SelectTownPageState();
}

class _SelectTownPageState extends State<SelectTownPage> {
  int selectedIndex = -1;
  final List<String> towns = [
    "Tapah Road",
    "Bidor",
    "Sungkai",
    "Chenderiang",
    "Temoh",
    "Tapah",
    "Slim River",
    "Trolak"
  ];
  List<String> filteredTowns = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredTowns = towns;
  }

  void filterTowns(String query) {
    setState(() {
      filteredTowns = query.isEmpty
          ? towns
          : towns.where((town) => town.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  Future<void> useCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location services are not enabled.")),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission denied. Please allow access.")),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied forever. Please enable it in app settings.")),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        String currentTown = placemarks[0].locality ?? '';
        setState(() {
          filteredTowns = towns.where((town) => town.toLowerCase() == currentTown.toLowerCase()).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You are in $currentTown.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unable to determine town.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
      );
    }
  }

  void showMap(String town) {
    LatLng coordinates;

    switch (town.toLowerCase()) {
      case 'tapah road':
        coordinates = const LatLng(4.173575670432285, 101.1915848844633);
        break;
      case 'bidor':
        coordinates = const LatLng(4.110405786956742, 101.28622808289924);
        break;
      case 'sungkai':
        coordinates = const LatLng(3.9972644529742176, 101.30924150984154);
        break;
      case 'chenderiang':
        coordinates = const LatLng(4.263982158107177, 101.23916556528941);
        break;
      case 'temoh':
        coordinates = const LatLng(4.243012709892088, 101.19480098668704);
        break;
      case 'tapah':
        coordinates = const LatLng(4.1980588660862335, 101.2615368830808);
        break;
      case 'felda gunung besout':
        coordinates = const LatLng(3.8368633259296088, 101.29244288817503);
        break;
      case 'pulau bekau':
        coordinates = const LatLng(4.172468572233982, 101.36409805589192);
        break;
      case 'air kuning':
        coordinates = const LatLng(4.195228730544714, 101.14296840180225);
        break;
      default:
        coordinates = const LatLng(0.0, 0.0);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPage(town: town, coordinates: coordinates),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff083c81),
        title: const Text(
          "Select Town",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            color: const Color(0xFF083C81),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: searchController,
                onChanged: filterTowns,
                decoration: const InputDecoration(
                  hintText: "Search your Town",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: filteredTowns.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredTowns[index]),
                  onTap: () => showMap(filteredTowns[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: const Color(0xFF083C81),
            onPressed: useCurrentLocation,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF083C81), width: 1),
            ),
            child: const Text(
              "Detect Location",
              style: TextStyle(
                color: Color(0xFF083C81),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
