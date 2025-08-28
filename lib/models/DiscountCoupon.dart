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


/** This is an auto generated class representing the DiscountCoupon type in your schema. */
class DiscountCoupon extends amplify_core.Model {
  static const classType = const _DiscountCouponModelType();
  final String id;
  final String? _couponName; // 쿠폰명
  final String? _recipientUserId; // 쿠폰 받는 사용자 ID
  final int? _discountRate; // 할인율 (%)
  final String? _couponCode; // 발행할 쿠폰 코드
  final String? _validUntil; // 쿠폰 유효 기간
  final bool? _isUsed; // 사용 여부
  final bool? _isActive; // 활성 상태
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  DiscountCouponModelIdentifier get modelIdentifier {
      return DiscountCouponModelIdentifier(
        id: id
      );
  }
  
  String? get couponName {
    return _couponName;
  }
  
  String? get recipientUserId {
    return _recipientUserId;
  }
  
  int? get discountRate {
    return _discountRate;
  }
  
  String? get couponCode {
    return _couponCode;
  }
  
  String? get validUntil {
    return _validUntil;
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
  
  const DiscountCoupon._internal({required this.id, couponName, recipientUserId, discountRate, couponCode, validUntil, isUsed, isActive, createdAt, updatedAt}): _couponName = couponName, _recipientUserId = recipientUserId, _discountRate = discountRate, _couponCode = couponCode, _validUntil = validUntil, _isUsed = isUsed, _isActive = isActive, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory DiscountCoupon({String? id, String? couponName, String? recipientUserId, int? discountRate, String? couponCode, String? validUntil, bool? isUsed, bool? isActive}) {
    return DiscountCoupon._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      couponName: couponName,
      recipientUserId: recipientUserId,
      discountRate: discountRate,
      couponCode: couponCode,
      validUntil: validUntil,
      isUsed: isUsed ?? false,
      isActive: isActive ?? true);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DiscountCoupon &&
      id == other.id &&
      _couponName == other._couponName &&
      _recipientUserId == other._recipientUserId &&
      _discountRate == other._discountRate &&
      _couponCode == other._couponCode &&
      _validUntil == other._validUntil &&
      _isUsed == other._isUsed &&
      _isActive == other._isActive;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("DiscountCoupon {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("couponName=" + "$_couponName" + ", ");
    buffer.write("recipientUserId=" + "$_recipientUserId" + ", ");
    buffer.write("discountRate=" + (_discountRate != null ? _discountRate!.toString() : "null") + ", ");
    buffer.write("couponCode=" + "$_couponCode" + ", ");
    buffer.write("validUntil=" + "$_validUntil" + ", ");
    buffer.write("isUsed=" + (_isUsed != null ? _isUsed!.toString() : "null") + ", ");
    buffer.write("isActive=" + (_isActive != null ? _isActive!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  DiscountCoupon copyWith({String? couponName, String? recipientUserId, int? discountRate, String? couponCode, String? validUntil, bool? isUsed, bool? isActive}) {
    return DiscountCoupon._internal(
      id: id,
      couponName: couponName ?? this.couponName,
      recipientUserId: recipientUserId ?? this.recipientUserId,
      discountRate: discountRate ?? this.discountRate,
      couponCode: couponCode ?? this.couponCode,
      validUntil: validUntil ?? this.validUntil,
      isUsed: isUsed ?? this.isUsed,
      isActive: isActive ?? this.isActive);
  }
  
  DiscountCoupon copyWithModelFieldValues({
    ModelFieldValue<String?>? couponName,
    ModelFieldValue<String?>? recipientUserId,
    ModelFieldValue<int?>? discountRate,
    ModelFieldValue<String?>? couponCode,
    ModelFieldValue<String?>? validUntil,
    ModelFieldValue<bool?>? isUsed,
    ModelFieldValue<bool?>? isActive
  }) {
    return DiscountCoupon._internal(
      id: id,
      couponName: couponName == null ? this.couponName : couponName.value,
      recipientUserId: recipientUserId == null ? this.recipientUserId : recipientUserId.value,
      discountRate: discountRate == null ? this.discountRate : discountRate.value,
      couponCode: couponCode == null ? this.couponCode : couponCode.value,
      validUntil: validUntil == null ? this.validUntil : validUntil.value,
      isUsed: isUsed == null ? this.isUsed : isUsed.value,
      isActive: isActive == null ? this.isActive : isActive.value
    );
  }
  
  DiscountCoupon.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _couponName = json['couponName'],
      _recipientUserId = json['recipientUserId'],
      _discountRate = (json['discountRate'] as num?)?.toInt(),
      _couponCode = json['couponCode'],
      _validUntil = json['validUntil'],
      _isUsed = json['isUsed'],
      _isActive = json['isActive'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'couponName': _couponName, 'recipientUserId': _recipientUserId, 'discountRate': _discountRate, 'couponCode': _couponCode, 'validUntil': _validUntil, 'isUsed': _isUsed, 'isActive': _isActive, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'couponName': _couponName,
    'recipientUserId': _recipientUserId,
    'discountRate': _discountRate,
    'couponCode': _couponCode,
    'validUntil': _validUntil,
    'isUsed': _isUsed,
    'isActive': _isActive,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<DiscountCouponModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<DiscountCouponModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final COUPONNAME = amplify_core.QueryField(fieldName: "couponName");
  static final RECIPIENTUSERID = amplify_core.QueryField(fieldName: "recipientUserId");
  static final DISCOUNTRATE = amplify_core.QueryField(fieldName: "discountRate");
  static final COUPONCODE = amplify_core.QueryField(fieldName: "couponCode");
  static final VALIDUNTIL = amplify_core.QueryField(fieldName: "validUntil");
  static final ISUSED = amplify_core.QueryField(fieldName: "isUsed");
  static final ISACTIVE = amplify_core.QueryField(fieldName: "isActive");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "DiscountCoupon";
    modelSchemaDefinition.pluralName = "DiscountCoupons";
    
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
      key: DiscountCoupon.COUPONNAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DiscountCoupon.RECIPIENTUSERID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DiscountCoupon.DISCOUNTRATE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DiscountCoupon.COUPONCODE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DiscountCoupon.VALIDUNTIL,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DiscountCoupon.ISUSED,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: DiscountCoupon.ISACTIVE,
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

class _DiscountCouponModelType extends amplify_core.ModelType<DiscountCoupon> {
  const _DiscountCouponModelType();
  
  @override
  DiscountCoupon fromJson(Map<String, dynamic> jsonData) {
    return DiscountCoupon.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'DiscountCoupon';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [DiscountCoupon] in your schema.
 */
class DiscountCouponModelIdentifier implements amplify_core.ModelIdentifier<DiscountCoupon> {
  final String id;

  /** Create an instance of DiscountCouponModelIdentifier using [id] the primary key. */
  const DiscountCouponModelIdentifier({
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
  String toString() => 'DiscountCouponModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is DiscountCouponModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}