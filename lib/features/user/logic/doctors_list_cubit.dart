import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproj/features/doctor/data/models/doctor_model.dart';
import 'package:gradproj/features/user/data/repositories/user_repository_impl.dart';

part 'doctors_list_state.dart';

class DoctorsListCubit extends Cubit<DoctorsListState> {
  final UserRepository _repository;
  Timer? _pollingTimer;

  DoctorsListCubit(this._repository) : super(DoctorsListInitial());

  void startPolling(String token) {
    stopPolling();
    // Initial silent fetch
    fetchDoctors(token, isPolling: true);
    fetchMyDoctors(token, isPolling: true);

    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchDoctors(token, isPolling: true);
      fetchMyDoctors(token, isPolling: true);
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  Future<void> close() {
    stopPolling();
    return super.close();
  }

  /// Full list of all doctors (for "Find Doctors" tab)
  List<DoctorProfile> allDoctors = [];

  /// IDs returned from GET /patient/doctors (accepted doctor IDs for this patient)
  Set<String> myDoctorIds = {};

  Future<void> fetchDoctors(String token, {bool isPolling = false}) async {
    if (!isPolling) emit(DoctorsListLoading());
    final result = await _repository.getAllDoctors(token);

    if (result.failure != null) {
      if (!isPolling) emit(DoctorsListFailure(message: result.failure!.message));
    } else {
      allDoctors = result.doctors ?? [];
      emit(DoctorsListSuccess(doctors: allDoctors));
    }
  }

  Future<void> fetchMyDoctors(String token, {bool isPolling = false}) async {
    if (!isPolling) emit(MyDoctorsLoading());
    final result = await _repository.getMyDoctors(token);

    if (result.failure != null) {
      if (!isPolling) emit(MyDoctorsFailure(message: result.failure!.message));
    } else {
      myDoctorIds = Set<String>.from(result.ids ?? []);
      emit(MyDoctorsSuccess(ids: result.ids ?? []));
    }
  }

  Future<void> requestDoctor(String doctorId, String token) async {
    emit(DoctorRequestLoading(doctorId: doctorId));
    final failure = await _repository.requestDoctor(doctorId, token);

    if (failure != null) {
      emit(DoctorRequestFailure(message: failure.message));
    } else {
      emit(DoctorRequestSuccess());
    }
  }

  Future<void> deleteDoctor(String doctorId, String token) async {
    emit(DoctorDeleteLoading(doctorId: doctorId));
    final failure = await _repository.deletePatientDoctor(doctorId, token);

    if (failure != null) {
      emit(DoctorDeleteFailure(message: failure.message));
    } else {
      emit(DoctorDeleteSuccess(doctorId: doctorId));
      
      // Re-fetch my doctors list to sync local UI state
      await fetchMyDoctors(token);
    }
  }
}
