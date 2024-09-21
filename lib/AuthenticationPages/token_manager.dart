// token_manager.dart
class TokenManager {
  static String? token;

  static void setToken(String newToken) {

    token = newToken;
    print("token");
  }

  static String getToken() {
    print("object");
    return token ?? '';
  }
}
