import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import '../../../../core/utils/widgets/custom_form_field.dart';
import '../../../../core/utils/widgets/custom_dropdown.dart';

class AddressFormFields extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController cityNameController;
  final TextEditingController fullNameController;

  final int? selectedCountryId;
  final int? selectedStateId;

  final List<Map<String, dynamic>> countries;
  final List<Map<String, dynamic>> states;

  final Function(int?) onCountryChanged;
  final Function(int?) onStateChanged;

  final bool isLoading;

  const AddressFormFields({
    super.key,
    required this.addressController,
    required this.phoneController,
    required this.cityNameController,
    this.selectedCountryId,
    this.selectedStateId,
    required this.countries,
    required this.states,
    required this.onCountryChanged,
    required this.onStateChanged,
    this.isLoading = false,
    required this.fullNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        //full name
        customText('full_name'.tr(context), context),
        CustomTextFormField(
          controller: fullNameController,
          hint: 'enter_your_full_name'.tr(context),
          maxLines: 1,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'enter_your_full_name'.tr(context);
            }
            return null;
          },
        ),
        SizedBox(height: 20),

        // Phone field
        customText('phone_number'.tr(context), context),
        CustomTextFormField(
          controller: phoneController,
          hint: 'enter_your_phone_number'.tr(context),
          isMobileNumber: true,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'please_enter_phone'.tr(context);
            }
            return null;
          },
        ),
        SizedBox(height: 20),

        // Address field
        customText('address'.tr(context), context),
        CustomTextFormField(
          controller: addressController,
          hint: 'please_enter_address'.tr(context),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'please_enter_address'.tr(context);
            }
            return null;
          },
        ),
        SizedBox(height: 20),

        // Country dropdown
        customText('country'.tr(context), context),
        DropdownButtonFormField<int>(
          value: selectedCountryId,
          hint: Text('select_your_country'.tr(context)),
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.darkDividerColor, width: 1.0),
              borderRadius: BorderRadius.circular(4),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.darkDividerColor, width: 1.0),
              borderRadius: BorderRadius.circular(4),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.0),
              borderRadius: BorderRadius.circular(4),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.errorColor, width: 1.0),
              borderRadius: BorderRadius.circular(4),
            ),
            filled: false,
          ),
          validator: (value) {
            if (value == null) {
              return 'please_select_country'.tr(context);
            }
            return null;
          },
          items: countries.map((country) {
            return DropdownMenuItem<int>(
              value: country['id'] as int,
              child: Text(country['name'] as String),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onCountryChanged(value);
            }
          },
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.black54),
        ),
        SizedBox(height: 20),

        // State dropdown
        customText('state'.tr(context), context),
        DropdownButtonFormField<int>(
          value: selectedStateId,
          hint: Text('select_state'.tr(context)),
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.darkDividerColor, width: 1.0),
              borderRadius: BorderRadius.circular(4),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.darkDividerColor, width: 1.0),
              borderRadius: BorderRadius.circular(4),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.0),
              borderRadius: BorderRadius.circular(4),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.errorColor, width: 1.0),
              borderRadius: BorderRadius.circular(4),
            ),
            filled: false,
          ),
          validator: (value) {
            if (value == null) {
              return 'please_select_state'.tr(context);
            }
            return null;
          },
          items: states.map((state) {
            return DropdownMenuItem<int>(
              value: state['id'] as int,
              child: Text(state['name'] as String),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onStateChanged(value);
            }
          },
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.black54),
        ),
        SizedBox(height: 20),

        // City text field (replacing dropdown)
        customText('city'.tr(context), context),
        CustomTextFormField(
          controller: cityNameController,
          hint: 'select_city'.tr(context),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'please_select_city'.tr(context);
            }
            return null;
          },
        ),


      ],
    );
  }
  Text customText(String title,BuildContext context){
    return Text(
      title,
      style: context.titleSmall!.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
