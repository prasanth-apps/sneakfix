class ShopModel {
  final int shopId;
  final String shopName;
  final String district;
  final String services;
  final String contact;

  ShopModel({
    required this.shopId,
    required this.shopName,
    required this.district,
    required this.services,
    required this.contact,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      shopId: int.parse(json['shop_id'].toString()),
      shopName: json['shop_name'],
      district: json['district'],
      services: json['services'] ?? "",
      contact: json['contact'] ?? "",
    );
  }
}