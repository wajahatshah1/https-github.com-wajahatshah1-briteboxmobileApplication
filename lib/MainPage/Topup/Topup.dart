import 'package:Britebox/AuthenticationPages/AppUri.dart';
import 'package:Britebox/AuthenticationPages/PhoneNumberManager.dart';
import 'package:Britebox/AuthenticationPages/token_manager.dart';
import 'package:Britebox/MainPage/More/Colors.dart';
import 'package:Britebox/MainPage/Topup/Payment.dart';
import 'package:Britebox/MainPage/Topup/PaymentWebView.dart';
import 'package:Britebox/MainPage/Topup/TopupService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Future<List<Amount>> futurePayment;
  final String phoneNumber = PhoneNumberManager.getphoneNumber();
  final Color navyBlue = MyColorScheme.navyBlue; // Navy blue color
  final Color lowContrastColor = Colors.white; // Color with lower contrast

  @override
  void initState() {
    super.initState();
    if (phoneNumber.isNotEmpty) {
      futurePayment =
      TopupService().fetchUnpaidAmounts() as Future<List<Amount>>;
    } else {
      futurePayment = Future.error('Phone number is empty');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Bills",
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,

            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp),
          // Cross icon instead of back arrow
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context); // Navigate back when the button is pressed
          },
        ),

        backgroundColor: navyBlue,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: FutureBuilder<List<Amount>>(
          future: futurePayment,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No unpaid amounts found.'));
            } else {
              List<Amount> payments = snapshot.data!;
              return ListView.builder(
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  Amount unpaidAmount = payments[index];

                  // Parse the date and format it
                  final DateTime date = DateTime.parse(unpaidAmount.Date);
                  final String formattedDate = DateFormat('dd/MM/yyyy').format(
                      date);

                  return Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.01),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            15), // Rounded corners
                      ),
                      elevation: 8, // Add elevation for shadow
                      color: lowContrastColor,
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order ID: ${unpaidAmount.orderNumber}',
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.043,
                                  color: navyBlue,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              'Amount: ${unpaidAmount.totalAmountWithTax}',
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              'Date: $formattedDate',
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  _proceedToPayment(unpaidAmount);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: navyBlue, // Button color
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.05,
                                    vertical: screenHeight * 0.018,
                                  ),
                                  textStyle: GoogleFonts.lato(
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: Text('Pay Now', style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800),),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  void _proceedToPayment(Amount unpaidAmount) async {
    print('Proceeding to payment with amount: ${unpaidAmount.totalAmountWithTax}');
    print('phone Number:${unpaidAmount.name}');

    try {
      double amount = double.parse(unpaidAmount.totalAmountWithTax);

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Processing payment, please wait...'),
                ],
              ),
            ),
          );
        },
      );

      final response = await http.post(
        Uri.parse(ApiUri.getEndpoint('/payment/charge')),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await TokenManager.getToken()}',
        },
        body: jsonEncode({
          'amount': amount,
          'orderNumber': unpaidAmount.orderNumber,
          'phoneNumber': unpaidAmount.phoneNumber,
          'firstName': unpaidAmount.name,
        }),

      );

      Navigator.of(context).pop(); // Dismiss loading indicator

      if (response.statusCode == 200) {
        final paymentUrl = response.body;

        if (paymentUrl.isNotEmpty) {
          final redirectUrl = ApiUri.getEndpoint('/homescreen');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  WebViewPage(
                    url: paymentUrl,
                    redirectUrl: redirectUrl,
                  ),
            ),
          );
        } else {
          _showError('Payment URL not provided');
        }
      } else {
        _showError('Failed to initiate payment');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss loading indicator
      _showError('Failed to initiate payment');
    }
  }


// Helper method to show error messages
  void _showError(String message) {
    print(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


}
