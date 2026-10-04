import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Rounded search bar from the Pokédex header.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(30)),
      borderSide: BorderSide(color: AppColors.grey200, width: 1.5),
    );
    final textStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontSize: 14);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: textStyle,
      decoration: InputDecoration(
        hintText: 'Search Pokémon...',
        hintStyle: textStyle?.copyWith(color: AppColors.grey400),
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          color: AppColors.grey800,
        ),
        // Rebuilds only the clear button as the text changes.
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close, size: 20),
                  color: AppColors.grey600,
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.grey600, width: 1.5),
        ),
      ),
    );
  }
}
