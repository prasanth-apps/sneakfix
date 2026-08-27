import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/donation_model.dart';
import '../../services/donation_service.dart';
import '../../core/api_config.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  List<DonationModel> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  Future<void> loadRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt("id") ?? 0;

    List<DonationModel> fetched =
        await DonationService.getMyRequestsWithCode(userId);

    if (!mounted) return;

    setState(() {
      requests = fetched;
      isLoading = false;
    });
  }

  /// STATUS COLOR
  Color getStatusColor(String status) {
    switch (status) {
      case "Requested":
        return Colors.orange;
      case "Approved":
        return Colors.green;
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

  Widget requestCard(DonationModel donation) {
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

                const SizedBox(height: 12),

                /// PICKUP CODE
                if (donation.requestCode != null &&
                    donation.requestCode!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.qr_code,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Pickup Code: ${donation.requestCode}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                /// STATUS ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Request Status",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    statusBadge(donation.status),
                  ],
                ),
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

    if (requests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment,
              size: 60,
              color: Colors.grey,
            ),
            SizedBox(height: 10),
            Text(
              "No Requests Yet",
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
      onRefresh: loadRequests,
      child: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          return requestCard(requests[index]);
        },
      ),
    );
  }
}
