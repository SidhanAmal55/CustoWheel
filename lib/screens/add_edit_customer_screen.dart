import 'package:flutter/material.dart';
import 'package:CustoWheel/screens/home_screen.dart';
import 'package:CustoWheel/models/customer.dart';
import 'package:CustoWheel/services/firestore_service.dart';

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
  

  final _vehicleNumberFocus = FocusNode();
  final _vehicleNameFocus = FocusNode();
  final _registrationFocus = FocusNode();
  final _cashFocus = FocusNode();
  final _contactFocus = FocusNode();
 

  @override
  void initState() {
    super.initState();
    if (widget.existingCustomer != null) {
      _nameController.text = widget.existingCustomer!.name;
      _vehicleNumberController.text = widget.existingCustomer!.vehicleNumber;
      _vehicleNameController.text = widget.existingCustomer!.vehicleName;
      _registrationController.text = widget.existingCustomer!.registration;
      _amountController.text = widget.existingCustomer!.cashToGive.toString();
      _contactController.text = widget.existingCustomer!.contact;
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

    super.dispose();
  }

  void _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      final customer = Customer(
        name: _nameController.text.trim(),
        vehicleNumber: _vehicleNumberController.text.trim().toUpperCase(),
        vehicleName: _vehicleNameController.text.trim(),
        registration: _registrationController.text.trim(),
        cashToGive: double.tryParse(_amountController.text.trim()) ?? 0.0,
        contact: _contactController.text.trim(),
      );

      await FirestoreService.addOrUpdateCustomer(customer);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer saved!')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
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
                        FocusScope.of(context).requestFocus(_vehicleNumberFocus),
                    decoration: _inputDecoration('Customer Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _contactController,
                    focusNode: _contactFocus,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration('Contact (Optional)'),
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
                    FocusScope.of(context).requestFocus(_cashFocus),
                    decoration: _inputDecoration(' Vehicle Registration (Full Capital)'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
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
