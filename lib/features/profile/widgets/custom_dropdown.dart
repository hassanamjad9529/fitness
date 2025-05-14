import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<List<String>>(
      initialValue: selectedItems,
      builder: (FormFieldState<List<String>> state) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          child: Wrap(
            spacing: 8.0,
            children: items.map((item) {
              return ChoiceChip(
                label: Text(item),
                selected: selectedItems.contains(item),
                onSelected: (selected) {
                  List<String> updated = List.from(selectedItems);
                  if (selected) {
                    updated.add(item);
                  } else {
                    updated.remove(item);
                  }
                  onChanged(updated);
                  state.didChange(updated);
                },
              );
            }).toList(),
          ),
        );
      },
      validator: (value) => value!.isEmpty ? '$label is required' : null,
    );
  }
}