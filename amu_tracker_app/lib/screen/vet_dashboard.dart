import 'package:flutter/material.dart';
import '../data_store.dart';
import '../amu_record.dart';
import '../utils/helpers.dart';
import 'amu_details_form.dart';

class VetDashboard extends StatefulWidget {
  const VetDashboard({super.key});

  @override
  State<VetDashboard> createState() => _VetDashboardState();
}

class _VetDashboardState extends State<VetDashboard> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _VetDashboardPage(onRecordUpdate: () => setState(() {})),
      _VetRecordsPage(onRecordAdded: () => setState(() {})),
      const _VetAlertsPage(),
      _VetProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF558B2F),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard (डैशबोर्ड)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_copy_rounded),
            label: 'History (इतिहास)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_rounded),
            label: 'Alerts (सूचनाएं)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile (प्रोफ़ाइल)',
          ),
        ],
      ),
    );
  }
}

class _VetDashboardPage extends StatelessWidget {
  final VoidCallback onRecordUpdate;
  const _VetDashboardPage({required this.onRecordUpdate});

  void _updateRecordStatus(BuildContext context, AMURecord record, String newStatus) {
    final index = DataStore.records.indexWhere((r) => r == record);
    if (index != -1) {
      DataStore.records[index] = record.copyWith(status: newStatus);
      onRecordUpdate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Record has been ${newStatus.toLowerCase()}!'),
          backgroundColor: newStatus == 'approved' ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingRecords = DataStore.records.where((r) => r.status == 'pending').toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF558B2F),
        foregroundColor: Colors.white,
        title: const Text('Review Pending (लंबित समीक्षा)'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => logout(context))],
      ),
      body: pendingRecords.isEmpty
          ? Center(
              child: Text(
                'No pending records to review.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: pendingRecords.length,
              itemBuilder: (context, index) {
                final record = pendingRecords[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Farmer (किसान): ${record.farmerName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const Divider(height: 20),
                        Text('Animal (पशु): ${record.animalType} (ID: ${record.animalId})'),
                        Text('Drug (दवा): ${record.antimicrobialName}'),
                        Text('Dosage (खुराक): ${record.dosage}'),
                        Text('Reason (कारण): ${record.reason}'),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.close),
                              label: const Text('Reject (अस्वीकार)'),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              onPressed: () => _updateRecordStatus(context, record, 'rejected'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check, color: Colors.white),
                              label: const Text('Approve (स्वीकार)', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              onPressed: () => _updateRecordStatus(context, record, 'approved'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _VetRecordsPage extends StatelessWidget {
  final VoidCallback onRecordAdded;
  const _VetRecordsPage({required this.onRecordAdded});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = DataStore.records;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF558B2F),
        foregroundColor: Colors.white,
        title: const Text('All Records History (सभी रिकॉर्ड)'),
      ),
      body: allRecords.isEmpty
          ? Center(
              child: Text(
                'No records in the system yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
              itemCount: allRecords.length,
              itemBuilder: (context, index) {
                final record = allRecords[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: _getStatusColor(record.status), width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text('Farmer (किसान): ${record.farmerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Animal ID: ${record.animalId}\nDrug (दवा): ${record.antimicrobialName}'),
                    trailing: Chip(
                      label: Text(record.status.toUpperCase(), style: const TextStyle(color: Colors.white)),
                      backgroundColor: _getStatusColor(record.status),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => AMUDetailsForm(userRole: 'Vet')))
              .then((value) {
            if (value == true) onRecordAdded();
          });
        },
        backgroundColor: const Color(0xFF558B2F),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Record (रिकॉर्ड जोड़ें)", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _VetAlertsPage extends StatelessWidget {
  const _VetAlertsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF558B2F),
        foregroundColor: Colors.white,
        title: const Text('System Alerts (सिस्टम सूचनाएं)'),
      ),
      body: DataStore.records.isEmpty
          ? Center(
              child: Text(
                'No notifications available.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: DataStore.records.length,
              itemBuilder: (context, index) {
                final record = DataStore.records[index];
                final nextDoseDate = record.date.add(const Duration(days: 90));
                const withdrawalDays = 15;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: ListTile(
                    leading: Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 36),
                    title: Text('Alert for (सूचना): ${record.animalId} (Farmer: ${record.farmerName})'),
                    subtitle: Text(
                      'Next Dose (अगली खुराक): ${nextDoseDate.day}/${nextDoseDate.month}/${nextDoseDate.year}\nWithdrawal (निकासी): $withdrawalDays days',
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _VetProfilePage extends StatefulWidget {
  @override
  _VetProfilePageState createState() => _VetProfilePageState();
}

class _VetProfilePageState extends State<_VetProfilePage> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _licenseController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: DataStore.currentUser);
    _licenseController = TextEditingController(text: 'VET12345');
    _phoneController = TextEditingController(text: '9876543210');
    _emailController = TextEditingController(text: '${DataStore.currentUser}@vet.com');
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _licenseController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _toggleEditSave() {
    setState(() {
      if (_isEditing) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved!'), backgroundColor: Colors.green),
        );
      }
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF558B2F),
        foregroundColor: Colors.white,
        title: const Text('Vet Profile (प्रोफ़ाइल)'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: _toggleEditSave,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              label: Text(_isEditing ? 'Save (सेव करें)' : 'Edit (बदलें)'),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileField(_nameController, 'Full Name (पूरा नाम)', Icons.person, enabled: _isEditing),
          const SizedBox(height: 16),
          _buildProfileField(_licenseController, 'License Number (लाइसेंस नंबर)', Icons.verified_user, enabled: _isEditing),
          const SizedBox(height: 16),
          _buildProfileField(_phoneController, 'Phone Number (फ़ोन नंबर)', Icons.phone, enabled: _isEditing, isNumeric: true),
          const SizedBox(height: 16),
          _buildProfileField(_emailController, 'Email Address (ईमेल पता)', Icons.email, enabled: _isEditing),
        ],
      ),
    );
  }

  Widget _buildProfileField(TextEditingController controller, String label, IconData icon,
      {required bool enabled, bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        filled: !enabled,
        fillColor: Colors.grey.shade200,
      ),
    );
  }
}