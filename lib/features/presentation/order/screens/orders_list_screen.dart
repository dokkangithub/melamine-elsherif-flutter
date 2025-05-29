import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_back_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_loading.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/themes.dart/theme.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../domain/order/entities/order.dart';
import '../controller/order_provider.dart';
import '../widgets/shimmer/orders_list_shimmer.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  // Filter categories
  final List<String> _tabs = [
    'all_orders',
    'processing',
    'shipped',
    'delivered',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _tabController.dispose();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'my_orders'.tr(context),
          style: context.displaySmall.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: const CustomBackButton(),
      ),
      body: Column(
        children: [
          // Tab bar for order categories
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppTheme.primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 3,
              dividerHeight: 0,
              labelColor: Colors.black87,
              labelStyle: context.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
              ),
              unselectedLabelColor: Colors.grey,
              unselectedLabelStyle: context.titleMedium.copyWith(
                fontWeight: FontWeight.w400,
              ),
              tabAlignment: TabAlignment.start,
              tabs: _tabs.map((tab) => Tab(text: tab.tr(context))).toList(),
              onTap: (index) {
                // Handle tab selection for filtering orders
                setState(() {});
              },
            ),
          ),

          // Order list
          Expanded(
            child: Consumer<OrderProvider>(
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
                          child: Text('try_again'.tr(context)),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.orders.isEmpty) {
                  return _buildEmptyOrdersState(context);
                }

                // Filter orders based on the selected tab
                final filteredOrders = _filterOrders(
                  provider.orders,
                  _tabController.index,
                );

                if (filteredOrders.isEmpty) {
                  final tabName = _tabs[_tabController.index].toLowerCase();
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon in a circular light background
                          Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF7F9FC),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                tabName == 'shipped'
                                    ? Icons.local_shipping_outlined
                                    : tabName == 'delivered'
                                    ? Icons.check_circle_outline
                                    : Icons.pending_outlined,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'no_${tabName.toLowerCase()}_orders'.tr(context),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'you_dont_have_any_${tabName.toLowerCase()}_orders_at_the_moment'
                                .tr(context),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchOrders(),
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    itemCount:
                        filteredOrders.length +
                        (provider.isLoadingMore ? 1 : 0),
                    separatorBuilder:
                        (context, index) => const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFEEEEEE),
                        ),
                    itemBuilder: (context, index) {
                      if (index == filteredOrders.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CustomLoadingWidget()),
                        );
                      }

                      final order = filteredOrders[index];
                      return _buildOrderCard(context, order);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper to filter orders based on tab selection
  List<Order> _filterOrders(List<Order> orders, int tabIndex) {
    if (tabIndex == 0) return orders; // All orders

    List<String> statuses = [];
    if (tabIndex == 1) {
      // Processing tab - show orders with "pending" or "قيد الانتظار" status
      statuses = ['pending', 'قيد الانتظار'];
    } else if (tabIndex == 2) {
      // Shipped tab - show orders with "picked_up", "on_the_way", "On The Way" status
      statuses = ['picked_up', 'on_the_way', 'On The Way'];
    } else {
      // Delivered tab - show orders with "delivered" status
      statuses = ['delivered'];
    }

    return orders
        .where(
          (order) =>
              statuses.contains(order.deliveryStatus) ||
              statuses.contains(order.deliveryStatus.toLowerCase()) ||
              statuses.contains(order.deliveryStatusString),
        )
        .toList();
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    final status = getStatusInfo(
      order.deliveryStatus,
      order.deliveryStatusString,
    );

    // Format the date to "May 25, 2025" style
    String formattedDate = order.date;

    // Get payment type icon based on payment_type
    IconData paymentIcon = Icons.credit_card;
    String paymentType = order.paymentType ?? 'Cash Payment';
    String paymentTypeKey = 'credit_card_payment';

    if (paymentType.toLowerCase().contains('cash')) {
      paymentIcon = Icons.money;
      paymentTypeKey = 'cash_payment';
    } else if (paymentType.toLowerCase().contains('wallet')) {
      paymentIcon = Icons.account_balance_wallet;
      paymentTypeKey = 'wallet_payment';
    } else if (paymentType.toLowerCase().contains('visa') ||
        paymentType.toLowerCase().contains('mastercard') ||
        paymentType.toLowerCase().contains('credit')) {
      paymentIcon = Icons.credit_card;
      paymentTypeKey = 'credit_card_payment';
    }

    return InkWell(
      onTap: () {
        AppRoutes.navigateTo(
          context,
          AppRoutes.orderDetailsScreen,
          arguments: {'orderId': order.id},
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order number and price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.code,
                  style: context.titleMedium.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  order.grandTotal,
                  style: context.titleLarge.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Date
            Text(
              formattedDate,
              style: context.bodyLarge.copyWith(color: Colors.grey[600]),
            ),

            const SizedBox(height: 16),

            // Payment method and status with right arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Payment icon and payment type text
                Row(
                  children: [
                    Icon(paymentIcon, size: 20, color: Colors.grey[800]),
                    const SizedBox(width: 8),
                    Text(
                      paymentTypeKey.tr(context),
                      style: context.bodyMedium.copyWith(
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),

                // Status and arrow
                Row(
                  children: [
                    Text(
                      status.label.tr(context),
                      style: context.titleMedium.copyWith(
                        color: status.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: status.color,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper to get status color and label
  StatusInfo getStatusInfo(String status, String statusString) {
    // Handle arabic and english status values
    String statusLower = status.toLowerCase();

    if (statusLower == 'pending' || statusLower.contains('انتظار')) {
      return StatusInfo('processing', AppTheme.primaryColor);
    } else if (statusLower == 'picked_up' ||
        statusLower == 'on_the_way' ||
        status == 'On The Way') {
      return StatusInfo('in_transit', const Color(0xFF2196F3));
    } else if (statusLower == 'delivered') {
      return StatusInfo('delivered', const Color(0xFF4CAF50));
    } else {
      // Use the status string provided by API if available
      return StatusInfo(statusString, const Color(0xFFFF9800));
    }
  }

  Widget _buildEmptyOrdersState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Shopping bag icon in a circular light background
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F9FC),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 40,
                  color: Colors.grey[400],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('no_orders_yet'.tr(context), style: context.titleMedium),
            const SizedBox(height: 12),
            Text(
              'looks_like_you_havent_placed_any_orders_yet_Start_shopping_to_see_your_orders_here'
                  .tr(context),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: CustomButton(
                onPressed: () {
                  // Navigate to home/shop page
                  Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
                },
                child: Text(
                  'start_shopping'.tr(context),
                  textAlign: TextAlign.center,
                  style: context.titleLarge.copyWith(color: AppTheme.white,fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class for status information
class StatusInfo {
  final String label;
  final Color color;

  StatusInfo(this.label, this.color);
}
