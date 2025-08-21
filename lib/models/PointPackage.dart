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


/** This is an auto generated class representing the PointPackage type in your schema. */
class PointPackage extends amplify_core.Model {
  static const classType = const _PointPackageModelType();
  final String id;
  final int? _points;
  final int? _bonusPoints;
  final int? _price;
  final int? _discountPercent;
  final bool? _isPopular;
  final bool? _isLimited;
  final int? _sortOrder;
  final bool? _active;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  PointPackageModelIdentifier get modelIdentifier {
      return PointPackageModelIdentifier(
        id: id
      );
  }
  
  int get points {
    try {
      return _points!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int? get bonusPoints {
    return _bonusPoints;
  }
  
  int get price {
    try {
      return _price!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int? get discountPercent {
    return _discountPercent;
  }
  
  bool? get isPopular {
    return _isPopular;
  }
  
  bool? get isLimited {
    return _isLimited;
  }
  
  int get sortOrder {
    try {
      return _sortOrder!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  bool get active {
    try {
      return _active!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const PointPackage._internal({required this.id, required points, bonusPoints, required price, discountPercent, isPopular, isLimited, required sortOrder, required active, createdAt, updatedAt}): _points = points, _bonusPoints = bonusPoints, _price = price, _discountPercent = discountPercent, _isPopular = isPopular, _isLimited = isLimited, _sortOrder = sortOrder, _active = active, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory PointPackage({String? id, required int points, int? bonusPoints, required int price, int? discountPercent, bool? isPopular, bool? isLimited, required int sortOrder, required bool active}) {
    return PointPackage._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      points: points,
      bonusPoints: bonusPoints,
      price: price,
      discountPercent: discountPercent,
      isPopular: isPopular,
      isLimited: isLimited,
      sortOrder: sortOrder,
      active: active);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PointPackage &&
      id == other.id &&
      _points == other._points &&
      _bonusPoints == other._bonusPoints &&
      _price == other._price &&
      _discountPercent == other._discountPercent &&
      _isPopular == other._isPopular &&
      _isLimited == other._isLimited &&
      _sortOrder == other._sortOrder &&
      _active == other._active;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("PointPackage {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("points=" + (_points != null ? _points!.toString() : "null") + ", ");
    buffer.write("bonusPoints=" + (_bonusPoints != null ? _bonusPoints!.toString() : "null") + ", ");
    buffer.write("price=" + (_price != null ? _price!.toString() : "null") + ", ");
    buffer.write("discountPercent=" + (_discountPercent != null ? _discountPercent!.toString() : "null") + ", ");
    buffer.write("isPopular=" + (_isPopular != null ? _isPopular!.toString() : "null") + ", ");
    buffer.write("isLimited=" + (_isLimited != null ? _isLimited!.toString() : "null") + ", ");
    buffer.write("sortOrder=" + (_sortOrder != null ? _sortOrder!.toString() : "null") + ", ");
    buffer.write("active=" + (_active != null ? _active!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  PointPackage copyWith({int? points, int? bonusPoints, int? price, int? discountPercent, bool? isPopular, bool? isLimited, int? sortOrder, bool? active}) {
    return PointPackage._internal(
      id: id,
      points: points ?? this.points,
      bonusPoints: bonusPoints ?? this.bonusPoints,
      price: price ?? this.price,
      discountPercent: discountPercent ?? this.discountPercent,
      isPopular: isPopular ?? this.isPopular,
      isLimited: isLimited ?? this.isLimited,
      sortOrder: sortOrder ?? this.sortOrder,
      active: active ?? this.active);
  }
  
  PointPackage copyWithModelFieldValues({
    ModelFieldValue<int>? points,
    ModelFieldValue<int?>? bonusPoints,
    ModelFieldValue<int>? price,
    ModelFieldValue<int?>? discountPercent,
    ModelFieldValue<bool?>? isPopular,
    ModelFieldValue<bool?>? isLimited,
    ModelFieldValue<int>? sortOrder,
    ModelFieldValue<bool>? active
  }) {
    return PointPackage._internal(
      id: id,
      points: points == null ? this.points : points.value,
      bonusPoints: bonusPoints == null ? this.bonusPoints : bonusPoints.value,
      price: price == null ? this.price : price.value,
      discountPercent: discountPercent == null ? this.discountPercent : discountPercent.value,
      isPopular: isPopular == null ? this.isPopular : isPopular.value,
      isLimited: isLimited == null ? this.isLimited : isLimited.value,
      sortOrder: sortOrder == null ? this.sortOrder : sortOrder.value,
      active: active == null ? this.active : active.value
    );
  }
  
  PointPackage.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _points = (json['points'] as num?)?.toInt(),
      _bonusPoints = (json['bonusPoints'] as num?)?.toInt(),
      _price = (json['price'] as num?)?.toInt(),
      _discountPercent = (json['discountPercent'] as num?)?.toInt(),
      _isPopular = json['isPopular'],
      _isLimited = json['isLimited'],
      _sortOrder = (json['sortOrder'] as num?)?.toInt(),
      _active = json['active'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'points': _points, 'bonusPoints': _bonusPoints, 'price': _price, 'discountPercent': _discountPercent, 'isPopular': _isPopular, 'isLimited': _isLimited, 'sortOrder': _sortOrder, 'active': _active, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'points': _points,
    'bonusPoints': _bonusPoints,
    'price': _price,
    'discountPercent': _discountPercent,
    'isPopular': _isPopular,
    'isLimited': _isLimited,
    'sortOrder': _sortOrder,
    'active': _active,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<PointPackageModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<PointPackageModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final POINTS = amplify_core.QueryField(fieldName: "points");
  static final BONUSPOINTS = amplify_core.QueryField(fieldName: "bonusPoints");
  static final PRICE = amplify_core.QueryField(fieldName: "price");
  static final DISCOUNTPERCENT = amplify_core.QueryField(fieldName: "discountPercent");
  static final ISPOPULAR = amplify_core.QueryField(fieldName: "isPopular");
  static final ISLIMITED = amplify_core.QueryField(fieldName: "isLimited");
  static final SORTORDER = amplify_core.QueryField(fieldName: "sortOrder");
  static final ACTIVE = amplify_core.QueryField(fieldName: "active");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "PointPackage";
    modelSchemaDefinition.pluralName = "PointPackages";
    
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
      key: PointPackage.POINTS,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PointPackage.BONUSPOINTS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PointPackage.PRICE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PointPackage.DISCOUNTPERCENT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PointPackage.ISPOPULAR,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PointPackage.ISLIMITED,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PointPackage.SORTORDER,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PointPackage.ACTIVE,
      isRequired: true,
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

class _PointPackageModelType extends amplify_core.ModelType<PointPackage> {
  const _PointPackageModelType();
  
  @override
  PointPackage fromJson(Map<String, dynamic> jsonData) {
    return PointPackage.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'PointPackage';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [PointPackage] in your schema.
 */
class PointPackageModelIdentifier implements amplify_core.ModelIdentifier<PointPackage> {
  final String id;

  /** Create an instance of PointPackageModelIdentifier using [id] the primary key. */
  const PointPackageModelIdentifier({
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
  String toString() => 'PointPackageModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is PointPackageModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}