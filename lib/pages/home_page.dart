import 'package:flutter/material.dart';
import 'package:loagapps/pages/cari_barang.dart';

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
                  builder: (_) => CariBarangPage(),
                ),
              );
              } ,
              icon: const Icon(Icons.search),
              label: const Text('cari_barang'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent),
            ),

          ],
        ),
        ),
    );
  }
}



