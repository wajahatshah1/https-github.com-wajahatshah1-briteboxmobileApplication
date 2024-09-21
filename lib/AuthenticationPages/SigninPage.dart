// import 'dart:convert';
//
// import 'package:mobile_application/AuthenticationPages/token_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// import '../DriverPart/AuthPage.dart';
// import '../MainPage/HomePage.dart';
// import 'AppUri.dart';
// import 'NameManager.dart';
// import 'PhoneNumberManager.dart';
// import 'SignInData.dart';
// import 'ForgetPassword.dart'; // Import your PasswordResetPage here
//
// class AuthenticationPage extends StatefulWidget {
//   @override
//   _AuthenticationPageState createState() => _AuthenticationPageState();
// }
//
// class _AuthenticationPageState extends State<AuthenticationPage> {
//   final _formKey = GlobalKey<FormState>();
//
//   // Controllers for signup form
//   final _signupemailController = TextEditingController();
//   final _signupnameController = TextEditingController();
//   final _signupmobileController = TextEditingController();
//   final _signupasswordController = TextEditingController();
//   final _signupconfirmpasswordController = TextEditingController();
//
//   // Controllers for login form
//   final _phoneNumberController = TextEditingController();
//   final _passwordController = TextEditingController();
//
//   bool loading = false;
//   bool showLoginForm =
//       true; // Flag to toggle between showing login form and Sign Up content
//
//
//
//   Future<void> signIn() async {
//     String url = ApiUri.getEndpoint(
//         '/auth/usersignin'); // Replace with your Spring Boot API URL
//     SignInData signInData = SignInData(
//       username: _phoneNumberController.text,
//       password: _passwordController.text,
//     );
//
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(signInData.toJson()),
//       );
//
//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         print(data);
//         String token = data['token'];
//
//         // Assuming TokenManager.setToken(token) saves token securely
//         TokenManager.setToken(token);
//         String phoneNumber = data['phoneNumber'] ?? "user";
//         PhoneNumberManager.setphoneNumber(phoneNumber);
//         String name = data['name'] ?? "user";
//         NameManager.setname(name);
//         _phoneNumberController.clear();
//         _passwordController.clear();
//         // Example of navigating to HomeScreen with user data
//         // Replace HomeScreen with your desired destination and pass user data accordingly
//         Navigator.of(context).pushReplacementNamed('/homescreen');
//       } else {
//         print('Failed to sign in: ${response.statusCode}');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Phone number or password is invalid"),
//             duration: Duration(seconds: 3), // Duration for the snack bar to be visible
//             behavior: SnackBarBehavior.floating, // Optional: Makes the snack bar float above other widgets
//           ),
//         );// Handle other status codes (e.g., show error to user)
//         print('Failed to sign in: ${response.statusCode}');
//       }
//     } catch (e) {
//       // Handle network errors
//       print('Error during sign in: $e');
//     }
//   }
//
//   void toggleView() {
//     setState(() {
//       showLoginForm = !showLoginForm;
//     });
//   }
//   final TextEditingController _pinController = TextEditingController();
//
//   Future<void> _sendPin() async {
//     final phoneNumber = _signupmobileController.text.trim();
//     final url = Uri.parse(ApiUri.getEndpoint('/password/account/send-pin'));
//
//     if (phoneNumber.length != 8) {
//       _showErrorDialog('Phone number must be 8 digits long.');
//       return;
//     }
//
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'phoneNumber': phoneNumber}),
//     );
//
//     if (response.statusCode == 200) {
//       _showDialog('PIN sent successfully.');
//     } else if (response.statusCode == 400){
//       _showErrorDialog('User already present');
//     }
//     else {
//       final responseBody = jsonDecode(response.body);
//       _showErrorDialog(responseBody['message'] ?? 'Failed to send PIN.');
//     }
//   }
//
//   Future<void> _signup() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
//
//     final phoneNumber = _signupmobileController.text;
//     final pin = _pinController.text;
//     final name = _signupnameController.text; // Assuming you have a name field
//     final password = _signupasswordController.text; // Assuming you have a password field
//     final email = _signupemailController.text; // Assuming you have an email field
//
//     final verifyPinUrl = Uri.parse(ApiUri.getEndpoint('/password/account/verify-pin'));
//     final signupUrl = Uri.parse(ApiUri.getEndpoint('/auth/signup/userSignup'));
//
//     try {
//       // Verify the PIN
//       final verifyResponse = await http.post(
//         verifyPinUrl,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'phoneNumber': phoneNumber, 'resetCode': pin}),
//       );
//
//
//
//       if (verifyResponse.statusCode == 200) {
//         // Check if the response is plain text
//         if (verifyResponse.headers['content-type']?.contains('text/plain') ?? false) {
//           final responseBody = verifyResponse.body.trim(); // Remove any extra whitespace
//
//           if (responseBody == 'PIN verified successfully') {
//             // Prepare user data for signup
//             final userData = {
//               'name': name,
//               'phoneNumber': phoneNumber,
//               'password': password,
//               'email': email,
//             };
//
//             final signupResponse = await http.post(
//               signupUrl,
//               headers: {'Content-Type': 'application/json'},
//               body: jsonEncode(userData),
//             );
//
//             print('Signup Response status: ${signupResponse.statusCode}');
//             print('Signup Response body: ${signupResponse.body}'); // Log the raw response
//
//             if (signupResponse.statusCode == 201 || signupResponse.statusCode == 200  ) { // Assuming 201 Created status code
//               _showDialog('Account created successfully.');
//               Navigator.of(context).pushReplacementNamed('/');
//             } else {
//               if (signupResponse.headers['content-type']?.contains('application/json') ?? false) {
//                 try {
//                   final signupResponseBody = jsonDecode(signupResponse.body);
//                   _showErrorDialog(signupResponseBody['message'] ?? 'Failed to create account.');
//                 } catch (e) {
//                   _showErrorDialog('Error parsing signup response: $e');
//                 }
//               } else {
//                 _showErrorDialog('Unexpected signup response format: ${signupResponse.body}');
//               }
//             }
//           } else {
//             _showErrorDialog('Invalid PIN verification response: $responseBody');
//           }
//         } else {
//           _showErrorDialog('Unexpected verify response format: ${verifyResponse.body}');
//         }
//       } else {
//         if (verifyResponse.headers['content-type']?.contains('application/json') ?? false) {
//           try {
//             final responseBody = jsonDecode(verifyResponse.body);
//             _showErrorDialog(responseBody['message'] ?? 'Invalid PIN.');
//           } catch (e) {
//             _showErrorDialog('Error parsing verify response: $e');
//           }
//         } else {
//           _showErrorDialog('Unexpected verify response format: ${verifyResponse.body}');
//         }
//       }
//     } catch (e) {
//
//       _showErrorDialog('Exception occurred: $e');
//     }
//   }
//
//
//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text('Error'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//             },
//             child: Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text('Info'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//             },
//             child: Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Stack(children: [
//                 Container(
//
//                   child: Image.asset(
//                     'assets/logo/final_logo.jpg',
//                     fit: BoxFit.cover,
//                   ),
//
//
//                 ),
//                 Positioned(
//                   top:20.0, // Adjust the top position
//                   right: 16.0, // Adjust the right position
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => DriverLoginPage())
//                       );
//                     },
//                     child: Text('Driver Login',style: TextStyle(fontWeight: FontWeight.w800),),
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Colors.blue, backgroundColor: Colors.white, // Text color
//                       padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20.0),
//                       ),
//                     ),
//                   ),
//                 ),
//               ]),
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     showLoginForm = false; // Show signup form when clicked
//                   });
//                 },
//                 child: Container(
//                   padding: EdgeInsets.only(left: 10),
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       "Click to create new account",
//                       style: TextStyle(
//                         fontSize: showLoginForm ? 24 : 15,
//                         fontWeight:
//                             showLoginForm ? FontWeight.bold : FontWeight.normal,
//                         color: showLoginForm ? Colors.black : Colors.black45,
//                         decoration: showLoginForm
//                             ? TextDecoration.underline
//                             : TextDecoration.none,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     showLoginForm = true; // Show login form when clicked
//                   });
//                 },
//                 child: Container(
//                   padding: EdgeInsets.only(left: 10),
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       "Login to your account",
//                       style: TextStyle(
//                         fontSize: showLoginForm ? 15 : 24,
//                         fontWeight:
//                             showLoginForm ? FontWeight.normal : FontWeight.bold,
//                         color: showLoginForm ? Colors.black45 : Colors.black,
//                         decoration: showLoginForm
//                             ? TextDecoration.none
//                             : TextDecoration.underline,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 40),
//               if (!showLoginForm)
//                 Form(
//                   key: _formKey,
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 10),
//                     child: Column(
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Name',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black45,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             TextFormField(
//                               controller: _signupnameController,
//                               decoration: InputDecoration(
//                                 border: OutlineInputBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(10)),
//                                 ),
//                               ),
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter your Name';
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 20),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Phone Number',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black45,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             Row(
//                               children: [
//                                 SizedBox(
//                                   width: MediaQuery.of(context).size.width*0.6,
//                                   child: TextFormField(
//                                     controller: _signupmobileController,
//                                     decoration: InputDecoration(
//                                       border: OutlineInputBorder(
//                                         borderRadius:
//                                         BorderRadius.all(Radius.circular(10)),
//                                       ),
//                                     ),
//                                     keyboardType: TextInputType.phone,
//                                     validator: (value) {
//                                       if (value == null || value.isEmpty) {
//                                         return 'Please enter your phone number';
//                                       } else if (value.length != 8) {
//                                         return 'Phone number must be 8 digits long';
//                                       } else if (!RegExp(r'^\d{8}$').hasMatch(value)) {
//                                         return 'Phone number must be numeric';
//                                       }
//                                       return null;
//                                     },
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(left:8.0),
//                                   child: ElevatedButton(
//                                     onPressed: _sendPin,
//                                     child: Text('Send PIN'),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             TextFormField(
//                               controller: _pinController,
//                               decoration: InputDecoration(labelText: 'PIN'),
//                               keyboardType: TextInputType.number,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter the PIN';
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 20),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Email',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black45,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             TextFormField(
//                               controller: _signupemailController,
//                               decoration: InputDecoration(
//                                 border: OutlineInputBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(10)),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 20),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Password',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black45,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             TextFormField(
//                               controller: _signupasswordController,
//                               obscureText: true,
//                               decoration: InputDecoration(
//                                 border: OutlineInputBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(10)),
//                                 ),
//                               ),
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter a password';
//                                 }
//                                 if (value.length < 6) {
//                                   return 'Password must be at least 6 characters long';
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 20),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Confirm Password',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black45,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             TextFormField(
//                               controller: _signupconfirmpasswordController,
//                               obscureText: true,
//                               decoration: InputDecoration(
//                                 border: OutlineInputBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(10)),
//                                 ),
//                               ),
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please confirm your password';
//                                 }
//                                 if (value != _signupasswordController.text) {
//                                   return 'Passwords do not match';
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 20),
//                         ElevatedButton(
//                           onPressed: _signup,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 Colors.blue, // Change button color here
//                             minimumSize:
//                                 Size(double.infinity, 50), // Increase button size
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(
//                                   10), // Change button radius here
//                             ),
//                           ),
//                           child: loading
//                               ? CircularProgressIndicator()
//                               : Text('Sign Up',
//                                   style: TextStyle(color: Colors.white)),
//                         ),
//                         SizedBox(height: 10),
//                       ],
//                     ),
//                   ),
//                 ),
//               if (showLoginForm)
//                 Form(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 10),
//                     child: Column(
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Phone Number',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black45,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             TextFormField(
//                               controller: _phoneNumberController,
//                               decoration: InputDecoration(
//                                 border: OutlineInputBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(10)),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 20),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Password',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black45,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             TextFormField(
//                               controller: _passwordController,
//                               obscureText: true,
//                               decoration: InputDecoration(
//                                 border: OutlineInputBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(10)),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => PasswordResetPage(),
//                                   ),
//                                 );
//                               },
//                               child: Text(
//                                 "Forget password",
//                                 style: TextStyle(
//                                   decoration: TextDecoration.underline,
//                                   decorationColor: Colors.blue,
//                                   fontSize: 16.0,
//                                   color: Colors.blue,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 20),
//                         ElevatedButton(
//                           onPressed: () {
//                             signIn();
//                           },
//                           style: ButtonStyle(
//                             backgroundColor:
//                                 WidgetStateProperty.all<Color>(Colors.blue),
//                             shape:
//                                 WidgetStateProperty.all<RoundedRectangleBorder>(
//                               RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                               ),
//                             ),
//                             minimumSize:
//                                 WidgetStateProperty.all<Size>(Size(200, 50)),
//                           ),
//                           child: Text('Log in',
//                               style:
//                                   TextStyle(color: Colors.white, fontSize: 18)),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
