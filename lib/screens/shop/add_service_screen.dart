import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/shop_service.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({Key? key}) : super(key: key);

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();

  bool isLoading = false;

  void saveService() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int userId = prefs.getInt("id") ?? 0;

    setState(() => isLoading = true);

    bool success = await ShopService.addService(
      userId,
      nameController.text.trim(),
      double.parse(priceController.text.trim()),
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to add service"),
        ),
      );
    }
  }

  Widget inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? type,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Service"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
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
                const Text(
                  "Create New Service",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                inputField(
                  controller: nameController,
                  label: "Service Name",
                  icon: Icons.cleaning_services,
                ),
                const SizedBox(height: 16),
                inputField(
                  controller: priceController,
                  label: "Price",
                  icon: Icons.currency_rupee,
                  type: TextInputType.number,
                ),
                const SizedBox(height: 24),
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: saveService,
                          icon: const Icon(Icons.save),
                          label: const Text("Save Service"),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
