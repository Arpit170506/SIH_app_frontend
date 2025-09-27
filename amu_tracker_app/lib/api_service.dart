import 'dart:convert';
import 'package:http/http.dart' as http;
import 'amu_record.dart';
import 'data_store.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.56.1:3000/api';

  // --- NEW: Government Dashboard Endpoint ---
  Future<Map<String, dynamic>> fetchGovernmentStats() async {
    final url = Uri.parse('$_baseUrl/stats/government');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load government stats');
    }
  }

  // --- Farmer Dashboard Endpoints ---
  Future<Map<String, dynamic>> fetchFarmerStats(String farmerName) async {
    final url = Uri.parse('$_baseUrl/stats/farmer/$farmerName');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load farmer stats');
    }
  }

  Future<List<AMURecord>> fetchFarmerRecords(String farmerName) async {
    final url = Uri.parse('$_baseUrl/records/farmer/$farmerName');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AMURecord.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load farmer records');
    }
  }

  // --- Vet Dashboard Endpoints ---
  Future<List<AMURecord>> fetchPendingRecords() async {
    final url = Uri.parse('$_baseUrl/records/pending');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AMURecord.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load pending records');
    }
  }

  Future<List<AMURecord>> fetchAllRecords() async {
    final url = Uri.parse('$_baseUrl/records/all');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AMURecord.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load all records');
    }
  }

  Future<bool> updateRecordStatus(String prescriptionId, String newStatus) async {
    final url = Uri.parse('$_baseUrl/records/update-status');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "prescriptionId": prescriptionId,
        "newStatus": newStatus,
      }),
    );
    return response.statusCode == 200;
  }

  // --- General Endpoints ---
  Future<List<dynamic>> fetchAlerts() async {
    final userName = DataStore.currentUser;
    final url = Uri.parse('$_baseUrl/alerts/farmer/$userName');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load alerts');
    }
  }

  Future<http.Response> submitNewRecord(Map<String, dynamic> recordData) async {
    final url = Uri.parse('$_baseUrl/record');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(recordData),
    );
    return response;
  }
}