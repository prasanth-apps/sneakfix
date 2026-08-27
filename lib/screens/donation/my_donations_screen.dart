import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/donation_model.dart';
import '../../services/donation_service.dart';
import '../../core/api_config.dart';

class MyDonationsScreen extends StatefulWidget {
  const MyDonationsScreen({Key? key}) : super(key: key);

  @override
  State<MyDonationsScreen> createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends State<MyDonationsScreen> {
  List<DonationModel> donations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMyDonations();
  }

  Future<void> loadMyDonations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt("id") ?? 0;

    List<DonationModel> fetched = await DonationService.getMyDonations(userId);

    if (!mounted) return;

    setState(() {
      donations = fetched;
      isLoading = false;
    });
  }

  /// STATUS COLOR
  Color getStatusColor(String status) {
    switch (status) {
      case "Available":
        return Colors.green;
      case "Requested":
        return Colors.orange;
      case "Approved":
        return Colors.blue;
      case "Collected":
        return Colors.purple;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget statusBadge(String status) {
    Color color = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// ACCEPT REQUEST
  Future<void> acceptRequest(String requestCode) async {
    bool success = await DonationService.updateRequestStatus(
      requestCode,
      "Approved",
    );

    if (success) {
      loadMyDonations();
    }
  }

  /// REJECT REQUEST
  Future<void> rejectRequest(String requestCode) async {
    bool success = await DonationService.updateRequestStatus(
      requestCode,
      "Cancelled",
    );

    if (success) {
      loadMyDonations();
    }
  }

  /// MARK COLLECTED
  Future<void> markCollected(String requestCode) async {
    bool success = await DonationService.markCollected(requestCode);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Donation collected successfully"),
        ),
      );

      loadMyDonations();
    }
  }

  Widget donationCard(DonationModel donation) {
    String imageUrl = "${ApiConfig.baseUrl}/uploads/${donation.image}";

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE
          if (donation.image.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 170,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported),
                    ),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE
                Text(
                  donation.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                /// DESCRIPTION
                Text(
                  donation.description,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 12),

                /// DETAILS
                Row(
                  children: [
                    const Icon(Icons.straighten, size: 18),
                    const SizedBox(width: 6),
                    Text("Size: ${donation.size}"),
                  ],
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(Icons.verified, size: 18),
                    const SizedBox(width: 6),
                    Text("Pickup Address: ${donation.pickupAddress}"),
                  ],
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18),
                    const SizedBox(width: 6),
                    Text("District: ${donation.district}"),
                  ],
                ),

                const SizedBox(height: 10),

                /// REQUESTER
                if (donation.requesterName != null &&
                    donation.requesterName!.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.person, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        "Requester: ${donation.requesterName}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 8),

                /// REQUEST CODE
                if (donation.requestCode != null &&
                    donation.requestCode!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          "Code: ${donation.requestCode}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 14),

                /// STATUS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Donation Status",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    statusBadge(donation.status),
                  ],
                ),

                const SizedBox(height: 12),

                /// ACTIONS

                if (donation.status == "Requested") ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () {
                            if (donation.requestCode != null) {
                              acceptRequest(donation.requestCode!);
                            }
                          },
                          icon: const Icon(Icons.check),
                          label: const Text("Accept"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            if (donation.requestCode != null) {
                              rejectRequest(donation.requestCode!);
                            }
                          },
                          icon: const Icon(Icons.close),
                          label: const Text("Reject"),
                        ),
                      ),
                    ],
                  ),
                ],

                if (donation.status == "Approved") ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                      ),
                      onPressed: () {
                        if (donation.requestCode != null) {
                          markCollected(donation.requestCode!);
                        }
                      },
                      icon: const Icon(Icons.done_all),
                      label: const Text("Mark Collected"),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (donations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard, size: 60, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              "No Donations Yet",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadMyDonations,
      child: ListView.builder(
        itemCount: donations.length,
        itemBuilder: (context, index) {
          return donationCard(donations[index]);
        },
      ),
    );
  }
}
