class PhoneNumberManager {
  static String? phoneNumber;

  static void setphoneNumber(String newphoneNumber) {

    phoneNumber = newphoneNumber;
    print(phoneNumber);
  }

  static String getphoneNumber() {

    return phoneNumber ?? '';
  }
}