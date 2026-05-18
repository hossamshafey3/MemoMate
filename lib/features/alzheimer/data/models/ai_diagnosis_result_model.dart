// ─────────────────────────────────────────────────────────────────────────────
//  ai_diagnosis_result_model.dart  –  Memomate
//  Represents a full AI text diagnosis result (32 clinical features).
//  Used to POST to /api/patient/checks on the Memomate backend.
// ─────────────────────────────────────────────────────────────────────────────

class AiDiagnosisResultModel {
  // ── Core result ───────────────────────────────────────────────────────────
  final bool alzheimerDetected; // true = Detected, false = Not Detected

  // ── All 32 clinical features (as collected by the wizard) ─────────────────
  final Map<String, dynamic> clinicalFeatures;

  const AiDiagnosisResultModel({
    required this.alzheimerDetected,
    required this.clinicalFeatures,
  });

  /// Converts the model into the JSON body expected by
  /// POST /api/patient/checks
  Map<String, dynamic> toJson(String patientId) {
    return {
      'features': clinicalFeatures,
      'patient_id': patientId,
      'result': alzheimerDetected ? 1 : 0, // Number for /checks
      'accuracy': 0.95,
      'text_data': alzheimerDetected ? 'Alzheimer\'s Detected' : 'No Alzheimer\'s Detected',
    };
  }
}
