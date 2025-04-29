import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../controller/order_provider.dart';
import '../widgets/order_details_card.dart';
import '../widgets/order_items_list.dart';
import '../widgets/shimmer/order_screen_shimmer.dart';
import '../widgets/shimmer/order_items_list_shimmer.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OrderProvider>();
      provider.fetchOrderDetails(widget.orderId);
      provider.fetchOrderItems(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          final bool isLoadingDetails =
              provider.orderDetailsState == LoadingState.loading;
          final bool isLoadingItems =
              provider.orderItemsState == LoadingState.loading;

          if (isLoadingDetails && isLoadingItems) {
            return const OrderScreenShimmer();
          }

          if (provider.orderDetailsState == LoadingState.error) {
            return Center(child: Text(provider.orderDetailsError));
          }

          if (provider.orderItemsState == LoadingState.error) {
            return Center(child: Text(provider.orderItemsError));
          }

          final orderDetails = provider.selectedOrderDetails;
          if (orderDetails == null) {
            return const Center(child: Text('Order details not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrderDetailsCard(orderDetails: orderDetails),
                const SizedBox(height: 20),
                Text(
                  'Order Items',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                isLoadingItems
                    ? const OrderItemsListShimmer()
                    : OrderItemsList(orderItems: provider.orderItems),
              ],
            ),
          );
        },
      ),
    );
  }
}
