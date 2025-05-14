import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'wallet_balance_shimmer.dart';
import 'club_points_shimmer.dart';
import 'transaction_item_shimmer.dart';

class WalletScreenShimmer extends StatelessWidget {
  const WalletScreenShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet Balance Shimmer
              const WalletBalanceShimmer(),
              
              // Club Points Shimmer
              const ClubPointsShimmer(),
              
              // Transaction History Title
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 180,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Transaction List Shimmer
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const TransactionItemShimmer(),
            childCount: 5, // Show 5 transaction items
          ),
        ),
      ],
    );
  }
} 