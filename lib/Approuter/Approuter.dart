// import 'package:flutter/material.dart';
// import 'package:britebox_mobile/MainPage/HomePage.dart'; // Import your HomePage
//
// class AppRouterDelegate extends RouterDelegate<String>
//     with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
//   @override
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//
//   String? _currentRoute;
//
//   @override
//   String? get currentConfiguration => _currentRoute;
//
//   @override
//   Widget build(BuildContext context) {
//     return Navigator(
//       key: navigatorKey,
//       onPopPage: (route, result) {
//         return route.didPop(result);
//       },
//       pages: _generatePages(),
//     );
//   }
//
//   @override
//   Future<void> setNewRoutePath(String configuration) async {
//     _currentRoute = configuration;
//     notifyListeners();
//   }
//
//   List<Page<dynamic>> _generatePages() {
//     if (_currentRoute == '/home') {
//       return [
//         MaterialPage(
//           key: const ValueKey('HomePage'),
//           child: HomePage(child: HomePage(phoneNumber: ar),), // Adjust this based on your HomePage constructor
//         ),
//       ];
//     }
//     // Handle other routes as needed
//     return [];
//   }
// }
