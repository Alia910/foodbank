import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({
    super.key,
    required this.child,
    this.showBackButton = true, // Default to true
    this.backgroundImage,  // Optional background image parameter
    this.floatingActionButton,  // Optional FloatingActionButton
    this.bottomNavigationBar,  // Optional Bottom Navigation Bar
  });

  final Widget child;
  final bool showBackButton;
  final String? backgroundImage; // Optional background image parameter
  final FloatingActionButton? floatingActionButton;  // Optional FloatingActionButton
  final BottomNavigationBar? bottomNavigationBar;  // Optional BottomNavigationBar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: showBackButton // Conditionally render the back button
            ? IconButton(
          icon: Container(
            width: 40.0,
            height: 40.0,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF151B89),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        )
            : null,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Use the passed backgroundImage, or fall back to a default image if not provided
          Image.asset(
            backgroundImage ?? 'assets/images/bg2.png', // Default to bg2.png
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: child,
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,  // Include the floating action button
      bottomNavigationBar: bottomNavigationBar,    // Include the bottom navigation bar
    );
  }
}
