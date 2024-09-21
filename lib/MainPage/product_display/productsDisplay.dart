import 'package:flutter/material.dart';
import 'package:Britebox/MainPage/product_display/products.dart';
import 'productFetch.dart';

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = false; // Flag to indicate data fetching state
  String _errorMessage = ""; // Stores any error message

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });
    try {
      List<Product> products = await fetchProducts();
      setState(() {
        _products = products;
        _isLoading = false; // Set loading state to false after successful fetch
        _errorMessage = ""; // Clear any previous error message
      });
    } catch (error) {
      setState(() {
        _isLoading = false; // Set loading state to false after error
        _errorMessage = "Error fetching products: $error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<int, String> sectionNames = {
      1: 'Britebox',
      2: 'Repairing',
      3: 'Alteration',
      // Add more sections as needed
    };

    Map<int, List<Product>> sections = {};

    // Organize products into sections
    _products.forEach((product) {
      if (!sections.containsKey(product.section)) {
        sections[product.section] = [];
      }
      sections[product.section]?.add(product);
    });

    final Color navyBlue = Color(0xFF003366); // Darker navy blue
    final Color sectionHeaderColor = Color(0xFFE0E0E0); // Light grey for section headers
    final Color tableBorderColor = Color(0xFFB0B0B0); // Lighter grey for table borders

    return Scaffold(
      appBar: AppBar(
        title: Text('Price List', style: TextStyle(color: Colors.white)),
        backgroundColor: navyBlue, // Darker navy blue app bar color
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // White arrow color
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Display progress indicator while loading
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red, fontSize: 16)))
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: sections.keys.map((sectionNumber) {
              final sectionProducts = sections[sectionNumber];
              final sectionName = sectionNames[sectionNumber];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),

                    child: Center(
                      child: Text(
                        sectionName ?? 'Section $sectionNumber',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: navyBlue,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: tableBorderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DataTable(

                      columns: [
                        DataColumn(
                          label: Text(
                            'Name',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Price',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                      rows: sectionProducts!.map((product) {
                        return DataRow(cells: <DataCell>[
                          DataCell(
                            Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              'BHD ${product.price.toString()}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 20), // Adjusted spacing
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
