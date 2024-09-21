import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppPage extends StatelessWidget {
  final String phoneNumber;

  WhatsAppPage({required this.phoneNumber});

  void _launchWhatsApp() async {
    final url = "https://wa.me/$phoneNumber"; // Use the phoneNumber variable
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _launchWhatsApp());

    return Scaffold(
      appBar: AppBar(
        title: Text('Opening WhatsApp'),
      ),
      body: Center(
        child: CircularProgressIndicator(), // Placeholder UI while WhatsApp is being opened
      ),
    );
  }
}
