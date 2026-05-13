// ─────────────────────────────────────────────
//  auth_storage.dart  –  Memomate
//  Persists JWT tokens and profiles for both
//  doctor and user sessions using SharedPrefs.
// ─────────────────────────────────────────────

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gradproj/features/doctor/data/models/doctor_model.dart';
import 'package:gradproj/features/user/data/models/user_models.dart';

class AuthStorage {
  AuthStorage._();

  // ── Doctor keys ────────────────────────────
  static const _keyDoctorToken = 'doctor_token';
  static const _keyDoctorProfile = 'doctor_profile';

  // ── User (caregiver) keys ──────────────────
  static const _keyUserToken = 'user_token';
  static const _keyUserProfile = 'user_profile';

  // ── Last active role (patient / caregiver) ─
  static const _keyLastRole = 'last_role';

  // ════════════════════════════════════════════
  //  DOCTOR SESSION
  // ════════════════════════════════════════════
  static Future<void> saveSession({
    required String token,
    required DoctorProfile profile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDoctorToken, token);
    await prefs.setString(
      _keyDoctorProfile,
      jsonEncode({
        '_id': profile.id,
        'name': profile.name,
        'email': profile.email,
        'image': profile.image,
        'specialization': profile.specialization,
        'degree': profile.degree,
        'experience': profile.experience,
        'about': profile.about,
        'available': profile.available,
        'requests': profile.requests,
        'patients': profile.patients,
        'createdAt': profile.createdAt,
        'updatedAt': profile.updatedAt,
      }),
    );
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDoctorToken);
  }

  static Future<DoctorProfile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyDoctorProfile);
    if (raw == null) return null;
    try {
      return DoctorProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDoctorToken);
    await prefs.remove(_keyDoctorProfile);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ════════════════════════════════════════════
  //  USER (CAREGIVER) SESSION
  // ════════════════════════════════════════════
  static Future<void> saveUserSession({
    required String token,
    required UserProfile profile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserToken, token);
    await prefs.setString(
      _keyUserProfile,
      jsonEncode({
        '_id': profile.id,
        'caregiverName': profile.caregiverName,
        'email': profile.email,
        'relationship': profile.relationship,
        'caregiverPhone': profile.caregiverPhone,
        'patientName': profile.patientName,
        'patientImage': profile.patientImage,
        'age': profile.age,
        'about': profile.about,
        'weight': profile.weight,
        'address': profile.address,
        'patientPhone': profile.patientPhone,
        'diseaseHistory': profile.diseaseHistory,
        'memoryProblem': profile.memoryProblem,
        'allergies': profile.allergies,
        'medicines': profile.medicines,
        'createdAt': profile.createdAt,
        'updatedAt': profile.updatedAt,
      }),
    );
  }

  static Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserToken);
  }

  static Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUserProfile);
    if (raw == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserToken);
    await prefs.remove(_keyUserProfile);
    await prefs.remove(_keyLastRole);
  }

  static Future<bool> isUserLoggedIn() async {
    final token = await getUserToken();
    return token != null && token.isNotEmpty;
  }

  // ════════════════════════════════════════════
  //  LAST ACTIVE ROLE  ('patient' | 'caregiver')
  // ════════════════════════════════════════════
  static Future<void> saveLastRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastRole, role);
  }

  static Future<String?> getLastRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastRole);
  }
}
