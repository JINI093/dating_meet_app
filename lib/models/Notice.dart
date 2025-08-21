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


/** This is an auto generated class representing the Notice type in your schema. */
class Notice extends amplify_core.Model {
  static const classType = const _NoticeModelType();
  final String id;
  final String? _title;
  final String? _content;
  final String? _targetType;
  final String? _status;
  final String? _authorId;
  final String? _authorName;
  final int? _viewCount;
  final bool? _isPinned;
  final bool? _isImportant;
  final List<String>? _tags;
  final String? _metadata;
  final amplify_core.TemporalDateTime? _publishedAt;
  final amplify_core.TemporalDateTime? _scheduledAt;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  NoticeModelIdentifier get modelIdentifier {
      return NoticeModelIdentifier(
        id: id
      );
  }
  
  String get title {
    try {
      return _title!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get content {
    try {
      return _content!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get targetType {
    try {
      return _targetType!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
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
  
  String get authorId {
    try {
      return _authorId!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get authorName {
    try {
      return _authorName!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int? get viewCount {
    return _viewCount;
  }
  
  bool? get isPinned {
    return _isPinned;
  }
  
  bool? get isImportant {
    return _isImportant;
  }
  
  List<String>? get tags {
    return _tags;
  }
  
  String? get metadata {
    return _metadata;
  }
  
  amplify_core.TemporalDateTime? get publishedAt {
    return _publishedAt;
  }
  
  amplify_core.TemporalDateTime? get scheduledAt {
    return _scheduledAt;
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
  
  const Notice._internal({required this.id, required title, required content, required targetType, required status, required authorId, required authorName, viewCount, isPinned, isImportant, tags, metadata, publishedAt, scheduledAt, required createdAt, required updatedAt}): _title = title, _content = content, _targetType = targetType, _status = status, _authorId = authorId, _authorName = authorName, _viewCount = viewCount, _isPinned = isPinned, _isImportant = isImportant, _tags = tags, _metadata = metadata, _publishedAt = publishedAt, _scheduledAt = scheduledAt, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Notice({String? id, required String title, required String content, required String targetType, required String status, required String authorId, required String authorName, int? viewCount, bool? isPinned, bool? isImportant, List<String>? tags, String? metadata, amplify_core.TemporalDateTime? publishedAt, amplify_core.TemporalDateTime? scheduledAt, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return Notice._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      title: title,
      content: content,
      targetType: targetType,
      status: status,
      authorId: authorId,
      authorName: authorName,
      viewCount: viewCount,
      isPinned: isPinned,
      isImportant: isImportant,
      tags: tags != null ? List<String>.unmodifiable(tags) : tags,
      metadata: metadata,
      publishedAt: publishedAt,
      scheduledAt: scheduledAt,
      createdAt: createdAt,
      updatedAt: updatedAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Notice &&
      id == other.id &&
      _title == other._title &&
      _content == other._content &&
      _targetType == other._targetType &&
      _status == other._status &&
      _authorId == other._authorId &&
      _authorName == other._authorName &&
      _viewCount == other._viewCount &&
      _isPinned == other._isPinned &&
      _isImportant == other._isImportant &&
      DeepCollectionEquality().equals(_tags, other._tags) &&
      _metadata == other._metadata &&
      _publishedAt == other._publishedAt &&
      _scheduledAt == other._scheduledAt &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Notice {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("title=" + "$_title" + ", ");
    buffer.write("content=" + "$_content" + ", ");
    buffer.write("targetType=" + "$_targetType" + ", ");
    buffer.write("status=" + "$_status" + ", ");
    buffer.write("authorId=" + "$_authorId" + ", ");
    buffer.write("authorName=" + "$_authorName" + ", ");
    buffer.write("viewCount=" + (_viewCount != null ? _viewCount!.toString() : "null") + ", ");
    buffer.write("isPinned=" + (_isPinned != null ? _isPinned!.toString() : "null") + ", ");
    buffer.write("isImportant=" + (_isImportant != null ? _isImportant!.toString() : "null") + ", ");
    buffer.write("tags=" + (_tags != null ? _tags!.toString() : "null") + ", ");
    buffer.write("metadata=" + "$_metadata" + ", ");
    buffer.write("publishedAt=" + (_publishedAt != null ? _publishedAt!.format() : "null") + ", ");
    buffer.write("scheduledAt=" + (_scheduledAt != null ? _scheduledAt!.format() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Notice copyWith({String? title, String? content, String? targetType, String? status, String? authorId, String? authorName, int? viewCount, bool? isPinned, bool? isImportant, List<String>? tags, String? metadata, amplify_core.TemporalDateTime? publishedAt, amplify_core.TemporalDateTime? scheduledAt, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return Notice._internal(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      targetType: targetType ?? this.targetType,
      status: status ?? this.status,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      viewCount: viewCount ?? this.viewCount,
      isPinned: isPinned ?? this.isPinned,
      isImportant: isImportant ?? this.isImportant,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      publishedAt: publishedAt ?? this.publishedAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  Notice copyWithModelFieldValues({
    ModelFieldValue<String>? title,
    ModelFieldValue<String>? content,
    ModelFieldValue<String>? targetType,
    ModelFieldValue<String>? status,
    ModelFieldValue<String>? authorId,
    ModelFieldValue<String>? authorName,
    ModelFieldValue<int?>? viewCount,
    ModelFieldValue<bool?>? isPinned,
    ModelFieldValue<bool?>? isImportant,
    ModelFieldValue<List<String>?>? tags,
    ModelFieldValue<String?>? metadata,
    ModelFieldValue<amplify_core.TemporalDateTime?>? publishedAt,
    ModelFieldValue<amplify_core.TemporalDateTime?>? scheduledAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return Notice._internal(
      id: id,
      title: title == null ? this.title : title.value,
      content: content == null ? this.content : content.value,
      targetType: targetType == null ? this.targetType : targetType.value,
      status: status == null ? this.status : status.value,
      authorId: authorId == null ? this.authorId : authorId.value,
      authorName: authorName == null ? this.authorName : authorName.value,
      viewCount: viewCount == null ? this.viewCount : viewCount.value,
      isPinned: isPinned == null ? this.isPinned : isPinned.value,
      isImportant: isImportant == null ? this.isImportant : isImportant.value,
      tags: tags == null ? this.tags : tags.value,
      metadata: metadata == null ? this.metadata : metadata.value,
      publishedAt: publishedAt == null ? this.publishedAt : publishedAt.value,
      scheduledAt: scheduledAt == null ? this.scheduledAt : scheduledAt.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  Notice.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _title = json['title'],
      _content = json['content'],
      _targetType = json['targetType'],
      _status = json['status'],
      _authorId = json['authorId'],
      _authorName = json['authorName'],
      _viewCount = (json['viewCount'] as num?)?.toInt(),
      _isPinned = json['isPinned'],
      _isImportant = json['isImportant'],
      _tags = json['tags']?.cast<String>(),
      _metadata = json['metadata'],
      _publishedAt = json['publishedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['publishedAt']) : null,
      _scheduledAt = json['scheduledAt'] != null ? amplify_core.TemporalDateTime.fromString(json['scheduledAt']) : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'title': _title, 'content': _content, 'targetType': _targetType, 'status': _status, 'authorId': _authorId, 'authorName': _authorName, 'viewCount': _viewCount, 'isPinned': _isPinned, 'isImportant': _isImportant, 'tags': _tags, 'metadata': _metadata, 'publishedAt': _publishedAt?.format(), 'scheduledAt': _scheduledAt?.format(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'title': _title,
    'content': _content,
    'targetType': _targetType,
    'status': _status,
    'authorId': _authorId,
    'authorName': _authorName,
    'viewCount': _viewCount,
    'isPinned': _isPinned,
    'isImportant': _isImportant,
    'tags': _tags,
    'metadata': _metadata,
    'publishedAt': _publishedAt,
    'scheduledAt': _scheduledAt,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<NoticeModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<NoticeModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final TITLE = amplify_core.QueryField(fieldName: "title");
  static final CONTENT = amplify_core.QueryField(fieldName: "content");
  static final TARGETTYPE = amplify_core.QueryField(fieldName: "targetType");
  static final STATUS = amplify_core.QueryField(fieldName: "status");
  static final AUTHORID = amplify_core.QueryField(fieldName: "authorId");
  static final AUTHORNAME = amplify_core.QueryField(fieldName: "authorName");
  static final VIEWCOUNT = amplify_core.QueryField(fieldName: "viewCount");
  static final ISPINNED = amplify_core.QueryField(fieldName: "isPinned");
  static final ISIMPORTANT = amplify_core.QueryField(fieldName: "isImportant");
  static final TAGS = amplify_core.QueryField(fieldName: "tags");
  static final METADATA = amplify_core.QueryField(fieldName: "metadata");
  static final PUBLISHEDAT = amplify_core.QueryField(fieldName: "publishedAt");
  static final SCHEDULEDAT = amplify_core.QueryField(fieldName: "scheduledAt");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Notice";
    modelSchemaDefinition.pluralName = "Notices";
    
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
      amplify_core.ModelIndex(fields: const ["targetType"], name: "byTargetType"),
      amplify_core.ModelIndex(fields: const ["status"], name: "byStatus")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Notice.TITLE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Notice.CONTENT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Notice.TARGETTYPE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Notice.STATUS,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Notice.AUTHORID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Notice.AUTHORNAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Notice.VIEWCOUNT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Notice.ISPINNED,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Notice.ISIMPORTANT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Notice.TAGS,
      isRequired: false,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Notice.METADATA,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Notice.PUBLISHEDAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Notice.SCHEDULEDAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Notice.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Notice.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _NoticeModelType extends amplify_core.ModelType<Notice> {
  const _NoticeModelType();
  
  @override
  Notice fromJson(Map<String, dynamic> jsonData) {
    return Notice.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Notice';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Notice] in your schema.
 */
class NoticeModelIdentifier implements amplify_core.ModelIdentifier<Notice> {
  final String id;

  /** Create an instance of NoticeModelIdentifier using [id] the primary key. */
  const NoticeModelIdentifier({
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
  String toString() => 'NoticeModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is NoticeModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}