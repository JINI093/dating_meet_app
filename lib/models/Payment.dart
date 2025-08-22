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


/** This is an auto generated class representing the Payment type in your schema. */
class Payment extends amplify_core.Model {
  static const classType = const _PaymentModelType();
  final String id;
  final String? _userId;
  final String? _userName;
  final String? _productName;
  final String? _productType;
  final int? _amount;
  final String? _paymentMethod;
  final String? _status;
  final String? _transactionId;
  final String? _gatewayResponse;
  final int? _refundAmount;
  final String? _refundReason;
  final amplify_core.TemporalDateTime? _refundedAt;
  final String? _failureReason;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  PaymentModelIdentifier get modelIdentifier {
      return PaymentModelIdentifier(
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
  
  String get userName {
    try {
      return _userName!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get productName {
    try {
      return _productName!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get productType {
    try {
      return _productType!;
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
  
  String get paymentMethod {
    try {
      return _paymentMethod!;
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
  
  String? get transactionId {
    return _transactionId;
  }
  
  String? get gatewayResponse {
    return _gatewayResponse;
  }
  
  int? get refundAmount {
    return _refundAmount;
  }
  
  String? get refundReason {
    return _refundReason;
  }
  
  amplify_core.TemporalDateTime? get refundedAt {
    return _refundedAt;
  }
  
  String? get failureReason {
    return _failureReason;
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
  
  const Payment._internal({required this.id, required userId, required userName, required productName, required productType, required amount, required paymentMethod, required status, transactionId, gatewayResponse, refundAmount, refundReason, refundedAt, failureReason, required createdAt, required updatedAt}): _userId = userId, _userName = userName, _productName = productName, _productType = productType, _amount = amount, _paymentMethod = paymentMethod, _status = status, _transactionId = transactionId, _gatewayResponse = gatewayResponse, _refundAmount = refundAmount, _refundReason = refundReason, _refundedAt = refundedAt, _failureReason = failureReason, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Payment({String? id, required String userId, required String userName, required String productName, required String productType, required int amount, required String paymentMethod, required String status, String? transactionId, String? gatewayResponse, int? refundAmount, String? refundReason, amplify_core.TemporalDateTime? refundedAt, String? failureReason, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return Payment._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      userId: userId,
      userName: userName,
      productName: productName,
      productType: productType,
      amount: amount,
      paymentMethod: paymentMethod,
      status: status,
      transactionId: transactionId,
      gatewayResponse: gatewayResponse,
      refundAmount: refundAmount,
      refundReason: refundReason,
      refundedAt: refundedAt,
      failureReason: failureReason,
      createdAt: createdAt,
      updatedAt: updatedAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Payment &&
      id == other.id &&
      _userId == other._userId &&
      _userName == other._userName &&
      _productName == other._productName &&
      _productType == other._productType &&
      _amount == other._amount &&
      _paymentMethod == other._paymentMethod &&
      _status == other._status &&
      _transactionId == other._transactionId &&
      _gatewayResponse == other._gatewayResponse &&
      _refundAmount == other._refundAmount &&
      _refundReason == other._refundReason &&
      _refundedAt == other._refundedAt &&
      _failureReason == other._failureReason &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Payment {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("userId=" + "$_userId" + ", ");
    buffer.write("userName=" + "$_userName" + ", ");
    buffer.write("productName=" + "$_productName" + ", ");
    buffer.write("productType=" + "$_productType" + ", ");
    buffer.write("amount=" + (_amount != null ? _amount!.toString() : "null") + ", ");
    buffer.write("paymentMethod=" + "$_paymentMethod" + ", ");
    buffer.write("status=" + "$_status" + ", ");
    buffer.write("transactionId=" + "$_transactionId" + ", ");
    buffer.write("gatewayResponse=" + "$_gatewayResponse" + ", ");
    buffer.write("refundAmount=" + (_refundAmount != null ? _refundAmount!.toString() : "null") + ", ");
    buffer.write("refundReason=" + "$_refundReason" + ", ");
    buffer.write("refundedAt=" + (_refundedAt != null ? _refundedAt!.format() : "null") + ", ");
    buffer.write("failureReason=" + "$_failureReason" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Payment copyWith({String? userId, String? userName, String? productName, String? productType, int? amount, String? paymentMethod, String? status, String? transactionId, String? gatewayResponse, int? refundAmount, String? refundReason, amplify_core.TemporalDateTime? refundedAt, String? failureReason, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return Payment._internal(
      id: id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      productName: productName ?? this.productName,
      productType: productType ?? this.productType,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      gatewayResponse: gatewayResponse ?? this.gatewayResponse,
      refundAmount: refundAmount ?? this.refundAmount,
      refundReason: refundReason ?? this.refundReason,
      refundedAt: refundedAt ?? this.refundedAt,
      failureReason: failureReason ?? this.failureReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  Payment copyWithModelFieldValues({
    ModelFieldValue<String>? userId,
    ModelFieldValue<String>? userName,
    ModelFieldValue<String>? productName,
    ModelFieldValue<String>? productType,
    ModelFieldValue<int>? amount,
    ModelFieldValue<String>? paymentMethod,
    ModelFieldValue<String>? status,
    ModelFieldValue<String?>? transactionId,
    ModelFieldValue<String?>? gatewayResponse,
    ModelFieldValue<int?>? refundAmount,
    ModelFieldValue<String?>? refundReason,
    ModelFieldValue<amplify_core.TemporalDateTime?>? refundedAt,
    ModelFieldValue<String?>? failureReason,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return Payment._internal(
      id: id,
      userId: userId == null ? this.userId : userId.value,
      userName: userName == null ? this.userName : userName.value,
      productName: productName == null ? this.productName : productName.value,
      productType: productType == null ? this.productType : productType.value,
      amount: amount == null ? this.amount : amount.value,
      paymentMethod: paymentMethod == null ? this.paymentMethod : paymentMethod.value,
      status: status == null ? this.status : status.value,
      transactionId: transactionId == null ? this.transactionId : transactionId.value,
      gatewayResponse: gatewayResponse == null ? this.gatewayResponse : gatewayResponse.value,
      refundAmount: refundAmount == null ? this.refundAmount : refundAmount.value,
      refundReason: refundReason == null ? this.refundReason : refundReason.value,
      refundedAt: refundedAt == null ? this.refundedAt : refundedAt.value,
      failureReason: failureReason == null ? this.failureReason : failureReason.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  Payment.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _userId = json['userId'],
      _userName = json['userName'],
      _productName = json['productName'],
      _productType = json['productType'],
      _amount = (json['amount'] as num?)?.toInt(),
      _paymentMethod = json['paymentMethod'],
      _status = json['status'],
      _transactionId = json['transactionId'],
      _gatewayResponse = json['gatewayResponse'],
      _refundAmount = (json['refundAmount'] as num?)?.toInt(),
      _refundReason = json['refundReason'],
      _refundedAt = json['refundedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['refundedAt']) : null,
      _failureReason = json['failureReason'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'userId': _userId, 'userName': _userName, 'productName': _productName, 'productType': _productType, 'amount': _amount, 'paymentMethod': _paymentMethod, 'status': _status, 'transactionId': _transactionId, 'gatewayResponse': _gatewayResponse, 'refundAmount': _refundAmount, 'refundReason': _refundReason, 'refundedAt': _refundedAt?.format(), 'failureReason': _failureReason, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'userId': _userId,
    'userName': _userName,
    'productName': _productName,
    'productType': _productType,
    'amount': _amount,
    'paymentMethod': _paymentMethod,
    'status': _status,
    'transactionId': _transactionId,
    'gatewayResponse': _gatewayResponse,
    'refundAmount': _refundAmount,
    'refundReason': _refundReason,
    'refundedAt': _refundedAt,
    'failureReason': _failureReason,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<PaymentModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<PaymentModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USERID = amplify_core.QueryField(fieldName: "userId");
  static final USERNAME = amplify_core.QueryField(fieldName: "userName");
  static final PRODUCTNAME = amplify_core.QueryField(fieldName: "productName");
  static final PRODUCTTYPE = amplify_core.QueryField(fieldName: "productType");
  static final AMOUNT = amplify_core.QueryField(fieldName: "amount");
  static final PAYMENTMETHOD = amplify_core.QueryField(fieldName: "paymentMethod");
  static final STATUS = amplify_core.QueryField(fieldName: "status");
  static final TRANSACTIONID = amplify_core.QueryField(fieldName: "transactionId");
  static final GATEWAYRESPONSE = amplify_core.QueryField(fieldName: "gatewayResponse");
  static final REFUNDAMOUNT = amplify_core.QueryField(fieldName: "refundAmount");
  static final REFUNDREASON = amplify_core.QueryField(fieldName: "refundReason");
  static final REFUNDEDAT = amplify_core.QueryField(fieldName: "refundedAt");
  static final FAILUREREASON = amplify_core.QueryField(fieldName: "failureReason");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Payment";
    modelSchemaDefinition.pluralName = "Payments";
    
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
      amplify_core.ModelIndex(fields: const ["userId"], name: "byUserId"),
      amplify_core.ModelIndex(fields: const ["status"], name: "byStatus")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payment.USERID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payment.USERNAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payment.PRODUCTNAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payment.PRODUCTTYPE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payment.AMOUNT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payment.PAYMENTMETHOD,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payment.STATUS,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payment.TRANSACTIONID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payment.GATEWAYRESPONSE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payment.REFUNDAMOUNT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payment.REFUNDREASON,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payment.REFUNDEDAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payment.FAILUREREASON,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payment.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Payment.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _PaymentModelType extends amplify_core.ModelType<Payment> {
  const _PaymentModelType();
  
  @override
  Payment fromJson(Map<String, dynamic> jsonData) {
    return Payment.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Payment';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Payment] in your schema.
 */
class PaymentModelIdentifier implements amplify_core.ModelIdentifier<Payment> {
  final String id;

  /** Create an instance of PaymentModelIdentifier using [id] the primary key. */
  const PaymentModelIdentifier({
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
  String toString() => 'PaymentModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is PaymentModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}