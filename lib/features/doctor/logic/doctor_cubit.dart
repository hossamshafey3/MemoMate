// ─────────────────────────────────────────────
//  doctor_cubit.dart  –  Memomate
//  Cubit + States for Doctor registration.
// ─────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproj/features/doctor/data/models/doctor_model.dart';
import 'package:gradproj/features/doctor/data/models/patient_model.dart';
import 'package:gradproj/features/doctor/data/repositories/doctor_repository_impl.dart';

part 'doctor_state.dart';

class DoctorCubit extends Cubit<DoctorState> {
  final DoctorRepository _repository;

  DoctorCubit(this._repository) : super(DoctorInitial());

  Future<void> registerDoctor(DoctorRegisterModel model) async {
    emit(DoctorLoading());

    final result = await _repository.registerDoctor(model);

    if (result.failure != null) {
      emit(DoctorFailure(message: result.failure!.message));
    } else {
      emit(DoctorSuccess());
    }
  }

  Future<void> loginDoctor(DoctorLoginModel model) async {
    emit(DoctorLoading());

    final result = await _repository.loginDoctor(model);

    if (result.failure != null) {
      emit(DoctorFailure(message: result.failure!.message));
    } else {
      emit(
        DoctorLoginSuccess(profile: result.profile!, token: result.token ?? ''),
      );
    }
  }

  Future<void> updateDoctor(String token, Map<String, dynamic> fields) async {
    emit(DoctorLoading());

    final result = await _repository.updateDoctor(token, fields);

    if (result.failure != null) {
      emit(DoctorFailure(message: result.failure!.message));
    } else {
      emit(DoctorUpdateSuccess(profile: result.profile!));
    }
  }

  Future<void> fetchRequests(String token) async {
    emit(DoctorRequestsLoading());

    final result = await _repository.getPatientRequests(token);

    if (result.failure != null) {
      emit(DoctorRequestsFailure(message: result.failure!.message));
    } else {
      emit(DoctorRequestsSuccess(requests: result.requests ?? []));
    }
  }

  Future<void> fetchPatients(String token) async {
    emit(DoctorPatientsLoading());

    final result = await _repository.getDoctorPatients(token);

    if (result.failure != null) {
      emit(DoctorPatientsFailure(message: result.failure!.message));
    } else {
      emit(DoctorPatientsSuccess(patients: result.patients ?? []));
    }
  }

  Future<void> respondToRequest(
    String token,
    String patientId,
    String status,
  ) async {
    emit(DoctorRespondLoading(patientId: patientId));

    final result = await _repository.respondToRequest(token, patientId, status);

    if (result.failure != null) {
      emit(DoctorRespondFailure(message: result.failure!.message));
    } else {
      emit(DoctorRespondSuccess(
        patientId: patientId,
        status: status,
        message: result.message ?? 'Success',
      ));
      
      // Re-fetch the list to ensure local state reflects the backend
      await fetchRequests(token);
    }
  }
}
