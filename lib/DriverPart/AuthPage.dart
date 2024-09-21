import 'dart:convert';



import 'package:Britebox/DriverPart/DriverMainPage/driverMainPage.dart';
import 'package:Britebox/MainPage/More/Colors.dart';
import 'package:Britebox/MainPage/QrCode/QrCode.dart';
import 'package:Britebox/Qr_scanner.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../AuthenticationPages/AppUri.dart';
import '../AuthenticationPages/ForgetPassword.dart';
import '../AuthenticationPages/NameManager.dart';
import '../AuthenticationPages/PhoneNumberManager.dart';
import '../AuthenticationPages/SignInData.dart';
import '../AuthenticationPages/token_manager.dart';
import '../MainPage/HomePage.dart';



class DriverLoginPage extends StatefulWidget {
  @override
  _DriverLoginPageState createState() => _DriverLoginPageState();
}

class _DriverLoginPageState extends State<DriverLoginPage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> signIn() async {
    print(_phoneNumberController.text);
    print(_passwordController.text);
    String url = ApiUri.getEndpoint(
        '/auth/driversignin');
    // Replace with your Spring Boot API URL
    SignInData signInData = SignInData(
      username: _phoneNumberController.text.trim()??'',
      password: _passwordController.text.trim()??'',
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
        var data = jsonDecode(response.body);
        print(data);
        // print(data["driverData"]);

        String token = data['token'];
        print(" i am  token$data['token']");

        // Assuming TokenManager.setToken(token) saves token securely
        TokenManager.setToken(token);
        String phoneNumber = data['phoneNumber'] ?? "user";
        PhoneNumberManager.setphoneNumber(phoneNumber);
        String name = data['name'] ?? "user";
        NameManager.setname(name);
        _phoneNumberController.clear();
        _passwordController.clear();
        // Example of navigating to HomeScreen with user data
        // Replace HomeScreen with your desired destination and pass user data accordingly
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QRCodeScannerPage(),
          ),
        );
      } else {
        // Handle other status codes (e.g., show error to user)
        print('Failed to sign in: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors
      print('Error during sign in: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Image.asset(
                    'assets/logo/Asset7.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20,),
                        SizedBox(child: Text("Driver Login",style: TextStyle(fontWeight: FontWeight.w800,fontSize: 20,color: MyColorScheme.navyBlue),),
                        ),
                        SizedBox(height: 20,),
                        Form(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Login Id',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black45,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    TextFormField(
                                      controller: _phoneNumberController,
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
                                      controller: _passwordController,
                                      obscureText: _obscureText,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(30)),

                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureText ? Icons.visibility : Icons.visibility_off,
                                            color: Colors.grey,
                                          ),
                                          onPressed: _togglePasswordVisibility,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 60),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // TextButton(
                                    //   onPressed: () {
                                    //     Navigator.push(
                                    //       context,
                                    //       MaterialPageRoute(
                                    //         builder: (context) => PasswordResetPage(),
                                    //       ),
                                    //     );
                                    //   },
                                    //   // child: Text(
                                    //   //   "Forget password",
                                    //   //   style: TextStyle(
                                    //   //     decoration: TextDecoration.underline,
                                    //   //     decorationColor: Colors.blue,
                                    //   //     fontSize: 16.0,
                                    //   //     color: Colors.blue,
                                    //   //   ),
                                    //   // ),
                                    // ),
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
