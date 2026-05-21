import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproj/features/user/data/models/family_member_model.dart';
import 'package:gradproj/features/user/data/repositories/user_repository_impl.dart';
import 'package:gradproj/features/user/logic/family_tree_state.dart';

class FamilyTreeCubit extends Cubit<FamilyTreeState> {
  final UserRepository _repository;

  FamilyTreeCubit(this._repository) : super(FamilyTreeInitial());

  List<FamilyMemberModel> currentMembers = [];

  Future<void> fetchFamilyTree(String token) async {
    emit(FamilyTreeLoading());

    final result = await _repository.getFamilyTree(token);

    if (result.failure != null) {
      emit(FamilyTreeError(result.failure!.message));
    } else {
      currentMembers = result.members ?? [];
      emit(FamilyTreeLoaded(currentMembers));
    }
  }

  Future<void> addFamilyMember(
    String token,
    String name,
    String relationship,
    String image,
    String phone,
  ) async {
    emit(FamilyTreeActionLoading());

    final member = FamilyMemberModel(
      id: '',
      familyMemberName: name,
      relationshipToPatient: relationship,
      familyMemberImage: image,
      familyMemberPhone: phone,
    );

    final result = await _repository.addFamilyMember(token, member);

    if (result.failure != null) {
      emit(FamilyTreeActionError(result.failure!.message));
    } else {
      currentMembers = result.members ?? [];
      emit(const FamilyTreeActionSuccess('Family member added successfully'));
      emit(FamilyTreeLoaded(currentMembers));
    }
  }

  Future<void> deleteFamilyMember(String token, String id) async {
    emit(FamilyTreeActionLoading());

    final failure = await _repository.deleteFamilyMember(token, id);

    if (failure != null) {
      emit(FamilyTreeActionError(failure.message));
    } else {
      emit(const FamilyTreeActionSuccess('Family member removed'));
      // Re-fetch to get fresh list
      await fetchFamilyTree(token);
    }
  }
}
