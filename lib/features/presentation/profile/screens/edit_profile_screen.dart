import 'dart:io';
import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_back_button.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/constants/app_strings.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../../core/utils/local_storage/local_storage_keys.dart';
import '../../../../core/utils/local_storage/secure_storage.dart';
import '../../../../core/utils/widgets/custom_appBar.dart';
import '../../../../core/utils/widgets/custom_button.dart';
import '../controller/profile_provider.dart';
import '../widgets/profile_form_widget.dart';
import '../widgets/profile_image_picker_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController.text = AppStrings.userName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'edit_profile'.tr(context),
        toolbarHeight: kToolbarHeight,
        leading: CustomBackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileImagePickerWidget(
              profileProvider: profileProvider,
              selectedImage: _selectedImage,
              onImageSelected: (file) {
                setState(() {
                  _selectedImage = file;
                });
              },
            ),
            const SizedBox(height: 24),
            ProfileFormWidget(
              formKey: _formKey,
              nameController: _nameController,
              passwordController: _passwordController,
              confirmPasswordController: _confirmPasswordController,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                isOutlined: true,
                onPressed: () => _updateProfile(context, profileProvider),
                text: 'update_profile'.tr(context),
                isLoading: profileProvider.updateState == LoadingState.loading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfile(BuildContext context, ProfileProvider profileProvider) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage != null) {
      final success = await profileProvider.updateProfileImage(_selectedImage!);
      if (!success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('failed_update_profile_image'.tr(context))),
        );
        return;
      }
    }

    // Update profile info if name or password is provided
    if (_nameController.text.isNotEmpty || _passwordController.text.isNotEmpty) {
      final success = await profileProvider.updateProfile(
        _nameController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        if (_nameController.text != AppStrings.userName) {
          AppStrings.userName = _nameController.text;
          await SecureStorage().save(LocalStorageKey.userName, _nameController.text);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('profile_updated_successfully'.tr(context))),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('failed_update_profile'.tr(context))),
        );
      }
    }
    else if (_selectedImage != null) {
      // If only image was updated and it was successful
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile_image_updated_successfully'.tr(context))),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}