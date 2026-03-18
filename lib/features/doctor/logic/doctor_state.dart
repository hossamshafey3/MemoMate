part of 'doctor_cubit.dart';

abstract class DoctorState extends Equatable {
  const DoctorState();

  @override
  List<Object?> get props => [];
}

/// Initial / idle state.
class DoctorInitial extends DoctorState {}

/// API call in progress.
class DoctorLoading extends DoctorState {}

/// Registration completed successfully.
class DoctorSuccess extends DoctorState {}

/// Login completed successfully — carries the doctor's profile and JWT token.
class DoctorLoginSuccess extends DoctorState {
  final DoctorProfile profile;
  final String token;
  const DoctorLoginSuccess({required this.profile, required this.token});

  @override
  List<Object?> get props => [profile, token];
}

/// Profile update completed successfully — carries the updated profile.
class DoctorUpdateSuccess extends DoctorState {
  final DoctorProfile profile;
  const DoctorUpdateSuccess({required this.profile});

  @override
  List<Object?> get props => [profile];
}

/// Registration failed with an error message.
class DoctorFailure extends DoctorState {
  final String message;
  const DoctorFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class DoctorRequestsLoading extends DoctorState {}

class DoctorRequestsSuccess extends DoctorState {
  final List<PatientModel> requests;
  const DoctorRequestsSuccess({required this.requests});

  @override
  List<Object?> get props => [requests];
}

class DoctorRequestsFailure extends DoctorState {
  final String message;
  const DoctorRequestsFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class DoctorRespondLoading extends DoctorState {
  final String patientId;
  const DoctorRespondLoading({required this.patientId});

  @override
  List<Object?> get props => [patientId];
}

class DoctorPatientsLoading extends DoctorState {}

class DoctorPatientsSuccess extends DoctorState {
  final List<PatientModel> patients;

  const DoctorPatientsSuccess({required this.patients});

  @override
  List<Object?> get props => [patients];
}

class DoctorPatientsFailure extends DoctorState {
  final String message;

  const DoctorPatientsFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class DoctorRespondSuccess extends DoctorState {
  final String patientId;
  final String status;
  final String message;

  const DoctorRespondSuccess({
    required this.patientId,
    required this.status,
    required this.message,
  });

  @override
  List<Object?> get props => [patientId, status, message];
}

class DoctorRespondFailure extends DoctorState {
  final String message;
  const DoctorRespondFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
