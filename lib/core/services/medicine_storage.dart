// ─────────────────────────────────────────────
//  medicine_storage.dart  –  Memomate
//  Handles daily tracking of medicine taken status.
// ─────────────────────────────────────────────

import 'package:shared_preferences/shared_preferences.dart';

class MedicineStorage {
  MedicineStorage._();

  /// Formulates a unique preference key for a medicine based on its ID or Name, 
  /// scoped to the current day. This ensures status resets every day.
  static String _getKey(String medicineId, String medicineName) {
    final today = DateTime.now().toIso8601String().split('T').first;
    final identifier = medicineId.isNotEmpty ? medicineId : medicineName;
    return 'taken_medicine_${identifier}_$today';
  }

  static String _getCountKey(String medicineId, String medicineName) {
    final today = DateTime.now().toIso8601String().split('T').first;
    final identifier = medicineId.isNotEmpty ? medicineId : medicineName;
    return 'taken_count_${identifier}_$today';
  }

  /// Checks if a medicine has been marked as taken today.
  static Future<bool> isTaken(String medicineId, String medicineName) async {
    if (medicineId.isEmpty && medicineName.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_getKey(medicineId, medicineName)) ?? false;
  }

  /// Sets the daily taken status of a medicine.
  static Future<void> setTaken(String medicineId, String medicineName, bool taken) async {
    if (medicineId.isEmpty && medicineName.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_getKey(medicineId, medicineName), taken);
  }

  /// Gets the count of doses taken today.
  static Future<int> getTakenCount(String medicineId, String medicineName) async {
    if (medicineId.isEmpty && medicineName.isEmpty) return 0;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_getCountKey(medicineId, medicineName)) ?? 0;
  }

  /// Sets the count of doses taken today.
  static Future<void> setTakenCount(String medicineId, String medicineName, int count) async {
    if (medicineId.isEmpty && medicineName.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_getCountKey(medicineId, medicineName), count);
  }
}
