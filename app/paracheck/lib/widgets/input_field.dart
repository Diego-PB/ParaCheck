/*
 InputField is a simple reusable text input widget.
 It wraps a TextField with a controller, label text, and optional keyboard type,
 simplifying the creation of labeled input fields throughout the app.
*/

import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller; // Controller to manage the input text
  final String label;                      // Label text displayed above the input
  final TextInputType? keyboardType;      // Optional keyboard type (e.g., text, number, email)

  const InputField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
    );
  }
}
