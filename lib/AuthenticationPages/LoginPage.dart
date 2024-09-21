import 'dart:convert';

import 'package:Britebox/AuthenticationPages/token_manager.dart';
import 'package:Britebox/MainPage/More/Colors.dart';
import 'package:Britebox/firebase/NotificationService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../DriverPart/AuthPage.dart';
import '../MainPage/HomePage.dart';
import 'AppUri.dart';
import 'NameManager.dart';
import 'PhoneNumberManager.dart';
import 'SignInData.dart';
import 'ForgetPassword.dart'; // Import your PasswordResetPage here

class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for signup form
  final _signupemailController = TextEditingController();
  final _signupnameController = TextEditingController();
  final _signupmobileController = TextEditingController();
  final _signupasswordController = TextEditingController();
  final _signupconfirmpasswordController = TextEditingController();

  // Controllers for login form
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();

  bool loading = false;
  bool showLoginForm =
      true; // Flag to toggle between showing login form and Sign Up content

  bool _obscureText = true;


// Call this function to save the username
  Future<void> _saveUsername(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneNumber', phoneNumber);
  }


  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  bool isLoading = false; // Loading state variable

  Future<void> _saveUserInfo(String phoneNumber, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneNumber', phoneNumber);
    await prefs.setString('paasword', password);
  }

  Future<void> signIn() async {
    if (isLoading) return; // Prevent multiple triggers

    setState(() {
      isLoading = true;
    });

    NotificationService notificationService = NotificationService();
    String url = ApiUri.getEndpoint('/auth/usersignin');
    SignInData signInData = SignInData(
      username: _phoneNumberController.text,
      password: _passwordController.text.trim(),
    );

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(signInData.toJson()),
      );

      if (response.statusCode == 200) {
        String userServiceToken = await notificationService.getDeviceToken() ?? 'default_value';

        var data = jsonDecode(response.body);
        String token = data['token'];
        String phoneNumber = data['phoneNumber'] ?? "user";
        String name = data['name'] ?? "user";

        TokenManager.setToken(token);
        PhoneNumberManager.setphoneNumber(phoneNumber);
        NameManager.setname(name);

        // Save phoneNumber and name after sign-in
        await _saveUserInfo(phoneNumber, name);

        await registerFcmToken(userServiceToken, phoneNumber);

        _phoneNumberController.clear();
        _passwordController.clear();

        Navigator.of(context).pushReplacementNamed('/homescreen');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Phone number or password is invalid"),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error during sign in: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> registerFcmToken(String deviceToken, String phoneNumber) async {
    String fcmUrl = ApiUri.getEndpoint('/fcm/registerToken'); // Spring Boot API URL for FCM token registration
    try {
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${TokenManager.getToken()}', // Pass the user's JWT token for authorization
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'fcmToken': deviceToken,
        }),
      );

      if (response.statusCode == 200) {
        print('FCM token registered successfully');
      } else {
        print('Failed to register FCM token: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors
      print('Error during FCM token registration: $e');
    }
  }

  void toggleView() {
    setState(() {
      showLoginForm = !showLoginForm;
    });
  }
  final TextEditingController _pinController = TextEditingController();

  Future<void> _sendPin() async {
    final phoneNumber = _signupmobileController.text.trim();
    final url = Uri.parse(ApiUri.getEndpoint('/password/account/send-pin'));

    if (phoneNumber.length != 8) {
      _showErrorDialog('Phone number must be 8 digits long.');
      return;
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phoneNumber}),
    );

    if (response.statusCode == 200) {
      _showDialog('PIN sent successfully.');
    } else if (response.statusCode == 400){
      _showErrorDialog('User already present');
    }
    else {
      final responseBody = jsonDecode(response.body);
      _showErrorDialog(responseBody['message'] ?? 'Failed to send PIN.');
    }
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phoneNumber = _signupmobileController.text.trim();
    final pin = _pinController.text .trim();
    final name = _signupnameController.text; // Assuming you have a name field
    final password = _signupasswordController.text.trim(); // Assuming you have a password field
    final email = _signupemailController.text.trim(); // Assuming you have an email field

    final verifyPinUrl = Uri.parse(ApiUri.getEndpoint('/password/account/verify-pin'));
    final signupUrl = Uri.parse(ApiUri.getEndpoint('/auth/signup/userSignup'));

    try {
      // Verify the PIN
      final verifyResponse = await http.post(
        verifyPinUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber, 'resetCode': pin}),
      );



      if (verifyResponse.statusCode == 200) {
        // Check if the response is plain text
        if (verifyResponse.headers['content-type']?.contains('text/plain') ?? false) {
          final responseBody = verifyResponse.body.trim(); // Remove any extra whitespace

          if (responseBody == 'PIN verified successfully') {

            print(password);

            // Prepare user data for signup
            final userData = {
              'name': name,
              'phoneNumber': phoneNumber,
              'password': password,
              'email': email,

            };

            final signupResponse = await http.post(
              signupUrl,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(userData),
            );

            print('Signup Response status: ${signupResponse.statusCode}');
            print('Signup Response body: ${signupResponse.body}'); // Log the raw response

            if (signupResponse.statusCode == 201 || signupResponse.statusCode == 200  ) { // Assuming 201 Created status code
              _showDialog('Account created successfully.');
              Navigator.of(context).pushReplacementNamed('/');
            } else {
              if (signupResponse.headers['content-type']?.contains('application/json') ?? false) {
                try {
                  final signupResponseBody = jsonDecode(signupResponse.body);
                  _showErrorDialog(signupResponseBody['message'] ?? 'Failed to create account.');
                } catch (e) {
                  _showErrorDialog('Error parsing signup response: $e');
                }
              } else {
                _showErrorDialog('Unexpected signup response format: ${signupResponse.body}');
              }
            }
          } else {
            _showErrorDialog('Invalid PIN verification response: $responseBody');
          }
        } else {
          _showErrorDialog('Unexpected verify response format: ${verifyResponse.body}');
        }
      } else {
        if (verifyResponse.headers['content-type']?.contains('application/json') ?? false) {
          try {
            final responseBody = jsonDecode(verifyResponse.body);
            _showErrorDialog(responseBody['message'] ?? 'Invalid PIN.');
          } catch (e) {
            _showErrorDialog('Error parsing verify response: $e');
          }
        } else {
          _showErrorDialog('Unexpected verify response format: ${verifyResponse.body}');
        }
      }
    } catch (e) {

      _showErrorDialog('Exception occurred: $e');
    }
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Info'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: Image.asset(
                    'assets/logo/Asset7.png',
                    fit: BoxFit.cover,
                  ),
                ),




                SizedBox(height: 60),
                if (!showLoginForm)
                  Text(
                    'Signup',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: MyColorScheme.navyBlue,
                      letterSpacing: 1.5,
                      fontFamily: 'Roboto',
                    ),
                  ),

                SizedBox(height: 40),

                if (!showLoginForm)

                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _signupnameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Name';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Phone Number',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width*0.6,
                                    child: TextFormField(
                                      controller: _signupmobileController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                        ),
                                      ),
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your phone number';
                                        } else if (value.length != 8) {
                                          return 'Phone number must be 8 digits long';
                                        } else if (!RegExp(r'^\d{8}$').hasMatch(value)) {
                                          return 'Phone number must be numeric';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left:8.0),
                                    child: ElevatedButton(
                                      onPressed: _sendPin,
                                      child: Text('Send PIN'),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: MyColorScheme.navyBlue, backgroundColor: Colors.white, // Text color
                                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30.0),
                                        ),



                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: _pinController,
                                decoration: InputDecoration(
                                  labelText: 'PIN',
                                  // Add borders
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide( width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide( width: 2.0),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the PIN';
                                  }
                                  return null;
                                },
                              )

                            ],
                          ),
                          SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _signupemailController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Password',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45,
                                  fontSize: 14,
                                ),

                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _signupasswordController,
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: IconButton(
                                      icon: Icon(
                                        _obscureText ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                      onPressed: _togglePasswordVisibility,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters long';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Confirm Password',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _signupconfirmpasswordController,
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: IconButton(
                                      icon: Icon(
                                        _obscureText ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                      onPressed: _toggleConfirmPasswordVisibility,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _signupasswordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _signup,
                            style:ButtonStyle(
                          backgroundColor:
                          WidgetStateProperty.all<Color>(MyColorScheme.navyBlue),
                      shape:
                      WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      minimumSize:
                      WidgetStateProperty.all<Size>(Size(200, 50)),
                    ),
                            child: loading
                                ? CircularProgressIndicator()
                                : Text('Sign Up',
                                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.w800)),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                if (showLoginForm)
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: MyColorScheme.navyBlue,
                      letterSpacing: 1.5,
                      fontFamily: 'Roboto',
                    ),
                  ),

                SizedBox(height: 40),
                if (showLoginForm)
                  Form(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Phone Number',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _phoneNumberController,
                                keyboardType: TextInputType.phone,


                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Password',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: IconButton(
                                      icon: Icon(
                                        _obscureText ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                      onPressed: _togglePasswordVisibility,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PasswordResetPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Forget password",
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    decorationColor: MyColorScheme.navyBlue,
                                    fontSize: 16.0,
                                    color: MyColorScheme.navyBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              signIn();
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(MyColorScheme.navyBlue),
                              shape:
                                  WidgetStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              minimumSize:
                                  WidgetStateProperty.all<Size>(Size(200, 50)),
                            ),
                            child: Text('Log in',
                                style:
                                    TextStyle(color: Colors.white, fontSize: 18,fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(
                  height: 40,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showLoginForm = !showLoginForm;
                      if (!showLoginForm) {
                        // Clear the login form fields when switching to signup
                        _phoneNumberController.clear();
                        _passwordController.clear();
                        _signupmobileController.clear();
                        _signupasswordController.clear();
                        _signupasswordController.clear();
                        _signupemailController.clear();
                        _signupnameController.clear();
                      }// Toggle between login and signup
                    });
                  },
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        showLoginForm
                            ? "Click to create a new account"
                            : "Click to sign in",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: MyColorScheme.navyBlue,
                          decoration: TextDecoration.underline,
                          decorationColor: MyColorScheme.navyBlue
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                if(showLoginForm)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DriverLoginPage())
                      );
                    },
                    child: Text('Driver Login',style: TextStyle(fontWeight: FontWeight.w800),),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: MyColorScheme.navyBlue, backgroundColor: Colors.white, // Text color
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),



    ))],
            ),
          ),
        ),
      ),
    );
  }
}
