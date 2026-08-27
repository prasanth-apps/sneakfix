class ServiceModel {
  final int serviceId;
  final String serviceName;
  final double price;

  ServiceModel({
    required this.serviceId,
    required this.serviceName,
    required this.price,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      serviceId: int.parse(json['service_id'].toString()),
      serviceName: json['service_name'],
      price: double.parse(json['price'].toString()),
    );
  }
}