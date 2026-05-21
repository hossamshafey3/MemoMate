// ─────────────────────────────────────────────
//  patient_model.dart  –  Memomate
// ─────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class PatientModel extends Equatable {
  final String id;
  final String caregiverName;
  final String patientName;
  final String patientImage;
  final int age;
  final String relationship;
  final String caregiverPhone;
  final String patientPhone;
  final String email;
  final String about;
  final num weight;
  final String address;
  final List<String> diseaseHistory;
  final String memoryProblem;
  final List<String> allergies;
  final List<dynamic> checks;
  final List<dynamic> mriResults;

  const PatientModel({
    required this.id,
    required this.caregiverName,
    required this.patientName,
    required this.patientImage,
    required this.age,
    required this.relationship,
    this.caregiverPhone = '',
    this.patientPhone = '',
    this.email = '',
    this.about = '',
    this.weight = 0,
    this.address = '',
    this.diseaseHistory = const [],
    this.memoryProblem = '',
    this.allergies = const [],
    this.checks = const [],
    this.mriResults = const [],
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['_id'] ?? '',
      caregiverName: json['caregiverName'] ?? '',
      patientName: json['patientName'] ?? '',
      patientImage: json['patientImage'] ?? '',
      age: json['age'] is int
          ? json['age']
          : int.tryParse(json['age']?.toString() ?? '0') ?? 0,
      relationship: json['relationship'] ?? '',
      caregiverPhone: json['caregiverPhone'] ?? '',
      patientPhone: json['patientPhone'] ?? '',
      email: json['email'] ?? '',
      about: json['about'] ?? '',
      weight: json['weight'] is num
          ? json['weight']
          : num.tryParse(json['weight']?.toString() ?? '0') ?? 0,
      address: json['address'] ?? '',
      diseaseHistory: json['diseaseHistory'] is List
          ? (json['diseaseHistory'] as List).map((e) => e.toString()).toList()
          : [],
      memoryProblem: json['memoryProblem'] ?? '',
      allergies: json['allergies'] is List
          ? (json['allergies'] as List).map((e) => e.toString()).toList()
          : [],
      checks: json['checks'] is List ? json['checks'] as List : const [],
      mriResults: json['mriResults'] is List ? json['mriResults'] as List : const [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        caregiverName,
        patientName,
        patientImage,
        age,
        relationship,
        caregiverPhone,
        patientPhone,
        email,
        about,
        weight,
        address,
        diseaseHistory,
        memoryProblem,
        allergies,
        checks,
        mriResults,
      ];
}
