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
import 'package:collection/collection.dart';


/** This is an auto generated class representing the UserPoints type in your schema. */
class UserPoints extends amplify_core.Model {
  static const classType = const _UserPointsModelType();
  final String id;
  final String? _userId;
  final int? _currentPoints;
  final int? _totalEarned;
  final int? _totalSpent;
  final amplify_core.TemporalDateTime? _lastUpdated;
  final List<PointTransaction>? _transactions;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  UserPointsModelIdentifier get modelIdentifier {
      return UserPointsModelIdentifier(
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
  
  int get currentPoints {
    try {
      return _currentPoints!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get totalEarned {
    try {
      return _totalEarned!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get totalSpent {
    try {
      return _totalSpent!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get lastUpdated {
    try {
      return _lastUpdated!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<PointTransaction>? get transactions {
    return _transactions;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const UserPoints._internal({required this.id, required userId, required currentPoints, required totalEarned, required totalSpent, required lastUpdated, transactions, createdAt, updatedAt}): _userId = userId, _currentPoints = currentPoints, _totalEarned = totalEarned, _totalSpent = totalSpent, _lastUpdated = lastUpdated, _transactions = transactions, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory UserPoints({String? id, required String userId, required int currentPoints, required int totalEarned, required int totalSpent, required amplify_core.TemporalDateTime lastUpdated, List<PointTransaction>? transactions}) {
    return UserPoints._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      userId: userId,
      currentPoints: currentPoints,
      totalEarned: totalEarned,
      totalSpent: totalSpent,
      lastUpdated: lastUpdated,
      transactions: transactions != null ? List<PointTransaction>.unmodifiable(transactions) : transactions);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserPoints &&
      id == other.id &&
      _userId == other._userId &&
      _currentPoints == other._currentPoints &&
      _totalEarned == other._totalEarned &&
      _totalSpent == other._totalSpent &&
      _lastUpdated == other._lastUpdated &&
      DeepCollectionEquality().equals(_transactions, other._transactions);
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("UserPoints {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("userId=" + "$_userId" + ", ");
    buffer.write("currentPoints=" + (_currentPoints != null ? _currentPoints!.toString() : "null") + ", ");
    buffer.write("totalEarned=" + (_totalEarned != null ? _totalEarned!.toString() : "null") + ", ");
    buffer.write("totalSpent=" + (_totalSpent != null ? _totalSpent!.toString() : "null") + ", ");
    buffer.write("lastUpdated=" + (_lastUpdated != null ? _lastUpdated!.format() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  UserPoints copyWith({String? userId, int? currentPoints, int? totalEarned, int? totalSpent, amplify_core.TemporalDateTime? lastUpdated, List<PointTransaction>? transactions}) {
    return UserPoints._internal(
      id: id,
      userId: userId ?? this.userId,
      currentPoints: currentPoints ?? this.currentPoints,
      totalEarned: totalEarned ?? this.totalEarned,
      totalSpent: totalSpent ?? this.totalSpent,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      transactions: transactions ?? this.transactions);
  }
  
  UserPoints copyWithModelFieldValues({
    ModelFieldValue<String>? userId,
    ModelFieldValue<int>? currentPoints,
    ModelFieldValue<int>? totalEarned,
    ModelFieldValue<int>? totalSpent,
    ModelFieldValue<amplify_core.TemporalDateTime>? lastUpdated,
    ModelFieldValue<List<PointTransaction>?>? transactions
  }) {
    return UserPoints._internal(
      id: id,
      userId: userId == null ? this.userId : userId.value,
      currentPoints: currentPoints == null ? this.currentPoints : currentPoints.value,
      totalEarned: totalEarned == null ? this.totalEarned : totalEarned.value,
      totalSpent: totalSpent == null ? this.totalSpent : totalSpent.value,
      lastUpdated: lastUpdated == null ? this.lastUpdated : lastUpdated.value,
      transactions: transactions == null ? this.transactions : transactions.value
    );
  }
  
  UserPoints.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _userId = json['userId'],
      _currentPoints = (json['currentPoints'] as num?)?.toInt(),
      _totalEarned = (json['totalEarned'] as num?)?.toInt(),
      _totalSpent = (json['totalSpent'] as num?)?.toInt(),
      _lastUpdated = json['lastUpdated'] != null ? amplify_core.TemporalDateTime.fromString(json['lastUpdated']) : null,
      _transactions = json['transactions']  is Map
        ? (json['transactions']['items'] is List
          ? (json['transactions']['items'] as List)
              .where((e) => e != null)
              .map((e) => PointTransaction.fromJson(new Map<String, dynamic>.from(e)))
              .toList()
          : null)
        : (json['transactions'] is List
          ? (json['transactions'] as List)
              .where((e) => e?['serializedData'] != null)
              .map((e) => PointTransaction.fromJson(new Map<String, dynamic>.from(e?['serializedData'])))
              .toList()
          : null),
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'userId': _userId, 'currentPoints': _currentPoints, 'totalEarned': _totalEarned, 'totalSpent': _totalSpent, 'lastUpdated': _lastUpdated?.format(), 'transactions': _transactions?.map((PointTransaction? e) => e?.toJson()).toList(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'userId': _userId,
    'currentPoints': _currentPoints,
    'totalEarned': _totalEarned,
    'totalSpent': _totalSpent,
    'lastUpdated': _lastUpdated,
    'transactions': _transactions,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<UserPointsModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<UserPointsModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USERID = amplify_core.QueryField(fieldName: "userId");
  static final CURRENTPOINTS = amplify_core.QueryField(fieldName: "currentPoints");
  static final TOTALEARNED = amplify_core.QueryField(fieldName: "totalEarned");
  static final TOTALSPENT = amplify_core.QueryField(fieldName: "totalSpent");
  static final LASTUPDATED = amplify_core.QueryField(fieldName: "lastUpdated");
  static final TRANSACTIONS = amplify_core.QueryField(
    fieldName: "transactions",
    fieldType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.model, ofModelName: 'PointTransaction'));
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "UserPoints";
    modelSchemaDefinition.pluralName = "UserPoints";
    
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
      amplify_core.ModelIndex(fields: const ["userId"], name: "byUserId")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserPoints.USERID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserPoints.CURRENTPOINTS,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserPoints.TOTALEARNED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserPoints.TOTALSPENT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: UserPoints.LASTUPDATED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.hasMany(
      key: UserPoints.TRANSACTIONS,
      isRequired: false,
      ofModelName: 'PointTransaction',
      associatedKey: PointTransaction.USERPOINTS
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

class _UserPointsModelType extends amplify_core.ModelType<UserPoints> {
  const _UserPointsModelType();
  
  @override
  UserPoints fromJson(Map<String, dynamic> jsonData) {
    return UserPoints.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'UserPoints';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [UserPoints] in your schema.
 */
class UserPointsModelIdentifier implements amplify_core.ModelIdentifier<UserPoints> {
  final String id;

  /** Create an instance of UserPointsModelIdentifier using [id] the primary key. */
  const UserPointsModelIdentifier({
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
  String toString() => 'UserPointsModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is UserPointsModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}