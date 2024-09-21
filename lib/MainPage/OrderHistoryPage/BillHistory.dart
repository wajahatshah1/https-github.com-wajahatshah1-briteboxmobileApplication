import 'dart:io';
import 'dart:typed_data'; // For typed data
import 'package:Britebox/MainPage/More/Colors.dart';
import 'package:Britebox/MainPage/OrderHistoryPage/pdfViewPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart'; // For getting the directory
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

import '../../AuthenticationPages/PhoneNumberManager.dart';
import 'BillHistoryFetch.dart';
import 'History.dart';

void main() {
  runApp(MaterialApp(
    home: HistoryPage(),
  ));
}

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<BillSummary>> futureBills;

  final String phoneNumber = PhoneNumberManager.getphoneNumber();
  String filter = 'all';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    futureBills = fetchBills(phoneNumber);
  }

  Future<void> viewPDF(Uint8List pdfBytes, BuildContext context) async {
    try {
      if (pdfBytes.isEmpty) {
        throw Exception('PDF data is empty');
      }

      // Ensure permissions are granted
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission is not granted');
      }

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/temp_bill.pdf');

      await file.writeAsBytes(pdfBytes);
      print('PDF saved to: ${file.path}');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewPage(filePath: file.path),
        ),
      );
    } catch (e) {
      print(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error viewing PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bill History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            _buildSearchAndFilterSection(),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<BillSummary>>(
                future: futureBills,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No bills available'));
                  } else {
                    return _buildBillDataTable(snapshot.data!);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search by Order Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: filter,
            isDense: true,
            decoration: InputDecoration(
              labelText: 'Filter',
              border: OutlineInputBorder(),
            ),
            onChanged: (String? newValue) {
              setState(() {
                filter = newValue!;
              });
            },
            items: <String>['all', 'paid', 'unpaid']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            itemHeight: 48,
          ),
        ),
      ],
    );
  }

  Widget _buildBillDataTable(List<BillSummary> bills) {
    // Apply search and filter
    List<BillSummary> filteredBills = bills;
    if (filter != 'all') {
      filteredBills = filteredBills.where((bill) => bill.status == filter).toList();
    }
    if (searchQuery.isNotEmpty) {
      filteredBills = filteredBills
          .where((bill) => bill.orderNumber.toLowerCase().contains(searchQuery))
          .toList();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: [
          DataColumn(label: Text('Order Number', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('View PDF', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: filteredBills.map((bill) {
          String formattedDate;
          try {
            // Try to parse the date string into a DateTime object
            final DateTime date = DateFormat('dd/MM/yyyy').parse(bill.date);
            formattedDate = DateFormat('dd/MM/yyyy').format(date);
          } catch (e) {
            print('Error formatting date: $e');
            formattedDate = bill.date; // Use original string if formatting fails
          }

          return DataRow(cells: [
            DataCell(Text(bill.orderNumber)),
            DataCell(Text('${bill.totalAmountWithTax}')),
            DataCell(Text(formattedDate)),
            DataCell(IconButton(
              icon: Icon(Icons.picture_as_pdf, color: MyColorScheme.navyBlue),
              onPressed: () {
                if (bill.pdfBytes.isNotEmpty) {
                  viewPDF(bill.pdfBytes, context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('PDF not available')),
                  );
                }
              },
            )),
          ]);
        }).toList(),
      ),
    );
  }
}
