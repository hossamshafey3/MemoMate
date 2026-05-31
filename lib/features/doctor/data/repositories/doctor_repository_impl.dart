// ─────────────────────────────────────────────
//  doctor_repository_impl.dart  –  Memomate
//  Repository that bridges data source ↔ cubit,
//  mapping exceptions to Failures.
// ─────────────────────────────────────────────

import 'package:gradproj/core/errors/exceptions.dart';
import 'package:gradproj/core/errors/failures.dart';
import 'package:gradproj/features/doctor/data/data_sources/doctor_remote_data_source.dart';
import 'package:gradproj/features/doctor/data/models/doctor_model.dart';
import 'package:gradproj/features/doctor/data/models/patient_model.dart';

abstract class DoctorRepository {
  Future<({DoctorProfile? profile, Failure? failure})> registerDoctor(
    DoctorRegisterModel model,
  );
  Future<({DoctorProfile? profile, String? token, Failure? failure})>
  loginDoctor(DoctorLoginModel model);
  Future<({DoctorProfile? profile, Failure? failure})> updateDoctor(
    String token,
    Map<String, dynamic> fields,
  );
  Future<({List<PatientModel>? requests, Failure? failure})> getPatientRequests(
    String token,
  );
  Future<({List<PatientModel>? patients, Failure? failure})> getDoctorPatients(
    String token,
  );
  Future<({String? message, Failure? failure})> respondToRequest(
    String token,
    String patientId,
    String status,
  );
  Future<Failure?> deleteDoctorPatient(String token, String patientId);
}

class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorRemoteDataSource _remoteDataSource;

  DoctorRepositoryImpl(this._remoteDataSource);

  @override
  Future<({DoctorProfile? profile, Failure? failure})> registerDoctor(
    DoctorRegisterModel model,
  ) async {
    try {
      final profile = await _remoteDataSource.registerDoctor(model);
      return (profile: profile, failure: null);
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
  Future<({DoctorProfile? profile, String? token, Failure? failure})>
  loginDoctor(DoctorLoginModel model) async {
    try {
      final loginResponse = await _remoteDataSource.loginDoctor(model);
      return (
        profile: loginResponse.profile,
        token: loginResponse.token,
        failure: null,
      );
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
  Future<({DoctorProfile? profile, Failure? failure})> updateDoctor(
    String token,
    Map<String, dynamic> fields,
  ) async {
    try {
      final profile = await _remoteDataSource.updateDoctor(token, fields);
      return (profile: profile, failure: null);
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
  Future<({List<PatientModel>? requests, Failure? failure})> getPatientRequests(
    String token,
  ) async {
    try {
      final requests = await _remoteDataSource.getPatientRequests(token);
      return (requests: requests, failure: null);
    } on NoInternetException {
      return (requests: null, failure: const NoInternetFailure());
    } on RequestTimeoutException {
      return (requests: null, failure: const RequestTimeoutFailure());
    } on ServerException catch (e) {
      return (
        requests: null,
        failure: ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return (
        requests: null,
        failure: UnexpectedFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<({List<PatientModel>? patients, Failure? failure})> getDoctorPatients(
    String token,
  ) async {
    try {
      final patients = await _remoteDataSource.getDoctorPatients(token);
      return (patients: patients, failure: null);
    } on NoInternetException {
      return (patients: null, failure: const NoInternetFailure());
    } on RequestTimeoutException {
      return (patients: null, failure: const RequestTimeoutFailure());
    } on ServerException catch (e) {
      return (
        patients: null,
        failure: ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return (
        patients: null,
        failure: UnexpectedFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<({String? message, Failure? failure})> respondToRequest(
    String token,
    String patientId,
    String status,
  ) async {
    try {
      final msg = await _remoteDataSource.respondToRequest(token, patientId, status);
      return (message: msg, failure: null);
    } on NoInternetException {
      return (message: null, failure: const NoInternetFailure());
    } on RequestTimeoutException {
      return (message: null, failure: const RequestTimeoutFailure());
    } on ServerException catch (e) {
      return (
        message: null,
        failure: ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return (message: null, failure: UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Failure?> deleteDoctorPatient(String token, String patientId) async {
    try {
      await _remoteDataSource.deleteDoctorPatient(token, patientId);
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
}
