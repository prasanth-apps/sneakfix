import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/order_model.dart';
import '../../services/shop_service.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<OrderModel> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int userId = prefs.getInt("id") ?? 0;

    List<OrderModel> fetchedOrders = await ShopService.getUserOrders(userId);

    if (!mounted) return;

    setState(() {
      orders = fetchedOrders;
      isLoading = false;
    });
  }

  /// CANCEL ORDER
  Future<void> cancelOrder(OrderModel order) async {
    bool success = await ShopService.updateOrderStatus(
      order.orderId,
      "Cancelled",
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order Cancelled"),
        ),
      );

      loadOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to cancel order"),
        ),
      );
    }
  }

  /// STATUS COLOR
  Color getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;

      case "Accepted":
        return Colors.blue;

      case "In Progress":
        return Colors.purple;

      case "Completed":
        return Colors.green;

      case "Cancelled":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  /// STATUS BADGE
  Widget buildStatusBadge(String status) {
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

  /// ORDER CARD
  Widget orderCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      padding: const EdgeInsets.all(16),
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
          /// SHOP HEADER
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                child: const Icon(
                  Icons.store,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  order.shopName ?? "Unknown Shop",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              buildStatusBadge(order.status),
            ],
          ),

          const SizedBox(height: 14),

          /// SERVICE
          Row(
            children: [
              const Icon(Icons.cleaning_services, size: 18),
              const SizedBox(width: 6),
              Text(
                "Service: ${order.serviceName}",
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// PICKUP DATE
          if (order.pickupDate != null)
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Pickup: ${order.pickupDate}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 12),

          /// CANCEL BUTTON
          if (order.status == "Pending")
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => cancelOrder(order),
                icon: const Icon(Icons.cancel),
                label: const Text("Cancel Order"),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : orders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "No Orders Yet",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadOrders,
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return orderCard(
                        orders[index],
                      );
                    },
                  ),
                ),
    );
  }
}
