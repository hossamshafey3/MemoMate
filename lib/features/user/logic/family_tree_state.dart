import 'package:equatable/equatable.dart';
import 'package:gradproj/features/user/data/models/family_member_model.dart';

abstract class FamilyTreeState extends Equatable {
  const FamilyTreeState();

  @override
  List<Object?> get props => [];
}

class FamilyTreeInitial extends FamilyTreeState {}

class FamilyTreeLoading extends FamilyTreeState {}

class FamilyTreeLoaded extends FamilyTreeState {
  final List<FamilyMemberModel> members;

  const FamilyTreeLoaded(this.members);

  @override
  List<Object?> get props => [members];
}

class FamilyTreeError extends FamilyTreeState {
  final String message;

  const FamilyTreeError(this.message);

  @override
  List<Object?> get props => [message];
}

class FamilyTreeActionLoading extends FamilyTreeState {}

class FamilyTreeActionSuccess extends FamilyTreeState {
  final String message;

  const FamilyTreeActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class FamilyTreeActionError extends FamilyTreeState {
  final String message;

  const FamilyTreeActionError(this.message);

  @override
  List<Object?> get props => [message];
}
