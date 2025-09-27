import 'package:flutter/material.dart';
import '../api_service.dart'; // Import the new service
import '../amu_record.dart';
import '../utils/helpers.dart';
import 'amu_details_form.dart';

// ===================================================================
// MAIN VET DASHBOARD WIDGET
// ===================================================================
class VetDashboard extends StatefulWidget {
  const VetDashboard({super.key});
  @override
  State<VetDashboard> createState() => _VetDashboardState();
}

class _VetDashboardState extends State<VetDashboard> {
  int _selectedIndex = 0;
  bool _hasNewAlerts = false;
  
  final GlobalKey<_VetDashboardPageState> _dashboardPageKey = GlobalKey<_VetDashboardPageState>();
  final GlobalKey<_VetRecordsPageState> _recordsPageKey = GlobalKey<_VetRecordsPageState>();
  final GlobalKey<_VetAlertsPageState> _alertsPageKey = GlobalKey<_VetAlertsPageState>();

  late final List<Widget> _pages;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _pages = [
      _VetDashboardPage(key: _dashboardPageKey, apiService: _apiService, onRecordUpdate: _refreshAllPages, onApproval: _triggerAlerts),
      _VetRecordsPage(key: _recordsPageKey, apiService: _apiService, onRecordAdded: _refreshAllPages),
      _VetAlertsPage(key: _alertsPageKey, apiService: _apiService),
      const _VetProfilePage(),
    ];
  }

  void _refreshAllPages() {
    _dashboardPageKey.currentState?.refreshRecords();
    _recordsPageKey.currentState?.refreshRecords();
    _alertsPageKey.currentState?.refreshAlerts();
  }

  void _triggerAlerts() {
    setState(() => _hasNewAlerts = true);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) _hasNewAlerts = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF558B2F),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard (डैशबोर्ड)'),
          const BottomNavigationBarItem(icon: Icon(Icons.folder_copy_rounded), label: 'History (इतिहास)'),
          BottomNavigationBarItem(
            icon: Badge(isLabelVisible: _hasNewAlerts, child: const Icon(Icons.notifications_rounded)),
            label: 'Alerts (सूचनाएं)',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile (प्रोफ़ाइल)'),
        ],
      ),
    );
  }
}

// ===================================
// PAGE 1: REVIEW PENDING
// ===================================
class _VetDashboardPage extends StatefulWidget {
  final ApiService apiService;
  final VoidCallback onRecordUpdate;
  final VoidCallback onApproval;
  const _VetDashboardPage({required this.apiService, required this.onRecordUpdate, required this.onApproval, super.key});
  @override
  State<_VetDashboardPage> createState() => _VetDashboardPageState();
}

class _VetDashboardPageState extends State<_VetDashboardPage> {
  Future<List<AMURecord>>? _pendingRecordsFuture;

  @override
  void initState() {
    super.initState();
    _pendingRecordsFuture = widget.apiService.fetchPendingRecords();
  }
  
  void refreshRecords() {
    setState(() {
      _pendingRecordsFuture = widget.apiService.fetchPendingRecords();
    });
  }

  Future<void> _updateRecordStatus(BuildContext context, AMURecord record, String newStatus) async {
    try {
      final success = await widget.apiService.updateRecordStatus(record.prescriptionId, newStatus);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Record has been ${newStatus.toLowerCase()}!'),
            backgroundColor: newStatus == 'approved' ? Colors.green : Colors.red,
          ),
        );
        
        if (newStatus == 'approved') {
          widget.onApproval();
        }
        widget.onRecordUpdate();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF558B2F),
        foregroundColor: Colors.white,
        title: const Text('Review Pending (लंबित समीक्षा)'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => logout(context))],
      ),
      body: FutureBuilder<List<AMURecord>>(
        future: _pendingRecordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No pending records to review.', style: TextStyle(fontSize: 16)));
          }
          final pendingRecords = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async { refreshRecords(); },
            child: ListView.builder(
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
        },
      ),
    );
  }
}

// ===================================
// PAGE 2: ALL RECORDS (HISTORY)
// ===================================
class _VetRecordsPage extends StatefulWidget {
  final ApiService apiService;
  final VoidCallback onRecordAdded;
  const _VetRecordsPage({required this.apiService, required this.onRecordAdded, super.key});
  @override
  State<_VetRecordsPage> createState() => _VetRecordsPageState();
}

class _VetRecordsPageState extends State<_VetRecordsPage> {
  Future<List<AMURecord>>? _allRecordsFuture;

  @override
  void initState() {
    super.initState();
    _allRecordsFuture = widget.apiService.fetchAllRecords();
  }

  void refreshRecords() {
    setState(() {
      _allRecordsFuture = widget.apiService.fetchAllRecords();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF558B2F),
        foregroundColor: Colors.white,
        title: const Text('All Records History (सभी रिकॉर्ड)'),
      ),
      body: FutureBuilder<List<AMURecord>>(
        future: _allRecordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No records in the system yet.', style: TextStyle(fontSize: 16)));
          }
          final allRecords = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async { refreshRecords(); },
            child: ListView.builder(
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => AMUDetailsForm(userRole: 'Vet')))
              .then((value) {
            if (value == true) {
              widget.onRecordAdded();
            }
          });
        },
        backgroundColor: const Color(0xFF558B2F),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Record (रिकॉर्ड जोड़ें)", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// ===================================
// PAGE 3: ALERTS
// ===================================
class _VetAlertsPage extends StatefulWidget {
  final ApiService apiService;
  const _VetAlertsPage({required this.apiService, super.key});
  @override
  State<_VetAlertsPage> createState() => _VetAlertsPageState();
}

class _VetAlertsPageState extends State<_VetAlertsPage> {
  Future<List<dynamic>>? _alertsFuture;

  @override
  void initState() {
    super.initState();
    _alertsFuture = widget.apiService.fetchAlerts();
  }
  
  void refreshAlerts() {
    setState(() {
      _alertsFuture = widget.apiService.fetchAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF558B2F),
        foregroundColor: Colors.white,
        title: const Text('System Alerts (सिस्टम सूचनाएं)'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No new alerts. (कोई नई सूचना नहीं है)', style: TextStyle(fontSize: 16)));
          }
          final alerts = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async { refreshAlerts(); },
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 40),
                    title: Text('Alert for Farmer: ${alert['farmerName']} (Animal ID: ${alert['animalId']})'),
                    subtitle: Text(
                      'Next Dosage Date: ${alert['nextDosageDate']}\nअगली खुराक की तारीख: ${alert['nextDosageDate']}\n\nWaiting Time: ${alert['waitingTime']} days\nप्रतीक्षा समय: ${alert['waitingTime']} दिन',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


// ===================================
// PAGE 4: PROFILE (No changes needed here as it's static)
// ===================================
class _VetProfilePage extends StatefulWidget {
  const _VetProfilePage({super.key});
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
    _nameController = TextEditingController(text: 'Dr. Aanchal Yadav'); // Assuming static for now
    _licenseController = TextEditingController(text: 'VET12345');
    _phoneController = TextEditingController(text: '9876543210');
    _emailController = TextEditingController(text: 'aanchal.yadav@vet.com');
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