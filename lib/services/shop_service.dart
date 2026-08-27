import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/shop_model.dart';
import '../models/order_model.dart';
import '../models/service_model.dart';

class ShopService {
  /// Fetch shops with district priority
  static Future<List<ShopModel>> getShops(String district) async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/service/get_shops.php?district=$district",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == "success") {
          List shops = data['shops'];
          return shops.map((e) => ShopModel.fromJson(e)).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint("Error fetching shops: $e");
      return [];
    }
  }

  /// Create booking order (Customer side)
  /// Create booking order (Customer side)
  static Future<bool> createOrder(
    int userId,
    int shopId,
    int serviceId,
    String pickupDate,
    String address,
    String landmark,
    String phone,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/order/create_order.php"),
        body: {
          "user_id": userId.toString(),
          "shop_id": shopId.toString(),
          "service_id": serviceId.toString(),
          "pickup_date": pickupDate,
          "pickup_address": address,
          "landmark": landmark,
          "phone": phone,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == "success";
      }

      return false;
    } catch (e) {
      debugPrint("Error creating order: $e");
      return false;
    }
  }

  /// Fetch logged-in customer's orders
  static Future<List<OrderModel>> getUserOrders(int userId) async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/order/get_user_orders.php?user_id=$userId",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == "success") {
          List orders = data['orders'];
          return orders.map((e) => OrderModel.fromJson(e)).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint("Error fetching user orders: $e");
      return [];
    }
  }

  /// Fetch logged-in shop's orders
  static Future<List<OrderModel>> getShopOrders(int userId) async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/order/get_shop_orders.php?user_id=$userId",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == "success") {
          List orders = data['orders'];
          return orders.map((e) => OrderModel.fromJson(e)).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint("Error fetching shop orders: $e");
      return [];
    }
  }

  /// Update order status (Shop side)
  static Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/order/update_order_status.php"),
        body: {
          "order_id": orderId.toString(),
          "status": status,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == "success";
      }

      return false;
    } catch (e) {
      debugPrint("Error updating order status: $e");
      return false;
    }
  }

  /// Fetch services of logged-in shop (Shop dashboard)
  static Future<List<ServiceModel>> getShopServices(int userId) async {
    try {
      final shopResponse = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/service/get_shop_by_user.php?user_id=$userId",
        ),
      );

      final shopData = jsonDecode(shopResponse.body);

      if (shopData['status'] != "success") return [];

      int shopId = shopData['shop_id'];

      return await getShopServicesByShopId(shopId);
    } catch (e) {
      debugPrint("Error fetching shop services: $e");
      return [];
    }
  }

  /// 🔥 NEW — Fetch services by shopId (Customer side)
  static Future<List<ServiceModel>> getShopServicesByShopId(int shopId) async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/service/get_shop_services.php?shop_id=$shopId",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == "success") {
          List services = data['services'];
          return services.map((e) => ServiceModel.fromJson(e)).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint("Error fetching services by shopId: $e");
      return [];
    }
  }

  /// Add new service (Shop side)
  static Future<bool> addService(
      int userId, String serviceName, double price) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/service/add_service.php"),
        body: {
          "user_id": userId.toString(),
          "service_name": serviceName,
          "price": price.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == "success";
      }

      return false;
    } catch (e) {
      debugPrint("Error adding service: $e");
      return false;
    }
  }
}
