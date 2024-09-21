import 'dart:convert';
import 'package:Britebox/MainPage/product_display/products.dart';
import 'package:http/http.dart' as http;

import '../../AuthenticationPages/AppUri.dart';
import '../../AuthenticationPages/token_manager.dart';

Future<List<Product>> fetchProducts() async {
  print('Fetching products...');

  // Ensure the endpoint is parsed as a Uri
  Uri url = Uri.parse(ApiUri.getEndpoint('/product/display'));

  final response = await http.get(url, headers: {
    // Add any necessary headers, like authorization tokens
    'Authorization': 'Bearer ${TokenManager.getToken()}',
  });

  print("object");
  if (response.statusCode == 200) {
    print('Response status code: 200');
    final List<dynamic> jsonData = json.decode(response.body);

    List<Product> products = [];
    for (var item in jsonData) {
      try {
        String name = item['name'] ?? 'Unknown'; // Provide a default value for name
        double price = (item['price'] as num).toDouble(); // Convert to double
        int section = int.parse(item['section']?.toString() ?? '0'); // Convert to string and then to int

        products.add(Product(
          name: name,
          price: price,
          section: section,
          // Add other attributes as needed based on your Product class definition
        ));
      } catch (error) {
        print("Error parsing product: $error");
        // You can handle parsing errors here (optional)
      }
    }

    print('Parsed products: $products');
    return products;
  } else {
    print('Failed to load products. Status code: ${response.statusCode}');
    throw Exception('Failed to load products');
  }
}
