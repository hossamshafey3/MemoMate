import 'package:equatable/equatable.dart';
import 'package:gradproj/features/user/data/models/user_models.dart';

abstract class CallState extends Equatable {
  const CallState();

  @override
  List<Object?> get props => [];
}

class CallInitial extends CallState {}

class CallLoading extends CallState {}

class CallIncoming extends CallState {
  final String channelId;
  final String callerName;
  final String? callerImage;

  const CallIncoming({
    required this.channelId,
    required this.callerName,
    this.callerImage,
  });

  @override
  List<Object?> get props => [channelId, callerName, callerImage];
}

class CallActive extends CallState {}

class CallError extends CallState {
  final String message;
  const CallError(this.message);

  @override
  List<Object?> get props => [message];
}
