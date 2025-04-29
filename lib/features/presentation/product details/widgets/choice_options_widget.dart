import 'package:flutter/material.dart';
import 'package:melamine_elsherif/features/domain/product%20details/entities/product_details.dart';
import 'package:melamine_elsherif/features/presentation/product%20details/controller/product_provider.dart';
import 'package:provider/provider.dart';

class ChoiceOptionsWidget extends StatelessWidget {
  final ProductDetails product;

  const ChoiceOptionsWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductDetailsProvider>(
      builder: (context, provider, child) {
        if (product.choiceOptions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: product.choiceOptions.map((option) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: option.options.map((optionValue) {
                      final isSelected = provider.selectedVariants[option.name] == optionValue;

                      return GestureDetector(
                        onTap: () {
                          provider.setVariantOption(option.name, optionValue);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            optionValue,
                            style: TextStyle(
                              color: isSelected ? Colors.blue : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}