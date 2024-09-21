// api_config.dart
//Britebox backend api
//163.172.91.5:8080/briterbox
class ApiUri {
  //static const String baseUrl = 'https://briteboxlaundry.com:8443/mybritebox';
  //static const String baseUrl = 'http://localhost:8080';
  static const String baseUrl = 'http://192.168.10.201:8080';
  static String getEndpoint(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
// topup written complete url
// homepage complete url