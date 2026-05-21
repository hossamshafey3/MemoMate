// ─────────────────────────────────────────────
//  family_member_model.dart  –  Memomate
//  Model for a single family member entry.
// ─────────────────────────────────────────────

class FamilyMemberModel {
  final String id;
  final String familyMemberName;
  final String relationshipToPatient;
  final String familyMemberImage;
  final String familyMemberPhone;

  const FamilyMemberModel({
    required this.id,
    required this.familyMemberName,
    required this.relationshipToPatient,
    required this.familyMemberImage,
    required this.familyMemberPhone,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) =>
      FamilyMemberModel(
        id: json['_id'] as String? ?? '',
        familyMemberName: json['familyMemberName'] as String? ?? '',
        relationshipToPatient: json['relationshipToPatient'] as String? ?? '',
        familyMemberImage: json['familyMemberImage'] as String? ?? '',
        familyMemberPhone: json['familyMemberPhone'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
    'familyMemberName': familyMemberName,
    'relationshipToPatient': relationshipToPatient,
    'familyMemberImage': familyMemberImage,
    'familyMemberPhone': familyMemberPhone,
  };
}
