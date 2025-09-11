import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

InputDecoration Inputs(
  BuildContext context,
  String label, {
  IconData? prefixIcon,
  Widget? suffixIcon, // 👈 ahora acepta Widget, no solo IconData
  bool requerido = false,
  double radius = 12,
  String? hintText,
}) {
  final Widget? richLabel = requerido
      ? Text.rich(
          TextSpan(
            text: label,
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        )
      : null;

  return InputDecoration(
    label: requerido ? richLabel : null,
    labelText: requerido ? null : label,
    hintText: hintText,
    prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

