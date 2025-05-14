import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/constants/app_assets.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../../core/utils/widgets/custom_cached_image.dart';
import '../../../domain/order/entities/order.dart';
import '../controller/order_provider.dart';
import '../widgets/shimmer/orders_list_shimmer.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  
  // Filter categories
  final List<String> _tabs = ['All Orders', 'Processing', 'Shipped', 'Delivered'];
  
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
          'orders'.tr(context),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: InkWell(
          child: const Padding(
            padding: EdgeInsets.all(20.0),
            child: CustomImage(assetPath: AppSvgs.back),
          ),
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          // Tab bar for order categories
          Container(
            height: 48,
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFEEEEEE),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black87,
              indicator: BoxDecoration(
                color: const Color(0xFFBD5B4D),
                borderRadius: BorderRadius.circular(24),
              ),
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.label,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              tabs: _tabs.map((tab) => _buildTab(tab.tr(context))).toList(),
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
                final filteredOrders = _filterOrders(provider.orders, _tabController.index);
                
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
                                tabName == 'shipped' ? Icons.local_shipping_outlined : 
                                tabName == 'delivered' ? Icons.check_circle_outline : 
                                Icons.pending_outlined,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text('no_${tabName.toLowerCase()}_orders'.tr(context),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'you_dont_have_any_${tabName.toLowerCase()}_orders_at_the_moment'.tr(context),
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

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: RefreshIndicator(
                    onRefresh: () => provider.fetchOrders(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.zero,
                      itemCount: filteredOrders.length +
                          (provider.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == filteredOrders.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final order = filteredOrders[index];
                        return _buildOrderCard(context, order);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Bottom indicator
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            width: 120,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper to build a tab
  Widget _buildTab(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  // Helper to filter orders based on tab selection
  List<Order> _filterOrders(List<Order> orders, int tabIndex) {
    if (tabIndex == 0) return orders; // All orders
    
    String status;
    if (tabIndex == 1) {
      status = 'pending'; // Processing
    } else if (tabIndex == 2) {
      status = 'picked_up'; // Shipped
    } else {
      status = 'delivered'; // Delivered
    }
    
    return orders.where((order) => order.deliveryStatus.toLowerCase() == status).toList();
  }
  
  Widget _buildOrderCard(BuildContext context, Order order) {
    final status = getStatusInfo(order.deliveryStatus, order.deliveryStatusString);

    // Use the actual order code instead of generating a random one
    String formattedOrderNumber = order.code;
    
    return GestureDetector(
      onTap: () {
        AppRoutes.navigateTo(
          context,
          AppRoutes.orderDetailsScreen,
          arguments: {'orderId': order.id},
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order number and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      formattedOrderNumber,
                      style: context.titleSmall!.copyWith(color: AppTheme.black, fontWeight: FontWeight.w800),
                    ),
                  ),
                  CustomButton(
                    onPressed: (){},
                    padding: const EdgeInsets.all(6),
                    backgroundColor: status.color,
                    child: Text(status.label.tr(context),
                      style: context.titleSmall!.copyWith(color: AppTheme.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Date and price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.date,
                    style: context.bodyMedium!.copyWith(color: AppTheme.darkDividerColor),
                  ),
                  Text(
                    '${order.grandTotal} L.E',
                    style: context.titleSmall!.copyWith(fontWeight: FontWeight.w800, color: AppTheme.black),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // View details
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // View details with arrow
                  Row(
                    children: [
                      Text('view_details'.tr(context),
                        style: context.titleSmall!.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper to get status color and label
  StatusInfo getStatusInfo(String status, String statusString) {
    switch (status.toLowerCase()) {
      case 'pending':
        return StatusInfo('processing', const Color(0xFFBD5B4D));
      case 'picked_up':
      case 'on_the_way':
        return StatusInfo('shipped', Colors.blue);
      case 'delivered':
        return StatusInfo('delivered', Colors.green);
      default:
        return StatusInfo(statusString.toLowerCase(), Colors.orange);
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
             Text('no_orders_yet'.tr(context),
              style: context.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'looks_like_you_havent_placed_any_orders_yet_Start_shopping_to_see_your_orders_here'.tr(context),
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
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to home/shop page
                  Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text('start_shopping'.tr(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
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
