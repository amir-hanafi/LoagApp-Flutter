import 'package:flutter/material.dart';
import 'map_page.dart';

class HomePage extends StatelessWidget {
  final String userId;

  const HomePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton.icon(
                  onPressed: () {Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => MapPage(userId: userId),
  ),
);
} ,
                  icon: const Icon(Icons.search),
                  label: const Text(''),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent),
                ),
          ],
        ),
        ),
    );
  }
}



