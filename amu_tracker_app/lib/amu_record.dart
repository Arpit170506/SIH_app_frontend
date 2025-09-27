// ======= AMU Record =======
class AMURecord {
  final String farmerName;
  final String phoneNumber;
  final String antimicrobialName;
  final String animalType;
  final String animalId;
  final String dosage;
  final String reason;
  final DateTime date;
  final String status;
  // Added from backend
  final String prescriptionId;

  AMURecord({
    required this.farmerName,
    required this.phoneNumber,
    required this.antimicrobialName,
    required this.animalType,
    required this.animalId,
    required this.dosage,
    required this.reason,
    required this.date,
    required this.status,
    required this.prescriptionId,
  });

  // --- NEW FACTORY CONSTRUCTOR ---
  // This creates an AMURecord from a JSON object
  factory AMURecord.fromJson(Map<String, dynamic> json) {
    return AMURecord(
      farmerName: json['farmerName'],
      phoneNumber: json['phoneNumber'],
      antimicrobialName: json['antimicrobialName'],
      animalType: json['animalType'],
      animalId: json['animalId'],
      dosage: json['dosage'],
      reason: json['reasonForUse'], // Note the key name change
      date: DateTime.parse(json['date']),
      status: json['status'],
      prescriptionId: json['prescriptionId'],
    );
  }
}