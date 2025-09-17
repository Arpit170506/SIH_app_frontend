import 'package:flutter/material.dart';
import '../data_store.dart';
import '../amu_record.dart';
import '../utils/helpers.dart';
import 'amu_details_form.dart';

// ===================== ENHANCED VET DASHBOARD =====================
class VetDashboard extends StatefulWidget {
  @override
  _VetDashboardState createState() => _VetDashboardState();
}

class _VetDashboardState extends State<VetDashboard> {
  @override
  Widget build(BuildContext context) {
    final pendingRecords = DataStore.records.where((r) => r.status == 'pending').length;

    return Scaffold(
      backgroundColor: Color(0xFFF2FCFE),
      appBar: AppBar(
        title: Text(
          'पशु चिकित्सक डैशबोर्ड (Vet Dashboard)',
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
            // Stats card
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('$pendingRecords', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                      Text('प्रतीक्षा में (Pending)', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('${DataStore.records.length}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F7F19))),
                      Text('कुल रिकॉर्ड (Total)', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _buildLargeActionButton(
                    'अपना रिकॉर्ड\nजोड़ें\n(Add Record)',
                    Icons.add_circle_outline,
                    Color(0xFF4CAF50),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AMUDetailsForm(userRole: 'Vet'),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildLargeActionButton(
                    'वीडियो\nसलाह\n(Consultation)',
                    Icons.video_call,
                    Color(0xFF2196F3),
                    () => showPlaceholderDialog(context, 'Video Consultation'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            Expanded(
              child: DataStore.records.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            'कोई रिकॉर्ड समीक्षा के लिए नहीं\n(No records to review)',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: DataStore.records.length,
                      itemBuilder: (context, index) =>
                          _buildEnhancedVetRecordCard(DataStore.records[index]),
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

  Widget _buildEnhancedVetRecordCard(AMURecord record) {
    Color statusColor;
    switch (record.status) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
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
        border: Border(
          left: BorderSide(color: statusColor, width: 4),
        ),
      ),   
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: Color(0xFF0F7F19), size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'किसान: ${record.farmerName} (Farmer)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              if (record.status == 'pending')
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'नया (NEW)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          
          // Medicine and Animal info
          Row(
            children: [
              Icon(Icons.medication, color: Colors.grey[600], size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${record.antimicrobialName}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          
          Row(
            children: [
              Icon(Icons.pets, color: Colors.grey[600], size: 18),
              SizedBox(width: 8),
              Text('${record.animalType}', style: TextStyle(fontSize: 14)),
              SizedBox(width: 20),
              Icon(Icons.phone, color: Colors.grey[600], size: 18),
              SizedBox(width: 8),
              Text('${record.phoneNumber}', style: TextStyle(fontSize: 14)),
            ],
          ),
          SizedBox(height: 6),
          
          Row(
            children: [
              Icon(Icons.colorize, color: Colors.grey[600], size: 18),
              SizedBox(width: 8),
              Text('खुराक: ${record.dosage}', style: TextStyle(fontSize: 14)),
              SizedBox(width: 20),
              Icon(Icons.calendar_today, color: Colors.grey[600], size: 18),
              SizedBox(width: 8),
              Text('${record.date.day}/${record.date.month}/${record.date.year}', 
                   style: TextStyle(fontSize: 14)),
            ],
          ),
          SizedBox(height: 6),
          
          Row(
            children: [
              Icon(Icons.healing, color: Colors.grey[600], size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text('कारण: ${record.reasonForUse}', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
          
          if (record.status == 'pending') ...[
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        int idx = DataStore.records.indexOf(record);
                        DataStore.records[idx] = record.copyWith(status: 'approved');
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('रिकॉर्ड स्वीकृत किया गया! (Record approved!)'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: Icon(Icons.check, color: Colors.white),
                    label: Text(
                      'स्वीकार करें (Approve)',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        int idx = DataStore.records.indexOf(record);
                        DataStore.records[idx] = record.copyWith(status: 'rejected');
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('रिकॉर्ड अस्वीकार किया गया! (Record rejected!)'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    icon: Icon(Icons.close, color: Colors.white),
                    label: Text(
                      'अस्वीकार करें (Reject)',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  record.status == 'approved' ? Icons.check_circle : Icons.cancel,
                  color: statusColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  record.status == 'approved' ? 'स्वीकृत (Approved)' : 'अस्वीकृत (Rejected)',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
