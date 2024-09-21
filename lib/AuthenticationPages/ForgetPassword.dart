import 'dart:convert';

import 'package:Britebox/MainPage/More/Colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'AppUri.dart';
import 'LoginPage.dart';

class PasswordResetPage extends StatefulWidget {
  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController resetCodeController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  Future<void> resetPassword() async {
    String newPassword = newPasswordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String phoneNumber = phoneNumberController.text.trim();

    if (newPassword.isNotEmpty && confirmPassword.isNotEmpty) {
      if (newPassword == confirmPassword) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(child: CircularProgressIndicator()),
        );

        try {
          final response = await http.put(
            Uri.parse(ApiUri.getEndpoint('/password/reset')),
            body: jsonEncode({
              'phoneNumber': phoneNumber,
              'newPassword': newPassword
            }),
            headers: {'Content-Type': 'application/json'},
          );

          Navigator.of(context).pop(); // Remove loading indicator

          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Password reset successful')),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AuthenticationPage()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to reset password. Please try again.')),
            );
          }
        } catch (e) {
          Navigator.of(context).pop(); // Remove loading indicator if error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Network error. Please try again.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Passwords do not match')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter new password and confirm password')),
      );
    }
  }

  Future<void> sendResetCode() async {
    String phoneNumber = phoneNumberController.text.trim();

    if (phoneNumber.isNotEmpty && phoneNumber.length == 8) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      try {
        final response = await http.post(
          Uri.parse(ApiUri.getEndpoint('/password/forgot')),
          body: jsonEncode({'phoneNumber': phoneNumber}),
          headers: {'Content-Type': 'application/json'},
        );

        Navigator.of(context).pop(); // Remove loading indicator

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reset code sent successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send reset code. Please try again.')),
          );
        }
      } catch (e) {
        Navigator.of(context).pop(); // Remove loading indicator if error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid phone number')),
      );
    }
  }

  Future<void> verifyResetCode() async {
    String phoneNumber = phoneNumberController.text.trim();
    String resetCode = resetCodeController.text.trim();

    if (phoneNumber.isNotEmpty && resetCode.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      try {
        final response = await http.post(
          Uri.parse(ApiUri.getEndpoint('/password/verify-reset-code')),
          body: jsonEncode({
            'phoneNumber': phoneNumber,
            'resetCode': resetCode
          }),
          headers: {'Content-Type': 'application/json'},
        );

        Navigator.of(context).pop(); // Remove loading indicator

        if (response.statusCode == 200) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Create New Password"),
                actions: [
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text('Enter new password:'),
                        TextField(
                          controller: newPasswordController,
                          decoration: InputDecoration(
                            hintText: 'New password',
                          ),
                          obscureText: true,
                        ),
                        SizedBox(height: 20.0),
                        Text('Confirm new password:'),
                        TextField(
                          controller: confirmPasswordController,
                          decoration: InputDecoration(
                            hintText: 'Confirm new password',
                          ),
                          obscureText: true,
                        ),
                        SizedBox(height: 20.0),
                        ElevatedButton(
                          onPressed: resetPassword,
                          child: Text('Reset Password'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: MyColorScheme.navyBlue, backgroundColor: Colors.white, // Text color
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid reset code')),
          );
        }
      } catch (e) {
        Navigator.of(context).pop(); // Remove loading indicator if error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter phone number and reset code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Reset'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: phoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Column(
                    children: [
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: sendResetCode,
                        child: Text('Send Code'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: MyColorScheme.navyBlue, backgroundColor: Colors.white, // Text color
                          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: resetCodeController,
                decoration: InputDecoration(
                  labelText: 'Reset Code',
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: verifyResetCode,
                child: Text('Verify Reset Code'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: MyColorScheme.navyBlue, backgroundColor: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
