import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:CustoWheel/models/customer.dart';
import 'package:CustoWheel/screens/add_edit_customer_screen.dart';
import 'package:CustoWheel/services/firestore_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultScreen extends StatelessWidget {
  final Customer customer;

  const ResultScreen({super.key, required this.customer});

  void _confirmDelete(BuildContext context) async {
    final confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2A4A),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        contentTextStyle: const TextStyle(color: Colors.white70),
        title: const Text('Delete Customer'),
        content: const Text('Are you sure you want to delete this customer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color.fromARGB(255, 244, 254, 55))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Color.fromARGB(255, 244, 255, 41))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirestoreService.deleteCustomer(customer.vehicleNumber);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer deleted')),
      );
      Navigator.pop(context);
    }
  }

  void _editCustomer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCustomerScreen(existingCustomer: customer),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2A4A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 226, 255, 64)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context) {
  final imageBytes = customer.profileImageBase64 != null && customer.profileImageBase64!.isNotEmpty
      ? base64Decode(customer.profileImageBase64!)
      : null;

  return Column(
    children: [
      GestureDetector(
        onTap: () {
          if (imageBytes != null) {
            showDialog(
              context: context,
              builder: (_) => Dialog(
                backgroundColor: Colors.transparent,
                child: InteractiveViewer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(imageBytes),
                  ),
                ),
              ),
            );
          }
        },
        child: CircleAvatar(
          radius: 58,
          backgroundImage: imageBytes != null
              ? MemoryImage(imageBytes)
              : const AssetImage('assets/images/profile.png') as ImageProvider,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        customer.name,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

 Widget _buildLocationLink(BuildContext context) {
  return customer.location != null && customer.location!.isNotEmpty
      ? InkWell(
          onTap: () {
            launchUrl(Uri.parse(customer.location!));
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2A4A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.map, color: Color.fromARGB(255, 226, 255, 64)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ' Click to Open Location in Google Maps',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        )
      : const SizedBox();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1B33),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Customer Info',
          style: TextStyle(color: Colors.white),
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileImage(context),
              const SizedBox(height: 20),

              _buildInfoTile("Vehicle Number", customer.vehicleNumber, Icons.confirmation_number),
              _buildInfoTile("Vehicle Name", customer.vehicleName, Icons.directions_car),
              _buildInfoTile("Vehicle Registration", customer.registration, Icons.app_registration),
              _buildInfoTile("Amount to Give", "د.إ ${customer.cashToGive.toStringAsFixed(2)}", Icons.money),
              _buildInfoTile("Contact", (customer.contact == null || customer.contact!.isEmpty) ? 'N/A' : customer.contact!, Icons.phone),
              _buildLocationLink(context),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _editCustomer(context),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Customer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
