// // Flutter code
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class Transaction {
//   final int id;
//   final double amount;
//   final bool paid;
//
//   Transaction({required this.id, required this.amount, required this.paid});
// }
//
// class TransactionListPage extends StatefulWidget {
//   @override
//   _TransactionListPageState createState() => _TransactionListPageState();
// }
//
// class _TransactionListPageState extends State<TransactionListPage> {
//   late List<Transaction> transactions = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchTransactions();
//   }
//
//   void fetchTransactions() async {
//     // Fetch transactions from backend
//     final response = await http.get(Uri.parse('http://192.168.10.201/'));
//     if (response.statusCode == 200) {
//       List<Transaction> fetchedTransactions = [];
//       final jsonData = json.decode(response.body);
//       for (var item in jsonData) {
//         fetchedTransactions.add(Transaction(
//           id: item['id'],
//           amount: item['amount'],
//           paid: item['paid'],
//         ));
//       }
//       setState(() {
//         transactions = fetchedTransactions;
//       });
//     } else {
//       throw Exception('Failed to load transactions');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Transaction List'),
//       ),
//       body: Column(
//         children: [
//           DropdownButton<String>(
//             items: <String>['All', 'Paid', 'Unpaid'].map((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//             onChanged: (String? value) {
//               setState(() {
//                 // Filter transactions based on dropdown selection
//                 if (value == 'Paid') {
//                   transactions = transactions.where((tx) => tx.paid).toList();
//                 } else if (value == 'Unpaid') {
//                   transactions = transactions.where((tx) => !tx.paid).toList();
//                 } else {
//                   fetchTransactions();
//                 }
//               });
//             },
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: transactions.length,
//               itemBuilder: (BuildContext context, int index) {
//                 return ListTile(
//                   title: Text('Transaction ${transactions[index].id}'),
//                   subtitle: Text('Amount: ${transactions[index].amount}'),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// void main() {
//   runApp(MaterialApp(
//     home: TransactionListPage(),
//   ));
// }
