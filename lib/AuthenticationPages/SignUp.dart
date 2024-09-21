// import 'dart:convert';
// import 'dart:math';
// import 'dart:typed_data';
//
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:qr_flutter/qr_flutter.dart';
//
// void main() {
//   runApp(MaterialApp(
//     home: SignUp(),
//   ));
// }
//
// class SignUp extends StatefulWidget {
//   const SignUp({Key? key}) : super(key: key);
//
//   @override
//   State<SignUp> createState() => _SignUpState();
// }
//
// class _SignUpState extends State<SignUp> {
//   final _formKey = GlobalKey<FormState>();
//   String? _selectedItem = 'Select an Option';
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _nameController = TextEditingController();
//   TextEditingController _mobileController = TextEditingController();
//   TextEditingController _passwordController = TextEditingController();
//   TextEditingController _confirmpasswordController = TextEditingController();
//
//   String generateCustomerId(String selectedItem) {
//     String firstThreeLetters = selectedItem.substring(0, 3).toUpperCase();
//     String randomNumber = Random().nextInt(10000000).toString().padLeft(7, '0');
//     String customerId = '$firstThreeLetters$randomNumber';
//     return customerId;
//   }
//
//   Future<void> signUp() async {
//     String customerId = generateCustomerId(_selectedItem!);
//
//     print({
//       'name': _nameController.text,
//       'email': _emailController.text,
//       'password': _passwordController.text,
//       'phoneNumber': _mobileController.text,
//       'region': _selectedItem!,
//       'customerId': customerId,
//     });
//
//     // Change 'localhost' to '10.0.2.2' if using Android emulator, or to your computer's IP address
//     final response = await http.post(
//       Uri.parse('http://192.168.235.60:8080/auth/signup/userSignup'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(<String, dynamic>{
//         'name': _nameController.text,
//         'email': _emailController.text,
//         'password': _passwordController.text,
//         'phoneNumber': _mobileController.text,
//         'region': _selectedItem!,
//         'customerId': customerId,
//       }),
//     );
//
//     print('Response status: ${response.statusCode}');
//     print('Response body: ${response.body}');
//
//     if (response.statusCode == 200) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => AuthenticationPage()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to create user: ${response.body}')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             child: Column(
//               children: [
//                 Container(
//                   width: 150,
//                   height: 150,
//                   child: Image.asset("assets/logo/logo.jpg"),
//                 ),
//                 Container(
//                   child: Center(
//                     child: Text(
//                       "SignUp",
//                       style: TextStyle(
//                         color: Colors.blueAccent,
//                         fontSize: 38,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.only(right: 40, left: 40),
//                   child: Center(
//                     child: Column(
//                       children: [
//                         Form(
//                           key: _formKey,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               Column(
//                                 children: [
//                                   Container(
//                                     padding: EdgeInsets.only(bottom: 5),
//                                     child: Row(
//                                       children: [
//                                         Text(
//                                           'Name', // Label text
//                                           style: TextStyle(
//                                             color: Colors.black45,
//                                             fontWeight: FontWeight.w900,
//                                           ), // Label text style
//                                         ),
//                                         Text(
//                                           '*', // Red star
//                                           style: TextStyle(color: Colors.red), // Color of the red star
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   TextFormField(
//                                     controller: _nameController,
//                                     decoration: InputDecoration(
//                                       fillColor: Colors.grey.shade100,
//                                       filled: true,
//                                       hintText: 'Name',
//                                       hintStyle: TextStyle(color: Colors.grey),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                         borderSide: BorderSide(color: Colors.grey),
//                                       ),
//                                     ),
//                                     validator: (value) {
//                                       if (value == null || value.isEmpty) {
//                                         return 'Please enter your Name';
//                                       }
//                                       return null;
//                                     },
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 10,),
//                               Column(
//                                 children: [
//                                   Container(
//                                     padding: EdgeInsets.only(bottom: 5),
//                                     child: Row(
//                                       children: [
//                                         Text(
//                                           'Phone Number', // Label text
//                                           style: TextStyle(
//                                             color: Colors.black45,
//                                             fontWeight: FontWeight.w900,
//                                           ), // Label text style
//                                         ),
//                                         Text(
//                                           '*', // Red star
//                                           style: TextStyle(color: Colors.red), // Color of the red star
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   TextFormField(
//                                     controller: _mobileController,
//                                     decoration: InputDecoration(
//                                       fillColor: Colors.grey.shade100,
//                                       filled: true,
//                                       hintText: 'Phone Number',
//                                       hintStyle: TextStyle(color: Colors.grey),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                         borderSide: BorderSide(color: Colors.grey),
//                                       ),
//                                     ),
//                                     validator: (value) {
//                                       if (value == null || value.isEmpty) {
//                                         return 'Please enter your Number';
//                                       }
//                                       return null;
//                                     },
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 10,),
//                               Column(
//                                 children: [
//                                   Container(
//                                     padding: EdgeInsets.only(bottom: 5),
//                                     child: Row(
//                                       children: [
//                                         Text(
//                                           'Email', // Label text
//                                           style: TextStyle(
//                                             color: Colors.black45,
//                                             fontWeight: FontWeight.w900,
//                                           ), // Label text style
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   TextFormField(
//                                     controller: _emailController,
//                                     decoration: InputDecoration(
//                                       fillColor: Colors.grey.shade100,
//                                       filled: true,
//                                       hintText: 'Email',
//                                       hintStyle: TextStyle(color: Colors.grey),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                         borderSide: BorderSide(color: Colors.grey),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 10,),
//                               Column(
//                                 children: [
//                                   Container(
//                                     padding: EdgeInsets.only(bottom: 5),
//                                     child: Row(
//                                       children: [
//                                         Text(
//                                           'Region', // Label text
//                                           style: TextStyle(
//                                             color: Colors.black45,
//                                             fontWeight: FontWeight.w900,
//                                           ), // Label text style
//                                         ),
//                                         Text(
//                                           '*', // Red star
//                                           style: TextStyle(color: Colors.red), // Color of the red star
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   DropdownButtonFormField<String>(
//                                     value: _selectedItem,
//                                     onChanged: (newValue) {
//                                       setState(() {
//                                         _selectedItem = newValue;
//                                       });
//                                     },
//                                     items: <String>['Select an Option', 'Manama', 'seef', 'Riffa', 'Juffair']
//                                         .map<DropdownMenuItem<String>>((String value) {
//                                       return DropdownMenuItem<String>(
//                                         value: value,
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(3.0),
//                                           child: Text(
//                                             value,
//                                             style: TextStyle(
//                                               fontSize: 16,
//                                               color: Colors.grey,
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     }).toList(),
//                                     decoration: InputDecoration(
//                                       filled: true,
//                                       fillColor: Colors.grey.shade200,
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                       contentPadding: EdgeInsets.symmetric(horizontal: 13, vertical: 20),
//                                     ),
//                                     validator: (value) {
//                                       if (value == "Select an Option") {
//                                         return 'Please enter your Region';
//                                       }
//                                       return null;
//                                     },
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 10,),
//                               Column(
//                                 children: [
//                                   Container(
//                                     padding: EdgeInsets.only(bottom: 5),
//                                     child: Row(
//                                       children: [
//                                         Text(
//                                           'Password', // Label text
//                                           style: TextStyle(
//                                             color: Colors.black45,
//                                             fontWeight: FontWeight.w900,
//                                           ), // Label text style
//                                         ),
//                                         Text(
//                                           '*', // Red star
//                                           style: TextStyle(color: Colors.red), // Color of the red star
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   TextFormField(
//                                     controller: _passwordController,
//                                     obscureText: true,
//                                     decoration: InputDecoration(
//                                       fillColor: Colors.grey.shade100,
//                                       filled: true,
//                                       hintText: 'Password',
//                                       hintStyle: TextStyle(color: Colors.grey),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                         borderSide: BorderSide(color: Colors.grey),
//                                       ),
//                                     ),
//                                     validator: (value) {
//                                       if (value == null || value.isEmpty) {
//                                         return 'Please enter a password';
//                                       }
//                                       if (value.length < 6) {
//                                         return 'Password must be at least 6 characters long';
//                                       }
//                                       return null;
//                                     },
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 10,),
//                               Column(
//                                 children: [
//                                   Container(
//                                     padding: EdgeInsets.only(bottom: 5),
//                                     child: Row(
//                                       children: [
//                                         Text(
//                                           'Confirm Password', // Label text
//                                           style: TextStyle(
//                                             color: Colors.black45,
//                                             fontWeight: FontWeight.w900,
//                                           ), // Label text style
//                                         ),
//                                         Text(
//                                           '*', // Red star
//                                           style: TextStyle(color: Colors.red), // Color of the red star
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   TextFormField(
//                                     controller: _confirmpasswordController,
//                                     obscureText: true,
//                                     decoration: InputDecoration(
//                                       fillColor: Colors.grey.shade100,
//                                       filled: true,
//                                       hintText: 'Confirm Password',
//                                       hintStyle: TextStyle(color: Colors.grey),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                         borderSide: BorderSide(color: Colors.grey),
//                                       ),
//                                     ),
//                                     validator: (value) {
//                                       if (value == null || value.isEmpty) {
//                                         return 'Please confirm your password';
//                                       }
//                                       if (value != _passwordController.text) {
//                                         return 'Passwords do not match';
//                                       }
//                                       return null;
//                                     },
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 20,),
//                               Container(
//                                 height: 50,
//                                 width: double.infinity,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     if (_formKey.currentState!.validate()) {
//                                       signUp();
//                                     }
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.blueAccent,
//                                     padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     'Sign Up',
//                                     style: GoogleFonts.roboto(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: 10,),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: <Widget>[
//                                   Text("Already have an account? "),
//                                   GestureDetector(
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(builder: (context) => AuthenticationPage()),
//                                       );
//                                     },
//                                     child: Text(
//                                       "Login",
//                                       style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
