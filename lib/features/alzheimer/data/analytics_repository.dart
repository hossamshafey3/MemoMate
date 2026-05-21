// ─────────────────────────────────────────────────────────────────────────────
//  analytics_repository.dart  –  Memomate
//  Fetches the patient's historical health-check records and MRI results
//  from the backend and maps them into the shape expected by AnalyticsBloc.
//
//  Endpoints used (both require Bearer token):
//    GET /api/patient/checks  →  list of 32-feature check objects
//    GET /api/patient/mri     →  list of MRI-result objects
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:gradproj/core/api/api_interceptors.dart';
import 'package:gradproj/core/api/endpoints.dart';
import 'package:gradproj/core/services/auth_storage.dart';
import 'models/ai_diagnosis_result_model.dart';
import 'models/mri_classification_model.dart';

class AnalyticsRepository {
  // ── Dio instance scoped to this repository ───────────────────────────────
  final Dio _dio;

  AnalyticsRepository()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        ) {
    _dio.interceptors.add(ApiInterceptors());
  }

  // ── MRI label → numeric level ─────────────────────────────────────────────
  static double _mriLabelToLevel(String? label) {
    switch ((label ?? '').toLowerCase()) {
      case 'no impairment':
        return 0.0;
      case 'very mild impairment':
        return 1.0;
      case 'mild impairment':
        return 2.0;
      case 'moderate impairment':
        return 3.0;
      default:
        return 0.0;
    }
  }

  // ── Safe numeric extractor ────────────────────────────────────────────────
  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  PUBLIC API
  // ══════════════════════════════════════════════════════════════════════════

  /// Fetches both /patient/checks and /patient/mri, then combines them into
  /// the [Map<String, dynamic>] shape that AnalyticsBloc stores in its state.
  ///
  /// The returned map always contains:
  ///   - 'dates'            : List of DateTime
  ///   - 'Vitals & Labs'    : List of List of double  (7 sub-features x N entries)
  ///   - 'Cognitive Tests'  : List of List of double
  ///   - 'Lifestyle'        : List of List of double
  ///   - 'Behavioral Check' : List of List of double
  ///   - 'Medical History'  : List of List of double
  ///   - 'MRI Progression'  : List of List of double
  Future<Map<String, dynamic>> getHistoricalAnalytics() async {
    // ── Attach the patient JWT before every call ──────────────────────────
    final token = await AuthStorage.getUserToken();
    if (token != null && token.isNotEmpty) {
      ApiInterceptors.setToken(token);
    }

    // ── Parallel fetch ────────────────────────────────────────────────────
    final results = await Future.wait([
      _dio.get(ApiEndpoints.patientChecks),
      _dio.get(ApiEndpoints.patientMri),
    ]);

    final checksRaw = results[0].data;
    final mriRaw    = results[1].data;

    // Normalise to List<Map>
    final checks = _asList(checksRaw);
    final mriList = _asList(mriRaw);

    // ── Build column-oriented lists from row-oriented JSON ────────────────
    //    Each List<double> below represents ONE sub-feature across all entries.

    // ── Dates ─────────────────────────────────────────────────────────────
    final dates = checks.map<DateTime>((e) {
      final raw = e['createdAt'] ?? e['created_at'] ?? e['date'];
      if (raw != null) {
        try { return DateTime.parse(raw.toString()); } catch (_) {}
      }
      return DateTime.now();
    }).toList();

    // ── Vitals & Labs (8 sub-features) ────────────────────────────────────
    final bmi           = checks.map((e) => _toDouble(e['features']?['BMI'] ?? e['BMI'])).toList();
    final systolicBp    = checks.map((e) => _toDouble(e['features']?['SystolicBP'] ?? e['SystolicBP'])).toList();
    final diastolicBp   = checks.map((e) => _toDouble(e['features']?['DiastolicBP'] ?? e['DiastolicBP'])).toList();
    final cholTotal     = checks.map((e) => _toDouble(e['features']?['CholesterolTotal'] ?? e['CholesterolTotal'])).toList();
    final cholLdl       = checks.map((e) => _toDouble(e['features']?['CholesterolLDL'] ?? e['CholesterolLDL'])).toList();
    final cholHdl       = checks.map((e) => _toDouble(e['features']?['CholesterolHDL'] ?? e['CholesterolHDL'])).toList();
    final triglycerides = checks.map((e) => _toDouble(e['features']?['CholesterolTriglycerides'] ?? e['CholesterolTriglycerides'])).toList();
    final hypertension  = checks.map((e) => _toDouble(e['features']?['Hypertension'] ?? e['Hypertension'])).toList();

    // ── Cognitive Tests (3 sub-features) ─────────────────────────────────
    final mmse        = checks.map((e) => _toDouble(e['features']?['MMSE'] ?? e['MMSE'])).toList();
    final functional  = checks.map((e) => _toDouble(e['features']?['FunctionalAssessment'] ?? e['FunctionalAssessment'])).toList();
    final adl         = checks.map((e) => _toDouble(e['features']?['ADL'] ?? e['ADL'])).toList();

    // ── Lifestyle (5 sub-features) ────────────────────────────────────────
    final smoking         = checks.map((e) => _toDouble(e['features']?['Smoking'] ?? e['Smoking'])).toList();
    final alcohol         = checks.map((e) => _toDouble(e['features']?['AlcoholConsumption'] ?? e['AlcoholConsumption'])).toList();
    final physicalActivity= checks.map((e) => _toDouble(e['features']?['PhysicalActivity'] ?? e['PhysicalActivity'])).toList();
    final dietQuality     = checks.map((e) => _toDouble(e['features']?['DietQuality'] ?? e['DietQuality'])).toList();
    final sleepQuality    = checks.map((e) => _toDouble(e['features']?['SleepQuality'] ?? e['SleepQuality'])).toList();

    // ── Behavioral Check (7 sub-features) ────────────────────────────────
    final memoryComplaints     = checks.map((e) => _toDouble(e['features']?['MemoryComplaints'] ?? e['MemoryComplaints'])).toList();
    final behavioralProblems   = checks.map((e) => _toDouble(e['features']?['BehavioralProblems'] ?? e['BehavioralProblems'])).toList();
    final confusion            = checks.map((e) => _toDouble(e['features']?['Confusion'] ?? e['Confusion'])).toList();
    final disorientation       = checks.map((e) => _toDouble(e['features']?['Disorientation'] ?? e['Disorientation'])).toList();
    final personalityChanges   = checks.map((e) => _toDouble(e['features']?['PersonalityChanges'] ?? e['PersonalityChanges'])).toList();
    final difficultyTasks      = checks.map((e) => _toDouble(e['features']?['DifficultyCompletingTasks'] ?? e['DifficultyCompletingTasks'])).toList();
    final forgetfulness        = checks.map((e) => _toDouble(e['features']?['Forgetfulness'] ?? e['Forgetfulness'])).toList();

    // ── Medical History (5 sub-features) ─────────────────────────────────
    final familyHistory        = checks.map((e) => _toDouble(e['features']?['FamilyHistoryAlzheimers'] ?? e['FamilyHistoryAlzheimers'])).toList();
    final cardiovascular       = checks.map((e) => _toDouble(e['features']?['CardiovascularDisease'] ?? e['CardiovascularDisease'])).toList();
    final diabetes             = checks.map((e) => _toDouble(e['features']?['Diabetes'] ?? e['Diabetes'])).toList();
    final depression           = checks.map((e) => _toDouble(e['features']?['Depression'] ?? e['Depression'])).toList();
    final headInjury           = checks.map((e) => _toDouble(e['features']?['HeadInjury'] ?? e['HeadInjury'])).toList();

    // ── MRI Progression (from mri endpoint, label → 0-3 level) ───────────
    final mriDates = mriList.map<DateTime>((e) {
      final raw = e['createdAt'] ?? e['created_at'] ?? e['date'];
      if (raw != null) {
        try { return DateTime.parse(raw.toString()); } catch (_) {}
      }
      return DateTime.now();
    }).toList();

    final mriLevels = mriList
        .map((e) => _mriLabelToLevel(
              e['mri_result']?.toString() ??
              e['result']?.toString() ??
              e['diagnosis']?.toString(),
            ))
        .toList();

    // ── Use the longer list as the primary date axis ──────────────────────
    final primaryDates = dates.isNotEmpty ? dates : mriDates;

    return {
      'dates': primaryDates,
      'mriDates': mriDates,
      'Vitals & Labs': [bmi, systolicBp, diastolicBp, cholTotal, cholLdl, cholHdl, triglycerides, hypertension],
      'Cognitive Tests': [mmse, functional, adl],
      'Lifestyle': [smoking, alcohol, physicalActivity, dietQuality, sleepQuality],
      'Behavioral Check': [
        memoryComplaints,
        behavioralProblems,
        confusion,
        disorientation,
        personalityChanges,
        difficultyTasks,
        forgetfulness,
      ],
      'Medical History': [familyHistory, cardiovascular, diabetes, depression, headInjury],
      'MRI Progression': [mriLevels],
    };
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SAVE NEW RESULTS  (auto-called after each diagnosis)
  // ══════════════════════════════════════════════════════════════════════════

  /// POSTs a full text-diagnosis result (32 features) to /api/patient/checks.
  Future<void> saveCheck(AiDiagnosisResultModel model) async {
    try {
      final token = await AuthStorage.getUserToken();
      if (token == null || token.isEmpty) {
        print('CRITICAL: Cannot save because Token is missing');
      }
      
      final profile = await AuthStorage.getUserProfile();
      final patientId = profile?.id;
      if (patientId == null) {
        print('CRITICAL: Cannot save because Patient ID is missing');
      }

      await _attachToken();
      
      // Ensure all features are numbers
      final cleanedFeatures = _cleanFeatures(model.clinicalFeatures);
      
      final body = {
        ...model.toJson(patientId ?? 'unknown'),
        'features': cleanedFeatures,
      };

      print('DEBUG: Sending POST to ${ApiEndpoints.baseUrl}${ApiEndpoints.patientChecks}');
      print('DEBUG: Body: ${jsonEncode(body)}');

      final response = await _dio.post(
        ApiEndpoints.patientChecks,
        data: jsonEncode(body),
        options: Options(
          headers: {'Content-Type': 'application/json'},
          followRedirects: false,
          validateStatus: (status) => true,
        ),
      );
      
      print('DEBUG: Server Response Code: ${response.statusCode}');
      print('DEBUG: Server Response Data: ${response.data}');
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Server returned ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('DEBUG: Save check failure: ${e.message}');
      print('DEBUG: Response data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('DEBUG: Unexpected error in saveCheck: $e');
      rethrow;
    }
  }

  /// POSTs an MRI classification result to /api/patient/mri.
  Future<void> saveMriResult(MriClassificationModel model) async {
    try {
      final token = await AuthStorage.getUserToken();
      if (token == null || token.isEmpty) {
        print('CRITICAL: Cannot save because Token is missing');
      }

      final profile = await AuthStorage.getUserProfile();
      final patientId = profile?.id;
      if (patientId == null) {
        print('CRITICAL: Cannot save because Patient ID is missing');
      }

      await _attachToken();

      final body = model.toJson(patientId ?? 'unknown');

      print('DEBUG: Sending POST to ${ApiEndpoints.baseUrl}${ApiEndpoints.patientMri}');
      print('DEBUG: Body: ${jsonEncode(body)}');

      final response = await _dio.post(
        ApiEndpoints.patientMri,
        data: jsonEncode(body),
        options: Options(
          headers: {'Content-Type': 'application/json'},
          followRedirects: false,
          validateStatus: (status) => true,
        ),
      );

      print('DEBUG: Server Response Code: ${response.statusCode}');
      print('DEBUG: Server Response Data: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Server returned ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('DEBUG: Save MRI failure: ${e.message}');
      print('DEBUG: Response data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('DEBUG: Unexpected error in saveMriResult: $e');
      rethrow;
    }
  }

  // ── Helper to ensure all values are num (int/double) ───────────────────
  Map<String, dynamic> _cleanFeatures(Map<String, dynamic> raw) {
    return raw.map((key, value) {
      if (value is String) {
        final parsed = double.tryParse(value);
        return MapEntry(key, parsed ?? 0.0);
      }
      if (value is bool) {
        return MapEntry(key, value ? 1 : 0);
      }
      return MapEntry(key, value);
    });
  }

  /// Fetches all saved records for the user.
  Future<List<Map<String, dynamic>>> getAllResults() async {
    await _attachToken();
    
    // We fetch from both endpoints and combine/sort them
    final results = await Future.wait([
      _dio.get(ApiEndpoints.patientChecks),
      _dio.get(ApiEndpoints.patientMri),
    ]);

    final checks = _asList(results[0].data);
    final mris = _asList(results[1].data);

    // Combine them into a single history list
    final List<Map<String, dynamic>> history = [];
    
    for (var check in checks) {
      history.add({
        ...check,
        'type': 'Full AI Diagnosis',
      });
    }
    
    for (var mri in mris) {
      history.add({
        ...mri,
        'type': 'MRI-Only',
      });
    }

    // Sort by date descending
    history.sort((a, b) {
      final dateA = DateTime.tryParse((a['createdAt'] ?? a['date'] ?? '').toString()) ?? DateTime(2000);
      final dateB = DateTime.tryParse((b['createdAt'] ?? b['date'] ?? '').toString()) ?? DateTime(2000);
      return dateB.compareTo(dateA);
    });

    return history;
  }

  // ── Internal: ensure token is fresh before every request ─────────────────
  Future<void> _attachToken() async {
    final token = await AuthStorage.getUserToken();
    if (token != null && token.isNotEmpty) {
      ApiInterceptors.setToken(token);
    }
  }

  // ── Helper: normalise API response to List<Map> ───────────────────────────
  static List<Map<String, dynamic>> _asList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw.whereType<Map<String, dynamic>>().toList();
    }
    // Some backends wrap the list: { "data": [...] }
    if (raw is Map) {
      final inner = raw['data'] ?? raw['checks'] ?? raw['results'] ?? raw['mri'];
      if (inner is List) {
        return inner.whereType<Map<String, dynamic>>().toList();
      }
    }
    return [];
  }
}
