import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import '../../../domain/address/entities/address.dart';

class AddressCard extends StatelessWidget {
  final Address address;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final String? userName;

  const AddressCard({
    super.key,
    required this.address,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width - 32, // Full width minus padding
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 1 : 0.5,
          ),
          // No border radius for flat design
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    userName ?? '',
                    style: context.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  InkWell(
                    onTap: onEdit,
                    child: Text(
                      'change_address'.tr(context),
                      style: context.titleMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (address.phone.isNotEmpty)
                Text(
                  address.phone,
                  style: context.titleMedium?.copyWith(color: AppTheme.darkDividerColor),
                ),
              const SizedBox(height: 2),
              Text(
                address.address,
                style: context.titleMedium?.copyWith(color: AppTheme.darkDividerColor),
              ),
              const SizedBox(height: 2),
              Text('${address.cityName}, ${address.stateName} ${address.postalCode}',
                style: context.titleMedium?.copyWith(color: AppTheme.darkDividerColor),
              ),
              const SizedBox(height: 2),
              Text(
                address.countryName.isNotEmpty ? address.countryName : 'United States',
                style: context.titleMedium?.copyWith(color: AppTheme.darkDividerColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 