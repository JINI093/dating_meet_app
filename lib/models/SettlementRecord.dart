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


/** This is an auto generated class representing the SettlementRecord type in your schema. */
class SettlementRecord extends amplify_core.Model {
  static const classType = const _SettlementRecordModelType();
  final String id;
  final String? _requestDate; // 요청 일자
  final String? _memberName; // 회원이름
  final int? _pointCount; // 교환된 포인트 개수
  final int? _settlementAmount; // 정산금액
  final String? _accountNumber; // 계좌번호
  final String? _settlementStatus; // 정산 상태 (PENDING, PROCESSING, COMPLETED)
  final String? _userId; // 사용자 ID
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  SettlementRecordModelIdentifier get modelIdentifier {
      return SettlementRecordModelIdentifier(
        id: id
      );
  }
  
  String? get requestDate {
    return _requestDate;
  }
  
  String? get memberName {
    return _memberName;
  }
  
  int? get pointCount {
    return _pointCount;
  }
  
  int? get settlementAmount {
    return _settlementAmount;
  }
  
  String? get accountNumber {
    return _accountNumber;
  }
  
  String? get settlementStatus {
    return _settlementStatus;
  }
  
  String? get userId {
    return _userId;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const SettlementRecord._internal({required this.id, requestDate, memberName, pointCount, settlementAmount, accountNumber, settlementStatus, userId, createdAt, updatedAt}): _requestDate = requestDate, _memberName = memberName, _pointCount = pointCount, _settlementAmount = settlementAmount, _accountNumber = accountNumber, _settlementStatus = settlementStatus, _userId = userId, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory SettlementRecord({String? id, String? requestDate, String? memberName, int? pointCount, int? settlementAmount, String? accountNumber, String? settlementStatus, String? userId}) {
    return SettlementRecord._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      requestDate: requestDate,
      memberName: memberName,
      pointCount: pointCount,
      settlementAmount: settlementAmount,
      accountNumber: accountNumber,
      settlementStatus: settlementStatus,
      userId: userId);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SettlementRecord &&
      id == other.id &&
      _requestDate == other._requestDate &&
      _memberName == other._memberName &&
      _pointCount == other._pointCount &&
      _settlementAmount == other._settlementAmount &&
      _accountNumber == other._accountNumber &&
      _settlementStatus == other._settlementStatus &&
      _userId == other._userId;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("SettlementRecord {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("requestDate=" + "$_requestDate" + ", ");
    buffer.write("memberName=" + "$_memberName" + ", ");
    buffer.write("pointCount=" + (_pointCount != null ? _pointCount!.toString() : "null") + ", ");
    buffer.write("settlementAmount=" + (_settlementAmount != null ? _settlementAmount!.toString() : "null") + ", ");
    buffer.write("accountNumber=" + "$_accountNumber" + ", ");
    buffer.write("settlementStatus=" + "$_settlementStatus" + ", ");
    buffer.write("userId=" + "$_userId" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  SettlementRecord copyWith({String? requestDate, String? memberName, int? pointCount, int? settlementAmount, String? accountNumber, String? settlementStatus, String? userId}) {
    return SettlementRecord._internal(
      id: id,
      requestDate: requestDate ?? this.requestDate,
      memberName: memberName ?? this.memberName,
      pointCount: pointCount ?? this.pointCount,
      settlementAmount: settlementAmount ?? this.settlementAmount,
      accountNumber: accountNumber ?? this.accountNumber,
      settlementStatus: settlementStatus ?? this.settlementStatus,
      userId: userId ?? this.userId);
  }
  
  SettlementRecord copyWithModelFieldValues({
    ModelFieldValue<String?>? requestDate,
    ModelFieldValue<String?>? memberName,
    ModelFieldValue<int?>? pointCount,
    ModelFieldValue<int?>? settlementAmount,
    ModelFieldValue<String?>? accountNumber,
    ModelFieldValue<String?>? settlementStatus,
    ModelFieldValue<String?>? userId
  }) {
    return SettlementRecord._internal(
      id: id,
      requestDate: requestDate == null ? this.requestDate : requestDate.value,
      memberName: memberName == null ? this.memberName : memberName.value,
      pointCount: pointCount == null ? this.pointCount : pointCount.value,
      settlementAmount: settlementAmount == null ? this.settlementAmount : settlementAmount.value,
      accountNumber: accountNumber == null ? this.accountNumber : accountNumber.value,
      settlementStatus: settlementStatus == null ? this.settlementStatus : settlementStatus.value,
      userId: userId == null ? this.userId : userId.value
    );
  }
  
  SettlementRecord.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _requestDate = json['requestDate'],
      _memberName = json['memberName'],
      _pointCount = (json['pointCount'] as num?)?.toInt(),
      _settlementAmount = (json['settlementAmount'] as num?)?.toInt(),
      _accountNumber = json['accountNumber'],
      _settlementStatus = json['settlementStatus'],
      _userId = json['userId'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'requestDate': _requestDate, 'memberName': _memberName, 'pointCount': _pointCount, 'settlementAmount': _settlementAmount, 'accountNumber': _accountNumber, 'settlementStatus': _settlementStatus, 'userId': _userId, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'requestDate': _requestDate,
    'memberName': _memberName,
    'pointCount': _pointCount,
    'settlementAmount': _settlementAmount,
    'accountNumber': _accountNumber,
    'settlementStatus': _settlementStatus,
    'userId': _userId,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<SettlementRecordModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<SettlementRecordModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final REQUESTDATE = amplify_core.QueryField(fieldName: "requestDate");
  static final MEMBERNAME = amplify_core.QueryField(fieldName: "memberName");
  static final POINTCOUNT = amplify_core.QueryField(fieldName: "pointCount");
  static final SETTLEMENTAMOUNT = amplify_core.QueryField(fieldName: "settlementAmount");
  static final ACCOUNTNUMBER = amplify_core.QueryField(fieldName: "accountNumber");
  static final SETTLEMENTSTATUS = amplify_core.QueryField(fieldName: "settlementStatus");
  static final USERID = amplify_core.QueryField(fieldName: "userId");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "SettlementRecord";
    modelSchemaDefinition.pluralName = "SettlementRecords";
    
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
      key: SettlementRecord.REQUESTDATE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SettlementRecord.MEMBERNAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SettlementRecord.POINTCOUNT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SettlementRecord.SETTLEMENTAMOUNT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SettlementRecord.ACCOUNTNUMBER,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SettlementRecord.SETTLEMENTSTATUS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: SettlementRecord.USERID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
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

class _SettlementRecordModelType extends amplify_core.ModelType<SettlementRecord> {
  const _SettlementRecordModelType();
  
  @override
  SettlementRecord fromJson(Map<String, dynamic> jsonData) {
    return SettlementRecord.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'SettlementRecord';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [SettlementRecord] in your schema.
 */
class SettlementRecordModelIdentifier implements amplify_core.ModelIdentifier<SettlementRecord> {
  final String id;

  /** Create an instance of SettlementRecordModelIdentifier using [id] the primary key. */
  const SettlementRecordModelIdentifier({
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
  String toString() => 'SettlementRecordModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is SettlementRecordModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}