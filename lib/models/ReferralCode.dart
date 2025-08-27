/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;


/** This is an auto generated class representing the ReferralCode type in your schema. */
class ReferralCode extends amplify_core.Model {
  static const classType = const _ReferralCodeModelType();
  final String id;
  final String? _referralCode; // 발행할 추천인 코드
  final String? _recipientUserId; // 코드 받는 사용자 ID
  final int? _rewardPoints; // 적립 포인트
  final bool? _isUsed; // 사용 여부
  final bool? _isActive; // 활성 상태
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  ReferralCodeModelIdentifier get modelIdentifier {
      return ReferralCodeModelIdentifier(
        id: id
      );
  }
  
  String? get referralCode {
    return _referralCode;
  }
  
  String? get recipientUserId {
    return _recipientUserId;
  }
  
  int? get rewardPoints {
    return _rewardPoints;
  }
  
  bool? get isUsed {
    return _isUsed;
  }
  
  bool? get isActive {
    return _isActive;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const ReferralCode._internal({required this.id, referralCode, recipientUserId, rewardPoints, isUsed, isActive, createdAt, updatedAt}): _referralCode = referralCode, _recipientUserId = recipientUserId, _rewardPoints = rewardPoints, _isUsed = isUsed, _isActive = isActive, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory ReferralCode({String? id, String? referralCode, String? recipientUserId, int? rewardPoints, bool? isUsed, bool? isActive}) {
    return ReferralCode._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      referralCode: referralCode,
      recipientUserId: recipientUserId,
      rewardPoints: rewardPoints,
      isUsed: isUsed ?? false,
      isActive: isActive ?? true);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReferralCode &&
      id == other.id &&
      _referralCode == other._referralCode &&
      _recipientUserId == other._recipientUserId &&
      _rewardPoints == other._rewardPoints &&
      _isUsed == other._isUsed &&
      _isActive == other._isActive;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("ReferralCode {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("referralCode=" + "$_referralCode" + ", ");
    buffer.write("recipientUserId=" + "$_recipientUserId" + ", ");
    buffer.write("rewardPoints=" + (_rewardPoints != null ? _rewardPoints!.toString() : "null") + ", ");
    buffer.write("isUsed=" + (_isUsed != null ? _isUsed!.toString() : "null") + ", ");
    buffer.write("isActive=" + (_isActive != null ? _isActive!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  ReferralCode copyWith({String? referralCode, String? recipientUserId, int? rewardPoints, bool? isUsed, bool? isActive}) {
    return ReferralCode._internal(
      id: id,
      referralCode: referralCode ?? this.referralCode,
      recipientUserId: recipientUserId ?? this.recipientUserId,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      isUsed: isUsed ?? this.isUsed,
      isActive: isActive ?? this.isActive);
  }
  
  ReferralCode copyWithModelFieldValues({
    ModelFieldValue<String?>? referralCode,
    ModelFieldValue<String?>? recipientUserId,
    ModelFieldValue<int?>? rewardPoints,
    ModelFieldValue<bool?>? isUsed,
    ModelFieldValue<bool?>? isActive
  }) {
    return ReferralCode._internal(
      id: id,
      referralCode: referralCode == null ? this.referralCode : referralCode.value,
      recipientUserId: recipientUserId == null ? this.recipientUserId : recipientUserId.value,
      rewardPoints: rewardPoints == null ? this.rewardPoints : rewardPoints.value,
      isUsed: isUsed == null ? this.isUsed : isUsed.value,
      isActive: isActive == null ? this.isActive : isActive.value
    );
  }
  
  ReferralCode.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _referralCode = json['referralCode'],
      _recipientUserId = json['recipientUserId'],
      _rewardPoints = (json['rewardPoints'] as num?)?.toInt(),
      _isUsed = json['isUsed'],
      _isActive = json['isActive'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'referralCode': _referralCode, 'recipientUserId': _recipientUserId, 'rewardPoints': _rewardPoints, 'isUsed': _isUsed, 'isActive': _isActive, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'referralCode': _referralCode,
    'recipientUserId': _recipientUserId,
    'rewardPoints': _rewardPoints,
    'isUsed': _isUsed,
    'isActive': _isActive,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<ReferralCodeModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<ReferralCodeModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final REFERRALCODE = amplify_core.QueryField(fieldName: "referralCode");
  static final RECIPIENTUSERID = amplify_core.QueryField(fieldName: "recipientUserId");
  static final REWARDPOINTS = amplify_core.QueryField(fieldName: "rewardPoints");
  static final ISUSED = amplify_core.QueryField(fieldName: "isUsed");
  static final ISACTIVE = amplify_core.QueryField(fieldName: "isActive");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "ReferralCode";
    modelSchemaDefinition.pluralName = "ReferralCodes";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PUBLIC,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ReferralCode.REFERRALCODE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ReferralCode.RECIPIENTUSERID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ReferralCode.REWARDPOINTS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ReferralCode.ISUSED,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ReferralCode.ISACTIVE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _ReferralCodeModelType extends amplify_core.ModelType<ReferralCode> {
  const _ReferralCodeModelType();
  
  @override
  ReferralCode fromJson(Map<String, dynamic> jsonData) {
    return ReferralCode.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'ReferralCode';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [ReferralCode] in your schema.
 */
class ReferralCodeModelIdentifier implements amplify_core.ModelIdentifier<ReferralCode> {
  final String id;

  /** Create an instance of ReferralCodeModelIdentifier using [id] the primary key. */
  const ReferralCodeModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'ReferralCodeModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is ReferralCodeModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}