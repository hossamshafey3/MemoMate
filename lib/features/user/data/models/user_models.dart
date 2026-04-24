// ─────────────────────────────────────────────
//  user_models.dart  –  Memomate
//  Models for user (patient/caregiver) feature.
// ─────────────────────────────────────────────

// ── Login request ──────────────────────────────
class UserLoginModel {
  final String email;
  final String password;

  const UserLoginModel({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

// ── User profile (returned inside "data") ──────
class UserProfile {
  final String id;
  final String caregiverName;
  final String email;
  final String relationship;
  final String caregiverPhone;
  final String patientName;
  final String patientImage;
  final int age;
  final String about;
  final int weight;
  final String address;
  final String patientPhone;
  final List<String> diseaseHistory;
  final String memoryProblem;
  final List<String> allergies;
  final List<dynamic> medicines;
  final String createdAt;
  final String updatedAt;

  const UserProfile({
    required this.id,
    required this.caregiverName,
    required this.email,
    required this.relationship,
    required this.caregiverPhone,
    required this.patientName,
    required this.patientImage,
    required this.age,
    required this.about,
    required this.weight,
    required this.address,
    required this.patientPhone,
    required this.diseaseHistory,
    required this.memoryProblem,
    required this.allergies,
    required this.medicines,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['_id'] as String? ?? '',
    caregiverName: json['caregiverName'] as String? ?? '',
    email: json['email'] as String? ?? '',
    relationship: json['relationship'] as String? ?? '',
    caregiverPhone: json['caregiverPhone'] as String? ?? '',
    patientName: json['patientName'] as String? ?? '',
    patientImage: json['patientImage'] as String? ?? '',
    age: (json['age'] as num?)?.toInt() ?? 0,
    about: json['about'] as String? ?? '',
    weight: (json['weight'] as num?)?.toInt() ?? 0,
    address: json['address'] as String? ?? '',
    patientPhone: json['patientPhone'] as String? ?? '',
    diseaseHistory:
        (json['diseaseHistory'] as List?)?.map((e) => e.toString()).toList() ??
        [],
    memoryProblem: json['memoryProblem'] as String? ?? '',
    allergies:
        (json['allergies'] as List?)?.map((e) => e.toString()).toList() ?? [],
    medicines: json['medicines'] as List? ?? [],
    createdAt: json['createdAt'] as String? ?? '',
    updatedAt: json['updatedAt'] as String? ?? '',
  );
}

// ── Full login response ─────────────────────────
class UserLoginResponse {
  final String token;
  final UserProfile profile;

  const UserLoginResponse({required this.token, required this.profile});

  factory UserLoginResponse.fromJson(Map<String, dynamic> json) =>
      UserLoginResponse(
        token: json['token'] as String? ?? '',
        profile: UserProfile.fromJson(
          json['data'] as Map<String, dynamic>? ?? {},
        ),
      );
}
