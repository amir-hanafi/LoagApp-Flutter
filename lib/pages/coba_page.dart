// register_page.dart
// import 'package:flutter/material.dart';

// class CobaPage extends StatelessWidget {
//   final Color kBeige = Color(0xFFDFC49A);
//   final Color kDark = Color(0xFF4B4038);
//   final BorderRadius kRadius = BorderRadius.all(Radius.circular(14));


//  CobaPage({super.key});

  

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Coba"),),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Container(
//             margin: EdgeInsets.symmetric(horizontal: 28),
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(color: Colors.white, borderRadius: kRadius),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 SizedBox(height: 8),
//                 Text('Daftar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
//                 SizedBox(height: 12),
//                 TextField(decoration: InputDecoration(hintText: 'Enter Email', filled: true, fillColor: kBeige.withOpacity(0.2), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
//                 SizedBox(height: 12),
//                 TextField(obscureText: true, decoration: InputDecoration(hintText: 'Password', filled: true, fillColor: kBeige.withOpacity(0.2), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
//                 SizedBox(height: 18),
//                 ElevatedButton(onPressed: () {}, child: Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Daftar')),
//                     style: ElevatedButton.styleFrom(backgroundColor: kDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


//////////////////////////////////////////////////////////////

// profil_page.dart
// class CobaPage extends StatelessWidget {
//     final Color kBeige = Color(0xFFDFC49A);
//   final Color kDark = Color(0xFF4B4038);
//   final BorderRadius kRadius = BorderRadius.all(Radius.circular(14));

//   CobaPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//      return Scaffold(
//       backgroundColor: kBeige,
//       appBar: AppBar(backgroundColor: kDark, title: Text('Menu')),
//       body: Center(
//         child: Container(
//           width: 320,
//           decoration: BoxDecoration(color: Colors.white, borderRadius: kRadius),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // headerCard('LOAG APP'),
//               Container(
//                 color: kBeige,
//                 padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
//                 child: Column(
//                   children: [
//                     menuItem('My Profil', Icons.person, () {}),
//                     SizedBox(height: 8),
//                     menuItem('Message', Icons.message, () {}),
//                     SizedBox(height: 8),
//                     menuItem('Location', Icons.location_on, () {}),
//                     SizedBox(height: 8),
//                     menuItem('Settings', Icons.settings, () {}),
//                     SizedBox(height: 24),
//                     TextButton(onPressed: () {}, child: Text('Logout'))
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget menuItem(String label, IconData icon, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         height: 48,
//         decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(12)),
//         child: Row(
//           children: [
//             SizedBox(width: 12),
//             Icon(icon, size: 20),
//             SizedBox(width: 12),
//             Text(label),
//           ],
//         ),
//       ),
//     );

//   }
// }

/////////////////////////////////////////////////////////////

// // cart_page.dart
// class CobaPage extends StatelessWidget {
//   final Color kBeige = Color(0xFFDFC49A);
//   final Color kDark = Color(0xFF4B4038);
//   final BorderRadius kRadius = BorderRadius.all(Radius.circular(14));

//   CobaPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var selected;
//     return Scaffold(
//       appBar: AppBar(title: Text('Cart Barang'), backgroundColor: kDark),
//       body: Container(
//         color: kBeige,
//         child: Column(
//           children: [
//             SizedBox(height: 12),
//             Expanded(
//               child: ListView.builder(
//                 padding: EdgeInsets.all(12),
//                 itemCount: selected.length,
//                 itemBuilder: (context, i) => cartRow(i),
//               ),
//             ),
//             Container(
//               color: Colors.white70,
//               padding: EdgeInsets.all(12),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
//                   ElevatedButton(onPressed: () {}, child: Text('Checkout'), style: ElevatedButton.styleFrom(backgroundColor: kDark)),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget cartRow(int index) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: kRadius),
//       child: Padding(
//         padding: EdgeInsets.all(8),
//         child: Row(
//           children: [
//             Container(width: 60, height: 60, color: kBeige.withOpacity(0.2)),
//             SizedBox(width: 10),
//             Expanded(child: Text('nama produk')),
//             Text('\$23'),
//             SizedBox(width: 10),
//             // Switch(value: selected[index], onChanged: (v) => setState(() => selected[index] = v)),
//           ],
//         ),
//       ),
//     );

//   }
// }

// // product_detail_page.dart
// class CobaPage extends StatelessWidget {
//   final Color kBeige = Color(0xFFDFC49A);
//   final Color kDark = Color(0xFF4B4038);
//   final BorderRadius kRadius = BorderRadius.all(Radius.circular(14));

//   CobaPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//      return Scaffold(
//       appBar: AppBar(title: Text('Detail Barang'), backgroundColor: kDark),
//       body: Container(
//         color: kBeige,
//         child: Center(
//           child: Container(
//             width: 320,
//             decoration: BoxDecoration(color: Colors.white, borderRadius: kRadius),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(height: 160, width: double.infinity, child: Center(child: Text('Gambar Barang')),
//                   decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.vertical(top: Radius.circular(8))),),
//                 Padding(
//                   padding: EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('\$00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//                       SizedBox(height: 8),
//                       Text('Deskripsi produk', style: TextStyle(fontWeight: FontWeight.bold)),
//                       SizedBox(height: 8),
//                       Text('Lorem ipsum is simply dummy text of the printing and typesetting industry. Lorem ipsum has been the industry\'s standard dummy text ever since the 1500s.'),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 SizedBox(
//                   width: double.infinity,
//                   child: TextButton(
//                     onPressed: () {},
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(vertical: 14),
//                       child: Text('Chat Penjual', style: TextStyle(color: Colors.black)),
//                     ),
//                     style: TextButton.styleFrom(backgroundColor: Colors.grey[300], shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)))),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//      );
//   }
// }
