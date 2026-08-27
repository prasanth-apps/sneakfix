import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/donation_model.dart';
import '../../services/donation_service.dart';
import '../../core/api_config.dart';

class DonationListScreen extends StatefulWidget {
  const DonationListScreen({Key? key}) : super(key: key);

  @override
  State<DonationListScreen> createState() => _DonationListScreenState();
}

class _DonationListScreenState extends State<DonationListScreen> {
  List<DonationModel> donations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDonations();
  }

  Future<void> loadDonations() async {
    List<DonationModel> fetched = await DonationService.getDonations();

    if (!mounted) return;

    setState(() {
      donations = fetched;
      isLoading = false;
    });
  }

  Future<void> requestDonation(DonationModel donation) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int userId = prefs.getInt("id") ?? 0;

    bool success = await DonationService.requestDonation(
      donation.donationId,
      userId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request Sent")),
      );

      loadDonations();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request Failed")),
      );
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
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
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

                if (donation.donorName != null &&
                    donation.donorName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.person, size: 18),
                        const SizedBox(width: 6),
                        Text("Donor: ${donation.donorName}"),
                      ],
                    ),
                  ),

                const SizedBox(height: 14),

                /// STATUS + BUTTON
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: donation.status == "Available"
                            ? Colors.green.withOpacity(0.15)
                            : Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        donation.status,
                        style: TextStyle(
                          color: donation.status == "Available"
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (donation.status == "Available")
                      ElevatedButton.icon(
                        onPressed: () => requestDonation(donation),
                        icon: const Icon(Icons.send),
                        label: const Text("Request"),
                      )
                    else
                      const Text(
                        "Requested",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

    if (donations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard, size: 60, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              "No Donations Available",
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
      onRefresh: loadDonations,
      child: ListView.builder(
        itemCount: donations.length,
        itemBuilder: (context, index) {
          return donationCard(donations[index]);
        },
      ),
    );
  }
}
