// ─────────────────────────────────────────────
//  user_remote_data_source.dart  –  Memomate
//  Remote data source for User feature.
// ─────────────────────────────────────────────

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:gradproj/core/api/endpoints.dart';
import 'package:gradproj/core/errors/exceptions.dart';
import 'package:gradproj/features/doctor/data/models/doctor_model.dart';
import 'package:gradproj/features/user/data/models/user_models.dart';
import 'package:gradproj/features/user/data/models/user_register_model.dart';
import 'package:gradproj/features/user/data/models/reminder_model.dart';
import 'package:gradproj/features/user/data/models/family_member_model.dart';

abstract class UserRemoteDataSource {
  Future<void> registerUser(UserRegisterModel model);
  Future<UserLoginResponse> loginUser(UserLoginModel model);
  Future<UserProfile> updateUserProfile(
    Map<String, dynamic> data,
    String token,
  );
  Future<List<DoctorProfile>> getAllDoctors(String token);
  Future<void> requestDoctor(String doctorId, String token);
  Future<List<String>> getMyDoctors(String token);

  // Medicines (Reminders)
  Future<List<ReminderModel>> getMedicines(String token);
  Future<void> addMedicine(String token, ReminderModel medicine);
  Future<void> deleteMedicine(String token, String id);

  // Family Tree
  Future<List<FamilyMemberModel>> getFamilyTree(String token);
  Future<List<FamilyMemberModel>> addFamilyMember(String token, FamilyMemberModel member);
  Future<void> deleteFamilyMember(String token, String id);

  // Location
  Future<void> updateLocation(String token, double lat, double lng);
  Future<Map<String, dynamic>> getLastLocation(String token);

  // Profile
  Future<UserProfile> getProfile(String token);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio _dio;
  UserRemoteDataSourceImpl(this._dio);

  Map<String, dynamic> _parseBody(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return data.map((k, v) => MapEntry(k.toString(), v));
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

  // ── Register ────────────────────────────────────────────────────
  @override
  Future<void> registerUser(UserRegisterModel model) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.patientRegister}',
        data: jsonEncode(model.toJson()),
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

      if (!success) {
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

  // ── Login ───────────────────────────────────────────────────────
  @override
  Future<UserLoginResponse> loginUser(UserLoginModel model) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.patientLogin}',
        data: jsonEncode(model.toJson()),
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

      if (!success) {
        final message = body['message'] as String? ?? 'Invalid credentials.';
        throw ServerException(
          message: message,
          statusCode: response.statusCode,
        );
      }

      return UserLoginResponse.fromJson(body);
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

  // ── Update Profile ──────────────────────────────────────────────
  @override
  Future<UserProfile> updateUserProfile(
    Map<String, dynamic> data,
    String token,
  ) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.patientUpdate}',
        data: jsonEncode(data),
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
      final success = body['success'] as bool? ?? false;

      if (!success) {
        final message =
            body['message'] as String? ?? 'Profile update failed. Try again.';
        throw ServerException(
          message: message,
          statusCode: response.statusCode,
        );
      }

      final updatedProfileData = body['data'] as Map<String, dynamic>? ?? {};
      return UserProfile.fromJson(updatedProfileData);
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

  // ── Get All Doctors ─────────────────────────────────────────────
  @override
  Future<List<DoctorProfile>> getAllDoctors(String token) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.getAllDoctors}',
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
      final success = body['success'] as bool? ?? false;

      if (!success) {
        final message =
            body['message'] as String? ?? 'Failed to fetch doctors.';
        throw ServerException(
          message: message,
          statusCode: response.statusCode,
        );
      }

      final dataList = body['data'] as List<dynamic>? ?? [];
      return dataList
          .map((e) => DoctorProfile.fromJson(e as Map<String, dynamic>))
          .toList();
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

  // ── Request Doctor ───────────────────────────────────────────────
  @override
  Future<void> requestDoctor(String doctorId, String token) async {
    try {
      final url =
          '${ApiEndpoints.baseUrl}${ApiEndpoints.withId(ApiEndpoints.requestDoctor, doctorId)}';
      final response = await _dio.post(
        url,
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
      final success = body['success'] as bool? ?? false;

      if (!success) {
        final message =
            body['message'] as String? ?? 'Failed to send request.';
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

  // ── Get My Doctors ───────────────────────────────────────────────
  @override
  Future<List<String>> getMyDoctors(String token) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.patientDoctors}',
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
      final success = body['success'] as bool? ?? false;

      if (!success) {
        final message =
            body['message'] as String? ?? 'Failed to fetch your doctors.';
        throw ServerException(
          message: message,
          statusCode: response.statusCode,
        );
      }

      final dataList = body['data'] as List<dynamic>? ?? [];
      return dataList.map((e) => e.toString()).toList();
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

  // ── Medicines (Reminders) ───────────────────────────────────────
  @override
  Future<List<ReminderModel>> getMedicines(String token) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.medicines}',
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
        final message = body['message'] as String? ?? 'Failed to fetch medicines.';
        throw ServerException(
          message: message,
          statusCode: response.statusCode,
        );
      }

      final dataList = body['data'] as List<dynamic>? ?? [];
      return dataList
          .map((e) => ReminderModel.fromJson(e as Map<String, dynamic>))
          .toList();
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
  Future<void> addMedicine(String token, ReminderModel medicine) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.medicines}',
        data: jsonEncode(medicine.toJson()),
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
      final success = body['success'] as bool? ?? false;

      if (!success) {
        final message = body['message'] as String? ?? 'Failed to add medicine.';
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
  Future<void> deleteMedicine(String token, String id) async {
    try {
      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.withId(ApiEndpoints.deleteMedicine, id)}';
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
        final message = body['message'] as String? ?? 'Failed to delete medicine.';
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

  // ── Family Tree ─────────────────────────────────────────────────
  @override
  Future<List<FamilyMemberModel>> getFamilyTree(String token) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.familyTree}',
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
        final message = body['message'] as String? ?? 'Failed to fetch family tree.';
        throw ServerException(
          message: message,
          statusCode: response.statusCode,
        );
      }

      final dataList = body['data'] as List<dynamic>? ?? [];
      return dataList
          .map((e) => FamilyMemberModel.fromJson(e as Map<String, dynamic>))
          .toList();
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
  Future<List<FamilyMemberModel>> addFamilyMember(String token, FamilyMemberModel member) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.familyTree}',
        data: jsonEncode(member.toJson()),
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
      final success = body['success'] as bool? ?? false;

      if (!success) {
        final message = body['message'] as String? ?? 'Failed to add family member.';
        throw ServerException(
          message: message,
          statusCode: response.statusCode,
        );
      }

      final dataList = body['data'] as List<dynamic>? ?? [];
      return dataList
          .map((e) => FamilyMemberModel.fromJson(e as Map<String, dynamic>))
          .toList();
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
  Future<void> deleteFamilyMember(String token, String id) async {
    try {
      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.withId(ApiEndpoints.deleteFamilyMember, id)}';
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
        final message = body['message'] as String? ?? 'Failed to delete family member.';
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

  // ── Location ────────────────────────────────────────────────────
  @override
  Future<void> updateLocation(String token, double lat, double lng) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.location}',
        data: jsonEncode({
          'lat': lat,
          'lng': lng,
        }),
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
      final success = body['success'] as bool? ?? false;

      if (!success) {
        final message = body['message'] as String? ?? 'Failed to update location.';
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
  Future<Map<String, dynamic>> getLastLocation(String token) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.location}',
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
        final message = body['message'] as String? ?? 'Failed to get location.';
        throw ServerException(
          message: message,
          statusCode: response.statusCode,
        );
      }

      return body['data'] as Map<String, dynamic>? ?? {};
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
  Future<UserProfile> getProfile(String token) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.patientUpdate}',
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
        final message = body['message'] as String? ?? 'Failed to fetch profile.';
        throw ServerException(
          message: message,
          statusCode: response.statusCode,
        );
      }

      final data = body['data'] as Map<String, dynamic>? ?? {};
      return UserProfile.fromJson(data);
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
