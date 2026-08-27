class OrderModel {
  final int orderId;
  final String serviceName;
  final String status;

  final String? shopName;
  final String? customerName;
  final String? pickupDate;

  final String? pickupAddress;
  final String? landmark;
  final String? phone;

  OrderModel({
    required this.orderId,
    required this.serviceName,
    required this.status,
    this.shopName,
    this.customerName,
    this.pickupDate,
    this.pickupAddress,
    this.landmark,
    this.phone,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: int.parse(json['order_id'].toString()),
      serviceName: json['service_name'] ?? "",
      status: json['status'] ?? "",
      shopName: json['shop_name'],
      customerName: json['customer_name'],
      pickupDate: json['pickup_date'],
      pickupAddress: json['pickup_address'],
      landmark: json['landmark'],
      phone: json['phone'],
    );
  }
}
