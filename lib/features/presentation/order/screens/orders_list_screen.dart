import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../controller/order_provider.dart';
import '../widgets/order_card.dart';
import '../widgets/shimmer/orders_list_shimmer.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<OrderProvider>();
      if (provider.hasNextPage && !provider.isLoadingMore) {
        provider.loadMoreOrders();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.ordersState == LoadingState.loading &&
              provider.orders.isEmpty) {
            return const OrdersListShimmer();
          }

          if (provider.ordersState == LoadingState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.ordersError),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchOrders(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (provider.orders.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () => provider.fetchOrders(),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        provider.orders.length +
                        (provider.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.orders.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final order = provider.orders[index];
                      return OrderCard(
                        order: order,
                        onTap: () {
                          AppRoutes.navigateTo(
                            context,
                            AppRoutes.orderDetailsScreen,
                            arguments: {'orderId': order.id},
                          );
                        },
                      );
                    },
                  ),
                ),
                if (provider.isLoadingMore)
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
