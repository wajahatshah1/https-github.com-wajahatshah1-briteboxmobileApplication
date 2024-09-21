// import 'package:flutter/material.dart';
// import 'LockerVideo.dart';
// import 'MainPage/HomePage.dart';
// import 'Qr_scanner.dart';
//
// class MainScreen extends StatelessWidget {
//   final String phoneNumber;
//   final String customerId;
//   final String name;
//
//   MainScreen({required this.phoneNumber, required this.customerId, required this.name});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Welcome!'),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               _buildServiceCard(
//                 'Laundry & Dry-cleaning',
//                 'Cleaning & Ironing Services for garments',
//                 Color(0xFF4C3BCF), // Background color for this card
//                     () {
//                   // Handle tap for Laundry & Dry-cleaning
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => HomePage(phoneNumber: phoneNumber, customerId: customerId,name: name,),
//                     ),
//                   );
//                 },
//               ),
//               _buildServiceCard(
//                 'Shoe Therapy',
//                 'Cleaning & Restoration Service',
//                 Color(0xFF7E8EF1), // Different background color
//                     () {
//                   // Handle tap for Shoe Therapy
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ComingSoonPage(),
//                     ),
//                   );
//                 },
//               ),
//               _buildServiceCard(
//                 'Bags',
//                 'Know More',
//                 Color(0XFF3DC2EC), // Another different background color
//                     () {
//                   // Handle tap for Personalized Garment Cleaning Service
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => QRCodeScanner(),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildServiceCard(String title, String subtitle, Color backgroundColor, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: EdgeInsets.all(10),
//         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
//         decoration: BoxDecoration(
//           color: backgroundColor,
//           borderRadius: BorderRadius.circular(15.0),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.5),
//               spreadRadius: 3,
//               blurRadius: 5,
//               offset: Offset(0, 3), // changes position of shadow
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 18.0,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: 5.0),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 14.0,
//                     color: Colors.white70,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
