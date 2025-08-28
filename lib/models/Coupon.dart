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


/** This is an auto generated class representing the Coupon type in your schema. */
class Coupon extends amplify_core.Model {
  static const classType = const _CouponModelType();
  final String id;
  final String? _couponCode; // 쿠폰 코드
  final String? _couponType; // 쿠폰 종류 (ONE_PLUS_ONE, PRODUCT_REWARD, POINT_REWARD)
  final String? _title; // 쿠폰 제목
  final String? _description; // 쿠폰 설명
  final String? _rewardType; // 보상 종류 (하트, 슈퍼챗 등)
  final int? _rewardAmount; // 보상 수량/포인트
  final String? _validUntil; // 유효기간
  final bool? _isActive; // 활성 상태
  final int? _usageCount; // 사용 횟수
  final int? _maxUsage; // 최대 사용 가능 횟수 (0이면 무제한)
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  CouponModelIdentifier get modelIdentifier {
      return CouponModelIdentifier(
        id: id
      );
  }
  
  String? get couponCode {
    return _couponCode;
  }
  
  String? get couponType {
    return _couponType;
  }
  
  String? get title {
    return _title;
  }
  
  String? get description {
    return _description;
  }
  
  String? get rewardType {
    return _rewardType;
  }
  
  int? get rewardAmount {
    return _rewardAmount;
  }
  
  String? get validUntil {
    return _validUntil;
  }
  
  bool? get isActive {
    return _isActive;
  }
  
  int? get usageCount {
    return _usageCount;
  }
  
  int? get maxUsage {
    return _maxUsage;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Coupon._internal({required this.id, couponCode, couponType, title, description, rewardType, rewardAmount, validUntil, isActive, usageCount, maxUsage, createdAt, updatedAt}): _couponCode = couponCode, _couponType = couponType, _title = title, _description = description, _rewardType = rewardType, _rewardAmount = rewardAmount, _validUntil = validUntil, _isActive = isActive, _usageCount = usageCount, _maxUsage = maxUsage, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Coupon({String? id, String? couponCode, String? couponType, String? title, String? description, String? rewardType, int? rewardAmount, String? validUntil, bool? isActive, int? usageCount, int? maxUsage}) {
    return Coupon._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      couponCode: couponCode,
      couponType: couponType,
      title: title,
      description: description,
      rewardType: rewardType,
      rewardAmount: rewardAmount,
      validUntil: validUntil,
      isActive: isActive ?? true,
      usageCount: usageCount ?? 0,
      maxUsage: maxUsage ?? 0);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Coupon &&
      id == other.id &&
      _couponCode == other._couponCode &&
      _couponType == other._couponType &&
      _title == other._title &&
      _description == other._description &&
      _rewardType == other._rewardType &&
      _rewardAmount == other._rewardAmount &&
      _validUntil == other._validUntil &&
      _isActive == other._isActive &&
      _usageCount == other._usageCount &&
      _maxUsage == other._maxUsage;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Coupon {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("couponCode=" + "$_couponCode" + ", ");
    buffer.write("couponType=" + "$_couponType" + ", ");
    buffer.write("title=" + "$_title" + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("rewardType=" + "$_rewardType" + ", ");
    buffer.write("rewardAmount=" + (_rewardAmount != null ? _rewardAmount!.toString() : "null") + ", ");
    buffer.write("validUntil=" + "$_validUntil" + ", ");
    buffer.write("isActive=" + (_isActive != null ? _isActive!.toString() : "null") + ", ");
    buffer.write("usageCount=" + (_usageCount != null ? _usageCount!.toString() : "null") + ", ");
    buffer.write("maxUsage=" + (_maxUsage != null ? _maxUsage!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Coupon copyWith({String? couponCode, String? couponType, String? title, String? description, String? rewardType, int? rewardAmount, String? validUntil, bool? isActive, int? usageCount, int? maxUsage}) {
    return Coupon._internal(
      id: id,
      couponCode: couponCode ?? this.couponCode,
      couponType: couponType ?? this.couponType,
      title: title ?? this.title,
      description: description ?? this.description,
      rewardType: rewardType ?? this.rewardType,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      validUntil: validUntil ?? this.validUntil,
      isActive: isActive ?? this.isActive,
      usageCount: usageCount ?? this.usageCount,
      maxUsage: maxUsage ?? this.maxUsage);
  }
  
  Coupon copyWithModelFieldValues({
    ModelFieldValue<String?>? couponCode,
    ModelFieldValue<String?>? couponType,
    ModelFieldValue<String?>? title,
    ModelFieldValue<String?>? description,
    ModelFieldValue<String?>? rewardType,
    ModelFieldValue<int?>? rewardAmount,
    ModelFieldValue<String?>? validUntil,
    ModelFieldValue<bool?>? isActive,
    ModelFieldValue<int?>? usageCount,
    ModelFieldValue<int?>? maxUsage
  }) {
    return Coupon._internal(
      id: id,
      couponCode: couponCode == null ? this.couponCode : couponCode.value,
      couponType: couponType == null ? this.couponType : couponType.value,
      title: title == null ? this.title : title.value,
      description: description == null ? this.description : description.value,
      rewardType: rewardType == null ? this.rewardType : rewardType.value,
      rewardAmount: rewardAmount == null ? this.rewardAmount : rewardAmount.value,
      validUntil: validUntil == null ? this.validUntil : validUntil.value,
      isActive: isActive == null ? this.isActive : isActive.value,
      usageCount: usageCount == null ? this.usageCount : usageCount.value,
      maxUsage: maxUsage == null ? this.maxUsage : maxUsage.value
    );
  }
  
  Coupon.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _couponCode = json['couponCode'],
      _couponType = json['couponType'],
      _title = json['title'],
      _description = json['description'],
      _rewardType = json['rewardType'],
      _rewardAmount = (json['rewardAmount'] as num?)?.toInt(),
      _validUntil = json['validUntil'],
      _isActive = json['isActive'],
      _usageCount = (json['usageCount'] as num?)?.toInt(),
      _maxUsage = (json['maxUsage'] as num?)?.toInt(),
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'couponCode': _couponCode, 'couponType': _couponType, 'title': _title, 'description': _description, 'rewardType': _rewardType, 'rewardAmount': _rewardAmount, 'validUntil': _validUntil, 'isActive': _isActive, 'usageCount': _usageCount, 'maxUsage': _maxUsage, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'couponCode': _couponCode,
    'couponType': _couponType,
    'title': _title,
    'description': _description,
    'rewardType': _rewardType,
    'rewardAmount': _rewardAmount,
    'validUntil': _validUntil,
    'isActive': _isActive,
    'usageCount': _usageCount,
    'maxUsage': _maxUsage,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<CouponModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<CouponModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final COUPONCODE = amplify_core.QueryField(fieldName: "couponCode");
  static final COUPONTYPE = amplify_core.QueryField(fieldName: "couponType");
  static final TITLE = amplify_core.QueryField(fieldName: "title");
  static final DESCRIPTION = amplify_core.QueryField(fieldName: "description");
  static final REWARDTYPE = amplify_core.QueryField(fieldName: "rewardType");
  static final REWARDAMOUNT = amplify_core.QueryField(fieldName: "rewardAmount");
  static final VALIDUNTIL = amplify_core.QueryField(fieldName: "validUntil");
  static final ISACTIVE = amplify_core.QueryField(fieldName: "isActive");
  static final USAGECOUNT = amplify_core.QueryField(fieldName: "usageCount");
  static final MAXUSAGE = amplify_core.QueryField(fieldName: "maxUsage");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Coupon";
    modelSchemaDefinition.pluralName = "Coupons";
    
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
      key: Coupon.COUPONCODE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Coupon.COUPONTYPE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Coupon.TITLE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Coupon.DESCRIPTION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Coupon.REWARDTYPE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Coupon.REWARDAMOUNT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Coupon.VALIDUNTIL,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Coupon.ISACTIVE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Coupon.USAGECOUNT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Coupon.MAXUSAGE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
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

class _CouponModelType extends amplify_core.ModelType<Coupon> {
  const _CouponModelType();
  
  @override
  Coupon fromJson(Map<String, dynamic> jsonData) {
    return Coupon.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Coupon';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Coupon] in your schema.
 */
class CouponModelIdentifier implements amplify_core.ModelIdentifier<Coupon> {
  final String id;

  /** Create an instance of CouponModelIdentifier using [id] the primary key. */
  const CouponModelIdentifier({
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
  String toString() => 'CouponModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is CouponModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}