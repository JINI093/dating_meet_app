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


/** This is an auto generated class representing the PointTransaction type in your schema. */
class PointTransaction extends amplify_core.Model {
  static const classType = const _PointTransactionModelType();
  final String id;
  final String? _userId;
  final int? _amount;
  final String? _type;
  final String? _description;
  final amplify_core.TemporalDateTime? _timestamp;
  final UserPoints? _userPoints;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  PointTransactionModelIdentifier get modelIdentifier {
      return PointTransactionModelIdentifier(
        id: id
      );
  }
  
  String get userId {
    try {
      return _userId!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get amount {
    try {
      return _amount!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get type {
    try {
      return _type!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get description {
    try {
      return _description!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get timestamp {
    try {
      return _timestamp!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  UserPoints? get userPoints {
    return _userPoints;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const PointTransaction._internal({required this.id, required userId, required amount, required type, required description, required timestamp, userPoints, createdAt, updatedAt}): _userId = userId, _amount = amount, _type = type, _description = description, _timestamp = timestamp, _userPoints = userPoints, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory PointTransaction({String? id, required String userId, required int amount, required String type, required String description, required amplify_core.TemporalDateTime timestamp, UserPoints? userPoints}) {
    return PointTransaction._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      userId: userId,
      amount: amount,
      type: type,
      description: description,
      timestamp: timestamp,
      userPoints: userPoints);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PointTransaction &&
      id == other.id &&
      _userId == other._userId &&
      _amount == other._amount &&
      _type == other._type &&
      _description == other._description &&
      _timestamp == other._timestamp &&
      _userPoints == other._userPoints;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("PointTransaction {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("userId=" + "$_userId" + ", ");
    buffer.write("amount=" + (_amount != null ? _amount!.toString() : "null") + ", ");
    buffer.write("type=" + "$_type" + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("timestamp=" + (_timestamp != null ? _timestamp!.format() : "null") + ", ");
    buffer.write("userPoints=" + (_userPoints != null ? _userPoints!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  PointTransaction copyWith({String? userId, int? amount, String? type, String? description, amplify_core.TemporalDateTime? timestamp, UserPoints? userPoints}) {
    return PointTransaction._internal(
      id: id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      userPoints: userPoints ?? this.userPoints);
  }
  
  PointTransaction copyWithModelFieldValues({
    ModelFieldValue<String>? userId,
    ModelFieldValue<int>? amount,
    ModelFieldValue<String>? type,
    ModelFieldValue<String>? description,
    ModelFieldValue<amplify_core.TemporalDateTime>? timestamp,
    ModelFieldValue<UserPoints?>? userPoints
  }) {
    return PointTransaction._internal(
      id: id,
      userId: userId == null ? this.userId : userId.value,
      amount: amount == null ? this.amount : amount.value,
      type: type == null ? this.type : type.value,
      description: description == null ? this.description : description.value,
      timestamp: timestamp == null ? this.timestamp : timestamp.value,
      userPoints: userPoints == null ? this.userPoints : userPoints.value
    );
  }
  
  PointTransaction.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _userId = json['userId'],
      _amount = (json['amount'] as num?)?.toInt(),
      _type = json['type'],
      _description = json['description'],
      _timestamp = json['timestamp'] != null ? amplify_core.TemporalDateTime.fromString(json['timestamp']) : null,
      _userPoints = json['userPoints'] != null
        ? json['userPoints']['serializedData'] != null
          ? UserPoints.fromJson(new Map<String, dynamic>.from(json['userPoints']['serializedData']))
          : UserPoints.fromJson(new Map<String, dynamic>.from(json['userPoints']))
        : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'userId': _userId, 'amount': _amount, 'type': _type, 'description': _description, 'timestamp': _timestamp?.format(), 'userPoints': _userPoints?.toJson(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'userId': _userId,
    'amount': _amount,
    'type': _type,
    'description': _description,
    'timestamp': _timestamp,
    'userPoints': _userPoints,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<PointTransactionModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<PointTransactionModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USERID = amplify_core.QueryField(fieldName: "userId");
  static final AMOUNT = amplify_core.QueryField(fieldName: "amount");
  static final TYPE = amplify_core.QueryField(fieldName: "type");
  static final DESCRIPTION = amplify_core.QueryField(fieldName: "description");
  static final TIMESTAMP = amplify_core.QueryField(fieldName: "timestamp");
  static final USERPOINTS = amplify_core.QueryField(
    fieldName: "userPoints",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'UserPoints'));
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "PointTransaction";
    modelSchemaDefinition.pluralName = "PointTransactions";
    
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
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["userPointsId"], name: "byUserPoints"),
      amplify_core.ModelIndex(fields: const ["userId"], name: "byUserId")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PointTransaction.USERID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PointTransaction.AMOUNT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PointTransaction.TYPE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PointTransaction.DESCRIPTION,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: PointTransaction.TIMESTAMP,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.belongsTo(
      key: PointTransaction.USERPOINTS,
      isRequired: false,
      targetNames: ['userPointsId'],
      ofModelName: 'UserPoints'
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

class _PointTransactionModelType extends amplify_core.ModelType<PointTransaction> {
  const _PointTransactionModelType();
  
  @override
  PointTransaction fromJson(Map<String, dynamic> jsonData) {
    return PointTransaction.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'PointTransaction';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [PointTransaction] in your schema.
 */
class PointTransactionModelIdentifier implements amplify_core.ModelIdentifier<PointTransaction> {
  final String id;

  /** Create an instance of PointTransactionModelIdentifier using [id] the primary key. */
  const PointTransactionModelIdentifier({
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
  String toString() => 'PointTransactionModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is PointTransactionModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}