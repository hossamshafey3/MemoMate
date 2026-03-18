part of 'doctors_list_cubit.dart';

abstract class DoctorsListState extends Equatable {
  const DoctorsListState();

  @override
  List<Object?> get props => [];
}

class DoctorsListInitial extends DoctorsListState {}

class DoctorsListLoading extends DoctorsListState {}

class DoctorsListSuccess extends DoctorsListState {
  final List<DoctorProfile> doctors;

  const DoctorsListSuccess({required this.doctors});

  @override
  List<Object?> get props => [doctors];
}

class DoctorsListFailure extends DoctorsListState {
  final String message;

  const DoctorsListFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

// ── Doctor Request States ─────────────────────────────────
class DoctorRequestLoading extends DoctorsListState {}

class DoctorRequestSuccess extends DoctorsListState {}

class DoctorRequestFailure extends DoctorsListState {
  final String message;

  const DoctorRequestFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

// ── My Doctors States ───────────────────────────────────────────────────
class MyDoctorsLoading extends DoctorsListState {}

class MyDoctorsSuccess extends DoctorsListState {
  final List<String> ids;

  const MyDoctorsSuccess({required this.ids});

  @override
  List<Object?> get props => [ids];
}

class MyDoctorsFailure extends DoctorsListState {
  final String message;

  const MyDoctorsFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
