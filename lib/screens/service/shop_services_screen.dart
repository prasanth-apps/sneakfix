import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/service_model.dart';
import '../../services/shop_service.dart';

class ShopServicesScreen extends StatefulWidget {
  final int shopId;
  final String shopName;

  const ShopServicesScreen({
    Key? key,
    required this.shopId,
    required this.shopName,
  }) : super(key: key);

  @override
  State<ShopServicesScreen> createState() => _ShopServicesScreenState();
}

class _ShopServicesScreenState extends State<ShopServicesScreen> {
  List<ServiceModel> services = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  Future<void> loadServices() async {
    final fetched = await ShopService.getShopServicesByShopId(widget.shopId);

    if (!mounted) return;

    setState(() {
      services = fetched;
      isLoading = false;
    });
  }

  /// ADDRESS INPUT DIALOG
  Future<Map<String, String>?> getPickupDetails() async {
    TextEditingController addressController = TextEditingController();
    TextEditingController landmarkController = TextEditingController();
    TextEditingController phoneController = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Pickup Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: "Pickup Address",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: landmarkController,
                decoration: const InputDecoration(
                  labelText: "Landmark",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (addressController.text.isEmpty ||
                    phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Address and phone required"),
                    ),
                  );
                  return;
                }

                Navigator.pop(context, {
                  "address": addressController.text,
                  "landmark": landmarkController.text,
                  "phone": phoneController.text,
                });
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Future<void> bookService(ServiceModel service) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt("id") ?? 0;

    DateTime? selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDate: DateTime.now(),
    );

    if (selectedDate == null) return;

    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null) return;

    final DateTime finalDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    /// ASK ADDRESS DETAILS
    final details = await getPickupDetails();

    if (details == null) return;

    bool success = await ShopService.createOrder(
      userId,
      widget.shopId,
      service.serviceId,
      finalDateTime.toString(),
      details["address"]!,
      details["landmark"]!,
      details["phone"]!,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? "Booking Successful" : "Booking Failed",
        ),
      ),
    );
  }

  Widget serviceCard(ServiceModel service) {
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
            child: const Icon(
              Icons.cleaning_services,
              color: Color(0xFF2563EB),
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.serviceName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "₹${service.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => bookService(service),
            icon: const Icon(Icons.calendar_today),
            label: const Text("Book"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shopName),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : services.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cleaning_services,
                          size: 60, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        "No Services Available",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadServices,
                  child: ListView.builder(
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      return serviceCard(services[index]);
                    },
                  ),
                ),
    );
  }
}
