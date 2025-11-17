import 'package:flutter/material.dart';
import 'package:loagapps/pages/list_page.dart';
import 'package:loagapps/pages/login_page.dart';
import 'package:loagapps/pages/home_page.dart';
import 'package:loagapps/pages/profil_page.dart';
import 'package:loagapps/pages/map_page.dart';
import 'package:loagapps/pages/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoagApp',
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}


class MainPage extends StatefulWidget {
  final String userId;

  const MainPage({super.key, required this.userId});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

@override
void initState() {
  super.initState();
  _pages = [
    HomePage(userId: widget.userId),
    ListPage(),
    ProfilePage(),
  ];
}


  // Saat item navbar ditekan
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // agar 3+ item bisa tampil
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Barang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'profil',
          ),
          
        ],
      ),
    );
  }
}