import 'package:flutter/material.dart';
import 'package:melamine_elsherif/features/domain/product%20details/entities/product_details.dart';
import 'package:melamine_elsherif/features/presentation/product%20details/controller/product_provider.dart';
import 'package:provider/provider.dart';

class ColorVariantsWidget extends StatelessWidget {
  final ProductDetails product;

  const ColorVariantsWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    if (product.colors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Consumer<ProductDetailsProvider>(
      builder: (context, provider, child) {
        final colorList = product.colors.map((color) {
          try {
            return Color(int.parse(color.replaceAll('#', '0xff')));
          } catch (e) {
            return Colors.grey;
          }
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Colors',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(colorList.length, (index) {
                final colorHex = product.colors[index];
                final isSelected = provider.selectedColor == colorHex;

                return GestureDetector(
                  onTap: () => provider.setSelectedColor(colorHex),
                  child: Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: colorList[index],
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.blue, width: 2)
                          : null,
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : null,
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}