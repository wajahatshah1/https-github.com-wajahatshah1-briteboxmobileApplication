// import 'package:britebox_mobile/LockerVideo.dart';
// import 'package:britebox_mobile/MainPage/LaundryService.dart';
// import 'package:britebox_mobile/MainPage/product_display/productsDisplay.dart';
// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:http/http.dart' as http;
// import '../../AuthenticationPages/LoginPage.dart';
// import '../../AuthenticationPages/token_manager.dart';
// import '../Topup/Topup.dart';
// import 'BillHistory.dart';
//
//
// class HomePage extends StatefulWidget {
//   final String customerId;
//   final String name;
//   final String phoneNumber;
//
//   HomePage({this.customerId = '', this.name = '', required this.phoneNumber});
//
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   int _selectedIndex = -1;
//   String? qrData;
//
//   void onTabTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   Future<void> _logout(BuildContext context) async {
//     const String logoutUrl = 'http://192.168.10.2:8080/auth/logout';
//
//     try {
//       final response = await http.post(Uri.parse(logoutUrl), headers: {
//         'Authorization': 'Bearer ${TokenManager.getToken()}',
//       });
//
//       if (response.statusCode == 200) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => AuthenticationPage()),
//         );
//       } else {
//         print('Logout failed: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Logout error: $e');
//     }
//   }
//
//   Future<void> _generateQRCode() async {
//     final String qrCodeUrl = 'http://192.168.10.2:8080/auth/generate-qr/${widget.phoneNumber}';
//     try {
//       final response = await http.get(Uri.parse(qrCodeUrl), headers: {
//         'Authorization': 'Bearer ${TokenManager.getToken()}',
//       });
//
//       if (response.statusCode == 200) {
//         setState(() {
//           qrData = response.body;
//         });
//       } else {
//         print('QR code generation failed: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('QR code generation error: $e');
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _generateQRCode();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 1,
//         automaticallyImplyLeading: false,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             PopupMenuButton<String>(
//               onSelected: (String value) {
//                 print('Selected: $value');
//               },
//               itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                 PopupMenuItem<String>(
//                   value: '',
//                   child: Center(
//                     child: Column(
//                       children: [
//                         Icon(Icons.person, size: 100,),
//                         Text(widget.name),
//                       ],
//                     ),
//                   ),
//                 ),
//                 PopupMenuDivider(),
//                 PopupMenuItem<String>(
//                   child: TextButton(onPressed: () {}, child: Text("Contact us")),
//                 ),
//                 PopupMenuItem<String>(
//                   child: TextButton(
//                     onPressed: () {
//                       _logout(context);
//                     },
//                     child: Text("Log out"),
//                   ),
//                 ),
//               ],
//               child: Row(
//                 children: [
//                   Icon(Icons.menu),
//                   SizedBox(width: 5),
//                 ],
//               ),
//               offset: Offset(-60, 40),
//             ),
//             Text("BriteBox", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
//             IconButton(onPressed: () {}, icon: Icon(Icons.notifications), color: Colors.grey),
//           ],
//         ),
//       ),
//       body: DefaultTabController(
//         length: 4,
//         child: Column(
//           children: [
//             TabBar(
//               indicator: null,
//               tabs: [
//                 Tab(child: Text("Locker Video", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45, fontSize: 12))),
//                 Tab(child: Text("Products", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45, fontSize: 12))),
//                 Tab(child: Text("Services", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45, fontSize: 12))),
//                 Tab(child: Text("History", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45, fontSize: 12))),
//               ],
//               onTap: onTabTapped,
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: _selectedIndex == -1
//                     ? Column(
//                   children: [
//                     Container(
//                       height: 100,
//                       child: Center(
//                         child: Text("Britebox", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.blueAccent)),
//                       ),
//                     ),
//                     SizedBox(height: 50,),
//                     qrData != null
//                         ? Container(
//                       width: 200,
//                       height: 200,
//                       child: QrImage(
//                         data: qrData!,
//                       ),
//                     )
//                         : CircularProgressIndicator(),
//                     SizedBox(height: 30,),
//                     Text("Scan to drop off the clothes!!", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.grey)),
//                   ],
//                 )
//                     : Column(
//                   children: [
//                     _selectedIndex == 0 ? ComingSoonPage() : Container(),
//                     _selectedIndex == 1 ? ProductsScreen() : Container(),
//                     _selectedIndex == 2 ? LaundryServiceScreen() : Container(),
//                     _selectedIndex == 3 ? HistoryPage(phoneNumber: widget.phoneNumber) : Container(),
//                     _selectedIndex == 4 ? PaymentPage(phoneNumber: widget.phoneNumber) : Container(),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         elevation: 1,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             IconButton(
//               onPressed: () {
//                 setState(() {
//                   _selectedIndex = -1;
//                 });
//               },
//               icon: Icon(Icons.home),
//               color: Colors.grey,
//             ),
//             IconButton(
//               onPressed: () {
//                 setState(() {
//                   _selectedIndex = 4;
//                 });
//               },
//               icon: Icon(Icons.credit_card),
//               color: Colors.grey,
//             ),
//             IconButton(onPressed: () {}, icon: Icon(Icons.chat_bubble), color: Colors.grey,),
//           ],
//         ),
//       ),
//     );
//   }
// }
