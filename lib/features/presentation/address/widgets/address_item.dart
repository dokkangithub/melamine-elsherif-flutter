import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import '../../../../core/config/themes.dart/theme.dart';
import '../../../domain/address/entities/address.dart';

class AddressItem extends StatelessWidget {
  final Address address;
  final bool isDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;
  final VoidCallback? onSelect;

  const AddressItem({
    Key? key,
    required this.address,
    required this.isDefault,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
    this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address title and actions
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    address.title.isNotEmpty ? address.title : 'home'.tr(context),
                    style: context.headlineMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Default switch - showing default state with the right configuration
                      GestureDetector(
                        onTap: !isDefault ? onSetDefault : null,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: !isDefault ? onSetDefault : null,
                              child: Container(
                                width: 60,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: isDefault ? const Color(0xFF003333) : Colors.grey.shade300,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: AnimatedAlign(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  alignment: isDefault ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    margin: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'default'.tr(context),
                              style: context.titleMedium.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Edit button
                      GestureDetector(
                        onTap: onEdit,
                        child: const CustomImage(
                          assetPath: AppSvgs.color_edit_profile,
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Delete button
                      GestureDetector(
                        onTap: onDelete,
                        child: const CustomImage(
                          assetPath: AppSvgs.delete_icon,
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Address details
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.address,
                    style: context.bodyLarge.copyWith(
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  if (address.cityName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${address.cityName}, ${address.stateName}',
                      style: context.bodyLarge.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    address.countryName,
                    style: context.bodyLarge.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+${address.phone}',
                    style: context.bodyLarge.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 