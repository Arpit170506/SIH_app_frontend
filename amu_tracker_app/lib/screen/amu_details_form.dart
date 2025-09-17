import 'package:flutter/material.dart';
import '../data_store.dart';
import '../amu_record.dart';
import '../app_data.dart';
import '../utils/helpers.dart';

// ======= Enhanced AMU Details Form =======
class AMUDetailsForm extends StatefulWidget {
  final String userRole;

  AMUDetailsForm({required this.userRole});

  @override
  _AMUDetailsFormState createState() => _AMUDetailsFormState();
}

class _AMUDetailsFormState extends State<AMUDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _customAntimicrobialController = TextEditingController();
  final _customDosageController = TextEditingController();
  
  String? selectedAnimalType;
  String? selectedAntimicrobial;
  String? selectedReason;
  String? selectedDosage;
  DateTime selectedDate = DateTime.now();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      String finalAntimicrobial = selectedAntimicrobial == 'अन्य (Other)' 
          ? _customAntimicrobialController.text 
          : selectedAntimicrobial!;
      
      String finalDosage = selectedDosage == 'अन्य (Other)'
          ? _customDosageController.text
          : selectedDosage!;

      DataStore.records.add(AMURecord(
        farmerName: DataStore.currentUser,
        phoneNumber: _phoneController.text,
        antimicrobialName: finalAntimicrobial,
        animalType: selectedAnimalType!,
        dosage: finalDosage,
        reasonForUse: selectedReason!,
        date: selectedDate,
      ));
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('रिकॉर्ड सफलतापूर्वक जमा किया गया! (Record submitted successfully!)'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Color(0xFF0F7F19)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2FCFE),
      appBar: AppBar(
        title: Text(
          '${widget.userRole} दवा रिकॉर्ड (Medicine Record)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF0F7F19),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            // Animal Type Dropdown with large, visual design
            _buildLargeDropdown(
              'जानवर का प्रकार (Animal Type)',
              Icons.pets,
              selectedAnimalType,
              AppData.animalTypes,
              (value) => setState(() => selectedAnimalType = value),
            ),
            SizedBox(height: 20),

            // Antimicrobial Dropdown
            _buildLargeDropdown(
              'दवा का नाम (Medicine Name)',
              Icons.medication,
              selectedAntimicrobial,
              AppData.commonAntimicrobials,
              (value) => setState(() => selectedAntimicrobial = value),
            ),
            
            // Custom antimicrobial field if "Other" selected
            if (selectedAntimicrobial == 'अन्य (Other)') ...[
              SizedBox(height: 16),
              _buildLargeTextField(
                'कस्टम दवा का नाम (Custom Medicine Name)',
                _customAntimicrobialController,
                Icons.edit,
              ),
            ],
            SizedBox(height: 20),

            // Dosage Dropdown
            _buildLargeDropdown(
              'खुराक (Dosage)',
              Icons.colorize,
              selectedDosage,
              AppData.dosageOptions,
              (value) => setState(() => selectedDosage = value),
            ),
            
            // Custom dosage field if "Other" selected
            if (selectedDosage == 'अन्य (Other)') ...[
              SizedBox(height: 16),
              _buildLargeTextField(
                'कस्टम खुराक (Custom Dosage)',
                _customDosageController,
                Icons.edit,
              ),
            ],
            SizedBox(height: 20),

            // Reason Dropdown
            _buildLargeDropdown(
              'दवा देने का कारण (Reason for Medicine)',
              Icons.healing,
              selectedReason,
              AppData.reasonsForUse,
              (value) => setState(() => selectedReason = value),
            ),
            SizedBox(height: 20),

            // Date Picker with large button
            _buildLargeDatePicker(),
            SizedBox(height: 20),

            // Phone Number with large input
            _buildLargeTextField(
              'फ़ोन नंबर (Phone Number)',
              _phoneController,
              Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 30),

            // Large Submit Button
            Container(
              height: 65,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0F7F19),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  'रिकॉर्ड जमा करें (SUBMIT RECORD)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeDropdown(String label, IconData icon, String? value, 
      List<String> items, Function(String?) onChanged) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xFF0F7F19), size: 30),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        ),
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item, style: TextStyle(fontSize: 16)),
        )).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'कृपया चुनें (Please select)' : null,
        dropdownColor: Colors.white,
        style: TextStyle(color: Colors.black87, fontSize: 16),
      ),
    );
  }

  Widget _buildLargeTextField(String label, TextEditingController controller, 
      IconData icon, {TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xFF0F7F19), size: 30),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        ),
        validator: (value) => value!.isEmpty ? 'कृपया भरें (Please fill)' : null,
      ),
    );
  }

  Widget _buildLargeDatePicker() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: ElevatedButton(
        onPressed: _selectDate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Color(0xFF0F7F19), size: 30),
            SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'दिनांक (Date)',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}