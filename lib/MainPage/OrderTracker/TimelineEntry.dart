import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../AuthenticationPages/PhoneNumberManager.dart';
import 'OrderStatus.dart';
import 'SampleData.dart';

class OrderDetailsPage extends StatelessWidget {
  final Color navyBlue = Color(0xFF3a679e); // Navy blue color
  final Color highContrastColor = Colors.black; // Color with higher contrast
  final Color lowContrastColor = Colors.white; // Color with lower contrast

  @override
  Widget build(BuildContext context) {
    // Get screen width
    final screenWidth = MediaQuery.of(context).size.width;
    // Define responsive font sizes
    final double headingFontSize = screenWidth * 0.046; // 5% of screen width
    final double subHeadingFontSize = screenWidth * 0.042; // 4% of screen width
    final double bodyFontSize = screenWidth * 0.04; // 3.5% of screen width

    return Scaffold(
      backgroundColor: Colors.grey[200], // Soft background color for better contrast
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: headingFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: navyBlue, // Navy blue AppBar color
        automaticallyImplyLeading: false, // Disable the default back arrow
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp), // Cross icon instead of back arrow
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context); // Navigate back when the button is pressed
          },
        ),
      ),
      body: FutureBuilder<List<OrderDetails>>(
        future: fetchOrders(PhoneNumberManager.getphoneNumber()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No orders found'));
          } else {
            // Filter and sort orders based on picked status and date
            final List<OrderDetails> filteredOrders = snapshot.data!.where((order) {
              if (order.customerPickup == true) {
                final pickedDate = DateTime.parse(order.depositTimestamp!);
                final now = DateTime.now();
                return now.difference(pickedDate).inDays <= 1;
              }
              return true;
            }).toList();

            // Sort orders with the most recent orders at the top
            filteredOrders.sort((a, b) {
              return DateTime.parse(b.depositTimestamp!).compareTo(DateTime.parse(a.depositTimestamp!));
            });

            if (filteredOrders.isEmpty) {
              return Center(child: Text('No orders found'));
            }

            return ListView.builder(
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final orderDetails = filteredOrders[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded corners
                    ),
                    elevation: 8, // Add elevation for a shadow effect
                    color: lowContrastColor, // Card background color
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.0,top: 20,bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Text(
                              'Order ID: ${orderDetails.orderId}',
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                  color: navyBlue,
                                  fontSize: headingFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildOrderTimeline(orderDetails, context),
                          SizedBox(height: 30),
                          _buildOrderDetailsSection(orderDetails, bodyFontSize, subHeadingFontSize),
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
    );
  }

  Widget _buildOrderDetailsSection(OrderDetails orderDetails, double bodyFontSize, double subHeadingFontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Order Date: ',
              style: GoogleFonts.lato(
                fontSize: bodyFontSize,
                fontWeight: FontWeight.w800,
                color: Colors.grey,
              ),
            ),
            Text(
              ' ${DateFormat('yMMMd').format(DateTime.parse(orderDetails.depositTimestamp!))}',
              style: GoogleFonts.lato(
                fontSize: bodyFontSize,
                fontWeight: FontWeight.w600,
                color: navyBlue,
              ),
            )
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Payment Status: ',
              style: GoogleFonts.lato(
                fontSize: bodyFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            Text(
              '${orderDetails.paymentStatus}',
              style: GoogleFonts.lato(
                fontSize: bodyFontSize,
                color: _getPaymentStatusColor(orderDetails.paymentStatus),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order Status:",
              style: GoogleFonts.lato(
                fontSize: subHeadingFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            SizedBox(width: 10),
            SizedBox(
              width: 500,
              child: TextField(
                controller: TextEditingController(
                  text: _getCurrentStatus(orderDetails),
                ),
                readOnly: true, // Make it read-only
                style: GoogleFonts.lato(fontSize: bodyFontSize, color: navyBlue),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Text('Member Id: ', style: GoogleFonts.lato(fontSize: bodyFontSize, color: Colors.grey)),
            Text(' ${orderDetails.memberId}', style: GoogleFonts.lato(fontSize: bodyFontSize, color: navyBlue)),
          ],
        ),
        Row(
          children: [
            Text('Name: ', style: GoogleFonts.lato(fontSize: bodyFontSize, color: Colors.grey)),
            Text(' ${orderDetails.customerName}', style: GoogleFonts.lato(fontSize: bodyFontSize, color: navyBlue)),
          ],
        ),
        Row(
          children: [
            Text('Phone Number: ', style: GoogleFonts.lato(fontSize: bodyFontSize, color: Colors.grey)),
            Text(' ${orderDetails.phoneNumber}', style: GoogleFonts.lato(fontSize: bodyFontSize, color: navyBlue)),
          ],
        ),
      ],
    );
  }

  // Helper function to determine color based on payment status
  Color _getPaymentStatusColor(String paymentStatus) {
    switch (paymentStatus) {
      case 'paid':
        return Colors.green;
      case 'marked':
        return Colors.blue;
      default:
        return Colors.red;
    }
  }

  String _getCurrentStatus(OrderDetails orderDetails) {
    if (orderDetails.customerPickup) return "Order has been picked";
    if (orderDetails.driverDrop) return 'Order has been in locker';
    if (orderDetails.customerDropoff) return 'Order has been dropped';
    if (orderDetails.driverPickup) return 'Order is picked up by driver';
    if (orderDetails.pickedFromWarehouse) return 'Order is ready in warehouse';
    if (orderDetails.readyClothes) return 'Order is cleaned and ready';
    if (orderDetails.cleaningClothes) return 'Order is being cleaned';
    if (orderDetails.billCreated) return 'Your bill is created';
    return 'Order status not available';
  }

  Widget _buildOrderTimeline(OrderDetails orderDetails, BuildContext context) {
    bool isPickedFromLocker = orderDetails.customerDropoff || orderDetails.driverPickup;
    bool isProcessing = (orderDetails.billCreated || orderDetails.cleaningClothes ||
        orderDetails.readyClothes || orderDetails.pickedFromWarehouse) &&
        !orderDetails.driverDrop && !orderDetails.customerDropoff;
    bool isArrivedInLocker = orderDetails.driverDrop;

    return Container(
      constraints: const BoxConstraints(maxHeight: 240), // Adjust height as needed
      color: Colors.white,
      child: Column(
        children: <Widget>[
          _buildTimelineTile(
            isActive: isPickedFromLocker,
            isCompleted: isPickedFromLocker || isProcessing || isArrivedInLocker,
            text: 'Picked From Locker',
          ),
          _buildTimelineTile(
            isActive: isProcessing,
            isCompleted: isProcessing || isArrivedInLocker,
            text: 'Processing',
          ),
          _buildTimelineTile(
            isActive: isArrivedInLocker,
            isCompleted: isArrivedInLocker,
            isLast: true,
            text: 'Arrived in Locker',
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTile({
    required String text,
    required bool isActive,
    required bool isCompleted,
    bool isLast = false,
  }) {
    return Container(
      height: 60, // Control the height to adjust the line length
      child: TimelineTile(
        axis: TimelineAxis.vertical,
        alignment: TimelineAlign.start,
        lineXY: 0.2, // Adjust to control the line's position
        isLast: isLast,
        indicatorStyle: IndicatorStyle(
          width: 30,
          height: 30, // Keep the indicator size consistent
          color: isCompleted ? navyBlue : (isActive ? Colors.blueAccent : Colors.grey),
          iconStyle: IconStyle(
            color: Colors.white,
            iconData: isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          ),
        ),
        beforeLineStyle: LineStyle(
          color: isCompleted ? navyBlue : Colors.grey,
          thickness: 4,
        ),
        afterLineStyle: LineStyle(
          color: isLast ? Colors.transparent : (isCompleted ? navyBlue : Colors.grey),
          thickness: 4,
        ),
        endChild: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 18),
          child: Text(
            text,
            textAlign: TextAlign.start,
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: navyBlue,
            ),
          ),
        ),
      ),
    );
  }

}
