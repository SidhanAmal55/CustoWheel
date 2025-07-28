import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String name;
  final String vehicleNumber;
  final String vehicleName;
  final double cashToGive;
  final String? contact;
  final String registration;
  final String? profileImageBase64;
  final String? location;

  Customer({
    required this.name,
    required this.vehicleNumber,
    required this.vehicleName,
    required this.cashToGive,
    this.contact,
    required this.registration,
    required this.profileImageBase64,
    required this.location,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      name: map['name'],
      vehicleNumber: map['vehicleNumber'],
      vehicleName: map['vehicleName'] ?? 'Unknown',
      cashToGive: (map['cashToGive'] ?? 0).toDouble(),
      contact: map['contact'], // optional, no default
      registration: map['registration'] ?? 'N/A',
      profileImageBase64: map['profileImageBase64'],
      location: map['location'],
    );
  }

  Map<String, dynamic> toMap() {
    final data = {
      'name': name,
      'vehicleNumber': vehicleNumber.toUpperCase().replaceAll(" ", ""),
      'vehicleName': vehicleName,
      'cashToGive': cashToGive,
      'registration': registration.toUpperCase().replaceAll(" ", ""),
      'profileImageBase64': profileImageBase64,
      'location': location,
    };

    // Add contact only if it's not null or empty
    if (contact != null && contact!.isNotEmpty) {
      data['contact'] = contact;
    }

    return data;
  }
}
