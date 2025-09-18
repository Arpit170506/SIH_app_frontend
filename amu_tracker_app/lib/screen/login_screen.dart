import 'package:flutter/material.dart';
import '../data_store.dart';
import '../utils/helpers.dart';
import 'farmer_dashboard.dart';
import 'vet_dashboard.dart';
import 'government_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
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

      await Future.delayed(const Duration(seconds: 1));

      DataStore.currentUser = _usernameController.text;
      DataStore.currentRole = _selectedRole;

      if (!mounted) return;

      if (_selectedRole == 'Farmer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FarmerDashboard()),
        );
      } else if (_selectedRole == 'Vet') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VetDashboard()),
        );
      } else if (_selectedRole == 'Government') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GovernmentDashboard()),
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
      backgroundColor: const Color(0xFF558B2F),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.agriculture,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'PureVet',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          'Login (लॉग इन करें)',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 30),

                        TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Username (उपयोगकर्ता नाम)',
                            prefixIcon: Icon(Icons.person, color: Colors.grey.shade600),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF558B2F)),
                            ),
                          ),
                          validator: (value) => value!.isEmpty ? 'Please enter name (कृपया नाम भरें)' : null,
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Password (पासवर्ड)',
                            prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF558B2F)),
                            ),
                          ),
                          validator: (value) => value!.isEmpty ? 'Please enter password (कृपया पासवर्ड भरें)' : null,
                        ),
                        const SizedBox(height: 20),

                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: InputDecoration(
                            labelText: 'Select Role (भूमिका चुनें)',
                            prefixIcon: Icon(Icons.work, color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF558B2F)),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Farmer',
                              child: Text('Farmer (किसान)', style: TextStyle(fontSize: 16)),
                            ),
                            DropdownMenuItem(
                              value: 'Vet',
                              child: Text('Vet (पशु चिकित्सक)', style: TextStyle(fontSize: 16)),
                            ),
                            DropdownMenuItem(
                              value: 'Government',
                              child: Text('Government (सरकारी)', style: TextStyle(fontSize: 16)),
                            ),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _selectedRole = val!;
                            });
                          },
                        ),
                        
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => showPlaceholderDialog(context, 'Forgot Password (पासवर्ड भूल गए)'),
                            child: const Text(
                              'Forgot Password? (पासवर्ड भूल गए?)',
                              style: TextStyle(
                                color: Color(0xFF558B2F),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF558B2F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Login (लॉग इन करें)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'OR (या)',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                          ],
                        ),
                        
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () => showPlaceholderDialog(context, 'Google Sign-In'),
                            // --- UPDATED: Replaced image asset with a code-based placeholder icon ---
                            icon: const Text(
                              'G',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.blueAccent),
                            ),
                            label: const Text(
                              'Sign in with Google (Google से साइन इन करें)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}