// page_home.dart
import 'package:bmkg_fix/login.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../fragment/fragment_magnitudo.dart';
import '../fragment/fragment_terkini.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _activeIndex = 0;

  // List of pages for navigation
  final List<Widget> _pages = [
    FragmentTerkini(),
    FragmentMagnitudo(),
  ];

  // Method untuk logout
  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    ); // Navigasi ke halaman LoginPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          'Informasi Gempa',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
      ),
      body: _pages[_activeIndex], // Tampilkan halaman berdasarkan _activeIndex
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.blue,
        items: [
          Icon(
            Icons.home,
            size: 30.0,
            color: _activeIndex == 0 ? Colors.white : const Color(0xFFC8C9CB),
          ),
          Icon(
            Icons.list_alt,
            size: 30.0,
            color: _activeIndex == 1 ? Colors.white : const Color(0xFFC8C9CB),
          ),
          Icon(
            Icons.logout,
            size: 30.0,
            color: Colors.red, // Warna merah untuk logout
          ),
        ],
        onTap: (index) {
          if (index == 2) {
            _logout(); // Panggil fungsi logout jika ikon logout di-tap
          } else {
            setState(() {
              _activeIndex = index;
            });
          }
        },
      ),
    );
  }
}
