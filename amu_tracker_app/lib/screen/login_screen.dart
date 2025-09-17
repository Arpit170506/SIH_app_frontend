import 'package:flutter/material.dart';
import '../data_store.dart';
import 'farmer_dashboard.dart';
import 'vet_dashboard.dart';
import 'government_dashboard.dart';

// ======= ENHANCED LOGIN SCREEN =======
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'Farmer';
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate loading delay
      await Future.delayed(Duration(seconds: 1));

      DataStore.currentUser = _usernameController.text;
      DataStore.currentRole = _selectedRole;

      if (_selectedRole == 'Farmer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => FarmerDashboard()),
        );
      } else if (_selectedRole == 'Vet') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => VetDashboard()),
        );
      } else if (_selectedRole == 'Government') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => GovernmentDashboard()),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2FCFE),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Logo/Icon
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF0F7F19).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.agriculture,
                      size: 60,
                      color: Color(0xFF0F7F19),
                    ),
                  ),
                  SizedBox(height: 20),

                  Text(
                    'AMU ट्रैकर में स्वागत\n(Welcome to AMU Tracker)',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F7F19),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),

                  // Username Field
                  TextFormField(
                    controller: _usernameController,
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'उपयोगकर्ता नाम (Username)',
                      prefixIcon: Icon(Icons.person, color: Color(0xFF0F7F19), size: 28),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Color(0xFFF2FCFE),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      labelStyle: TextStyle(fontSize: 16),
                    ),
                    validator: (value) => value!.isEmpty ? 'कृपया नाम भरें (Please enter name)' : null,
                  ),
                  SizedBox(height: 20),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'पासवर्ड (Password)',
                      prefixIcon: Icon(Icons.lock, color: Color(0xFF0F7F19), size: 28),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Color(0xFFF2FCFE),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      labelStyle: TextStyle(fontSize: 16),
                    ),
                    validator: (value) => value!.isEmpty ? 'कृपया पासवर्ड भरें (Please enter password)' : null,
                  ),
                  SizedBox(height: 20),

                  // Role Selection Dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF2FCFE),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: InputDecoration(
                        labelText: 'भूमिका चुनें (Select Role)',
                        prefixIcon: Icon(Icons.work, color: Color(0xFF0F7F19), size: 28),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color(0xFFF2FCFE),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        labelStyle: TextStyle(fontSize: 16),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'Farmer',
                          child: Text('किसान (Farmer)', style: TextStyle(fontSize: 16)),
                        ),
                        DropdownMenuItem(
                          value: 'Vet',
                          child: Text('पशु चिकित्सक (Vet)', style: TextStyle(fontSize: 16)),
                        ),
                        DropdownMenuItem(
                          value: 'Government',
                          child: Text('सरकारी अधिकारी (Government)', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedRole = val!;
                        });
                      },
                      dropdownColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),

                  // Login Button
                  Container(
                    height: 60,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0F7F19),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'लॉग इन करें (LOGIN)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Demo accounts info
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF0F7F19).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'डेमो के लिए कोई भी नाम और पासवर्ड डालें\n(Enter any name and password for demo)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0F7F19),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
