import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../AuthenticationPages/PhoneNumberManager.dart';
import '../../AuthenticationPages/AppUri.dart';
import '../../AuthenticationPages/token_manager.dart';
import 'Payment.dart'; // Assuming Payment.dart contains the UnpaidAmount class

class TopupService {
  final String phoneNumber =PhoneNumberManager.getphoneNumber();





  Future<List<Amount>> fetchUnpaidAmounts() async {
    try {

      final response = await http.get(
        Uri.parse(ApiUri.getEndpoint('/bill/unpaidamounts/$phoneNumber')),
        headers: {'Authorization': 'Bearer ${TokenManager.getToken()}'},
      );



      if (response.statusCode == 200) {
        // Decode the response body into a list of dynamic objects
        final List<dynamic> responseBody = json.decode(response.body);


        // Convert the dynamic objects to UnpaidAmount objects
        final List<Amount> unpaidAmounts = responseBody.map((item) {
          // Assuming UnpaidAmount.fromJson() method to parse the JSON

          return Amount.fromJson(item);
        }).toList();


        return unpaidAmounts;
      } else if (response.statusCode == 404) {
        print('No unpaid amounts found for phone number: $phoneNumber');
        return []; // Return an empty list if not found
      } else {
        print('Failed to load unpaid amounts: ${response.statusCode}');
        throw Exception('Failed to load unpaid amounts: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Failed to fetch unpaid amounts: $e');
    }
  }
}
