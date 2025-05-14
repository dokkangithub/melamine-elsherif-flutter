import 'package:flutter/material.dart';

class WalletBalanceCard extends StatelessWidget {
  final String balance;
  final String lastRecharged;

  const WalletBalanceCard({
    Key? key,
    required this.balance,
    required this.lastRecharged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wallet Balance',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              balance,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Colors.white70,
                  size: 16.0,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Last recharged: $lastRecharged',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 