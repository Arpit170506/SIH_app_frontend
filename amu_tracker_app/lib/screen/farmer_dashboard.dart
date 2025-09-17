import 'package:flutter/material.dart';
import '../data_store.dart';
import '../amu_record.dart';
import 'amu_details_form.dart';
import '../utils/helpers.dart';

// ===================== ENHANCED FARMER DASHBOARD =====================
class FarmerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userRecords = DataStore.records
        .where((r) => r.farmerName == DataStore.currentUser)
        .toList();

    return Scaffold(
      backgroundColor: Color(0xFFF2FCFE),
      appBar: AppBar(
        title: Text(
          'किसान डैशबोर्ड (Farmer Dashboard)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF0F7F19),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: 28),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Welcome message
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
                ],
              ),
              child: Text(
                'नमस्ते ${DataStore.currentUser}! (Hello ${DataStore.currentUser}!)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),

            // Action Buttons with larger, more visual design
            Row(
              children: [
                Expanded(
                  child: _buildLargeActionButton(
                    'दवा रिकॉर्ड\nजोड़ें\n(Add Medicine)',
                    Icons.add_circle_outline,
                    Color(0xFF4CAF50),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AMUDetailsForm(userRole: 'Farmer'),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildLargeActionButton(
                    'वीडियो\nसलाह\n(Video Call)',
                    Icons.video_call,
                    Color(0xFF2196F3),
                    () => showPlaceholderDialog(context, 'Video Consultation'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Records Section with better header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'आपके रिकॉर्ड (Your Records): ${userRecords.length}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12),

            // Records List
            Expanded(
              child: userRecords.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            'कोई रिकॉर्ड नहीं मिला\n(No records found)',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: userRecords.length,
                      itemBuilder: (context, index) => 
                          _buildEnhancedRecordCard(userRecords[index]),
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

  Widget _buildLargeActionButton(
      String title, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      height: 120,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedRecordCard(AMURecord record) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (record.status) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'स्वीकृत (Approved)';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'अस्वीकृत (Rejected)';
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'प्रतीक्षा में (Pending)';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pets, color: Color(0xFF0F7F19), size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${record.antimicrobialName}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'जानवर: ${record.animalType}',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          Text(
            'खुराक: ${record.dosage}',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          Text(
            'दिनांक: ${record.date.day}/${record.date.month}/${record.date.year}',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(statusIcon, size: 20, color: statusColor),
              SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
