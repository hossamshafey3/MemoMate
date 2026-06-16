import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproj/features/user/data/models/reminder_model.dart';
import 'package:gradproj/features/user/data/repositories/user_repository_impl.dart';
import 'package:gradproj/features/user/logic/medicines_state.dart';
import 'package:gradproj/core/services/notification_service.dart';

class MedicinesCubit extends Cubit<MedicinesState> {
  final UserRepository _repository;
  Timer? _pollingTimer;

  MedicinesCubit(this._repository) : super(MedicinesInitial());

  List<ReminderModel> currentMedicines = [];

  Future<void> fetchMedicines(String token, {bool isPolling = false}) async {
    if (!isPolling) {
      emit(MedicinesLoading());
    }

    final result = await _repository.getMedicines(token);

    if (result.failure != null) {
      if (!isPolling) {
        emit(MedicinesError(result.failure!.message));
      }
    } else {
      final newMedicines = result.medicines ?? [];
      
      // Sort: newest/latest date and time first
      newMedicines.sort((a, b) {
        final dtA = _getReminderDateTime(a);
        final dtB = _getReminderDateTime(b);
        return dtB.compareTo(dtA);
      });
      
      // Check if medicines have actually changed
      bool listChanged = false;
      if (currentMedicines.length != newMedicines.length) {
        listChanged = true;
      } else {
        for (int i = 0; i < currentMedicines.length; i++) {
          if (currentMedicines[i] != newMedicines[i]) {
            listChanged = true;
            break;
          }
        }
      }

      currentMedicines = newMedicines;
      emit(MedicinesLoaded(currentMedicines));

      // Schedule alarms outside of UI limits
      if (listChanged || currentMedicines.isNotEmpty && !isPolling) {
        NotificationService().scheduleMedicineReminders(currentMedicines);
      }
    }
  }

  Future<void> addMedicine(String token, ReminderModel medicine) async {
    emit(MedicineActionLoading());
    final failure = await _repository.addMedicine(token, medicine);

    if (failure != null) {
      emit(MedicineActionError(failure.message));
    } else {
      emit(const MedicineActionSuccess('Medicine added successfully'));
      // Re-fetch list
      await fetchMedicines(token, isPolling: false);
    }
  }

  Future<void> deleteMedicine(String token, String id) async {
    emit(MedicineActionLoading());
    final failure = await _repository.deleteMedicine(token, id);

    if (failure != null) {
      emit(MedicineActionError(failure.message));
    } else {
      emit(const MedicineActionSuccess('Medicine deleted successfully'));
      // Re-fetch list
      await fetchMedicines(token, isPolling: false);
    }
  }

  void startPolling(String token) {
    stopPolling(); // Ensure no duplicate timers

    // Initial fetch silently
    fetchMedicines(token, isPolling: true);

    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchMedicines(token, isPolling: true);
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

  DateTime _getReminderDateTime(ReminderModel med) {
    try {
      final dateStr = med.date.split('T').first;
      final timeStr = med.time.toUpperCase().trim();
      
      final timeParts = timeStr.split(' ');
      final hm = timeParts[0].split(':');
      int hour = int.parse(hm[0]);
      int minute = int.parse(hm[1]);
      
      if (timeParts.length > 1) {
        final period = timeParts[1];
        if (period == 'PM' && hour < 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;
      }
      
      final dateParts = dateStr.split('-');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      
      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      return DateTime.tryParse(med.date) ?? DateTime(2000);
    }
  }
}
