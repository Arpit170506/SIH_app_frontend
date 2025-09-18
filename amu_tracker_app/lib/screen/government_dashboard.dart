import 'package:flutter/material.dart';
import '../data_store.dart';
import '../utils/helpers.dart';

class GovernmentDashboard extends StatelessWidget {
  const GovernmentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final totalFarms = DataStore.records.map((r) => r.farmerName).toSet().length;
    final totalVets = 3;
    final totalRecords = DataStore.records.length;
    final approvedRecords = DataStore.records.where((r) => r.status == 'approved').length;
    final pendingRecords = DataStore.records.where((r) => r.status == 'pending').length;
    final acceptancePercentage = totalRecords > 0 ? (approvedRecords / totalRecords) * 100 : 0.0;

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
      body: ListView(
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
              _buildStatCard('Accepted % (स्वीकृत %)', '${acceptancePercentage.toStringAsFixed(1)}%', Icons.check_circle, Colors.green),
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