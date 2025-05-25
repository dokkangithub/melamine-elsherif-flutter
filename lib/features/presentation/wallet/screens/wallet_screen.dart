import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import '../../../../core/config/themes.dart/theme.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../club_point/controller/club_point_provider.dart';
import '../controller/wallet_provider.dart';
import '../widgets/transaction_item.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/shimmer/wallet_balance_shimmer.dart';
import '../widgets/shimmer/club_points_shimmer.dart';
import '../widgets/shimmer/transaction_item_shimmer.dart';
import '../widgets/shimmer/wallet_screen_shimmer.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    // Initial data loading
    Future.microtask(() {
      context.read<WalletProvider>().fetchWalletBalance();
      context.read<WalletProvider>().fetchWalletHistory();
      context.read<ClubPointProvider>().fetchClubPoints();
    });

    // Setup pagination scroll listener
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll * 0.9) {
      _isLoadingMore = true;
      context.read<WalletProvider>().fetchWalletHistory().then((_) {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final isInitialLoading = (walletProvider.balanceState == LoadingState.loading ||
        walletProvider.historyState == LoadingState.loading) &&
        walletProvider.transactions.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title:  Text('my_wallet'.tr(context),style: context.headlineMedium!.copyWith(color: AppTheme.white),),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<WalletProvider>().refreshWallet();
          await context.read<ClubPointProvider>().fetchClubPoints(refresh: true);
        },
        child: isInitialLoading
            ? const WalletScreenShimmer()
            : CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: _buildWalletBalance(),
            ),
            SliverToBoxAdapter(
              child: _buildClubPointsSection(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'transaction_history'.tr(context),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            _buildTransactionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletBalance() {
    return Consumer<WalletProvider>(
      builder: (context, provider, child) {
        switch (provider.balanceState) {
          case LoadingState.loading:
            return const WalletBalanceShimmer();
          case LoadingState.loaded:
            return provider.walletBalance != null
                ? WalletBalanceCard(
              balance: provider.walletBalance!.balance,
              lastRecharged: provider.walletBalance!.lastRecharged,
            )
                : Center(child: Text('no_wallet_data_available'.tr(context)));
          case LoadingState.error:
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: ${provider.errorMessage}'),
              ),
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildClubPointsSection() {
    return Consumer<ClubPointProvider>(
      builder: (context, provider, child) {
        switch (provider.clubPointsState) {
          case LoadingState.loading:
            return const ClubPointsShimmer();
          case LoadingState.loaded:
            return Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'your_club_points'.tr(context),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      provider.totalPoints,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.clubPoints.isEmpty
                        ? null
                        : () => _convertPointsToWallet(context, provider),
                    child: provider.convertState == LoadingState.loading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text('convert_to_wallet'.tr(context),style: context.titleMedium!.copyWith(color: AppTheme.white),
                    ),
                  ),),
                  ],
                ),
              ),
            );
          case LoadingState.error:
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: ${provider.errorMessage}'),
              ),
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildTransactionsList() {
    return Consumer<WalletProvider>(
      builder: (context, provider, child) {
        if (provider.historyState == LoadingState.loading && provider.transactions.isEmpty) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => const TransactionItemShimmer(),
              childCount: 5,
            ),
          );
        }

        if (provider.historyState == LoadingState.error && provider.transactions.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Text('Error: ${provider.errorMessage}'),
            ),
          );
        }

        if (provider.transactions.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Text('no_transactions_available'.tr(context)),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              if (index < provider.transactions.length) {
                return TransactionItem(
                  transaction: provider.transactions[index],
                );
              } else if (provider.hasMoreTransactions) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: provider.historyState == LoadingState.loading
                        ? const TransactionItemShimmer()
                        : Text('no_more_transactions'.tr(context)),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
            childCount: provider.transactions.length + (provider.hasMoreTransactions ? 1 : 0),
          ),
        );
      },
    );
  }

  void _convertPointsToWallet(BuildContext context, ClubPointProvider provider) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'convert_points'.tr(context),
      text: 'are_you_sure_you_want_to_convert_all_your_club_points_to_wallet_balance'.tr(context),
      confirmBtnText: 'convert'.tr(context),
      cancelBtnText: 'cancel'.tr(context),
      onConfirmBtnTap: () async {
        Navigator.pop(context);
        await provider.convertPointsToWallet();
        if (!context.mounted) return;
        if (provider.convertState == LoadingState.loaded) {
          // Refresh wallet data after conversion
          context.read<WalletProvider>().refreshWallet();
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'success'.tr(context),
            text: 'points_successfully_converted_to_wallet!'.tr(context),
          );
        }
      },
    );
  }
}