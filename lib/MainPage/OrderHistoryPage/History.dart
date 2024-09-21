import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart'; // For date formatting

class BillSummary {
  final String orderNumber;
  final String date; // The formatted date as a string
  final double totalAmountWithTax;
  final String status;
  final Uint8List pdfBytes;

  BillSummary({
    required this.orderNumber,
    required this.date,
    required this.totalAmountWithTax,
    required this.status,
    required this.pdfBytes,
  });

  factory BillSummary.fromJson(Map<String, dynamic> json) {
    try {
      print('Raw JSON: $json'); // Debug output

      // Decode PDF bytes safely
      Uint8List pdfBytes;
      final base64Pdf = json['pdf'] ?? '';
      if (base64Pdf.isNotEmpty) {
        try {
          pdfBytes = base64Decode(base64Pdf);
        } catch (e) {
          print('Failed to decode PDF base64 string: $e');
          pdfBytes = Uint8List(0); // Default to empty if decoding fails
        }
      } else {
        pdfBytes = Uint8List(0); // Default to empty if base64 string is empty
      }

      // Parse the date field
      String dateString;
      if (json['depositTimestamp'] != null) {
        try {
          // Parse the ISO 8601 date string
          DateTime dateTime = DateTime.parse(json['depositTimestamp']);
          dateString = DateFormat('dd/MM/yyyy').format(dateTime); // Format to desired string format
        } catch (e) {
          print('Error parsing date: $e');
          dateString = '20/02/2034'; // Default date in case of error
        }
      } else {
        // Fallback default date if the field is null
        dateString = '20/02/2034';
      }

      return BillSummary(
        orderNumber: json['orderNumber'] ?? '',
        date: dateString, // Use the formatted date string
        totalAmountWithTax: double.tryParse(json['totalAmountWithTax']?.toString() ?? '0.0') ?? 0.0,
        status: json['paymentStatus'] ?? '', // Changed to 'status' to match the field name in the JSON
        pdfBytes: pdfBytes,
      );
    } catch (e) {
      print('Error parsing BillSummary: $e');
      // Handle parsing error by returning a default BillSummary
      return BillSummary(
        orderNumber: '',
        date: '20/02/2034', // Default date
        totalAmountWithTax: 0.0,
        status: '',
        pdfBytes: Uint8List(0),
      );
    }
  }
}
