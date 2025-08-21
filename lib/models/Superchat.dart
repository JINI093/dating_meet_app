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


/** This is an auto generated class representing the Superchat type in your schema. */
class Superchat extends amplify_core.Model {
  static const classType = const _SuperchatModelType();
  final String id;
  final String? _fromUserId;
  final String? _toProfileId;
  final String? _message;
  final int? _pointsUsed;
  final String? _templateType;
  final String? _customData;
  final String? _status;
  final int? _priority;
  final amplify_core.TemporalDateTime? _expiresAt;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  SuperchatModelIdentifier get modelIdentifier {
      return SuperchatModelIdentifier(
        id: id
      );
  }
  
  String get fromUserId {
    try {
      return _fromUserId!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get toProfileId {
    try {
      return _toProfileId!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get message {
    try {
      return _message!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get pointsUsed {
    try {
      return _pointsUsed!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get templateType {
    return _templateType;
  }
  
  String? get customData {
    return _customData;
  }
  
  String get status {
    try {
      return _status!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get priority {
    try {
      return _priority!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get expiresAt {
    try {
      return _expiresAt!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get createdAt {
    try {
      return _createdAt!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get updatedAt {
    try {
      return _updatedAt!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  const Superchat._internal({required this.id, required fromUserId, required toProfileId, required message, required pointsUsed, templateType, customData, required status, required priority, required expiresAt, required createdAt, required updatedAt}): _fromUserId = fromUserId, _toProfileId = toProfileId, _message = message, _pointsUsed = pointsUsed, _templateType = templateType, _customData = customData, _status = status, _priority = priority, _expiresAt = expiresAt, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Superchat({String? id, required String fromUserId, required String toProfileId, required String message, required int pointsUsed, String? templateType, String? customData, required String status, required int priority, required amplify_core.TemporalDateTime expiresAt, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return Superchat._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      fromUserId: fromUserId,
      toProfileId: toProfileId,
      message: message,
      pointsUsed: pointsUsed,
      templateType: templateType,
      customData: customData,
      status: status,
      priority: priority,
      expiresAt: expiresAt,
      createdAt: createdAt,
      updatedAt: updatedAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Superchat &&
      id == other.id &&
      _fromUserId == other._fromUserId &&
      _toProfileId == other._toProfileId &&
      _message == other._message &&
      _pointsUsed == other._pointsUsed &&
      _templateType == other._templateType &&
      _customData == other._customData &&
      _status == other._status &&
      _priority == other._priority &&
      _expiresAt == other._expiresAt &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Superchat {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("fromUserId=" + "$_fromUserId" + ", ");
    buffer.write("toProfileId=" + "$_toProfileId" + ", ");
    buffer.write("message=" + "$_message" + ", ");
    buffer.write("pointsUsed=" + (_pointsUsed != null ? _pointsUsed!.toString() : "null") + ", ");
    buffer.write("templateType=" + "$_templateType" + ", ");
    buffer.write("customData=" + "$_customData" + ", ");
    buffer.write("status=" + "$_status" + ", ");
    buffer.write("priority=" + (_priority != null ? _priority!.toString() : "null") + ", ");
    buffer.write("expiresAt=" + (_expiresAt != null ? _expiresAt!.format() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Superchat copyWith({String? fromUserId, String? toProfileId, String? message, int? pointsUsed, String? templateType, String? customData, String? status, int? priority, amplify_core.TemporalDateTime? expiresAt, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return Superchat._internal(
      id: id,
      fromUserId: fromUserId ?? this.fromUserId,
      toProfileId: toProfileId ?? this.toProfileId,
      message: message ?? this.message,
      pointsUsed: pointsUsed ?? this.pointsUsed,
      templateType: templateType ?? this.templateType,
      customData: customData ?? this.customData,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  Superchat copyWithModelFieldValues({
    ModelFieldValue<String>? fromUserId,
    ModelFieldValue<String>? toProfileId,
    ModelFieldValue<String>? message,
    ModelFieldValue<int>? pointsUsed,
    ModelFieldValue<String?>? templateType,
    ModelFieldValue<String?>? customData,
    ModelFieldValue<String>? status,
    ModelFieldValue<int>? priority,
    ModelFieldValue<amplify_core.TemporalDateTime>? expiresAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return Superchat._internal(
      id: id,
      fromUserId: fromUserId == null ? this.fromUserId : fromUserId.value,
      toProfileId: toProfileId == null ? this.toProfileId : toProfileId.value,
      message: message == null ? this.message : message.value,
      pointsUsed: pointsUsed == null ? this.pointsUsed : pointsUsed.value,
      templateType: templateType == null ? this.templateType : templateType.value,
      customData: customData == null ? this.customData : customData.value,
      status: status == null ? this.status : status.value,
      priority: priority == null ? this.priority : priority.value,
      expiresAt: expiresAt == null ? this.expiresAt : expiresAt.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  Superchat.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _fromUserId = json['fromUserId'],
      _toProfileId = json['toProfileId'],
      _message = json['message'],
      _pointsUsed = (json['pointsUsed'] as num?)?.toInt(),
      _templateType = json['templateType'],
      _customData = json['customData'],
      _status = json['status'],
      _priority = (json['priority'] as num?)?.toInt(),
      _expiresAt = json['expiresAt'] != null ? amplify_core.TemporalDateTime.fromString(json['expiresAt']) : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'fromUserId': _fromUserId, 'toProfileId': _toProfileId, 'message': _message, 'pointsUsed': _pointsUsed, 'templateType': _templateType, 'customData': _customData, 'status': _status, 'priority': _priority, 'expiresAt': _expiresAt?.format(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'fromUserId': _fromUserId,
    'toProfileId': _toProfileId,
    'message': _message,
    'pointsUsed': _pointsUsed,
    'templateType': _templateType,
    'customData': _customData,
    'status': _status,
    'priority': _priority,
    'expiresAt': _expiresAt,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<SuperchatModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<SuperchatModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final FROMUSERID = amplify_core.QueryField(fieldName: "fromUserId");
  static final TOPROFILEID = amplify_core.QueryField(fieldName: "toProfileId");
  static final MESSAGE = amplify_core.QueryField(fieldName: "message");
  static final POINTSUSED = amplify_core.QueryField(fieldName: "pointsUsed");
  static final TEMPLATETYPE = amplify_core.QueryField(fieldName: "templateType");
  static final CUSTOMDATA = amplify_core.QueryField(fieldName: "customData");
  static final STATUS = amplify_core.QueryField(fieldName: "status");
  static final PRIORITY = amplify_core.QueryField(fieldName: "priority");
  static final EXPIRESAT = amplify_core.QueryField(fieldName: "expiresAt");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Superchat";
    modelSchemaDefinition.pluralName = "Superchats";
    
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
      amplify_core.ModelIndex(fields: const ["fromUserId"], name: "byFromUserId"),
      amplify_core.ModelIndex(fields: const ["toProfileId"], name: "byToProfileId")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Superchat.FROMUSERID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Superchat.TOPROFILEID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Superchat.MESSAGE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Superchat.POINTSUSED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Superchat.TEMPLATETYPE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Superchat.CUSTOMDATA,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Superchat.STATUS,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Superchat.PRIORITY,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Superchat.EXPIRESAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Superchat.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Superchat.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _SuperchatModelType extends amplify_core.ModelType<Superchat> {
  const _SuperchatModelType();
  
  @override
  Superchat fromJson(Map<String, dynamic> jsonData) {
    return Superchat.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Superchat';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Superchat] in your schema.
 */
class SuperchatModelIdentifier implements amplify_core.ModelIdentifier<Superchat> {
  final String id;

  /** Create an instance of SuperchatModelIdentifier using [id] the primary key. */
  const SuperchatModelIdentifier({
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
  String toString() => 'SuperchatModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is SuperchatModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}