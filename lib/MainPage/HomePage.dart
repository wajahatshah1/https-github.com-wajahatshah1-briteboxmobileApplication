import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:Britebox/AuthenticationPages/PhoneNumberManager.dart';
import 'package:Britebox/MainPage/Map/Google.dart';
import 'package:Britebox/MainPage/OrderTracker/TimelineEntry.dart';
import 'package:Britebox/MainPage/product_display/productsDisplay.dart';
import 'package:flutter/material.dart';
import 'package:Britebox/LockerVideo.dart';
import 'package:Britebox/MainPage/OrderHistoryPage/BillHistory.dart';
import 'package:Britebox/MainPage/QrCode/QrCode.dart';
import 'package:Britebox/MainPage/Settings/Settings.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../AuthenticationPages/AppUri.dart';
import '../AuthenticationPages/LoginPage.dart';
import '../AuthenticationPages/NameManager.dart';
import '../AuthenticationPages/token_manager.dart';

import 'Topup/Topup.dart';

class HomeScreen extends StatefulWidget {


  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _hasCallSupport = false;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  final Color navyBlue = Color(0xFF3a679e);
  final nameChangeController = TextEditingController();
  final passwordChnageController= TextEditingController();
  final phoneChnageController= TextEditingController();
  String _token = '';


  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  String _qrData = '';
  @override
  void initState() {
    super.initState();
    _token = _generateRandomToken();
    _qrData = _generateQrData();
    _sendTokenToBackend(_token);

    print(_qrData);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(_controller);

  }

  String _generateRandomToken() {
    var uuid = Uuid();
    return uuid.v4(); // Generates a random UUID
  }

  // Method to generate the QR code data using token and phone number
  String _generateQrData() {

    final phoneNumber = PhoneNumberManager.getphoneNumber();
    return 'qrCodeToken:$_token, PhoneNumber:$phoneNumber';
  }

  // Method to send the token to the backend using phone number as a parameter
  Future<void> _sendTokenToBackend(String _token) async {
    final phoneNumber = PhoneNumberManager.getphoneNumber(); // Get the phone number
    final url = ApiUri.getEndpoint('/auth/tokens/$phoneNumber'); // Replace with your Spring Boot backend URL
    print("my toke $_token");
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'qrToken': _token,
        }),
      );

      if (response.statusCode == 200) {
        print('Token saved successfully.');
      } else {
        print('Failed to save token: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }




  Future<void> _changePassword(BuildContext context) async {
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldPasswordController,
                  decoration: InputDecoration(labelText: 'Old Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your old password';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: newPasswordController,
                  decoration: InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your new password';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                print(newPasswordController.text);
                if (_formKey.currentState!.validate()) {
                  try {
                    final response = await http.post(
                      Uri.parse(ApiUri.getEndpoint('/auth/changepassword?phoneNumber=${PhoneNumberManager.getphoneNumber()}')),
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer ${TokenManager.getToken()}',
                      },
                      body: jsonEncode({
                        'oldPassword': oldPasswordController.text.trim(),
                        'newPassword': newPasswordController.text.trim(),
                      }),
                    );

                    final responseBody = response.body; // Capture the response body

                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Password changed successfully')),
                      );
                      Navigator.of(context).pop();
                    } else if (response.statusCode == 401) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Old password is incorrect')),
                      );
                    } else {
                      print(response.statusCode);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to change password: ${response.statusCode}, ${responseBody}')),
                      );
                    }
                  } catch (e) {
                    print(e);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to change password: ${e.toString()}')),
                    );
                  }
                }
              },
              child: Text('Change Password'),
            ),
          ],
        );
      },
    );
  }

  // Future<void> _changeName(BuildContext context) async {
  //   final TextEditingController oldPasswordController = TextEditingController();
  //   final TextEditingController newPasswordController = TextEditingController();
  //   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Change name'),
  //         content: Form(
  //           key: _formKey,
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               TextFormField(
  //                 controller: oldPasswordController,
  //                 decoration: InputDecoration(labelText: 'Old Password'),
  //                 obscureText: true,
  //                 validator: (value) {
  //                   if (value == null || value.isEmpty) {
  //                     return 'Please enter your old password';
  //                   }
  //                   return null;
  //                 },
  //               ),
  //               TextFormField(
  //                 controller: newPasswordController,
  //                 decoration: InputDecoration(labelText: 'New Password'),
  //                 obscureText: true,
  //                 validator: (value) {
  //                   if (value == null || value.isEmpty) {
  //                     return 'Please enter your new password';
  //                   }
  //                   return null;
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               if (_formKey.currentState!.validate()) {
  //                 const String changePasswordUrl = 'https://163.172.91.5/auth/changepassword'; // Replace with your API endpoint
  //
  //                 try {
  //                   final response = await http.post(
  //                     Uri.parse(changePasswordUrl),
  //                     headers: {
  //                       'Content-Type': 'application/json',
  //                       'Authorization': 'Bearer ${TokenManager.getToken()}',
  //                     },
  //                     body: jsonEncode({
  //                       'oldPassword': oldPasswordController.text,
  //                       'newPassword': newPasswordController.text,
  //                     }),
  //                   );
  //
  //                   if (response.statusCode == 200) {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(content: Text('Password changed successfully')),
  //                     );
  //                     Navigator.of(context).pop();
  //                   } else if (response.statusCode == 401) {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(content: Text('Old password is incorrect')),
  //                     );
  //                   } else {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(content: Text('Failed to change password: ${response.statusCode}')),
  //                     );
  //                   }
  //                 } catch (e) {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(content: Text('Failed to change password')),
  //                   );
  //                 }
  //               }
  //             },
  //             child: Text('Change Password'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> _logout(BuildContext context) async {
    try {
      final uri = Uri.parse(ApiUri.getEndpoint('/auth/logout'));
      final response = await http.post(uri, headers: {
        'Authorization': 'Bearer ${TokenManager.getToken()}',
      });

      if (response.statusCode == 200) {
        // Clear user data (e.g., tokens, session information)
        // For demonstration, we're just navigating to the login screen

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthenticationPage()),
        );
      } else {
        // Handle logout failure
        print('Logout failed: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Logout error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    if (_controller.isDismissed) {
      _controller.forward();
    } else if (_controller.isCompleted) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    String showName = NameManager.getname().split(" ").first;
    DateTime now = DateTime.now();
    int hour = now.hour;
    String greetings;

    if (hour < 12) {
      greetings = 'Good Morning ☺️ ';
    } else if (hour > 12 && hour < 15) {
      greetings = 'Good noon ☺️';
    } else if (hour < 17) {
      greetings = 'Good Afternoon ☺️';
    } else {
      greetings = 'Good Evening ☺️';
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: navyBlue,
        title: Row(
          children: [
            Text(
              "$greetings",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
            ),
            SizedBox(width: 5),
            Text(
              NameManager.getname(),
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
            ),
            )],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications,color: Colors.white,),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: <Widget>[
              SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 16, right: 5, left: 5, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Card(
                        color: Colors.white,
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Scan Qr',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                    MediaQuery.of(context).size.width * 0.23,
                                  ),
                                  SizedBox(
                                    child: Text(PhoneNumberManager.getphoneNumber(),style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),),
                                  ),

                                ],
                              ),
                              SizedBox(height: 8),
                              Center(
                                child: QrImageView(
                                  data: _qrData,
                                  version: QrVersions.auto,
                                  size: MediaQuery.of(context).size.width * 0.6,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Active Laundry',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 8),
                      Card(
                        elevation: 4,
                        color: Color(0xFF3a679e),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Laundry Status',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Your clothes are getting\n washed now',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(height: 2),

                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OrderDetailsPage(
                                        ),
                                      ));
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white),
                                child: Text(
                                  'View detail',
                                  style: TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Card(
                        elevation: 4,
                        color: Color(0xFFa43420),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ready to Pay',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Invoice has been issued',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),


                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PaymentPage(
                                      ),
                                      ));
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white),
                                  child: Text(
                                    'Pay Now',
                                    style: TextStyle(
                                        fontSize: 11, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Locker Locations',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 8),
                      Card(
                        elevation: 4,
                        color: Color(0xFFd58473),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Locker Locations',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Check Your Nearest Britebox Lockers',
                                  style:
                                      TextStyle(fontSize: 14, color: Colors.white),
                                ),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MapScreen(),
                                      ),
                                    );

                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white),
                                  child: Text(
                                    'View Map',
                                    style: TextStyle(color: Colors.orangeAccent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              HistoryPage(),
            ],
          ),
          SlideTransition(
            position: _offsetAnimation,
            child: _buildDrawer(),
          ),
        ],
      ),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 4,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home,color: Colors.grey,),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.layers,color: Colors.grey),
              label: 'Invoices',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu,color: Colors.grey),
              label: 'Menu',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 2) {
              _toggleDrawer();
            } else {
              _onItemTapped(index);
            }
          },
        ),
    );
  }

  Widget _buildDrawer() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 250,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.video_library),
              title: Text('LockerVideo'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComingSoonPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.list_alt_rounded),
              title: Text('Price list'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductsScreen(),
                  ),
                );
              },
            ),

            ExpansionTile(
                leading: Icon(Icons.contact_mail),
                title: Text('Contact Us'),
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.facebook,
                      color: Colors.blue,
                    ),
                    title: Text('Facebook'),
                    onTap: () => _launchMessenger(),
                  ),
                  ListTile(
                      leading: Icon(Icons.phone),
                      title: Text('Phone Number'),
                      onTap: () {
                        print("i am tapped");
                        _makePhoneCall("+923361426310");
                      }

                      //     canLaunchUrl(Uri(scheme: 'tel', path: '123')).then((bool result) {
                      //   setState(() {
                      //     _hasCallSupport = result;
                      //   });
                      // })
                      ),
                  ListTile(
                    leading: Icon(
                      Icons.email,
                      color: Colors.red,
                    ),
                    title: Text('Gmail'),
                    onTap: () => _launchGmail("wjahath849@gmail.com"),
                  ),
                  ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text('Instagram'),
                    onTap: () => _launchInstagramProfile("_itx_wajahat_hussain"),
                  ),
                  ListTile(
                    leading: Icon(Icons.chat, color: Color(0xFF355E3B)),
                    title: Text('WhatsApp'),
                     onTap: () => _launchWhatsApp('https://wa.me/+923361426310'),
                  )
                ]),
            ExpansionTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              children: [
                // ListTile(
                //   leading: Icon(Icons.drive_file_rename_outline),
                //   title: Text("Change name"),
                //   onTap: (){
                //
                //   }
                // ),
                // ListTile(
                //   leading: Icon(Icons.phone),
                //   title: Text("Change Phonenumber"),
                // ),
                ListTile(
                  leading: Icon(Icons.password),
                  title: Text("Change password"),
                  onTap: (){
                    _changePassword(context);
                  },
                )
              ],
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log out'),
              onTap: () {
                print("i am pressed");
                _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch $launchUri');
    }
  }

  Future<void> _messege(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch $launchUri');
    }
  }
  Future<void> _launchMessenger() async {
    const url = 'fb-messenger://user-thread/wajahath3';
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchInstagramProfile(String username) async {
    final String url = 'https://www.instagram.com/$username';
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchGmail(String recipient) async {
    final String url = 'mailto:$recipient';
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
  Future<void> _launchWhatsApp(String phoneNumber) async {
    final String url = 'whatsapp://send?phone=$phoneNumber';
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
  }

