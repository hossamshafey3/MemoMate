import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproj/features/user/data/repositories/user_repository_impl.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final UserRepository _repository;

  LocationCubit(this._repository) : super(LocationInitial());

  Future<void> updateLocation(String token, double lat, double lng) async {
    emit(LocationLoading());
    final failure = await _repository.updateLocation(token, lat, lng);
    if (failure != null) {
      emit(LocationFailure(failure.message));
    } else {
      emit(LocationUpdateSuccess());
    }
  }

  Future<void> getLastLocation(String token) async {
    emit(LocationLoading());
    final result = await _repository.getLastLocation(token);
    if (result.failure != null) {
      emit(LocationFailure(result.failure!.message));
    } else if (result.location != null) {
      emit(LocationFetchSuccess(result.location!));
    }
  }
}
