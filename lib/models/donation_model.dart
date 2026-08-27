class DonationModel {
  final int donationId;
  final String title;
  final String description;
  final String image;
  final String status;

  final String size;
  final String district;
  final String pickupAddress;

  final String? donorName;
  final String? requesterName;
  final String? requestCode;

  DonationModel({
    required this.donationId,
    required this.title,
    required this.description,
    required this.image,
    required this.status,
    required this.size,
    required this.district,
    required this.pickupAddress,
    this.donorName,
    this.requesterName,
    this.requestCode,
  });

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      donationId: int.tryParse(json['donation_id'].toString()) ?? 0,
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      image: json['image'] ?? "",
      status: json['status'] ?? "",
      size: json['size'] ?? "",
      district: json['district'] ?? "",
      pickupAddress: json['pickup_address'] ?? "",
      donorName: json['donor_name'],
      requesterName: json['requester_name'],
      requestCode: json['request_code'],
    );
  }
}
