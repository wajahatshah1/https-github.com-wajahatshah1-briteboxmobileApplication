import 'package:Britebox/AuthenticationPages/AppUri.dart';
import 'package:Britebox/AuthenticationPages/PhoneNumberManager.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart'; // Import the uuid package
import 'package:http/http.dart' as http; // Import http package
import 'dart:convert';

class QrCodePage extends StatefulWidget {
  @override
  _QrCodePageState createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  final Color navyBlue = Color(0xFF3a679e);
  String _qrData = '';
  String _token = '';

  @override
  void initState() {
    super.initState();
    // Generate the token and QR data when the widget is initialized
    _token = _generateRandomToken();
    _qrData = _generateQrData();
    _sendTokenToBackend(_token); // Send token to the backend
    print('QR Data: $_qrData');
  }

  // Method to generate a random token
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
  Future<void> _sendTokenToBackend(String token) async {
    final phoneNumber = PhoneNumberManager.getphoneNumber(); // Get the phone number
    final url = ApiUri.getEndpoint('/auth/tokens/$phoneNumber'); // Replace with your Spring Boot backend URL

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'qrToken': token,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Generator', style: TextStyle(color: Colors.white)),
        backgroundColor: navyBlue,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_qrData.isNotEmpty)
                Column(
                  children: [
                    Text(
                      'Scan the QR Code:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: QrImageView(
                        data: _qrData,
                        version: QrVersions.auto,
                        size: MediaQuery.of(context).size.width * 0.8,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  'QR Data not available',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
