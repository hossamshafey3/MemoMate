import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproj/features/user/data/repositories/user_repository_impl.dart';
import 'package:gradproj/features/user/logic/call_state.dart';

class CallCubit extends Cubit<CallState> {
  final UserRepository _repository;
  Timer? _pollingTimer;
  String? _currentToken;
  bool _isCurrentlyCalling = false;

  CallCubit(this._repository) : super(CallInitial());

  void startPolling(String token) {
    _currentToken = token;
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkCallStatus();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _checkCallStatus() async {
    if (_currentToken == null || _isCurrentlyCalling) return;

    final result = await _repository.getProfile(_currentToken!);
    if (result.profile != null) {
      final about = result.profile!.about;
      if (about.startsWith('CALLING:')) {
        final parts = about.split(':');
        if (parts.length >= 2) {
          final channelId = parts[1];
          // If we haven't already signaled this call, emit Incoming
          if (state is! CallIncoming || (state as CallIncoming).channelId != channelId) {
            emit(CallIncoming(
              channelId: channelId,
              callerName: result.profile!.caregiverName,
              callerImage: null, // Image can be added if available
            ));
          }
        }
      } else if (state is CallIncoming) {
        // If it was incoming but now the signal is gone, reset
        emit(CallInitial());
      }
    }
  }

  Future<void> startCallSignal(String token, String channelId) async {
    _isCurrentlyCalling = true;
    final result = await _repository.updateUserProfile(
      {'about': 'CALLING:$channelId'},
      token,
    );
    if (result.failure != null) {
      emit(CallError(result.failure!.message));
    } else {
      emit(CallActive());
    }
  }

  Future<void> endCallSignal(String token) async {
    _isCurrentlyCalling = false;
    await _repository.updateUserProfile(
      {'about': ''},
      token,
    );
    emit(CallInitial());
  }

  @override
  Future<void> close() {
    stopPolling();
    return super.close();
  }
}
