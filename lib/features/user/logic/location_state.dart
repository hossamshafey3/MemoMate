import 'package:equatable/equatable.dart';
import 'package:gradproj/features/user/data/models/location_model.dart';

abstract class LocationState extends Equatable {
  const LocationState();
  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationUpdateSuccess extends LocationState {}

class LocationFetchSuccess extends LocationState {
  final LocationModel location;
  const LocationFetchSuccess(this.location);
  @override
  List<Object?> get props => [location];
}

class LocationFailure extends LocationState {
  final String message;
  const LocationFailure(this.message);
  @override
  List<Object?> get props => [message];
}
