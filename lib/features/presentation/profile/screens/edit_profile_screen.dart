import 'dart:io';
import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/constants/app_strings.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../../core/utils/extension/text_style_extension.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../../core/utils/local_storage/local_storage_keys.dart';
import '../../../../core/utils/local_storage/secure_storage.dart';
import '../../../../core/utils/widgets/custom_button.dart';
import '../../auth/controller/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../controller/profile_provider.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fullNameController.text = AppStrings.userName ?? '';
    _emailController.text = AppStrings.userEmail ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final isUpdating = profileProvider.updateState == LoadingState.loading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: context.titleLarge,
        ),
        leading: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: CustomImage(assetPath: AppSvgs.back),
          ),
          onTap: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: isUpdating ? null : () => _updateProfile(context, profileProvider),
            child: Text(
              'Save',
              style: context.titleMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Image
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(width: 0.5,color: Colors.grey),
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : profileProvider.profileImageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(profileProvider.profileImageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                        ),
                        child: profileProvider.profileImageUrl == null && _selectedImage == null
                            ? const Icon(Icons.person, size: 80, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.red[400],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _pickImage,
                  child: Text(
                    'Change Photo',
                    style: context.titleSmall.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Form Fields
                _buildFormField(
                  label: 'Full Name',
                  controller: _fullNameController,
                ),
                const SizedBox(height: 16),
                
                _buildFormField(
                  label: 'Username',
                  readOnly: true,
                  controller: _fullNameController,
                  prefix: '@',
                ),
                const SizedBox(height: 16),
                
                _buildFormField(
                  label: 'Bio',
                  controller: _bioController,
                  maxLines: 4,
                  hintText: 'Write something about yourself',
                ),
                const SizedBox(height: 16),
                
                _buildFormField(
                  label: 'Email',
                  controller: _emailController,
                  readOnly: true,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                
                _buildFormField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 32),
                
                // Delete Account
                CustomButton(
                  onPressed: () {
                    _showLogoutConfirmation(context);
                  },
                  isOutlined: true,
                  child: Text(
                    'Delete Account',
                    style: context.titleMedium.copyWith(color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? hintText,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.titleSmall.copyWith(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            prefixText: prefix,
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
    );
  }


  Future<void> _updateProfile(BuildContext context, ProfileProvider profileProvider) async {
    if (!_formKey.currentState!.validate()) return;

    // Handle image upload if needed
    if (_selectedImage != null) {
      final success = await profileProvider.updateProfileImage(_selectedImage!);
      if (!success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile image')),
        );
        return;
      }
    }

    // Update profile info
    final success = await profileProvider.updateProfile(
      _fullNameController.text,
      '', // Don't update password from this screen
    );

    if (!mounted) return;

    if (success) {
      if (_fullNameController.text != AppStrings.userName) {
        AppStrings.userName = _fullNameController.text;
        await SecureStorage().save(LocalStorageKey.userName, _fullNameController.text);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    final navigatorContext = context;

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
        title: Text('Delete account'),
        content: Text('Are you Sure you need to delete this account ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr(navigatorContext),style: context.titleSmall.copyWith(color: AppTheme.darkDividerColor),),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await navigatorContext.read<AuthProvider>().logout();
              AppStrings.userId = null;
              AppStrings.token = null;

              if (navigatorContext.mounted) {
                Navigator.of(navigatorContext).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                );
              }
            },
            child: Text(
              'delete'.tr(navigatorContext),
              style: context.titleSmall.copyWith(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

}