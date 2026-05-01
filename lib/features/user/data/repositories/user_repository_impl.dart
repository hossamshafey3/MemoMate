// ─────────────────────────────────────────────
//  user_repository_impl.dart  –  Memomate
// ─────────────────────────────────────────────

import 'package:gradproj/core/errors/exceptions.dart';
import 'package:gradproj/core/errors/failures.dart';
import 'package:gradproj/features/doctor/data/models/doctor_model.dart';
import 'package:gradproj/features/user/data/data_sources/user_remote_data_source.dart';
import 'package:gradproj/features/user/data/models/user_models.dart';
import 'package:gradproj/features/user/data/models/user_register_model.dart';
import 'package:gradproj/features/user/data/models/reminder_model.dart';
import 'package:gradproj/features/user/data/models/family_member_model.dart';
import 'package:gradproj/features/user/data/models/location_model.dart';

abstract class UserRepository {
  Future<Failure?> registerUser(UserRegisterModel model);
  Future<({UserProfile? profile, String? token, Failure? failure})> loginUser(
    UserLoginModel model,
  );
  Future<({UserProfile? profile, Failure? failure})> updateUserProfile(
    Map<String, dynamic> data,
    String token,
  );
  Future<({List<DoctorProfile>? doctors, Failure? failure})> getAllDoctors(
    String token,
  );
  Future<Failure?> requestDoctor(String doctorId, String token);
  Future<({List<String>? ids, Failure? failure})> getMyDoctors(String token);

  // Medicines
  Future<({List<ReminderModel>? medicines, Failure? failure})> getMedicines(String token);
  Future<Failure?> addMedicine(String token, ReminderModel medicine);
  Future<Failure?> deleteMedicine(String token, String id);

  // Family Tree
  Future<({List<FamilyMemberModel>? members, Failure? failure})> getFamilyTree(String token);
  Future<({List<FamilyMemberModel>? members, Failure? failure})> addFamilyMember(String token, FamilyMemberModel member);
  Future<Failure?> deleteFamilyMember(String token, String id);

  // Location
  Future<Failure?> updateLocation(String token, double lat, double lng);
  Future<({LocationModel? location, Failure? failure})> getLastLocation(String token);
}

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remote;
  UserRepositoryImpl(this._remote);

  @override
  Future<Failure?> registerUser(UserRegisterModel model) async {
    try {
      await _remote.registerUser(model);
      return null;
    } on NoInternetException {
      return const NoInternetFailure();
    } on RequestTimeoutException {
      return const RequestTimeoutFailure();
    } on ServerException catch (e) {
      return ServerFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      return UnexpectedFailure(message: e.toString());
    }
  }

  @override
  Future<({UserProfile? profile, String? token, Failure? failure})> loginUser(
    UserLoginModel model,
  ) async {
    try {
      final response = await _remote.loginUser(model);
      return (profile: response.profile, token: response.token, failure: null);
    } on NoInternetException {
      return (profile: null, token: null, failure: const NoInternetFailure());
    } on RequestTimeoutException {
      return (
        profile: null,
        token: null,
        failure: const RequestTimeoutFailure(),
      );
    } on ServerException catch (e) {
      return (
        profile: null,
        token: null,
        failure: ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return (
        profile: null,
        token: null,
        failure: UnexpectedFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<({UserProfile? profile, Failure? failure})> updateUserProfile(
    Map<String, dynamic> data,
    String token,
  ) async {
    try {
      final updatedProfile = await _remote.updateUserProfile(data, token);
      return (profile: updatedProfile, failure: null);
    } on NoInternetException {
      return (profile: null, failure: const NoInternetFailure());
    } on RequestTimeoutException {
      return (profile: null, failure: const RequestTimeoutFailure());
    } on ServerException catch (e) {
      return (
        profile: null,
        failure: ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return (profile: null, failure: UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<({List<DoctorProfile>? doctors, Failure? failure})> getAllDoctors(
    String token,
  ) async {
    try {
      final doctors = await _remote.getAllDoctors(token);
      return (doctors: doctors, failure: null);
    } on NoInternetException {
      return (doctors: null, failure: const NoInternetFailure());
    } on RequestTimeoutException {
      return (doctors: null, failure: const RequestTimeoutFailure());
    } on ServerException catch (e) {
      return (
        doctors: null,
        failure: ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return (doctors: null, failure: UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Failure?> requestDoctor(String doctorId, String token) async {
    try {
      await _remote.requestDoctor(doctorId, token);
      return null;
    } on NoInternetException {
      return const NoInternetFailure();
    } on RequestTimeoutException {
      return const RequestTimeoutFailure();
    } on ServerException catch (e) {
      return ServerFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      return UnexpectedFailure(message: e.toString());
    }
  }

  @override
  Future<({List<String>? ids, Failure? failure})> getMyDoctors(
    String token,
  ) async {
    try {
      final ids = await _remote.getMyDoctors(token);
      return (ids: ids, failure: null);
    } on NoInternetException {
      return (ids: null, failure: const NoInternetFailure());
    } on RequestTimeoutException {
      return (ids: null, failure: const RequestTimeoutFailure());
    } on ServerException catch (e) {
      return (
        ids: null,
        failure: ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return (ids: null, failure: UnexpectedFailure(message: e.toString()));
    }
  }

  // ── Medicines ────────────────────────────────────────────────────────
  @override
  Future<({List<ReminderModel>? medicines, Failure? failure})> getMedicines(
    String token,
  ) async {
    try {
      final res = await _remote.getMedicines(token);
      return (medicines: res, failure: null);
    } on NoInternetException {
      return (medicines: null, failure: const NoInternetFailure());
    } on RequestTimeoutException {
      return (medicines: null, failure: const RequestTimeoutFailure());
    } on ServerException catch (e) {
      return (
        medicines: null,
        failure: ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return (medicines: null, failure: UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Failure?> addMedicine(String token, ReminderModel medicine) async {
    try {
      await _remote.addMedicine(token, medicine);
      return null;
    } on NoInternetException {
      return const NoInternetFailure();
    } on RequestTimeoutException {
      return const RequestTimeoutFailure();
    } on ServerException catch (e) {
      return ServerFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      return UnexpectedFailure(message: e.toString());
    }
  }

  @override
  Future<Failure?> deleteMedicine(String token, String id) async {
    try {
      await _remote.deleteMedicine(token, id);
      return null;
    } on NoInternetException {
      return const NoInternetFailure();
    } on RequestTimeoutException {
      return const RequestTimeoutFailure();
    } on ServerException catch (e) {
      return ServerFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      return UnexpectedFailure(message: e.toString());
    }
  }

  // ── Family Tree ───────────────────────────────────────────────────
  @override
  Future<({List<FamilyMemberModel>? members, Failure? failure})> getFamilyTree(
    String token,
  ) async {
    try {
      final res = await _remote.getFamilyTree(token);
      return (members: res, failure: null);
    } on NoInternetException {
      return (members: null, failure: const NoInternetFailure());
    } on RequestTimeoutException {
      return (members: null, failure: const RequestTimeoutFailure());
    } on ServerException catch (e) {
      return (
        members: null,
        failure: ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return (members: null, failure: UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<({List<FamilyMemberModel>? members, Failure? failure})> addFamilyMember(
    String token,
    FamilyMemberModel member,
  ) async {
    try {
      final res = await _remote.addFamilyMember(token, member);
      return (members: res, failure: null);
    } on NoInternetException {
      return (members: null, failure: const NoInternetFailure());
    } on RequestTimeoutException {
      return (members: null, failure: const RequestTimeoutFailure());
    } on ServerException catch (e) {
      return (
        members: null,
        failure: ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return (members: null, failure: UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Failure?> deleteFamilyMember(String token, String id) async {
    try {
      await _remote.deleteFamilyMember(token, id);
      return null;
    } on NoInternetException {
      return const NoInternetFailure();
    } on RequestTimeoutException {
      return const RequestTimeoutFailure();
    } on ServerException catch (e) {
      return ServerFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      return UnexpectedFailure(message: e.toString());
    }
  }

  // ── Location ──────────────────────────────────────────────────────
  @override
  Future<Failure?> updateLocation(String token, double lat, double lng) async {
    try {
      await _remote.updateLocation(token, lat, lng);
      return null;
    } on NoInternetException {
      return const NoInternetFailure();
    } on RequestTimeoutException {
      return const RequestTimeoutFailure();
    } on ServerException catch (e) {
      return ServerFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      return UnexpectedFailure(message: e.toString());
    }
  }

  @override
  Future<({LocationModel? location, Failure? failure})> getLastLocation(
    String token,
  ) async {
    try {
      final res = await _remote.getLastLocation(token);
      final location = LocationModel.fromJson(res);
      return (location: location, failure: null);
    } on NoInternetException {
      return (location: null, failure: const NoInternetFailure());
    } on RequestTimeoutException {
      return (location: null, failure: const RequestTimeoutFailure());
    } on ServerException catch (e) {
      return (
        location: null,
        failure: ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return (location: null, failure: UnexpectedFailure(message: e.toString()));
    }
  }
}
