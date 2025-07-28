import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:CustoWheel/screens/home_screen.dart';
import 'package:CustoWheel/models/customer.dart';
import 'package:CustoWheel/services/firestore_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:CustoWheel/screens/location_picker_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:typed_data';
import 'dart:convert';



class AddEditCustomerScreen extends StatefulWidget {
  final Customer? existingCustomer;

  const AddEditCustomerScreen({super.key, this.existingCustomer});

  @override
  State<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends State<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _vehicleNameController = TextEditingController();
  final _registrationController = TextEditingController();
  final _amountController = TextEditingController();
  final _contactController = TextEditingController();
  final _mapLinkController = TextEditingController();
  // File? _selectedImage;
  // String? _uploadedImageUrl;
  // String? _photoUrl;
  // Uint8List? _photoBytes;              // compressed bytes for preview
  // String?    _photoBase64;             // final Base64 string to save
  File? _selectedImage;
  String? _photoBase64; // used instead of _uploadedImageUrl/_photoUrl




  

  final _vehicleNumberFocus = FocusNode();
  final _vehicleNameFocus = FocusNode();
  final _registrationFocus = FocusNode();
  final _cashFocus = FocusNode();
  final _contactFocus = FocusNode();
  final _maplinkFocus = FocusNode();
 

  @override
  void initState() {
    super.initState();
    if (widget.existingCustomer != null) {
      _nameController.text = widget.existingCustomer!.name;
      _vehicleNumberController.text = widget.existingCustomer!.vehicleNumber;
      _vehicleNameController.text = widget.existingCustomer!.vehicleName;
      _registrationController.text = widget.existingCustomer!.registration;
      _amountController.text = widget.existingCustomer!.cashToGive.toString();
      // _contactController.text = widget.existingCustome.contact;
       _mapLinkController.text = widget.existingCustomer!.location ?? '';
       _photoBase64= widget.existingCustomer!.profileImageBase64;
       //_location = widget.existingCustomer!.location;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _vehicleNumberController.dispose();
    _vehicleNameController.dispose();
    _registrationController.dispose();
    _amountController.dispose();
    _contactController.dispose();

    _vehicleNumberFocus.dispose();
    _vehicleNameFocus.dispose();
    _registrationFocus.dispose(); 
    _cashFocus.dispose();
    _contactFocus.dispose();
    _mapLinkController.dispose();

    super.dispose();
  }
//   Future<void> _pickAndUploadImage() async {
//   try {
//     final picked = await ImagePicker().pickImage(source: ImageSource.camera);

//     if (picked != null) {
//       setState(() {
//         _selectedImage = File(picked.path);
//       });

//       final storageRef = FirebaseStorage.instance
//           .ref()
//           .child('customer_photos/${DateTime.now().millisecondsSinceEpoch}.jpg');

//       await storageRef.putFile(_selectedImage!);

//       final downloadUrl = await storageRef.getDownloadURL();

//       setState(() {
//         _uploadedImageUrl = downloadUrl;
//          _photoBase64= _uploadedImageUrl;
//       });
//     }
//   } catch (e) {
//     print('Error picking or uploading image: $e');
//     // Optional: Show error to user via Snackbar or Dialog
//   }
// }
Future<File> compressImage(File file) async {
  final compressedImage = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    '${file.parent.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg',
    quality: 30,
  );

  if (compressedImage == null) {
    throw Exception("Image compression failed");
  }

  return File(compressedImage.path); // ✅ Convert XFile to File
}




Future<void> _pickImageFromGallery() async {
  try {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (pickedFile != null) {
      File originalImage = File(pickedFile.path);
      File compressedImage = await compressImage(originalImage);

      final bytes = await compressedImage.readAsBytes();
      final base64String = base64Encode(bytes);

      setState(() {
        _selectedImage = compressedImage;
        _photoBase64 = base64String;
      });

      print("✅ Image selected and converted to base64.");
    }
  } catch (e) {
    print("Error picking image from gallery: $e");
  }
}



Future<void> _captureImageFromCamera() async {
  try {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );

    if (pickedFile != null) {
      File originalImage = File(pickedFile.path);
      File compressedImage = await compressImage(originalImage);

      final bytes = await compressedImage.readAsBytes();
      final base64String = base64Encode(bytes);

      setState(() {
        _selectedImage = compressedImage;
        _photoBase64 = base64String;
      });

      print("✅ Image captured and converted to base64.");
    }
  } catch (e) {
    print("Error capturing image from camera: $e");
  }
}



// Future<void> _pickLocation() async {
//   final LatLng? selected = await Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => LocationPickerScreen(),
//     ),
//   );

//   if (selected != null) {
//     setState(() {
//       _location = GeoPoint(selected.latitude, selected.longitude);
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Location selected')),
//     );
//   }
// }





  

 void _saveCustomer() async {
  if (_formKey.currentState!.validate()) {
    // Ensure image is picked and uploaded before saving
    if (_photoBase64== null || _photoBase64!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a profile photo.')),
      );
      return;
    }

    final customer = Customer(
      name: _nameController.text.trim(),
      vehicleNumber: _vehicleNumberController.text.trim().toUpperCase(),
      vehicleName: _vehicleNameController.text.trim(),
      registration: _registrationController.text.trim(),
      cashToGive: double.tryParse(_amountController.text.trim()) ?? 0.0,
      contact: _contactController.text.trim(),
      profileImageBase64: _photoBase64,
      location: _mapLinkController.text.trim().isNotEmpty
          ? _mapLinkController.text.trim()
          : null,
    );

    try {
      await FirestoreService.addOrUpdateCustomer(customer);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer saved successfully!')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save customer: $e')),
      );
    }
  }
}

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required Color bgColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  const Color(0xFF1C1B33),
      appBar: AppBar(
        title: Text(widget.existingCustomer != null ? 'Edit Customer' : 'Add Customer'),
        centerTitle: true,
        elevation: 0,
        backgroundColor:  const Color(0xFF1C1B33),
        foregroundColor: Colors.white ,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildCard(
                title: "Customer Details",
                icon: Icons.person_outline,
                bgColor: const Color.fromARGB(255, 219, 253, 215),
                children: [
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_contactFocus),
                    decoration: _inputDecoration('Customer Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _contactController,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_vehicleNumberFocus),
                    decoration: _inputDecoration('Contact  (Optional)'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  

                ],
              ),
              _buildCard(
                title: "Vehicle Information",
                icon: Icons.directions_car_filled_outlined,
                bgColor: const Color(0xFFFFF2CC),
                children: [
                  TextFormField(
                    controller: _vehicleNumberController,
                    focusNode: _vehicleNumberFocus,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_vehicleNameFocus),
                    decoration: _inputDecoration('Vehicle Number'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _vehicleNameController,
                    focusNode: _vehicleNameFocus,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_registrationFocus),
                    decoration: _inputDecoration('Vehicle Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _registrationController,
                    focusNode: _registrationFocus,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_maplinkFocus),
                    decoration: _inputDecoration(' Vehicle Registration (Full Capital)'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                ],
              ),
              _buildCard(
  title: "Location Details",
  icon: Icons.location_city,
  bgColor: const Color.fromARGB(255, 243, 201, 246),
  children: [
    TextFormField(
      controller: _mapLinkController,
      focusNode: _maplinkFocus,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) =>
          FocusScope.of(context).requestFocus(_cashFocus),
      decoration: _inputDecoration('Google Map Link'),
      validator: (value) => value!.isEmpty ? 'Required' : null,
    ),
    const SizedBox(height: 10),
    Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        onPressed: () async {
          final url = Uri.parse('https://www.google.com/maps');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Could not open Google Maps")),
            );
          }
        },
        icon: const Icon(Icons.map),
        label: const Text("Open Google Maps"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue,
        ),
      ),
    ),
  ],
),

              _buildCard(
                title: "Payment Details",
                icon: Icons.payment_outlined,
                bgColor: const Color(0xFFDEE9FF),
                children: [
                  TextFormField(
                    controller: _amountController,
                    focusNode: _cashFocus,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Amount to Give'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                ],
              ),
              const SizedBox(height: 20,),
             Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    IconButton(
      onPressed: _pickImageFromGallery, // 📁 Pick from gallery
      icon: const Icon(Icons.image, color: Colors.white, size: 50),
      tooltip: 'Pick from Gallery',
    ),
    const SizedBox(width: 16),
    IconButton(
      onPressed: _captureImageFromCamera, // 📸 Take photo
      icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 50),
      tooltip: 'Capture from Camera',
    ),
  ],
),

const SizedBox(height: 20),

// SizedBox(
//   width: double.infinity,
//   child: ElevatedButton.icon(
//     icon: const Icon(Icons.location_on),
//     label: const Text('Set Location'),
//      onPressed: _pickLocation,
//     style: ElevatedButton.styleFrom(
//       padding: const EdgeInsets.symmetric(vertical: 16),
//     ),
//   ),
// ),
// if (_location != null)
//   Padding(
//     padding: const EdgeInsets.only(top: 10),
//     child: Text(
//       "Location: ${_location!.latitude.toStringAsFixed(5)}, ${_location!.longitude.toStringAsFixed(5)}",
//       style: const TextStyle(color: Colors.white70),
//     ),
//   ),


              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCustomer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  backgroundColor: const Color.fromARGB(255, 247, 248, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.existingCustomer != null ? 'Update Customer' : 'Add Customer',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

