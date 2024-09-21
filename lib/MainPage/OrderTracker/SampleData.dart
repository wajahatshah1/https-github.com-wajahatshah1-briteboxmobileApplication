import 'dart:convert';
import 'package:http/http.dart' as http;


import '../../AuthenticationPages/AppUri.dart';

import '../../AuthenticationPages/PhoneNumberManager.dart';
import 'OrderStatus.dart';

Future<List<OrderDetails>> fetchOrders(String phoneNumber) async {
  final response = await http.get(Uri.parse(ApiUri.getEndpoint('/bill/timeline?phoneNumber=${PhoneNumberManager.getphoneNumber()}')));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    print(jsonResponse);
    return jsonResponse.map((order) => OrderDetails.fromJson(order)).toList();
  } else {

    print(Exception());
    throw Exception('Failed to load orders');
  }
}
