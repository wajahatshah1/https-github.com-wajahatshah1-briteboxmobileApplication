import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../AuthenticationPages/AppUri.dart';
import 'History.dart';

Future<List<BillSummary>> fetchBills(String phoneNumber) async {
  final response = await http.get(Uri.parse(ApiUri.getEndpoint('/bill/byPhoneNumber/$phoneNumber')));

  if (response.statusCode == 200) {
    List<dynamic> jsonList = json.decode(response.body);
    print(jsonList);
    return jsonList.map((json) => BillSummary.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load bills');
  }
}
