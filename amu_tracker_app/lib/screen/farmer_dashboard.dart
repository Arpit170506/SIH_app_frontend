import 'package:flutter/material.dart';
import '../api_service.dart'; // Import the new service
import '../data_store.dart';
import '../amu_record.dart';
import '../utils/helpers.dart';
import 'amu_details_form.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  int _selectedIndex = 0;
  bool _hasNewAlerts = false; 

  // --- REFACTOR: Keys and ApiService instance ---
  final ApiService _apiService = ApiService();
  final GlobalKey<_DashboardPageState> _dashboardPageKey = GlobalKey<_DashboardPageState>();
  final GlobalKey<_RecordsPageState> _recordsPageKey = GlobalKey<_RecordsPageState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Pass the ApiService instance to each page
    _pages = [
      _DashboardPage(key: _dashboardPageKey, apiService: _apiService),
      _RecordsPage(key: _recordsPageKey, apiService: _apiService),
      _NotificationsPage(apiService: _apiService),
      const _ProfilePage(),
    ];
  }
  
  void _triggerRefresh() {
    // Refresh the pages using their GlobalKeys
    _dashboardPageKey.currentState?.refreshStats();
    _recordsPageKey.currentState?.refreshRecords();
    setState(() {
      _hasNewAlerts = true; 
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) {
        _hasNewAlerts = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (context) => AMUDetailsForm(userRole: 'Farmer')),
                ).then((value) {
                  if (value == true) _triggerRefresh();
                });
              },
              backgroundColor: const Color(0xFF558B2F),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("New Record (नया रिकॉर्ड)", style: TextStyle(color: Colors.white)),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF558B2F),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard (डैशबोर्ड)'),
          const BottomNavigationBarItem(icon: Icon(Icons.folder_copy_rounded), label: 'Records (रिकॉर्ड्स)'),
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

class _DashboardPage extends StatefulWidget {
  final ApiService apiService;
  const _DashboardPage({required this.apiService, super.key});
  @override
  State<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage> {
  Future<Map<String, dynamic>>? _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = widget.apiService.fetchFarmerStats(DataStore.currentUser);
  }

  void refreshStats() {
    setState(() {
      _statsFuture = widget.apiService.fetchFarmerStats(DataStore.currentUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF558B2F),
        title: const Text('Farmer Dashboard (किसान डैशबोर्ड)'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => logout(context))],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No stats available.'));
          }

          final stats = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async { refreshStats(); },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text('Welcome (नमस्ते), ${DataStore.currentUser}!', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Here is your activity summary.', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                const SizedBox(height: 24),
                _buildStatCard('Total Applications (कुल आवेदन)', '${stats['total'] ?? 0}', Icons.all_inbox, Colors.blue.shade700),
                const SizedBox(height: 16),
                _buildStatCard('Approval % (स्वीकृति %)', '${stats['percentage'] ?? 0.0}%', Icons.check_circle, Colors.green.shade700),
                const SizedBox(height: 16),
                _buildStatCard('Rejected Applications (अस्वीकृत)', '${stats['rejected'] ?? 0}', Icons.cancel, Colors.red.shade700),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showPlaceholderDialog(context, 'Video Consultation (वीडियो सलाह)'),
        label: const Text('Video Consult (वीडियो सलाह)', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.video_call, color: Colors.white),
        backgroundColor: const Color(0xFF558B2F),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }  
}

class _RecordsPage extends StatefulWidget {
  final ApiService apiService;
  const _RecordsPage({required this.apiService, super.key});
  @override
  State<_RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<_RecordsPage> {
  Future<List<AMURecord>>? _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = widget.apiService.fetchFarmerRecords(DataStore.currentUser);
  }

  void refreshRecords() {
    setState(() {
      _recordsFuture = widget.apiService.fetchFarmerRecords(DataStore.currentUser);
    });
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF558B2F),
        foregroundColor: Colors.white,
        title: const Text('Treatment Records (उपचार रिकॉर्ड्स)'),
      ),
      body: FutureBuilder<List<AMURecord>>(
        future: _recordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No records found. (कोई रिकॉर्ड नहीं मिला)',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            );
          }

          final records = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async { refreshRecords(); },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text('Animal ID (पशु ID): ${record.animalId}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text('Drug (दवा): ${record.antimicrobialName}\nDate (तारीख): ${record.date.toLocal().toString().split(' ')[0]}'),
                    trailing: _buildStatusChip(record.status),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final Color color;
    final String label;
    if (status == 'approved') {
      color = Colors.green;
      label = 'Approved (स्वीकृत)';
    } else if (status == 'rejected') {
      color = Colors.red;
      label = 'Rejected (अस्वीकृत)';
    } else {
      color = Colors.orange;
      label = 'Pending (लंबित)';
    }
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _NotificationsPage extends StatefulWidget {
  final ApiService apiService;
  const _NotificationsPage({required this.apiService, super.key});
  @override
  State<_NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<_NotificationsPage> {
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
        title: const Text('Alerts (सूचनाएं)'),
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
            return const Center(
              child: Text('No new alerts. (कोई नई सूचना नहीं है)', style: TextStyle(fontSize: 16)),
            );
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
                    title: Text('Alert for Animal ID (पशु ID): ${alert['animalId']}'),
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

class _ProfilePage extends StatefulWidget {
  const _ProfilePage();
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _cattleCountController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: DataStore.currentUser);
    _cattleCountController = TextEditingController(text: '25');
    _phoneController = TextEditingController(text: '999XXXXX99');
    _emailController = TextEditingController(text: '${DataStore.currentUser}@domain.com');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cattleCountController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _toggleEditSave() {
    setState(() {
      if (_isEditing) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved! (प्रोफ़ाइल सेव हो गया!)'), backgroundColor: Colors.green),
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
        title: const Text('Profile (प्रोफ़ाइल)'),
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
          _buildProfileField(_cattleCountController, 'Number of Cattle (पशुओं की संख्या)', Icons.pets, enabled: _isEditing, isNumeric: true),
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