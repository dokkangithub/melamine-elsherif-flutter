import 'package:flutter/material.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../domain/address/entities/address.dart';

class AddressItemDetails extends StatelessWidget {
  final Address address;

  const AddressItemDetails({Key? key, required this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and default badge
        Row(
          children: [
            Expanded(
              child: Text(
                address.title.isNotEmpty
                    ? address.title
                    : 'address'.tr(context),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (address.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'default'.tr(context),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
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
              child: Text(
                address.address,
                style: const TextStyle(fontSize: 16),
              ),
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
          ],
        ),
        const SizedBox(height: 8),

        // Contact details
        Row(
          children: [
            const Icon(Icons.phone, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(address.phone, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }
}
