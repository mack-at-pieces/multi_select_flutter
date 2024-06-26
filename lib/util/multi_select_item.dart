import 'package:flutter/material.dart';

/// A model class used to represent a selectable item.
class MultiSelectItem<T> {
  final T value;
  final String label;
  bool selected = false;
  final Widget? icon;
  final Widget? selectedIcon;

  MultiSelectItem(
    this.value,
    this.label, {
    this.icon,
    this.selectedIcon,
  });
}
