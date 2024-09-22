import 'dart:convert';
import 'dart:io';

import 'package:Britebox/AuthenticationPages/AppUri.dart';
import 'package:Britebox/AuthenticationPages/token_manager.dart';
import 'package:Britebox/MainPage/More/Colors.dart';
import 'package:Britebox/MainPage/QrCode/QrCode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:googleapis/apigeeregistry/v1.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class QRCodeScannerPage extends StatefulWidget {
  @override
  _QRCodeScannerPageState createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends State<QRCodeScannerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColorScheme.navyBlue,
        title: Text(
          'QR Code & Scanner',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false, // Disable the default back arrow
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp), // Back arrow
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context); // Navigate back when the button is pressed
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QrCodePage()
                    ),
                  );
                },
                child: Text('Locker QR', style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: MyColorScheme.navyBlue, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Adjust border radius
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 16.0), // Adjust padding
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderNumberScannerPage(),
                    ),
                  );
                },
                child: Text('Invoice to ready', style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: MyColorScheme.navyBlue, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Adjust border radius
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 16.0), // Adjust padding
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HeatSealScannerPage(),
                    ),
                  );
                },
                child: Text('HeatSeal Finder', style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: MyColorScheme.navyBlue, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Adjust border radius
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 16.0), // Adjust padding
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class OrderNumberScannerPage extends StatefulWidget {
  @override
  _OrderNumberScannerPageState createState() => _OrderNumberScannerPageState();
}

class _OrderNumberScannerPageState extends State<OrderNumberScannerPage> {
  String _error = '';
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String scannedOrderNumber = '';

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Number Scanner'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                scannedOrderNumber.isNotEmpty
                    ? 'Scanned Order Number: $scannedOrderNumber'
                    : 'Scan an order number',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        scannedOrderNumber = scanData.code ?? '';
      });
      controller.pauseCamera();
      _showOrderNumberDialog(scannedOrderNumber);
    });
  }
  Future<void> _updateCleaningFlag(String orderNumber) async {
    try {
      final response = await http.put(
        Uri.parse(ApiUri.getEndpoint('/bill/updateFlag/$orderNumber/cleaning')),
        headers: {
          'Authorization': 'Bearer ${await TokenManager.getToken()}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {

      } else {
        throw Exception('Failed to update Pick Up flag: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = 'Error updating Pick Up flag: $e';
      });
    }
  }


  void _showOrderNumberDialog(String orderNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order Number Scanned'),
        content: Text(orderNumber),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller?.resumeCamera();
            },
            child: Text('Scan Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateCleaningFlag(orderNumber);
              // Perform any action like updating order status or processing the order
            },
            child: Text('Process Order'),
          ),
        ],
      ),
    );
  }
  Future<void> _fetchAndNavigateToPDF(String heatSealNumber) async {
    try {
      final response = await http.get(Uri.parse(ApiUri.getEndpoint('/bill/$heatSealNumber')));

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final base64Pdf = jsonResponse['pdf'] as String;
        final pdfBytes = base64Decode(base64Pdf);

        final tempDir = await getTemporaryDirectory();
        final pdfFile = File('${tempDir.path}/heat_seal_$heatSealNumber.pdf');
        await pdfFile.writeAsBytes(pdfBytes); // Save decoded bytes

        // Dispose the scanner controller before navigating
        controller?.dispose();

        // Navigate to PDF view page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewPage(pdfFile: pdfFile),
          ),
        );
      } else {
        _showErrorDialog('Failed to fetch PDF. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog('An error occurred while fetching the PDF.');
    }
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}


class HeatSealScannerPage extends StatefulWidget {
  @override
  _HeatSealScannerPageState createState() => _HeatSealScannerPageState();
}

class _HeatSealScannerPageState extends State<HeatSealScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String scannedHeatSeal = '';

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Heat Seal Scanner'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                scannedHeatSeal.isNotEmpty
                    ? 'Scanned Heat Seal: $scannedHeatSeal'
                    : 'Scan a heat seal',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        scannedHeatSeal = scanData.code ?? '';
      });
      controller.pauseCamera(); // Stop scanning
      _showHeatSealDialog(scannedHeatSeal);
    });
  }

  void _showHeatSealDialog(String heatSeal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Heat Seal Scanned'),
        content: Text(heatSeal),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller?.resumeCamera(); // Resume scanning if needed
            },
            child: Text('Scan Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _fetchAndNavigateToPDF(heatSeal); // Fetch and view PDF
            },
            child: Text('View PDF'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchAndNavigateToPDF(String heatSealNumber) async {
    try {
      final response = await http.get(Uri.parse(ApiUri.getEndpoint('/bill/$heatSealNumber')));

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final base64Pdf = jsonResponse['pdf'] as String;
        final pdfBytes = base64Decode(base64Pdf);

        final tempDir = await getTemporaryDirectory();
        final pdfFile = File('${tempDir.path}/heat_seal_$heatSealNumber.pdf');
        await pdfFile.writeAsBytes(pdfBytes); // Save decoded bytes

        // Dispose the scanner controller before navigating
        controller?.dispose();

        // Navigate to PDF view page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewPage(pdfFile: pdfFile),
          ),
        );
      } else {
        _showErrorDialog('Failed to fetch PDF. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog('An error occurred while fetching the PDF.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
class PDFViewPage extends StatelessWidget {
  final File pdfFile;

  PDFViewPage({required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF View'),
      ),
      body: pdfFile.existsSync()
          ? PDFView(
        filePath: pdfFile.path,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: true,
        pageSnap: true,
        onRender: (_pages) {
          print('PDF rendered with $_pages pages');
        },
        onError: (error) {
          print('PDF view error: $error');
        },
        onPageError: (page, error) {
          print('Error on page $page: $error');
        },
      )
          : Center(child: Text('PDF file not found')),
    );
  }
}
