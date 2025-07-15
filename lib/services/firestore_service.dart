import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:CustoWheel/models/customer.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static bool get isUserLoggedIn => FirebaseAuth.instance.currentUser != null;


  // Get the reference to the current user's customer subcollection
  static CollectionReference get _userCustomers {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");
    return _firestore.collection('users').doc(uid).collection('customers');
  }

  // Get customer by vehicle number
 static Future<List<Customer>> getCustomersByVehicle(String vehicleNumber) async {
  final uid = _auth.currentUser?.uid;
  if (uid == null) return [];

  final normalized = vehicleNumber.toUpperCase().replaceAll(" ", "");
  print('🔍 Searching: $normalized for user $uid');

  final query = await _firestore
      .collection('users')
      .doc(uid)
      .collection('customers')
      .where('vehicleNumber', isEqualTo: normalized)
      .get();

  return query.docs
      .map((doc) => Customer.fromMap(doc.data() as Map<String, dynamic>))
      .toList();
}


  
    // Add or update customer by vehicle number
  static Future<void> addOrUpdateCustomer(Customer customer) async {
  final uid = _auth.currentUser?.uid;
  if (uid == null) throw Exception('User not logged in');

  final normalizedVehicleNumber = customer.vehicleNumber.toUpperCase().replaceAll(" ", "");
  final normalizedRegistration = customer.registration.toUpperCase().replaceAll(" ", "");

  final query = await _firestore
      .collection('users')
      .doc(uid)
      .collection('customers')
      .where('vehicleNumber', isEqualTo: normalizedVehicleNumber)
      .where('registration', isEqualTo: normalizedRegistration)
      .get();

  if (query.docs.isNotEmpty) {
    // 🔁 Update ALL matching documents to avoid duplication
    for (var doc in query.docs) {
      await doc.reference.update(customer.toMap());
    }
    print('✅ Updated existing customer(s)');
  } else {
    // ➕ Add new customer
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('customers')
        .add(customer.toMap());
    print('✅ New customer added');
  }
}

  // Delete customer by vehicle number
  static Future<void> deleteCustomer(String vehicleNumber) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final query = await _firestore
        .collection('users')
        .doc(uid)
        .collection('customers')
        .where('vehicleNumber', isEqualTo: vehicleNumber)
        .get();

    for (var doc in query.docs) {
      await doc.reference.delete();
    }
  }

  // Update customer by vehicle number
  // static Future<void> updateCustomer(Customer customer) async {
  //   final uid = _auth.currentUser?.uid;
  //   if (uid == null) return;

  //   final query = await _firestore
  //       .collection('users')
  //       .doc(uid)
  //       .collection('customers')
  //       .where('vehicleNumber', isEqualTo: customer.vehicleNumber)
  //       .get();

  //   if (query.docs.isNotEmpty) {
  //     for (var doc in query.docs) {
  //       await doc.reference.set(customer.toMap());
  //     }
  //   } else {
  //     // Add new if not found
  //     await addCustomer(customer);
  //   }
  // }

}
