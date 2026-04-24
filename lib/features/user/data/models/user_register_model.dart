// ─────────────────────────────────────────────
//  user_register_model.dart  –  Memomate
//  Model for caregiver + patient registration.
// ─────────────────────────────────────────────

class UserRegisterModel {
  // ── Caregiver ──────────────────────────────
  final String caregiverName;
  final String email;
  final String password;
  final String caregiverGender;
  final String relationship;
  final String caregiverPhone;

  // ── Patient ────────────────────────────────
  final String patientName;
  final String patientImage;
  final String patientGender;
  final int age;
  final String about;
  final int weight;
  final String address;
  final String patientPhone;
  final List<String> diseaseHistory;
  final String memoryProblem;
  final List<String> allergies;

  const UserRegisterModel({
    required this.caregiverName,
    required this.email,
    required this.password,
    required this.caregiverGender,
    required this.relationship,
    required this.caregiverPhone,
    required this.patientName,
    required this.patientImage,
    required this.patientGender,
    required this.age,
    required this.about,
    required this.weight,
    required this.address,
    required this.patientPhone,
    required this.diseaseHistory,
    required this.memoryProblem,
    required this.allergies,
  });

  Map<String, dynamic> toJson() => {
    'caregiverName': caregiverName,
    'email': email,
    'password': password,
    'caregiverGender': caregiverGender,
    'relationship': relationship,
    'caregiverPhone': caregiverPhone,
    'patientName': patientName,
    'patientImage': patientImage,
    'patientGender': patientGender,
    'age': age,
    'about': about,
    'weight': weight,
    'address': address,
    'patientPhone': patientPhone,
    'diseaseHistory': diseaseHistory,
    'memoryProblem': memoryProblem,
    'allergies': allergies,
    'medicines': [], // always sent empty
  };
}
