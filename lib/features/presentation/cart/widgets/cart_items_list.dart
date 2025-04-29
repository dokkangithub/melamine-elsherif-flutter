import 'package:flutter/material.dart';
import '../../../domain/cart/entities/cart.dart';
import 'custom_product_in_cart.dart';

class CartItemsList extends StatelessWidget {
  final List<CartItem> items;
  final Function(int) onDeleteItem;
  final Function(int, int) onQuantityChanged;

  const CartItemsList({
    super.key,
    required this.items,
    required this.onDeleteItem,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ProductItemInCart(
            item: item,
            index: index,
            onDelete: () {
              onDeleteItem(item.id);
            },
            onQuantityChanged: (newQuantity) {
              if (newQuantity >= item.lowerLimit &&
                  newQuantity <= item.upperLimit) {
                onQuantityChanged(item.id, newQuantity);
              }
            },
          );
        },
      ),
    );
  }
}
