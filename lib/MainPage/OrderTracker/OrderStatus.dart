class OrderDetails {
  final String? orderId;
  final String? memberId;
  final String? depositTimestamp;
  final String? customerName;
  final String? phoneNumber;
  final String paymentStatus;

  // Flags for order tracking
  final String? driverDropTimestamp;
  final bool customerDropoff;
  final bool driverPickup;
  final bool cleaningClothes;
  final bool readyClothes;
  final bool pickedFromWarehouse;
  final bool driverDrop;
  final bool customerPickup;
  final bool overduePickup;
  final bool showBills;
  final bool billCreated;

  OrderDetails({
    this.orderId,

    this.memberId,
    this.depositTimestamp,
    this.customerName,
    this.phoneNumber,
     required this.paymentStatus,
     this.driverDropTimestamp,
    required this.customerDropoff,
    required this.driverPickup,
    required this.cleaningClothes,
    required this.readyClothes,
    required this.pickedFromWarehouse,
    required this.driverDrop,
    required this.customerPickup,
    required this.overduePickup,
    required this.showBills,
    required this.billCreated,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      orderId: json['orderNumber'] ?? "unknown",


      memberId: json['memberId'].toString() ?? "unknown",
      depositTimestamp: json['depositTimestamp']?.toString(),
      customerName: json['customerName']?? "unknown",
      phoneNumber: json['phoneNumber']?? "unknown",
      driverDropTimestamp: json['driverDropTimestamp']?.toString()?? "unknown",
      paymentStatus: json['paymentStatus']?? "unknown",
      customerDropoff: json['customerDropoff'] ?? true,
      driverPickup: json['driverPickup'] ?? false,
      cleaningClothes: json['cleaningClothes'] ?? false,
      readyClothes: json['readyClothes'] ?? false,
      pickedFromWarehouse: json['pickedFromWarehouse'] ?? false,
      driverDrop: json['driverDrop'] ?? false,
      customerPickup: json['customerPickup'] ?? false,
      overduePickup: json['overduePickup'] ?? false,
      showBills: json['showBills'] ?? false,
      billCreated: json['billCreated'] ?? false,
    );
  }
}
