// ======= AMU Record =======
class AMURecord {
  final String farmerName;
  final String phoneNumber;
  final String antimicrobialName;
  final String animalType;
  final String dosage;
  final String reasonForUse;
  final DateTime date;
  final String status;

  AMURecord({
    required this.farmerName,
    required this.phoneNumber,
    required this.antimicrobialName,
    required this.animalType,
    required this.dosage,
    required this.reasonForUse,
    required this.date,
    this.status = 'pending',
  });

  AMURecord copyWith({String? status}) {
    return AMURecord(
      farmerName: this.farmerName,
      phoneNumber: this.phoneNumber,
      antimicrobialName: this.antimicrobialName,
      animalType: this.animalType,
      dosage: this.dosage,
      reasonForUse: this.reasonForUse,
      date: this.date,
      status: status ?? this.status,
    );
  }
}