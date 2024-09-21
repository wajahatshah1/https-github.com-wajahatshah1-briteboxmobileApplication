import 'package:flutter/material.dart';

class LaundryServiceScreen extends StatefulWidget {
  @override
  _LaundryServiceScreenState createState() => _LaundryServiceScreenState();
}

class _LaundryServiceScreenState extends State<LaundryServiceScreen> {
  final Map<String, double> prices = {
    'T-shirt (Washing)': 5.0,
    'T-shirt (Ironing)': 3.0,
    'Shirt (Washing)': 7.0,
    'Shirt (Ironing)': 4.0,
    'Trouser (Washing)': 6.0,
    'Trouser (Ironing)': 4.0,
    'Suit (Dry Wash)': 12.0,
    'Dress (Dry Wash)': 10.0,
  };

  final Map<String, int> cart = {};

  double get totalPrice {
    double total = 0.0;
    cart.forEach((key, value) {
      total += prices[key]! * value;
    });
    return total;
  }

  void addToCart(String item) {
    setState(() {
      if (cart.containsKey(item)) {
        cart[item] = cart[item]! + 1;
      } else {
        cart[item] = 1;
      }
    });
  }

  void generateBill() {
    print('Generating Bill...');
    print('Cart: $cart');
    if (cart.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Bill'),
            content: SingleChildScrollView(
              child: ListBody(
                children: cart.keys.map((item) {
                  return Text('$item: ${cart[item]} x \BHD${prices[item]}');
                }).toList()
                  ..add(Text('\nTotal: \BHD ${totalPrice.toStringAsFixed(2)}')),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Proceed Payment'),
                onPressed: () {
                  // Implement payment logic here
                  // For simplicity, we're just navigating to the payment screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PaymentScreen(totalPrice: totalPrice)),
                  );
                },
              ),
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      print('Cart is empty.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            children: prices.keys.map((item) {
              int itemCount = cart[item] ?? 0; // Get the count of the item in the cart
              return ListTile(
                title: Text('$item (\BHD ${prices[item]})'),
                subtitle: itemCount > 0 ? Text('Count: $itemCount') : null,
                trailing: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    addToCart(item);
                  },
                ),
              );
            }).toList(),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height*0.6,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: generateBill,
              child: Icon(Icons.pedal_bike_sharp),
            ),
          ),
        ],
      ),
    );
  }



}

class PaymentScreen extends StatelessWidget {
  final double totalPrice;

  PaymentScreen({required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total Amount: \BHD ${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Implement payment processing logic
                // For demonstration, we'll just navigate back to the home page
                LaundryServiceScreen();
              },
              child: Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}
