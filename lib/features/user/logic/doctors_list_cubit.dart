import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproj/features/doctor/data/models/doctor_model.dart';
import 'package:gradproj/features/user/data/repositories/user_repository_impl.dart';

part 'doctors_list_state.dart';

class DoctorsListCubit extends Cubit<DoctorsListState> {
  final UserRepository _repository;

  DoctorsListCubit(this._repository) : super(DoctorsListInitial());

  /// Full list of all doctors (for "Find Doctors" tab)
  List<DoctorProfile> allDoctors = [];

  /// IDs returned from GET /patient/doctors (accepted doctor IDs for this patient)
  Set<String> myDoctorIds = {};

  Future<void> fetchDoctors(String token) async {
    emit(DoctorsListLoading());
    final result = await _repository.getAllDoctors(token);

    if (result.failure != null) {
      emit(DoctorsListFailure(message: result.failure!.message));
    } else {
      allDoctors = result.doctors ?? [];
      emit(DoctorsListSuccess(doctors: allDoctors));
    }
  }

  Future<void> fetchMyDoctors(String token) async {
    emit(MyDoctorsLoading());
    final result = await _repository.getMyDoctors(token);

    if (result.failure != null) {
      emit(MyDoctorsFailure(message: result.failure!.message));
    } else {
      myDoctorIds = Set<String>.from(result.ids ?? []);
      emit(MyDoctorsSuccess(ids: result.ids ?? []));
    }
  }

  Future<void> requestDoctor(String doctorId, String token) async {
    emit(DoctorRequestLoading());
    final failure = await _repository.requestDoctor(doctorId, token);

    if (failure != null) {
      emit(DoctorRequestFailure(message: failure.message));
    } else {
      emit(DoctorRequestSuccess());
    }
  }
}
