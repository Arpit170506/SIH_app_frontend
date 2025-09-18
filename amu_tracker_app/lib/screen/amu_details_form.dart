import 'package:flutter/material.dart';
import '../data_store.dart';
import '../amu_record.dart';
import '../app_data.dart';

class AMUDetailsForm extends StatefulWidget {
  final String userRole;
  const AMUDetailsForm({required this.userRole, super.key});

  @override
  State<AMUDetailsForm> createState() => _AMUDetailsFormState();
}

class _AMUDetailsFormState extends State<AMUDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  
  final _animalIdController = TextEditingController();
  final _antimicrobialController = TextEditingController();
  final _reasonController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String? _selectedAnimalType;
  String? _selectedDosage;

  @override
  void dispose() {
    _animalIdController.dispose();
    _antimicrobialController.dispose();
    _reasonController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newRecord = AMURecord(
        farmerName: DataStore.currentUser, 
        phoneNumber: _phoneController.text, 
        antimicrobialName: _antimicrobialController.text,
        animalType: _selectedAnimalType!,
        animalId: _animalIdController.text,
        dosage: _selectedDosage!,
        reason: _reasonController.text,
        date: DateTime.now(),
        status: 'pending',
      );

      DataStore.records.add(newRecord);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record submitted successfully!'), backgroundColor: Colors.green),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Record (नया रिकॉर्ड)'),
        backgroundColor: const Color(0xFF558B2F),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildDropdown(
              label: 'Animal Type (पशु का प्रकार)',
              value: _selectedAnimalType,
              items: AppData.animalTypes,
              onChanged: (value) => setState(() => _selectedAnimalType = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _animalIdController,
              decoration: const InputDecoration(labelText: 'Animal ID (पशु ID)', border: OutlineInputBorder()),
              validator: (value) => value!.isEmpty ? 'Please enter an animal ID' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _antimicrobialController,
              decoration: const InputDecoration(labelText: 'Antimicrobial Name (दवा का नाम)', border: OutlineInputBorder()),
              validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),
             _buildDropdown(
              label: 'Dosage (खुराक)',
              value: _selectedDosage,
              items: AppData.dosageOptions,
              onChanged: (value) => setState(() => _selectedDosage = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(labelText: 'Reason for Use (कारण)', border: OutlineInputBorder()),
              maxLines: 3,
              validator: (value) => value!.isEmpty ? 'Please enter a reason' : null,
            ),
             const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number (फ़ोन नंबर)', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
              validator: (value) => value!.isEmpty ? 'Please enter a phone number' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF558B2F),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Submit Record (रिकॉर्ड जमा करें)', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select an option' : null,
    );
  }
}