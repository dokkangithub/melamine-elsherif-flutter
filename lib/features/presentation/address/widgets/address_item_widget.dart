import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import '../../../../core/config/themes.dart/theme.dart';
import '../../../../core/utils/constants/app_assets.dart';
import '../../../domain/address/entities/address.dart';

class AddressItemWidget extends StatelessWidget {
  final Address address;
  final bool isSelectable;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;
  final VoidCallback? onSelect;
  final int index;

  const AddressItemWidget({
    Key? key,
    required this.address,
    this.isSelectable = false,
    this.showActions = true,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
    this.onSelect,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isSelectable ? onSelect : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and default badge
            Row(
              children: [
                Text(
                  address.title.isNotEmpty
                      ? address.title
                      : 'Address ${index + 1}',
                  style: context.titleMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 10),
                InkWell(
                  onTap: onSetDefault,
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          address.isDefault
                              ? Color(0xFFE6F4FF)
                              : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                       address.isDefault?'Default':'set as Default',
                      style: context.bodySmall!.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight:
                            address.isDefault ? FontWeight.w800 : FontWeight.w300,
                        fontSize: address.isDefault ? 12 : 10,
                      ),
                    ),
                  ),
                ),
                Spacer(),
                InkWell(
                  onTap: onEdit,
                  child: Icon(
                    Icons.edit,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Address details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(address.address, style: context.bodyMedium),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Location details
            Row(
              children: [
                const Icon(Icons.map, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${address.cityName}, ${address.stateName}, ${address.countryName}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
                InkWell(
                  onTap: onDelete,
                  child: CustomImage(assetPath: AppSvgs.delete_icon),
                ),
              ],
            ),
            Divider(color: AppTheme.lightDividerColor),

            // // Contact details
            // Row(
            //   children: [
            //     const Icon(Icons.phone, color: Colors.grey, size: 20),
            //     const SizedBox(width: 8),
            //     Text(address.phone, style: const TextStyle(fontSize: 14)),
            //   ],
            // ),

            // Action buttons

            // Select button for selectable mode
            // if (isSelectable && !showActions) ...[
            //   const SizedBox(height: 16),
            //   const Divider(),
            //   Center(
            //     child: ElevatedButton(
            //       onPressed: onSelect,
            //       style: ElevatedButton.styleFrom(
            //         padding: const EdgeInsets.symmetric(
            //           horizontal: 24,
            //           vertical: 12,
            //         ),
            //       ),
            //       child: const Text('Use This Address'),
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }
}
