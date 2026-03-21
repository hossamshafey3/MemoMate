import 'package:equatable/equatable.dart';
import 'package:gradproj/features/user/data/models/reminder_model.dart';

abstract class MedicinesState extends Equatable {
  const MedicinesState();

  @override
  List<Object?> get props => [];
}

class MedicinesInitial extends MedicinesState {}

class MedicinesLoading extends MedicinesState {}

class MedicinesLoaded extends MedicinesState {
  final List<ReminderModel> medicines;

  const MedicinesLoaded(this.medicines);

  @override
  List<Object?> get props => [medicines];
}

class MedicinesError extends MedicinesState {
  final String message;

  const MedicinesError(this.message);

  @override
  List<Object?> get props => [message];
}

class MedicineActionLoading extends MedicinesState {}

class MedicineActionSuccess extends MedicinesState {
  final String message;

  const MedicineActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class MedicineActionError extends MedicinesState {
  final String message;

  const MedicineActionError(this.message);

  @override
  List<Object?> get props => [message];
}
