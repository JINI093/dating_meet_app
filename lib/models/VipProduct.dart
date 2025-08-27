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


/** This is an auto generated class representing the VipProduct type in your schema. */
class VipProduct extends amplify_core.Model {
  static const classType = const _VipProductModelType();
  final String id;
  final String? _title;
  final String? _subtitle;
  final String? _description;
  final String? _tier; // GOLD, SILVER, BRONZE
  final String? _iconColor;
  final bool? _isActive;
  final List<String>? _features;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  VipProductModelIdentifier get modelIdentifier {
      return VipProductModelIdentifier(
        id: id
      );
  }
  
  String? get title {
    return _title;
  }
  
  String? get subtitle {
    return _subtitle;
  }
  
  String? get description {
    return _description;
  }
  
  String? get tier {
    return _tier;
  }
  
  String? get iconColor {
    return _iconColor;
  }
  
  bool? get isActive {
    return _isActive;
  }
  
  List<String>? get features {
    return _features;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const VipProduct._internal({required this.id, title, subtitle, description, tier, iconColor, isActive, features, createdAt, updatedAt}): _title = title, _subtitle = subtitle, _description = description, _tier = tier, _iconColor = iconColor, _isActive = isActive, _features = features, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory VipProduct({String? id, String? title, String? subtitle, String? description, String? tier, String? iconColor, bool? isActive, List<String>? features}) {
    return VipProduct._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      title: title,
      subtitle: subtitle,
      description: description,
      tier: tier,
      iconColor: iconColor,
      isActive: isActive,
      features: features != null ? List<String>.unmodifiable(features) : features);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VipProduct &&
      id == other.id &&
      _title == other._title &&
      _subtitle == other._subtitle &&
      _description == other._description &&
      _tier == other._tier &&
      _iconColor == other._iconColor &&
      _isActive == other._isActive &&
      _features == other._features;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("VipProduct {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("title=" + "$_title" + ", ");
    buffer.write("subtitle=" + "$_subtitle" + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("tier=" + "$_tier" + ", ");
    buffer.write("iconColor=" + "$_iconColor" + ", ");
    buffer.write("isActive=" + (_isActive != null ? _isActive!.toString() : "null") + ", ");
    buffer.write("features=" + (_features != null ? _features!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  VipProduct copyWith({String? title, String? subtitle, String? description, String? tier, String? iconColor, bool? isActive, List<String>? features}) {
    return VipProduct._internal(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      tier: tier ?? this.tier,
      iconColor: iconColor ?? this.iconColor,
      isActive: isActive ?? this.isActive,
      features: features ?? this.features);
  }
  
  VipProduct copyWithModelFieldValues({
    ModelFieldValue<String?>? title,
    ModelFieldValue<String?>? subtitle,
    ModelFieldValue<String?>? description,
    ModelFieldValue<String?>? tier,
    ModelFieldValue<String?>? iconColor,
    ModelFieldValue<bool?>? isActive,
    ModelFieldValue<List<String>?>? features
  }) {
    return VipProduct._internal(
      id: id,
      title: title == null ? this.title : title.value,
      subtitle: subtitle == null ? this.subtitle : subtitle.value,
      description: description == null ? this.description : description.value,
      tier: tier == null ? this.tier : tier.value,
      iconColor: iconColor == null ? this.iconColor : iconColor.value,
      isActive: isActive == null ? this.isActive : isActive.value,
      features: features == null ? this.features : features.value
    );
  }
  
  VipProduct.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _title = json['title'],
      _subtitle = json['subtitle'],
      _description = json['description'],
      _tier = json['tier'],
      _iconColor = json['iconColor'],
      _isActive = json['isActive'],
      _features = json['features']?.cast<String>(),
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'title': _title, 'subtitle': _subtitle, 'description': _description, 'tier': _tier, 'iconColor': _iconColor, 'isActive': _isActive, 'features': _features, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'title': _title,
    'subtitle': _subtitle,
    'description': _description,
    'tier': _tier,
    'iconColor': _iconColor,
    'isActive': _isActive,
    'features': _features,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<VipProductModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<VipProductModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final TITLE = amplify_core.QueryField(fieldName: "title");
  static final SUBTITLE = amplify_core.QueryField(fieldName: "subtitle");
  static final DESCRIPTION = amplify_core.QueryField(fieldName: "description");
  static final TIER = amplify_core.QueryField(fieldName: "tier");
  static final ICONCOLOR = amplify_core.QueryField(fieldName: "iconColor");
  static final ISACTIVE = amplify_core.QueryField(fieldName: "isActive");
  static final FEATURES = amplify_core.QueryField(fieldName: "features");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "VipProduct";
    modelSchemaDefinition.pluralName = "VipProducts";
    
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
      key: VipProduct.TITLE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: VipProduct.SUBTITLE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: VipProduct.DESCRIPTION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: VipProduct.TIER,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: VipProduct.ICONCOLOR,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: VipProduct.ISACTIVE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: VipProduct.FEATURES,
      isRequired: false,
      isArray: true,
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

class _VipProductModelType extends amplify_core.ModelType<VipProduct> {
  const _VipProductModelType();
  
  @override
  VipProduct fromJson(Map<String, dynamic> jsonData) {
    return VipProduct.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'VipProduct';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [VipProduct] in your schema.
 */
class VipProductModelIdentifier implements amplify_core.ModelIdentifier<VipProduct> {
  final String id;

  /** Create an instance of VipProductModelIdentifier using [id] the primary key. */
  const VipProductModelIdentifier({
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
  String toString() => 'VipProductModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is VipProductModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}