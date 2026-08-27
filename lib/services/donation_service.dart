import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/donation_model.dart';

class DonationService {
  /// Get available donations
  static Future<List<DonationModel>> getDonations() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/donation/get_donations.php"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == "success") {
          List donations = data['donations'];
          return donations.map((e) => DonationModel.fromJson(e)).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint("Donation fetch error: $e");
      return [];
    }
  }

  /// Request donation
  static Future<bool> requestDonation(
    int donationId,
    int userId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/donation/request_donation.php"),
        body: {
          "donation_id": donationId.toString(),
          "user_id": userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == "success";
      }

      return false;
    } catch (e) {
      debugPrint("Request donation error: $e");
      return false;
    }
  }

  /// Get my donations (donations I posted)
  static Future<List<DonationModel>> getMyDonations(int userId) async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/donation/get_my_donations.php?user_id=$userId",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == "success") {
          List donations = data['donations'];
          return donations.map((e) => DonationModel.fromJson(e)).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint("My donations error: $e");
      return [];
    }
  }

  /// Get my requested donations (old API)
  static Future<List<DonationModel>> getMyRequests(int userId) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/donation/get_my_requests.php"),
        body: {
          "user_id": userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == "success") {
          List requests = data['requests'];
          return requests.map((e) => DonationModel.fromJson(e)).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint("My requests error: $e");
      return [];
    }
  }

  /// Get my requests WITH pickup code
  static Future<List<DonationModel>> getMyRequestsWithCode(int userId) async {
    try {
      final response = await http.post(
        Uri.parse(
            "${ApiConfig.baseUrl}/donation/get_my_requests_with_code.php"),
        body: {
          "user_id": userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == "success") {
          List requests = data['requests'];
          return requests.map((e) => DonationModel.fromJson(e)).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint("My requests with code error: $e");
      return [];
    }
  }

  /// Update request status (Accept / Reject)
  static Future<bool> updateRequestStatus(
    String requestCode,
    String status,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/donation/update_request_status.php"),
        body: {
          "request_code": requestCode,
          "status": status,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == "success";
      }

      return false;
    } catch (e) {
      debugPrint("Update request error: $e");
      return false;
    }
  }

  /// Mark donation as collected
  static Future<bool> markCollected(String requestCode) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/donation/mark_collected.php"),
        body: {
          "request_code": requestCode,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == "success";
      }

      return false;
    } catch (e) {
      debugPrint("Mark collected error: $e");
      return false;
    }
  }

  /// Add donation with image
  static Future<bool> addDonation(
    int userId,
    String title,
    String description,
    String size,
    String district,
    String pickupAddress,
    File image,
  ) async {
    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("${ApiConfig.baseUrl}/donation/add_donation.php"),
      );

      request.fields['user_id'] = userId.toString();
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['size'] = size;
      request.fields['district'] = district;
      request.fields['pickup_address'] = pickupAddress;

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
        ),
      );

      var response = await request.send();

      var respStr = await response.stream.bytesToString();
      print(respStr);

      if (response.statusCode == 200) {
        final data = jsonDecode(respStr);
        return data['status'] == "success";
      }

      return false;
    } catch (e) {
      debugPrint("Add donation error: $e");
      return false;
    }
  }
}
