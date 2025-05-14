import 'package:flutter/material.dart';
import '../../../domain/wallet/entities/wallet_transaction.dart';

class TransactionItem extends StatelessWidget {
  final WalletTransaction transaction;

  const TransactionItem({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction Icon
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                _getTransactionIcon(),
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16.0),
            
            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.paymentMethod,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14.0,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        transaction.date,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                  if (transaction.approvalString != 'N/A') ...[
                    const SizedBox(height: 4.0),
                    Text(
                      'Approval: ${transaction.approvalString}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            
            // Amount
            Text(
              transaction.amount,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _isPositiveAmount() ? Colors.green : Colors.black,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTransactionIcon() {
    if (transaction.paymentMethod.toLowerCase().contains('club point')) {
      return Icons.card_giftcard;
    } else if (transaction.paymentMethod.toLowerCase().contains('refund')) {
      return Icons.replay;
    } else if (transaction.paymentMethod.toLowerCase().contains('order')) {
      return Icons.shopping_bag;
    } else {
      return Icons.account_balance_wallet;
    }
  }

  bool _isPositiveAmount() {
    return !transaction.amount.contains('-');
  }
} 