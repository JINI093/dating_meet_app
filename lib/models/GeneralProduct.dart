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


/** This is an auto generated class representing the GeneralProduct type in your schema. */
class GeneralProduct extends amplify_core.Model {
  static const classType = const _GeneralProductModelType();
  final String id;
  final String? _title;
  final String? _subtitle;
  final String? _description;
  final String? _iconType;
  final String? _iconColor;
  final bool? _isActive;
  final double? _price;
  final String? _category;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  GeneralProductModelIdentifier get modelIdentifier {
      return GeneralProductModelIdentifier(
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
  
  String? get iconType {
    return _iconType;
  }
  
  String? get iconColor {
    return _iconColor;
  }
  
  bool? get isActive {
    return _isActive;
  }
  
  double? get price {
    return _price;
  }
  
  String? get category {
    return _category;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const GeneralProduct._internal({required this.id, title, subtitle, description, iconType, iconColor, isActive, price, category, createdAt, updatedAt}): _title = title, _subtitle = subtitle, _description = description, _iconType = iconType, _iconColor = iconColor, _isActive = isActive, _price = price, _category = category, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory GeneralProduct({String? id, String? title, String? subtitle, String? description, String? iconType, String? iconColor, bool? isActive, double? price, String? category}) {
    return GeneralProduct._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      title: title,
      subtitle: subtitle,
      description: description,
      iconType: iconType,
      iconColor: iconColor,
      isActive: isActive,
      price: price,
      category: category);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GeneralProduct &&
      id == other.id &&
      _title == other._title &&
      _subtitle == other._subtitle &&
      _description == other._description &&
      _iconType == other._iconType &&
      _iconColor == other._iconColor &&
      _isActive == other._isActive &&
      _price == other._price &&
      _category == other._category;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("GeneralProduct {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("title=" + "$_title" + ", ");
    buffer.write("subtitle=" + "$_subtitle" + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("iconType=" + "$_iconType" + ", ");
    buffer.write("iconColor=" + "$_iconColor" + ", ");
    buffer.write("isActive=" + (_isActive != null ? _isActive!.toString() : "null") + ", ");
    buffer.write("price=" + (_price != null ? _price!.toString() : "null") + ", ");
    buffer.write("category=" + "$_category" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  GeneralProduct copyWith({String? title, String? subtitle, String? description, String? iconType, String? iconColor, bool? isActive, double? price, String? category}) {
    return GeneralProduct._internal(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      iconType: iconType ?? this.iconType,
      iconColor: iconColor ?? this.iconColor,
      isActive: isActive ?? this.isActive,
      price: price ?? this.price,
      category: category ?? this.category);
  }
  
  GeneralProduct copyWithModelFieldValues({
    ModelFieldValue<String?>? title,
    ModelFieldValue<String?>? subtitle,
    ModelFieldValue<String?>? description,
    ModelFieldValue<String?>? iconType,
    ModelFieldValue<String?>? iconColor,
    ModelFieldValue<bool?>? isActive,
    ModelFieldValue<double?>? price,
    ModelFieldValue<String?>? category
  }) {
    return GeneralProduct._internal(
      id: id,
      title: title == null ? this.title : title.value,
      subtitle: subtitle == null ? this.subtitle : subtitle.value,
      description: description == null ? this.description : description.value,
      iconType: iconType == null ? this.iconType : iconType.value,
      iconColor: iconColor == null ? this.iconColor : iconColor.value,
      isActive: isActive == null ? this.isActive : isActive.value,
      price: price == null ? this.price : price.value,
      category: category == null ? this.category : category.value
    );
  }
  
  GeneralProduct.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _title = json['title'],
      _subtitle = json['subtitle'],
      _description = json['description'],
      _iconType = json['iconType'],
      _iconColor = json['iconColor'],
      _isActive = json['isActive'],
      _price = (json['price'] as num?)?.toDouble(),
      _category = json['category'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'title': _title, 'subtitle': _subtitle, 'description': _description, 'iconType': _iconType, 'iconColor': _iconColor, 'isActive': _isActive, 'price': _price, 'category': _category, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'title': _title,
    'subtitle': _subtitle,
    'description': _description,
    'iconType': _iconType,
    'iconColor': _iconColor,
    'isActive': _isActive,
    'price': _price,
    'category': _category,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<GeneralProductModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<GeneralProductModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final TITLE = amplify_core.QueryField(fieldName: "title");
  static final SUBTITLE = amplify_core.QueryField(fieldName: "subtitle");
  static final DESCRIPTION = amplify_core.QueryField(fieldName: "description");
  static final ICONTYPE = amplify_core.QueryField(fieldName: "iconType");
  static final ICONCOLOR = amplify_core.QueryField(fieldName: "iconColor");
  static final ISACTIVE = amplify_core.QueryField(fieldName: "isActive");
  static final PRICE = amplify_core.QueryField(fieldName: "price");
  static final CATEGORY = amplify_core.QueryField(fieldName: "category");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "GeneralProduct";
    modelSchemaDefinition.pluralName = "GeneralProducts";
    
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
      key: GeneralProduct.TITLE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: GeneralProduct.SUBTITLE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: GeneralProduct.DESCRIPTION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: GeneralProduct.ICONTYPE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: GeneralProduct.ICONCOLOR,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: GeneralProduct.ISACTIVE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: GeneralProduct.PRICE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: GeneralProduct.CATEGORY,
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

class _GeneralProductModelType extends amplify_core.ModelType<GeneralProduct> {
  const _GeneralProductModelType();
  
  @override
  GeneralProduct fromJson(Map<String, dynamic> jsonData) {
    return GeneralProduct.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'GeneralProduct';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [GeneralProduct] in your schema.
 */
class GeneralProductModelIdentifier implements amplify_core.ModelIdentifier<GeneralProduct> {
  final String id;

  /** Create an instance of GeneralProductModelIdentifier using [id] the primary key. */
  const GeneralProductModelIdentifier({
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
  String toString() => 'GeneralProductModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is GeneralProductModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}