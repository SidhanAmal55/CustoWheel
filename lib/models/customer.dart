class Customer {
  final String name;
  final String vehicleNumber;
  final String vehicleName;
  final double cashToGive;
  final String contact;
  final String registration;

  Customer({
    required this.name,
    required this.vehicleNumber,
    required this.vehicleName,
    required this.cashToGive,
    required this.contact,
    required this.registration,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      name: map['name'],
      vehicleNumber: map['vehicleNumber'],
      vehicleName: map['vehicleName'] ?? 'Unknown',
      cashToGive: (map['cashToGive'] ?? 0).toDouble(),
      contact: map['contact'] ?? 'N/A',
      registration: map['registration'] ?? 'N/A',
    );
  }

Map<String, dynamic> toMap() {
  return {
    'name': name,
    'vehicleNumber': vehicleNumber.toUpperCase().replaceAll(" ", ""),
    'vehicleName': vehicleName,
    'cashToGive': cashToGive,
    'contact': contact,
    'registration': registration.toUpperCase().replaceAll(" ", ""),
  };
}

}
