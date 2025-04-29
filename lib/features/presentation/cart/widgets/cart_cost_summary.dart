import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';

import '../../../domain/cart/entities/cart.dart';


class CartCostSummary extends StatelessWidget {
  final CartSummary summary;

  const CartCostSummary({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        // Remove or tweak shadow as needed
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _buildRow(context, 'subtotal'.tr(context),
                  '${summary.currencySymbol}${summary.subtotal.toStringAsFixed(2)}'),
              _buildRow(
                context,
                'shipping'.tr(context),
                summary.shippingCost > 0
                    ? '${summary.currencySymbol}${summary.shippingCost.toStringAsFixed(2)}'
                    : 'Free',
              ),

                _buildRow(context, 'tax'.tr(context),
                    '${summary.currencySymbol}${summary.tax.toStringAsFixed(2)}'),
                Divider(),
                _buildRow(context, 'total_cost'.tr(context),
                    '${summary.currencySymbol}${summary.total.toStringAsFixed(2)}'),
            ]
          ),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.titleMedium,
        ),
        Text(
          value,
          style: context.titleMedium,
        )
      ],
    );
  }
}

