import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import '../../../../core/utils/widgets/custom_form_field.dart';
import '../../../../core/utils/widgets/custom_dropdown.dart';

class AddressFormFields extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController phoneController;

  final int? selectedCountryId;
  final int? selectedStateId;
  final int? selectedCityId;

  final List<Map<String, dynamic>> countries;
  final List<Map<String, dynamic>> states;
  final List<Map<String, dynamic>> cities;

  final Function(int?) onCountryChanged;
  final Function(int?) onStateChanged;
  final Function(int?) onCityChanged;

  final bool isLoading;

  const AddressFormFields({
    super.key,
    required this.addressController,
    required this.phoneController,
    this.selectedCountryId,
    this.selectedStateId,
    this.selectedCityId,
    required this.countries,
    required this.states,
    required this.cities,
    required this.onCountryChanged,
    required this.onStateChanged,
    required this.onCityChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Country dropdown
        CustomDropdown<int>(
          label: 'country'.tr(context),
          hint: 'select_country'.tr(context),
          value: selectedCountryId,
          prefixIcon: const Icon(Icons.public),
          items:
              countries.map((country) {
                return DropdownMenuItem<int>(
                  value: country['id'] as int,
                  child: Text(country['name'] as String),
                );
              }).toList(),
          onChanged: onCountryChanged,
          isLoading: isLoading,
          validator: (value) {
            if (value == null) {
              return 'please_select_country'.tr(context);
            }
            return null;
          },
        ),

        // State dropdown
        CustomDropdown<int>(
          label: 'state_province'.tr(context),
          hint: 'select_state'.tr(context),
          value: selectedStateId,
          prefixIcon: const Icon(Icons.map),
          items:
              states.map((state) {
                return DropdownMenuItem<int>(
                  value: state['id'] as int,
                  child: Text(state['name'] as String),
                );
              }).toList(),
          onChanged: onStateChanged,
          isLoading: isLoading,
          validator: (value) {
            if (value == null) {
              return 'please_select_state'.tr(context);
            }
            return null;
          },
        ),

        // City dropdown
        CustomDropdown<int>(
          label: 'city'.tr(context),
          hint: 'select_city'.tr(context),
          value: selectedCityId,
          prefixIcon: const Icon(Icons.location_city),
          items:
              cities.map((city) {
                return DropdownMenuItem<int>(
                  value: city['id'] as int,
                  child: Text(city['name'] as String),
                );
              }).toList(),
          onChanged: onCityChanged,
          isLoading: isLoading,
          validator: (value) {
            if (value == null) {
              return 'please_select_city'.tr(context);
            }
            return null;
          },
        ),

        // Address field
        CustomTextFormField(
          controller: addressController,
          label: 'address'.tr(context),
          hint: 'address_hint'.tr(context),
          prefixIcon: const Icon(Icons.home),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'please_enter_address'.tr(context);
            }
            return null;
          },
        ),

        // Phone field
        CustomTextFormField(
          controller: phoneController,
          label: 'phone'.tr(context),
          hint: 'phone_hint'.tr(context),
          isMobileNumber: true,
          prefixIcon: const Icon(Icons.phone),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'please_enter_phone'.tr(context);
            }
            return null;
          },
        ),
      ],
    );
  }
}
