import 'package:flutter/material.dart';
import 'package:foodbank/widgets/section_row.dart';
import 'package:get/get.dart';
import 'package:foodbank/widgets/map.dart';
import 'package:foodbank/notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Retain if using Google Maps in the future

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<Map<String, String>> adsArr = [
    {"img": "assets/images/ad_1.png"},
    {"img": "assets/images/ad_1.png"},
  ];

  final List<Map<String, dynamic>> nearFoodBankArr = [
    {
      "name": "Food Bank Siswa",
      "address": "UiTM Cawangan Perak, Kampus Tapah, Tapah Road, 35400 Tapah Road, Perak",
      "img": "assets/images/fb1.jpg",
      "coordinates": const LatLng(4.179135667138885, 101.2196918242871),
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xff083c81),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.blueAccent),
            onPressed: () {
              // Navigate to Notification Page
              Get.to(() => const NotificationsPage());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ads Section
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.5,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                itemBuilder: (context, index) {
                  final ad = adsArr[index];
                  return InkWell(
                    onTap: () {
                      // Handle ad click
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 1),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          ad["img"]!,
                          width: MediaQuery.of(context).size.width * 0.85,
                          height: MediaQuery.of(context).size.width * 0.425,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 15),
                itemCount: adsArr.length,
              ),
            ),

            // Section Title
            SectionRow(
              title: "Food Bank nearby you",
              onPressed: () {
                Get.to(() => const MapPage(
                  town: 'Tapah Road',
                  coordinates: LatLng(4.179135667138885, 101.2196918242871),
                ));
              },
            ),

            // Food Banks List
            SizedBox(
              height: 220,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final foodBank = nearFoodBankArr[index];
                  return ShopCell(
                    obj: foodBank,
                    onPressed: () {
                      Get.to(() => MapPage(
                        town: foodBank['name'],
                        coordinates: foodBank['coordinates'],
                      ));
                    },
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 20),
                itemCount: nearFoodBankArr.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShopCell extends StatelessWidget {
  final Map<String, dynamic> obj;
  final VoidCallback onPressed;

  const ShopCell({required this.obj, required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.asset(
                obj["img"]!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    obj["name"]!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    obj["address"]!,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
