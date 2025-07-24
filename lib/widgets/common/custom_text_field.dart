import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_dimensions.dart';

enum CustomTextFieldType {
  text,
  email,
  password,
  phone,
  number,
  multiline,
}

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? label; // Alternative to labelText
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final CustomTextFieldType type;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? suffix;
  final VoidCallback? onSuffixIconTap;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.label,
    this.hintText,
    this.errorText,
    this.helperText,
    this.type = CustomTextFieldType.text,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
    this.onSuffixIconTap,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.validator,
    this.inputFormatters,
    this.textInputAction,
    this.focusNode,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.contentPadding,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.type == CustomTextFieldType.password;
    
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null || widget.label != null) ...[
          Text(
            widget.labelText ?? widget.label!,
            style: AppTextStyles.inputLabel,
          ),
          const SizedBox(height: AppDimensions.spacing8),
        ],
        
        Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? 
                   (widget.enabled ? AppColors.surface : AppColors.divider),
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppDimensions.textFieldRadius,
            ),
            border: Border.all(
              color: _getBorderColor(),
              width: AppDimensions.borderNormal,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            obscureText: _obscureText,
            maxLines: widget.type == CustomTextFieldType.multiline 
                ? widget.maxLines 
                : 1,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            keyboardType: _getKeyboardType(),
            textInputAction: widget.textInputAction ?? _getDefaultTextInputAction(),
            inputFormatters: widget.inputFormatters ?? _getDefaultInputFormatters(),
            onTap: widget.onTap,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            onEditingComplete: widget.onEditingComplete,
            validator: widget.validator,
            style: AppTextStyles.inputText.copyWith(
              color: widget.enabled 
                  ? AppColors.textPrimary 
                  : AppColors.textHint,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTextStyles.inputHint,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused 
                          ? AppColors.primary 
                          : AppColors.textSecondary,
                      size: AppDimensions.iconM,
                    )
                  : null,
              suffixIcon: _buildSuffixIcon(),
              suffix: widget.suffix,
              contentPadding: widget.contentPadding ?? 
                  const EdgeInsets.all(AppDimensions.textFieldPadding),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              counterText: '',
            ),
          ),
        ),
        
        if (widget.errorText != null) ...[
          const SizedBox(height: AppDimensions.spacing4),
          Row(
            children: [
              const Icon(
                CupertinoIcons.exclamationmark_circle,
                color: AppColors.error,
                size: AppDimensions.iconS,
              ),
              const SizedBox(width: AppDimensions.spacing4),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: AppTextStyles.errorText,
                ),
              ),
            ],
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: AppDimensions.spacing4),
          Text(
            widget.helperText!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        
        if (widget.maxLength != null && widget.type == CustomTextFieldType.multiline) ...[
          const SizedBox(height: AppDimensions.spacing4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${widget.controller?.text.length ?? 0}/${widget.maxLength}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.type == CustomTextFieldType.password) {
      return IconButton(
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        icon: Icon(
          _obscureText 
              ? CupertinoIcons.eye_slash 
              : CupertinoIcons.eye,
          color: AppColors.textSecondary,
          size: AppDimensions.iconM,
        ),
      );
    }
    
    if (widget.suffixIcon != null) {
      return IconButton(
        onPressed: widget.onSuffixIconTap,
        icon: Icon(
          widget.suffixIcon,
          color: AppColors.textSecondary,
          size: AppDimensions.iconM,
        ),
      );
    }
    
    return null;
  }

  Color _getBorderColor() {
    if (widget.errorText != null) {
      return AppColors.error;
    }
    
    if (widget.borderColor != null) {
      return widget.borderColor!;
    }
    
    if (_isFocused) {
      return AppColors.primary;
    }
    
    return AppColors.cardBorder;
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case CustomTextFieldType.email:
        return TextInputType.emailAddress;
      case CustomTextFieldType.phone:
        return TextInputType.phone;
      case CustomTextFieldType.number:
        return TextInputType.number;
      case CustomTextFieldType.multiline:
        return TextInputType.multiline;
      case CustomTextFieldType.password:
      case CustomTextFieldType.text:
      default:
        return TextInputType.text;
    }
  }

  TextInputAction _getDefaultTextInputAction() {
    switch (widget.type) {
      case CustomTextFieldType.multiline:
        return TextInputAction.newline;
      case CustomTextFieldType.email:
      case CustomTextFieldType.password:
        return TextInputAction.next;
      default:
        return TextInputAction.done;
    }
  }

  List<TextInputFormatter>? _getDefaultInputFormatters() {
    switch (widget.type) {
      case CustomTextFieldType.phone:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ];
      case CustomTextFieldType.number:
        return [
          FilteringTextInputFormatter.digitsOnly,
        ];
      case CustomTextFieldType.email:
        return [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
        ];
      default:
        return null;
    }
  }
}