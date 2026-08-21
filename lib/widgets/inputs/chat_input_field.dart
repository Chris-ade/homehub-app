// lib/widgets/inputs/chat_input_field.dart
// Chat input field widget used in chat screens.
// It provides a multi‑line input with a send button as a suffix icon.
// The widget is built on top of CustomInputField for consistent styling.

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import './custom_input_field.dart';
import '../../theme/app_theme.dart';

/// A reusable chat input field.
///
/// Parameters:
/// * [controller] – Text editing controller.
/// * [onSend] – Callback invoked when the send button is pressed.
/// * [isDark] – Theme flag for dark mode.
/// * [hintText] – Placeholder text, defaults to "Type a message...".
/// * [focusNode] – Optional focus node.
class ChatInputField extends StatelessWidget {
  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    required this.isDark,
    this.hintText = "Type a message...",
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction = TextInputAction.send,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isDark;
  final String hintText;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      controller: controller,
      hintText: hintText,
      focusNode: focusNode,
      isDark: isDark,
      minLines: 1,
      maxLines: 5,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      // Use a send icon as the custom suffix.
      customSuffixIcon: IconButton(
        icon: Icon(LucideIcons.send, size: 20, color: isDark ? AppColors.amber : AppColors.amberDeep),
        onPressed: onSend,
      ),
    );
  }
}
