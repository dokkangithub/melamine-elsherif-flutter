import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/cutsom_toast.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/themes.dart/theme.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../../core/utils/widgets/custom_back_button.dart';
import '../../../../core/utils/widgets/custom_button.dart';
import '../../../domain/address/entities/address.dart';
import '../controller/address_provider.dart';
import '../widgets/address_form_fields.dart';
import '../widgets/shimmer/address_form_shimmer.dart';
import '../../../domain/address/extensions/location_extensions.dart';

class AddEditAddressScreen extends StatefulWidget {
  final Address? address;

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityNameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  int? _selectedCountryId;
  int? _selectedStateId;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Default country to Egypt (ID: 1)
    _selectedCountryId = 1;

    // If editing an existing address, populate the form
    if (widget.address != null) {
      _addressController.text = widget.address!.address;
      _phoneController.text = widget.address!.phone;
      _cityNameController.text = widget.address!.cityName;
      _titleController.text = widget.address!.title;
      _postalCodeController.text = widget.address!.postalCode;
      _selectedStateId = widget.address!.stateId;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCountryData();
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _cityNameController.dispose();
    _titleController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _loadCountryData() async {
    final addressProvider = context.read<AddressProvider>();
    
    // Always load states for Egypt (ID: 1)
    await addressProvider.fetchStatesByCountry(1);
    
    // If editing and we have a state ID, use it
    if (widget.address != null && _selectedStateId != null) {
      // State is already selected from the widget.address
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        leading: const CustomBackButton(),
        backgroundColor: AppTheme.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: FadeIn(
          duration: const Duration(milliseconds: 400),
          child: Text(
            widget.address == null
              ? 'add_new_address'.tr(context)
              : 'edit_address'.tr(context),
            style: context.displaySmall.copyWith(
              fontFamily: GoogleFonts.cormorantGaramond().fontFamily,
              fontWeight: FontWeight.w600,
            )
          ),
        ),
      ),
      body: Consumer<AddressProvider>(
        builder: (context, addressProvider, child) {
          // Show shimmer while loading countries
          final bool isLoadingInitialData =
              addressProvider.addressState == LoadingState.loading;

          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: isLoadingInitialData
                      ? const AddressFormShimmer()
                      : _buildAddressForm(addressProvider),
                  ),
                ),
                _buildSaveButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddressForm(AddressProvider addressProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Address field
        _buildFormLabel('address'.tr(context)),
        _buildTextField(
          controller: _addressController,
          hintText: 'enter_your_address'.tr(context),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'please_enter_your_address'.tr(context);
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Country dropdown
        _buildFormLabel('country'.tr(context)),
        _buildDropdown(
          value: _selectedCountryId,
          items: [
            const DropdownMenuItem(
              value: 1,
              child: Text('Egypt'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCountryId = value;
              _selectedStateId = null;
            });
            addressProvider.fetchStatesByCountry(value!);
          },
        ),
        const SizedBox(height: 16),

        // State dropdown
        _buildFormLabel('state'.tr(context)),
        _buildDropdown(
          value: _selectedStateId,
          items: addressProvider.states.map((state) {
            return DropdownMenuItem(
              value: state.id,
              child: Text(state.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedStateId = value;
            });
          },
          hint: 'select_state'.tr(context),
          validator: (value) {
            if (value == null) {
              return 'please_select_a_state'.tr(context);
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // City field
        _buildFormLabel('city'.tr(context)),
        _buildTextField(
          controller: _cityNameController,
          hintText: 'enter_city'.tr(context),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'please_enter_your_city'.tr(context);
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Postal code field
        _buildFormLabel('postal_code'.tr(context)),
        _buildTextField(
          controller: _postalCodeController,
          hintText: 'enter_postal_code'.tr(context),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),

        // Phone number field
        _buildFormLabel('phone_number'.tr(context)),
        _buildTextField(
          controller: _phoneController,
          hintText: 'enter_phone_number'.tr(context),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'please_enter_your_phone_number'.tr(context);
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: context.titleMedium.copyWith(
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: context.bodyLarge.copyWith(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required void Function(int?)? onChanged,
    String? hint,
    String? Function(int?)? validator,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: context.bodyLarge.copyWith(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      validator: validator,
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              backgroundColor: Colors.transparent,
              borderColor: Colors.grey.shade300,
              child: Text(
                'cancel'.tr(context),
                style: context.titleLarge.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              onPressed: _isLoading ? null : _saveAddress,
              backgroundColor: AppTheme.primaryColor,
              child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'save'.tr(context),
                    style: context.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final addressProvider = context.read<AddressProvider>();
        final cityName = _cityNameController.text.trim();

        if (widget.address == null) {
          // Add new address
          await addressProvider.addAddress(
            address: _addressController.text,
            countryId: _selectedCountryId ?? 1, // Default to Egypt
            stateId: _selectedStateId!,
            cityName: cityName,
            phone: _phoneController.text,
          );

          if (mounted) {
            CustomToast.showToast(
              message: 'address_saved_successfully'.tr(context),
              type: ToastType.success,
            );
            Navigator.pop(context);
          }
        } else {
          // Update existing address
          await addressProvider.updateAddress(
            id: widget.address!.id,
            address: _addressController.text,
            countryId: _selectedCountryId ?? 1,
            stateId: _selectedStateId!,
            cityName: cityName,
            phone: _phoneController.text,
          );

          if (mounted) {
            CustomToast.showToast(
              message: 'address_updated_successfully'.tr(context),
              type: ToastType.success,
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          CustomToast.showToast(
            message: 'Error: ${e.toString()}',
            type: ToastType.error,
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
