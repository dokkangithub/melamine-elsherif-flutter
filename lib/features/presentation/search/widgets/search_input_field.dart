import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_form_field.dart';

class SearchInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Function(String) onSubmitted;

  const SearchInputField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CustomTextFormField(
        controller: controller,
        textInputAction: TextInputAction.search,
        hint: 'search_skin_care_products'.tr(context),
        onChanged: onChanged,
        suffixIcon: InkWell(
            onTap: (){
              controller.clear();
            },
            child: Icon(Icons.close,color: AppTheme.accentColor)),

        onFieldSubmitted: onSubmitted,
      ),
    );
  }
}