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


/** This is an auto generated class representing the Report type in your schema. */
class Report extends amplify_core.Model {
  static const classType = const _ReportModelType();
  final String id;
  final String? _reporterUserId;
  final String? _reporterName;
  final String? _reportedUserId;
  final String? _reportedName;
  final String? _reportType;
  final String? _reportReason;
  final String? _reportContent;
  final List<String>? _evidence;
  final String? _status;
  final String? _priority;
  final String? _adminNotes;
  final String? _processedBy;
  final amplify_core.TemporalDateTime? _processedAt;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  ReportModelIdentifier get modelIdentifier {
      return ReportModelIdentifier(
        id: id
      );
  }
  
  String get reporterUserId {
    try {
      return _reporterUserId!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get reporterName {
    try {
      return _reporterName!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get reportedUserId {
    try {
      return _reportedUserId!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get reportedName {
    try {
      return _reportedName!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get reportType {
    try {
      return _reportType!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get reportReason {
    try {
      return _reportReason!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get reportContent {
    try {
      return _reportContent!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<String>? get evidence {
    return _evidence;
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
  
  String get priority {
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
  
  String? get adminNotes {
    return _adminNotes;
  }
  
  String? get processedBy {
    return _processedBy;
  }
  
  amplify_core.TemporalDateTime? get processedAt {
    return _processedAt;
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
  
  const Report._internal({required this.id, required reporterUserId, required reporterName, required reportedUserId, required reportedName, required reportType, required reportReason, required reportContent, evidence, required status, required priority, adminNotes, processedBy, processedAt, required createdAt, required updatedAt}): _reporterUserId = reporterUserId, _reporterName = reporterName, _reportedUserId = reportedUserId, _reportedName = reportedName, _reportType = reportType, _reportReason = reportReason, _reportContent = reportContent, _evidence = evidence, _status = status, _priority = priority, _adminNotes = adminNotes, _processedBy = processedBy, _processedAt = processedAt, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Report({String? id, required String reporterUserId, required String reporterName, required String reportedUserId, required String reportedName, required String reportType, required String reportReason, required String reportContent, List<String>? evidence, required String status, required String priority, String? adminNotes, String? processedBy, amplify_core.TemporalDateTime? processedAt, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return Report._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      reporterUserId: reporterUserId,
      reporterName: reporterName,
      reportedUserId: reportedUserId,
      reportedName: reportedName,
      reportType: reportType,
      reportReason: reportReason,
      reportContent: reportContent,
      evidence: evidence != null ? List<String>.unmodifiable(evidence) : evidence,
      status: status,
      priority: priority,
      adminNotes: adminNotes,
      processedBy: processedBy,
      processedAt: processedAt,
      createdAt: createdAt,
      updatedAt: updatedAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Report &&
      id == other.id &&
      _reporterUserId == other._reporterUserId &&
      _reporterName == other._reporterName &&
      _reportedUserId == other._reportedUserId &&
      _reportedName == other._reportedName &&
      _reportType == other._reportType &&
      _reportReason == other._reportReason &&
      _reportContent == other._reportContent &&
      DeepCollectionEquality().equals(_evidence, other._evidence) &&
      _status == other._status &&
      _priority == other._priority &&
      _adminNotes == other._adminNotes &&
      _processedBy == other._processedBy &&
      _processedAt == other._processedAt &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Report {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("reporterUserId=" + "$_reporterUserId" + ", ");
    buffer.write("reporterName=" + "$_reporterName" + ", ");
    buffer.write("reportedUserId=" + "$_reportedUserId" + ", ");
    buffer.write("reportedName=" + "$_reportedName" + ", ");
    buffer.write("reportType=" + "$_reportType" + ", ");
    buffer.write("reportReason=" + "$_reportReason" + ", ");
    buffer.write("reportContent=" + "$_reportContent" + ", ");
    buffer.write("evidence=" + (_evidence != null ? _evidence!.toString() : "null") + ", ");
    buffer.write("status=" + "$_status" + ", ");
    buffer.write("priority=" + "$_priority" + ", ");
    buffer.write("adminNotes=" + "$_adminNotes" + ", ");
    buffer.write("processedBy=" + "$_processedBy" + ", ");
    buffer.write("processedAt=" + (_processedAt != null ? _processedAt!.format() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Report copyWith({String? reporterUserId, String? reporterName, String? reportedUserId, String? reportedName, String? reportType, String? reportReason, String? reportContent, List<String>? evidence, String? status, String? priority, String? adminNotes, String? processedBy, amplify_core.TemporalDateTime? processedAt, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return Report._internal(
      id: id,
      reporterUserId: reporterUserId ?? this.reporterUserId,
      reporterName: reporterName ?? this.reporterName,
      reportedUserId: reportedUserId ?? this.reportedUserId,
      reportedName: reportedName ?? this.reportedName,
      reportType: reportType ?? this.reportType,
      reportReason: reportReason ?? this.reportReason,
      reportContent: reportContent ?? this.reportContent,
      evidence: evidence ?? this.evidence,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      adminNotes: adminNotes ?? this.adminNotes,
      processedBy: processedBy ?? this.processedBy,
      processedAt: processedAt ?? this.processedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  Report copyWithModelFieldValues({
    ModelFieldValue<String>? reporterUserId,
    ModelFieldValue<String>? reporterName,
    ModelFieldValue<String>? reportedUserId,
    ModelFieldValue<String>? reportedName,
    ModelFieldValue<String>? reportType,
    ModelFieldValue<String>? reportReason,
    ModelFieldValue<String>? reportContent,
    ModelFieldValue<List<String>?>? evidence,
    ModelFieldValue<String>? status,
    ModelFieldValue<String>? priority,
    ModelFieldValue<String?>? adminNotes,
    ModelFieldValue<String?>? processedBy,
    ModelFieldValue<amplify_core.TemporalDateTime?>? processedAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return Report._internal(
      id: id,
      reporterUserId: reporterUserId == null ? this.reporterUserId : reporterUserId.value,
      reporterName: reporterName == null ? this.reporterName : reporterName.value,
      reportedUserId: reportedUserId == null ? this.reportedUserId : reportedUserId.value,
      reportedName: reportedName == null ? this.reportedName : reportedName.value,
      reportType: reportType == null ? this.reportType : reportType.value,
      reportReason: reportReason == null ? this.reportReason : reportReason.value,
      reportContent: reportContent == null ? this.reportContent : reportContent.value,
      evidence: evidence == null ? this.evidence : evidence.value,
      status: status == null ? this.status : status.value,
      priority: priority == null ? this.priority : priority.value,
      adminNotes: adminNotes == null ? this.adminNotes : adminNotes.value,
      processedBy: processedBy == null ? this.processedBy : processedBy.value,
      processedAt: processedAt == null ? this.processedAt : processedAt.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  Report.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _reporterUserId = json['reporterUserId'],
      _reporterName = json['reporterName'],
      _reportedUserId = json['reportedUserId'],
      _reportedName = json['reportedName'],
      _reportType = json['reportType'],
      _reportReason = json['reportReason'],
      _reportContent = json['reportContent'],
      _evidence = json['evidence']?.cast<String>(),
      _status = json['status'],
      _priority = json['priority'],
      _adminNotes = json['adminNotes'],
      _processedBy = json['processedBy'],
      _processedAt = json['processedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['processedAt']) : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'reporterUserId': _reporterUserId, 'reporterName': _reporterName, 'reportedUserId': _reportedUserId, 'reportedName': _reportedName, 'reportType': _reportType, 'reportReason': _reportReason, 'reportContent': _reportContent, 'evidence': _evidence, 'status': _status, 'priority': _priority, 'adminNotes': _adminNotes, 'processedBy': _processedBy, 'processedAt': _processedAt?.format(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'reporterUserId': _reporterUserId,
    'reporterName': _reporterName,
    'reportedUserId': _reportedUserId,
    'reportedName': _reportedName,
    'reportType': _reportType,
    'reportReason': _reportReason,
    'reportContent': _reportContent,
    'evidence': _evidence,
    'status': _status,
    'priority': _priority,
    'adminNotes': _adminNotes,
    'processedBy': _processedBy,
    'processedAt': _processedAt,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<ReportModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<ReportModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final REPORTERUSERID = amplify_core.QueryField(fieldName: "reporterUserId");
  static final REPORTERNAME = amplify_core.QueryField(fieldName: "reporterName");
  static final REPORTEDUSERID = amplify_core.QueryField(fieldName: "reportedUserId");
  static final REPORTEDNAME = amplify_core.QueryField(fieldName: "reportedName");
  static final REPORTTYPE = amplify_core.QueryField(fieldName: "reportType");
  static final REPORTREASON = amplify_core.QueryField(fieldName: "reportReason");
  static final REPORTCONTENT = amplify_core.QueryField(fieldName: "reportContent");
  static final EVIDENCE = amplify_core.QueryField(fieldName: "evidence");
  static final STATUS = amplify_core.QueryField(fieldName: "status");
  static final PRIORITY = amplify_core.QueryField(fieldName: "priority");
  static final ADMINNOTES = amplify_core.QueryField(fieldName: "adminNotes");
  static final PROCESSEDBY = amplify_core.QueryField(fieldName: "processedBy");
  static final PROCESSEDAT = amplify_core.QueryField(fieldName: "processedAt");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Report";
    modelSchemaDefinition.pluralName = "Reports";
    
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
      amplify_core.ModelIndex(fields: const ["reporterUserId"], name: "byReporterUserId"),
      amplify_core.ModelIndex(fields: const ["reportedUserId"], name: "byReportedUserId"),
      amplify_core.ModelIndex(fields: const ["reportType"], name: "byReportType"),
      amplify_core.ModelIndex(fields: const ["status"], name: "byStatus")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Report.REPORTERUSERID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Report.REPORTERNAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Report.REPORTEDUSERID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Report.REPORTEDNAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Report.REPORTTYPE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Report.REPORTREASON,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Report.REPORTCONTENT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Report.EVIDENCE,
      isRequired: false,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Report.STATUS,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Report.PRIORITY,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Report.ADMINNOTES,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Report.PROCESSEDBY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Report.PROCESSEDAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Report.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Report.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _ReportModelType extends amplify_core.ModelType<Report> {
  const _ReportModelType();
  
  @override
  Report fromJson(Map<String, dynamic> jsonData) {
    return Report.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Report';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Report] in your schema.
 */
class ReportModelIdentifier implements amplify_core.ModelIdentifier<Report> {
  final String id;

  /** Create an instance of ReportModelIdentifier using [id] the primary key. */
  const ReportModelIdentifier({
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
  String toString() => 'ReportModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is ReportModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}