import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/order_model.dart';
import '../../services/shop_service.dart';
import '../home/home_screen.dart';
import 'manage_services_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopDashboardScreen extends StatefulWidget {
  const ShopDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ShopDashboardScreen> createState() => _ShopDashboardScreenState();
}

class _ShopDashboardScreenState extends State<ShopDashboardScreen>
    with SingleTickerProviderStateMixin {
  List<OrderModel> orders = [];
  bool isLoading = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    loadOrders();
  }

  Future<void> loadOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt("id") ?? 0;

    List<OrderModel> fetchedOrders = await ShopService.getShopOrders(userId);

    if (!mounted) return;

    setState(() {
      orders = fetchedOrders;
      isLoading = false;
    });
  }

  /// CALL CUSTOMER
  Future<void> callCustomer(String phone) async {
    final Uri phoneUri = Uri.parse("tel:$phone");

    try {
      await launchUrl(phoneUri);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot open phone dialer"),
        ),
      );
    }
  }

  Future<void> updateStatus(OrderModel order, String newStatus) async {
    bool success = await ShopService.updateOrderStatus(
      order.orderId,
      newStatus,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Order updated to $newStatus"),
        ),
      );

      loadOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update status"),
        ),
      );
    }
  }

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

  Widget buildActionButton(OrderModel order) {
    if (order.status == "Cancelled") {
      return const Text(
        "Cancelled",
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (order.status == "Pending") {
      return ElevatedButton.icon(
        onPressed: () => updateStatus(order, "Accepted"),
        icon: const Icon(Icons.check),
        label: const Text("Accept"),
      );
    }

    if (order.status == "Accepted") {
      return ElevatedButton.icon(
        onPressed: () => updateStatus(order, "In Progress"),
        icon: const Icon(Icons.play_arrow),
        label: const Text("Start"),
      );
    }

    if (order.status == "In Progress") {
      return ElevatedButton.icon(
        onPressed: () => updateStatus(order, "Completed"),
        icon: const Icon(Icons.done),
        label: const Text("Complete"),
      );
    }

    return const SizedBox();
  }

  void goToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
      (route) => false,
    );
  }

  Widget orderCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                child: const Icon(Icons.person),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  order.customerName ?? "Unknown Customer",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              buildStatusBadge(order.status),
            ],
          ),
          const SizedBox(height: 10),
          Text("Service: ${order.serviceName}"),
          if (order.pickupDate != null) Text("Pickup: ${order.pickupDate}"),
          if (order.pickupAddress != null)
            Text("Address: ${order.pickupAddress}"),
          if (order.landmark != null) Text("Landmark: ${order.landmark}"),
          if (order.phone != null) Text("Phone: ${order.phone}"),
          const SizedBox(height: 10),
          if (order.phone != null)
            ElevatedButton.icon(
              onPressed: () => callCustomer(order.phone!),
              icon: const Icon(Icons.phone),
              label: const Text("Call Customer"),
            ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: buildActionButton(order),
          ),
        ],
      ),
    );
  }

  Widget ordersTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orders.isEmpty) {
      return const Center(
        child: Text("No Orders Yet"),
      );
    }

    return RefreshIndicator(
      onRefresh: loadOrders,
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return orderCard(orders[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shop Panel"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: goToHome,
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Orders"),
            Tab(text: "Services"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          /// ORDERS TAB
          ordersTab(),

          /// SERVICES TAB
          const ManageServicesScreen(),
        ],
      ),
    );
  }
}
