import 'package:flutter/material.dart';
import '../data_store.dart';
import '../amu_record.dart';
import '../utils/helpers.dart';

// ===================== ENHANCED GOVERNMENT DASHBOARD =====================
class GovernmentDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final totalRecords = DataStore.records.length;
    final approvedRecords = DataStore.records.where((r) => r.status == 'approved').length;
    final pendingRecords = DataStore.records.where((r) => r.status == 'pending').length;
    final rejectedRecords = DataStore.records.where((r) => r.status == 'rejected').length;

    return Scaffold(
      backgroundColor: Color(0xFFF2FCFE),
      appBar: AppBar(
        title: Text(
          'सरकारी डैशबोर्ड (Government Dashboard)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF0F7F19),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: 28),
            onPressed: () => logout(context),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'कुल रिकॉर्ड\n(Total Records)', 
                    '$totalRecords', 
                    Color(0xFF0F7F19),
                    Icons.description,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'स्वीकृत\n(Approved)', 
                    '$approvedRecords', 
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'प्रतीक्षा में\n(Pending)', 
                    '$pendingRecords', 
                    Colors.orange,
                    Icons.pending,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'अस्वीकृत\n(Rejected)', 
                    '$rejectedRecords', 
                    Colors.red,
                    Icons.cancel,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            // Analytics Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.analytics, size: 60, color: Color(0xFF0F7F19)),
                  SizedBox(height: 16),
                  Text(
                    'विश्लेषण और रिपोर्ट\n(Analytics & Reports)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F7F19),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'क्षेत्रवार और वर्षवार AMU डेटा\n(Area-wise and Year-wise AMU data)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => showPlaceholderDialog(context, 'Analytics'),
                    icon: Icon(Icons.bar_chart, color: Colors.white),
                    label: Text(
                      'विस्तृत रिपोर्ट देखें (View Detailed Reports)',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0F7F19),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Recent Activities
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'हाल की गतिविधियां (Recent Activities)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F7F19),
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: totalRecords == 0
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inbox, size: 60, color: Colors.grey[400]),
                                  SizedBox(height: 16),
                                  Text(
                                    'कोई गतिविधि नहीं\n(No activities yet)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: DataStore.records.take(5).length,
                              itemBuilder: (context, index) {
                                final record = DataStore.records[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Color(0xFF0F7F19),
                                    child: Icon(Icons.medication, color: Colors.white),
                                  ),
                                  title: Text(
                                    '${record.farmerName} ने ${record.antimicrobialName} का रिकॉर्ड जमा किया',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    '${record.date.day}/${record.date.month}/${record.date.year}',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  trailing: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: record.status == 'approved' 
                                          ? Colors.green 
                                          : record.status == 'rejected'
                                          ? Colors.red
                                          : Colors.orange,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      record.status == 'approved' 
                                          ? 'स्वीकृत' 
                                          : record.status == 'rejected'
                                          ? 'अस्वीकृत'
                                          : 'प्रतीक्षा',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showPlaceholderDialog(context, 'Notifications'),
        backgroundColor: Color(0xFFFFC107),
        icon: Icon(Icons.notifications, size: 28),
        label: Text('सूचना (Alert)', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
