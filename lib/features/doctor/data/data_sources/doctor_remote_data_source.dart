// ─────────────────────────────────────────────
//  doctor_remote_data_source.dart  –  Memomate
//  Remote data source for Doctor feature.
// ─────────────────────────────────────────────

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:gradproj/core/api/endpoints.dart';
import 'package:gradproj/core/errors/exceptions.dart';
import 'package:gradproj/features/doctor/data/models/doctor_model.dart';
import 'package:gradproj/features/doctor/data/models/patient_model.dart';

abstract class DoctorRemoteDataSource {
  /// POSTs a new doctor registration to the API.
  Future<DoctorProfile> registerDoctor(DoctorRegisterModel model);

  /// POSTs doctor login credentials and returns the login response (token + profile).
  Future<DoctorLoginResponse> loginDoctor(DoctorLoginModel model);

  /// PUTs updated doctor fields — requires the JWT token for Authorization.
  Future<DoctorProfile> updateDoctor(String token, Map<String, dynamic> fields);

  /// GETs the doctor's profile containing populated `requests` (patients).
  Future<List<PatientModel>> getPatientRequests(String token);

  /// GETs the doctor's accepted patients.
  Future<List<PatientModel>> getDoctorPatients(String token);

  /// POSTs an accept/decline action for a specific patient.
  Future<String> respondToRequest(String token, String patientId, String status);

  /// DELETEs a patient from the doctor's active list.
  Future<void> deleteDoctorPatient(String token, String patientId);
}

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final Dio _dio;

  DoctorRemoteDataSourceImpl(this._dio);

  // Safely convert response body to Map regardless of whether
  // Dio parsed the JSON or left it as a raw String.
  Map<String, dynamic> _parseBody(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    // Handle Map<dynamic, dynamic> (sometimes produced by Dio/jsonDecode)
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          return decoded.map((k, v) => MapEntry(k.toString(), v));
        }
      } catch (_) {}
    }
    return {};
  }

  @override
  Future<DoctorProfile> registerDoctor(DoctorRegisterModel model) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.doctorRegister}',
        data: model.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          // Don't throw on non-2xx so we can read the body ourselves
          validateStatus: (status) => true,
        ),
      );

      final body = _parseBody(response.data);
      final success = body['success'] as bool? ?? false;

      if (success) {
        return DoctorProfile.fromJson(_parseBody(body['data']));
      } else {
        final message =
            body['message'] as String? ?? 'Registration failed. Try again.';
        throw ServerException(
          message: message,
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const RequestTimeoutException();
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const NoInternetException();
      }
      final body = _parseBody(e.response?.data);
      final message =
          body['message'] as String? ?? 'An unexpected error occurred.';
      throw ServerException(
        message: message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<DoctorLoginResponse> loginDoctor(DoctorLoginModel model) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.doctorLogin}',
        data: model.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) => true,
        ),
      );

      final body = _parseBody(response.data);
      final success = body['success'] as bool? ?? false;

      if (success) {
        return DoctorLoginResponse.fromJson(body);
      } else {
        final message =
            body['message'] as String? ?? 'Login failed. Try again.';
        throw ServerException(
          message: message,
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const RequestTimeoutException();
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const NoInternetException();
      }
      final body = _parseBody(e.response?.data);
      final message =
          body['message'] as String? ?? 'An unexpected error occurred.';
      throw ServerException(
        message: message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<DoctorProfile> updateDoctor(
    String token,
    Map<String, dynamic> fields,
  ) async {
    try {
      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.doctorUpdate}';

      final response = await _dio.put(
        url,
        data: jsonEncode(fields),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) => true,
        ),
      );

      // ignore: avoid_print
      print(
        '[updateDoctor] status=${response.statusCode} body=${response.data}',
      );

      final body = _parseBody(response.data);
      final rawSuccess = body['success'];
      final success =
          rawSuccess == true || rawSuccess.toString().toLowerCase() == 'true';

      if (success) {
        return DoctorProfile.fromJson(_parseBody(body['data']));
      } else {
        final message =
            body['message'] as String? ??
            body['error'] as String? ??
            'Update failed (status ${response.statusCode}).';
        throw ServerException(
          message: message,
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const RequestTimeoutException();
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const NoInternetException();
      }
      final body = _parseBody(e.response?.data);
      final message =
          body['message'] as String? ?? 'An unexpected error occurred.';
      throw ServerException(
        message: message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<PatientModel>> getPatientRequests(String token) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.doctorRequests}',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) => true,
        ),
      );

      final body = _parseBody(response.data);
      final rawSuccess = body['success'];
      final success =
          rawSuccess == true || rawSuccess.toString().toLowerCase() == 'true';

      if (success && body['data'] != null) {
        final data = body['data'];

        List<dynamic> requestsList = [];
        if (data is Map && data.containsKey('requests')) {
          requestsList = data['requests'] as List<dynamic>? ?? [];
        } else if (data is List) {
          requestsList = data; // API returns the list directly in 'data'
        }

        return requestsList
            .map((e) => PatientModel.fromJson(_parseBody(e)))
            .toList();
      } else {
        final message =
            body['message'] as String? ?? 'Failed to fetch requests.';
        throw ServerException(
          message: message,
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const RequestTimeoutException();
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const NoInternetException();
      }
      final body = _parseBody(e.response?.data);
      final message =
          body['message'] as String? ?? 'An unexpected error occurred.';
      throw ServerException(
        message: message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<PatientModel>> getDoctorPatients(String token) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.doctorPatients}',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) => true,
        ),
      );

      final body = _parseBody(response.data);
      final rawSuccess = body['success'];
      final success =
          rawSuccess == true || rawSuccess.toString().toLowerCase() == 'true';

      if (success) {
        final data = body['data'];
        
        List<dynamic> patientsList = [];
        if (data is Map && data.containsKey('patients')) {
          patientsList = data['patients'] as List<dynamic>? ?? [];
        } else if (data is List) {
          patientsList = data; // In case the API returns the array directly inside data
        }

        return patientsList
            .map((e) => PatientModel.fromJson(_parseBody(e)))
            .toList();
      } else {
        final message =
            body['message'] as String? ?? 'Failed to fetch patients.';
        throw ServerException(
          message: message,
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const RequestTimeoutException();
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const NoInternetException();
      }
      final body = _parseBody(e.response?.data);
      final message =
          body['message'] as String? ?? 'An unexpected error occurred.';
      throw ServerException(
        message: message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<String> respondToRequest(
    String token,
    String patientId,
    String status,
  ) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.doctorRequests}',
        data: {'status': status, 'patientId': patientId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) => true,
        ),
      );

      final body = _parseBody(response.data);
      final rawSuccess = body['success'];
      final success =
          rawSuccess == true || rawSuccess.toString().toLowerCase() == 'true';

      final message = body['message'] as String? ?? '';

      if (success) {
        return message;
      } else {
        throw ServerException(
          message: message.isNotEmpty ? message : 'Failed to respond to request.',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const RequestTimeoutException();
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const NoInternetException();
      }
      final body = _parseBody(e.response?.data);
      final message =
          body['message'] as String? ?? 'An unexpected error occurred.';
      throw ServerException(
        message: message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteDoctorPatient(String token, String patientId) async {
    try {
      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.withId(ApiEndpoints.deleteDoctorPatient, patientId)}';
      final response = await _dio.delete(
        url,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) => true,
        ),
      );

      final body = _parseBody(response.data);
      final success = body['success'] as bool? ?? false;

      if (!success) {
        final message = body['message'] as String? ?? 'Failed to delete patient.';
        throw ServerException(
          message: message,
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const RequestTimeoutException();
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const NoInternetException();
      }
      final body = _parseBody(e.response?.data);
      final message =
          body['message'] as String? ?? 'An unexpected error occurred.';
      throw ServerException(
        message: message,
        statusCode: e.response?.statusCode,
      );
    }
  }
}
