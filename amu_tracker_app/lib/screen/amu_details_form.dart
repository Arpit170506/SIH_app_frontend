import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_service.dart';
import '../data_store.dart';
import '../app_data.dart';
import '../utils/helpers.dart';

class AMUDetailsForm extends StatefulWidget {
  final String userRole;
  const AMUDetailsForm({required this.userRole, super.key});

  @override
  State<AMUDetailsForm> createState() => _AMUDetailsFormState();
}

class _AMUDetailsFormState extends State<AMUDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final _animalIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _antimicrobialController = TextEditingController();
  final _reasonController = TextEditingController();

  String? _selectedAnimalType;
  String? _selectedDosage;
  bool _isLoading = false;

  @override
  void dispose() {
    _animalIdController.dispose();
    _phoneController.dispose();
    _antimicrobialController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // --- BUG FIX: Determine vetName based on user's role ---
      String vetName;
      if (widget.userRole == 'Farmer') {
        // A Farmer submits TO a vet. For this MVP, we'll assume it's the only vet in the system.
        vetName = 'Dr. Aanchal Yadav';
      } else { // The user role is 'Vet'
        // A Vet submits a record on their own behalf.
        vetName = DataStore.currentUser;
      }

      final recordData = {
        "farmerName": DataStore.currentUser,
        "phoneNumber": _phoneController.text,
        "vetName": vetName, // Use the correctly determined vet name
        "antimicrobialName": _antimicrobialController.text,
        "animalId": _animalIdController.text,
        "animalType": _selectedAnimalType,
        "dosage": _selectedDosage,
        "reasonForUse": _reasonController.text,
        "date": DateTime.now().toIso8601String(),
      };

      try {
        final http.Response response = await _apiService.submitNewRecord(recordData);

        if (response.statusCode == 200) {
          String title = widget.userRole == 'Vet'
              ? 'Record Created (रिकॉर्ड बन गया)'
              : 'Record Submitted (रिकॉर्ड जमा हो गया)';
          String content = widget.userRole == 'Vet'
              ? 'The new record has been created and is now pending review on your dashboard.'
              : 'Your form has been submitted and will be shown on your dashboard after vet\'s approval or rejection.';

          if (mounted) {
            showSuccessDialog(context, title, content, () => Navigator.pop(context, true));
          }
        } else {
          final responseBody = jsonDecode(response.body);
          if (mounted) {
            showSuccessDialog(
              context,
              'Error (त्रुटि)',
              'Failed to submit record: ${responseBody['msg']}',
              () => Navigator.pop(context),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          showSuccessDialog(
            context,
            'Connection Error (कनेक्शन त्रुटि)',
            'Failed to connect to the server. Please check your network connection.\n\nError: $e',
            () => Navigator.pop(context),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // --- NO CHANGES to the UI code (build method and helpers) below ---
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
            _buildSelectionField(
              context: context,
              controller: _antimicrobialController,
              label: 'Antimicrobial Name (दवा का नाम)',
              options: AppData.commonAntimicrobials,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Dosage (खुराक)',
              value: _selectedDosage,
              items: AppData.dosageOptions,
              onChanged: (value) => setState(() => _selectedDosage = value),
            ),
            const SizedBox(height: 16),
            _buildSelectionField(
              context: context,
              controller: _reasonController,
              label: 'Reason for Use (कारण)',
              options: AppData.reasonsForUse,
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
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF558B2F),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text('Submit Record (रिकॉर्ड जमा करें)', style: TextStyle(fontSize: 18, color: Colors.white)),
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

  Widget _buildSelectionField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required List<String> options,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.arrow_drop_down),
      ),
      onTap: () => _showOptionsDialog(context, controller, options, label),
      validator: (value) => value!.isEmpty ? 'Please select or enter a value' : null,
    );
  }

  void _showOptionsDialog(BuildContext context, TextEditingController controller, List<String> options, String title) {
    showDialog(
      context: context,
      builder: (context) {
        final allOptions = [...options, 'अन्य (Other)'];
        return AlertDialog(
          title: Text('Select (चुनें) $title'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: allOptions.length,
              itemBuilder: (context, index) {
                final option = allOptions[index];
                return ListTile(
                  title: Text(option),
                  onTap: () {
                    if (option == 'अन्य (Other)') {
                      Navigator.pop(context);
                      _showCustomInputDialog(context, controller, title);
                    } else {
                      setState(() => controller.text = option);
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showCustomInputDialog(BuildContext context, TextEditingController controller, String title) {
    final customValueController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter (दर्ज करें) $title'),
          content: TextFormField(
            controller: customValueController,
            autofocus: true,
            decoration: InputDecoration(labelText: 'Custom Value (कस्टम मान)'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel (रद्द करें)')),
            TextButton(
              onPressed: () {
                if (customValueController.text.isNotEmpty) {
                  setState(() => controller.text = customValueController.text);
                }
                Navigator.pop(context);
              },
              child: const Text('OK (ठीक है)'),
            ),
          ],
        );
      },
    );
  }
}