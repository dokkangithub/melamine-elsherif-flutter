import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/features/domain/product%20details/entities/product_details.dart';
import 'package:melamine_elsherif/features/presentation/product details/widgets/product_theme.dart';

class DescriptionWidget extends StatelessWidget {
  final ProductDetails product;

  const DescriptionWidget({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('description'.tr(context), style: ProductTheme.titleMedium(context)),
        const SizedBox(height: 8),
        product.description.isNotEmpty
            ? Html(
          data: product.description,
          style: {
            '*': Style(
              fontSize: FontSize(14.0),
              lineHeight: LineHeight(1.6),
              color: Colors.black54,
            ),
          },
        )
            :  Text('no_description_available'.tr(context),
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }
}