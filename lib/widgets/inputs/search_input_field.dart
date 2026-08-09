// lib/widgets/inputs/search_input_field.dart
// A dedicated search input field widget built on CustomInputField.

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import './custom_input_field.dart';

/// A reusable search input widget.
class SearchInputField extends StatelessWidget {
  const SearchInputField({
    super.key,
    required this.controller,
    required this.isDark,
    this.hintText = "Search by location, city, or neighborhood...",
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  final TextEditingController controller;
  final bool isDark;
  final String hintText;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      controller: controller,
      hintText: hintText,
      focusNode: focusNode,
      isDark: isDark,
      prefixIcon: LucideIcons.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onClear: onClear,
      textInputAction: TextInputAction.search,
    );
  }
}
