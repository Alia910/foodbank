import 'package:flutter/material.dart';
import 'package:foodbank/dashboard.dart';
import 'package:foodbank/account.dart';
import 'package:foodbank/select_town.dart';
import 'package:foodbank/widgets/donations.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const DashboardPage(),
    const DonationsPage(notifications: [],),
    const SelectTownPage(),
    const AccPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex], // Display the selected page
      bottomNavigationBar: SlidingClippedNavBar(
        backgroundColor: Colors.white,
        onButtonPressed: (index) {
          setState(() {
            selectedIndex = index; // Update the selected index
          });
        },
        iconSize: 30,
        activeColor: const Color(0xFF083C81),
        selectedIndex: selectedIndex, // Highlight the selected index
        barItems: [
          BarItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
          ),
          BarItem(
            icon: Icons.volunteer_activism,
            title: 'Donations',
          ),
          BarItem(
            icon: Icons.map,
            title: 'Map',
          ),
          BarItem(
            icon: Icons.account_box,
            title: 'Account',
          ),
        ],
      ),
    );
  }
}
