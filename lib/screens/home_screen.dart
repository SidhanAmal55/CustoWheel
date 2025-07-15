import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:CustoWheel/screens/add_edit_customer_screen.dart';
import 'package:CustoWheel/screens/login_screen.dart';
import 'package:CustoWheel/services/firestore_service.dart';
import 'package:CustoWheel/screens/result_screen.dart';
import 'package:CustoWheel/models/customer.dart';
import 'package:CustoWheel/services/ocr_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  Future<void> _pickImageAndExtractText({required ImageSource source}) async {
  final picker = ImagePicker();
  final pickedImage = await picker.pickImage(source: source);

  if (pickedImage != null) {
    setState(() => _loading = true);
    final numberPlate = await OCRService.extractText(File(pickedImage.path));
    _controller.text = numberPlate;
    await _searchCustomer(numberPlate);
    setState(() => _loading = false);
  }
}

Future<String?> _askForRegistration(BuildContext context) async {
  String input = '';
  return await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Enter Registration'),
      content: TextField(
        onChanged: (value) => input = value,
        decoration: const InputDecoration(hintText: 'Registration '),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, input),
          child: const Text('Submit'),
        ),
      ],
    ),
  );
}



  Future<void> _searchCustomer(String vehicleNumber) async {
  if (vehicleNumber.trim().isEmpty) return;

  if (!FirestoreService.isUserLoggedIn) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please log in first.')),
    );
    return;
  }

  setState(() => _loading = true);

  try {
    final customers = await FirestoreService.getCustomersByVehicle(vehicleNumber);
    setState(() => _loading = false);

    if (customers.length == 1) {
      // 👉 Directly show result if only 1 customer found
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(customer: customers[0]),
        ),
      );
    } else if (customers.length > 1) {
      // 👉 Ask user to choose based on registration
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Multiple Matches Found'),
          content: const Text('Please enter the registration to continue.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () async {
                Navigator.pop(context);
                final reg = await _askForRegistration(context);
                if (reg != null && reg.isNotEmpty) {
                  final match = customers.firstWhere(
                    (c) => c.registration.toUpperCase().replaceAll(" ", "") ==
                        reg.toUpperCase().replaceAll(" ", ""),
                   
                  );

                  if (match.name.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultScreen(customer: match),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No customer matched registration.')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer not found')),
      );
    }
  } catch (e) {
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1B33), // Dark background

      appBar: AppBar(
  title: const Text(
    'Customer Lookup',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 22,
    ),
  ),
  backgroundColor: Colors.transparent,
  elevation: 0,
  centerTitle: true,
  actions: [
    IconButton(
      icon: const Icon(Icons.logout, color: Colors.white),
      tooltip: 'Logout',
      onPressed: () async {
  await FirebaseAuth.instance.signOut(); // ✅ Sign out
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginDemo1()), // Go back to login
    (route) => false, // Remove all previous routes
  );
},

    ),
  ],
),


      body:  SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Input field
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter Vehicle Number',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.person, color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF2C2A4A),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.pinkAccent, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 2),
                ),
              ),
              cursorColor: Colors.white,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => _searchCustomer(value),
            ),

            const SizedBox(height: 26),

            // Search button with gradient
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFE6197), Color(0xFFFFB463)], // pink to orange
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: () => _searchCustomer(_controller.text.trim()),
                icon: const Icon(Icons.search, color: Colors.white),
                label: const Text('Search'),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 26),
SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton.icon(
   onPressed: () => _pickImageAndExtractText(source: ImageSource.camera),
    icon: const Icon(Icons.camera_alt),
    label: const Text('Scan Number Plate'),
    style: ElevatedButton.styleFrom(
      foregroundColor: const Color(0xFF1C1B33),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
),
const SizedBox(height: 16),

SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton.icon(
    onPressed: () => _pickImageAndExtractText(source: ImageSource.gallery),
    icon: const Icon(Icons.upload_file),
    label: const Text('Upload Number Plate Image'),
    style: ElevatedButton.styleFrom(
      foregroundColor: const Color(0xFF1C1B33),
      backgroundColor: const Color.fromARGB(255, 246, 255, 74),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
),


            const SizedBox(height: 24),

            // Loader
            if (_loading)
              const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),

      // Add new customer button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditCustomerScreen()),
          );
        },
        backgroundColor: const Color.fromARGB(255, 255, 254, 254),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
