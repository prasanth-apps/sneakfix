import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/donation_service.dart';

class AddDonationScreen extends StatefulWidget {
  const AddDonationScreen({Key? key}) : super(key: key);

  @override
  State<AddDonationScreen> createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final sizeController = TextEditingController();
  final districtController = TextEditingController();
  final addressController = TextEditingController();

  File? selectedImage;
  bool isLoading = false;

  /// PICK IMAGE
  Future<void> pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null && mounted) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  /// SUBMIT DONATION
  Future<void> submitDonation() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image")),
      );
      return;
    }

    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        sizeController.text.isEmpty ||
        districtController.text.isEmpty ||
        addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    int userId = prefs.getInt("id") ?? 0;

    setState(() {
      isLoading = true;
    });

    bool success = await DonationService.addDonation(
      userId,
      titleController.text,
      descriptionController.text,
      sizeController.text,
      districtController.text,
      addressController.text,
      selectedImage!,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Donation uploaded successfully")),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload failed")),
      );
    }
  }

  Widget inputField(
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    sizeController.dispose();
    districtController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donate Shoes"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// IMAGE PICKER
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: selectedImage == null
                    ? const Center(
                        child: Text("Tap to select image"),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            inputField("Title", titleController),
            inputField("Description", descriptionController),
            inputField("Shoe Size", sizeController),
            inputField("District", districtController),
            inputField("Pickup Address", addressController),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitDonation,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text("Upload Donation"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
