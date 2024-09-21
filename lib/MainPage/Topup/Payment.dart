class Amount {
  final int id;
  final String phoneNumber;
  final String totalAmountWithTax;
  final String Date;
  final String name;
  final String status;
  final String lockerSerialNumber;
  final String orderNumber;

  Amount({
    required this.orderNumber,
    required this.lockerSerialNumber,
    required this.id,
    required this.phoneNumber,
    required this.totalAmountWithTax,
    required this.Date,
    required this.status,
    required this.name,
  });

  factory Amount.fromJson(Map<String, dynamic> json) {
    return Amount(
      id: json['id']??-1,
      phoneNumber: json['phoneNumber'] ?? '',
      totalAmountWithTax: json['totalAmountWithTax'] ?? '0.0',
      Date: json['date'] ?? "",
      status: json['status'] ??"",
      name: json['customerName']?? "",
      lockerSerialNumber: json['lockerSerialNumber'],
      orderNumber: json['orderNumber']// Assuming it's a string
    );
  }
}
