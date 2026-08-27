import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/shop_model.dart';
import '../../services/shop_service.dart';
import 'shop_services_screen.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({Key? key}) : super(key: key);

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  List<ShopModel> shops = [];
  bool isLoading = true;
  String userDistrict = "";

  @override
  void initState() {
    super.initState();
    loadShops();
  }

  Future<void> loadShops() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    userDistrict = prefs.getString("district") ?? "";

    List<ShopModel> fetchedShops = await ShopService.getShops(userDistrict);

    if (!mounted) return;

    setState(() {
      shops = fetchedShops;
      isLoading = false;
    });
  }

  Widget shopCard(ShopModel shop) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShopServicesScreen(
              shopId: shop.shopId,
              shopName: shop.shopName,
            ),
          ),
        );
      },
      child: Container(
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
        child: Row(
          children: [
            /// SHOP ICON
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
              child: const Icon(
                Icons.store,
                color: Color(0xFF2563EB),
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            /// SHOP DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.shopName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        shop.district,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// ARROW
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Shops"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : shops.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.store,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "No Shops Available",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadShops,
                  child: ListView.builder(
                    itemCount: shops.length,
                    itemBuilder: (context, index) {
                      return shopCard(shops[index]);
                    },
                  ),
                ),
    );
  }
}
