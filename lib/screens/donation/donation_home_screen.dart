import 'package:flutter/material.dart';
import 'donation_list_screen.dart';
import 'my_requests_screen.dart';
import 'my_donations_screen.dart';

class DonationHomeScreen extends StatelessWidget {
  const DonationHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Shoe Donations"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            /// MODERN TAB BAR
            Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  labelColor: const Color(0xFF2563EB),
                  unselectedLabelColor: Colors.black87,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.volunteer_activism),
                      text: "Available",
                    ),
                    Tab(
                      icon: Icon(Icons.assignment),
                      text: "My Requests",
                    ),
                    Tab(
                      icon: Icon(Icons.card_giftcard),
                      text: "My Donations",
                    ),
                  ],
                )),

            /// TAB CONTENT
            const Expanded(
              child: TabBarView(
                children: [
                  DonationListScreen(),
                  MyRequestsScreen(),
                  MyDonationsScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
