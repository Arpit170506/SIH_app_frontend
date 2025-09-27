import 'package:flutter/material.dart';
import '../api_service.dart'; // Import the service
import '../utils/helpers.dart';

class GovernmentDashboard extends StatefulWidget {
  const GovernmentDashboard({super.key});

  @override
  State<GovernmentDashboard> createState() => _GovernmentDashboardState();
}

class _GovernmentDashboardState extends State<GovernmentDashboard> {
  // --- REFACTOR: Use ApiService and a Future ---
  final ApiService _apiService = ApiService();
  Future<Map<String, dynamic>>? _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _apiService.fetchGovernmentStats();
  }

  Future<void> _refreshStats() async {
    setState(() {
      _statsFuture = _apiService.fetchGovernmentStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF558B2F),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Authority Dashboard (प्राधिकरण)'),
            Text('Compliance monitoring overview', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
          ],
        ),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => logout(context))],
      ),
      // --- REFACTOR: Use a FutureBuilder to handle loading/error states ---
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No statistics found."));
          }

          final stats = snapshot.data!;
          final totalFarms = stats['totalFarms'] ?? 0;
          final totalVets = stats['totalVets'] ?? 0;
          final pendingRecords = stats['pendingRecords'] ?? 0;
          final acceptancePercentage = stats['acceptancePercentage'] ?? 0.0;

          return RefreshIndicator(
            onRefresh: _refreshStats,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text('Quick Stats (त्वरित आँकड़े)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildStatCard('Farms Connected (जुड़े फार्म)', '$totalFarms', Icons.agriculture, Colors.orange),
                    _buildStatCard('Vets Connected (जुड़े वेट्स)', '$totalVets', Icons.medical_services, Colors.blue),
                    _buildStatCard('Accepted % (स्वीकृत %)', '${acceptancePercentage}%', Icons.check_circle, Colors.green),
                    _buildStatCard('Pending (लंबित)', '$pendingRecords', Icons.hourglass_top, Colors.red),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Analytics (विश्लेषण)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildGraphPlaceholderCard(
                  title: 'Area-wise Compliance (क्षेत्र-वार)',
                  subtitle: 'Compliance rates across regions.',
                  icon: Icons.bar_chart,
                  color: Colors.purple,
                ),
                const SizedBox(height: 16),
                _buildGraphPlaceholderCard(
                  title: 'Report Status (रिपोर्ट स्थिति)',
                  subtitle: 'Approved vs. Rejected vs. Pending.',
                  icon: Icons.pie_chart,
                  color: Colors.teal,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 32, color: color),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphPlaceholderCard({required String title, required String subtitle, required IconData icon, required Color color}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 16),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(icon, size: 60, color: color.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}