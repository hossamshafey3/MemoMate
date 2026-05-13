// ─────────────────────────────────────────────────────────────────────────────
//  mri_classification_model.dart  –  Memomate
//  Represents an MRI-only scan result from the AI classifier.
//  Used to POST to /api/patient/mri on the Memomate backend.
// ─────────────────────────────────────────────────────────────────────────────

class MriClassificationModel {
  /// Human-readable label returned by the AI, e.g.:
  ///   "No Impairment" | "Very Mild Impairment" | "Mild Impairment" | "Moderate Impairment"
  final String mriResult;

  /// Optional confidence string as returned by the AI, e.g. "94.2%"
  final String? confidence;

  const MriClassificationModel({
    required this.mriResult,
    this.confidence,
  });

  // ── Numeric level mapping (0–3) ───────────────────────────────────────────
  static const Map<String, int> _levelMap = {
    'No Impairment': 0,
    'Very Mild Impairment': 1,
    'Mild Impairment': 2,
    'Moderate Impairment': 3,
  };

  int get numericLevel => _levelMap[mriResult] ?? 0;

  /// Converts to the JSON body expected by POST /api/patient/mri
  Map<String, dynamic> toJson(String patientId) {
    return {
      'features': {}, // Empty features for MRI only
      'patient_id': patientId,
      'result': mriResult, // String for /mri
      'accuracy': 0.95,
      'text_data': mriResult, 
    };
  }
}
