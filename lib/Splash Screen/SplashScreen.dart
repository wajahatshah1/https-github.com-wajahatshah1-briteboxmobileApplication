import 'package:Britebox/MainPage/More/Colors.dart';
import 'package:Britebox/firebase/NotificationService.dart';
import 'package:flutter/material.dart';
import 'package:Britebox/firebase/firebase.dart';

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  NotificationService notificationService = NotificationService();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    notificationService.requestNotificationPermission();
    notificationService.getDeviceToken();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);

    // Set up the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Set up the fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if the controller is initialized and is animating
    if (_controller.isAnimating || _controller.value > 0) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Image.asset('assets/logo/Asset7.png'), // Replace with your logo path
                ),
              ),
              SizedBox(height: 70),
              FadeTransition(
                opacity: _fadeAnimation,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pushReplacementNamed(context, "/authentication");
                    GetServerKey getServerKey = GetServerKey();
                    String accessToken = await getServerKey.getServerKeyToken();
                    print(accessToken);
                  },
                  icon: Center(
                    child: Icon(
                      Icons.arrow_forward,
                      size: 50.0,  // Adjust the size as needed
                      color: Colors.white,  // Set the color for the icon
                    ),
                  ),
                   // You can remove this if you don't want any text
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: MyColorScheme.navyBlue,  // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),  // Adjust border radius for the button shape
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),  // Adjust padding
                  ), label: Text(""),
                )
                ,
              ),

            ],
          ),
        ),
      );
    } else {
      // Return an empty container if the controller is not yet initialized
      return Container();
    }
  }
}
