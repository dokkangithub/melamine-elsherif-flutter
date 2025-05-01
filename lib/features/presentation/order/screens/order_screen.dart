import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../controller/order_provider.dart';
import '../widgets/shimmer/order_screen_shimmer.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        leading: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: CustomImage(assetPath: AppSvgs.back),
          ),
          onTap: () => Navigator.pop(context),
        ),
        title: Text(
          'Order Details',
          style: context.headlineSmall,
        ),
      ),
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
            return Center(child: Text('order_details_not_found'.tr(context)));
          }

          DateTime? orderDate;
          try {
            final parts = orderDetails.date.split('/');
            if (parts.length >= 3) {
              // Format is likely "dd/mm/yyyy"
              orderDate = DateTime(
                int.parse(parts[2]), // year
                int.parse(parts[1]), // month
                int.parse(parts[0]), // day
              );
            }
          } catch (e) {
            // If parsing fails, use the current date as a fallback
            orderDate = DateTime.now();
          }
          
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Number and Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order Number',
                                style: context.titleSmall!.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text('#ORD-2023-12-001'.tr(context),
                                style: context.titleMedium!.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          
                          Text(
                            'In Transit',
                            style: context.titleSmall!.copyWith(fontWeight: FontWeight.w600,color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                      
                      // Order Progress Bar
                      const SizedBox(height: 10),
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(color: Colors.transparent),
                            ),
                          ],
                        ),
                      ),
                      
                      // Order Timeline Steps
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSimpleOrderStep('Ordered', true),
                          _buildSimpleOrderStep('Shipped', false),
                          _buildSimpleOrderStep('Delivered', false),
                        ],
                      ),

                      
                      const SizedBox(height: 20),
                      
                      // Delivery Address
                       Text(
                        'Delivery Address',
                        style: context.titleMedium!.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      _buildAddressCard(orderDetails.shippingAddress),
                      
                      const SizedBox(height: 20),
                      
                      // Order Items
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order Items (${provider.orderItems.length})'.tr(context),
                            style: context.titleMedium!.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Order Items List
                      isLoadingItems 
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.orderItems.length,
                              itemBuilder: (context, index) {
                                final item = provider.orderItems[index];
                                return _buildOrderItemCard(item);
                              },
                            ),
                              
                      const SizedBox(height: 20),
                      
                      // Price Details
                       Text(
                        'Price Details',
                        style: context.titleMedium!.copyWith(fontWeight: FontWeight.w800,color: AppTheme.black),
                      ),
                      const SizedBox(height: 10),
                      _buildPriceDetailsCard(orderDetails),
                      
                      const SizedBox(height: 32),
                      
                      // Payment Information
                       Text(
                        'Payment Information',
                        style: context.titleMedium!.copyWith(fontWeight: FontWeight.w800,color: AppTheme.black),
                      ),
                      const SizedBox(height: 16),
                      _buildPaymentInfoCard(orderDetails),
                      
                      const SizedBox(height: 32),
                      
                      // Order Timeline
                      const Text(
                        'Order Timeline',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildOrderTimelineCard(orderDetails),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              
              // Support and Cancel Buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Contact support logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBD5B4D),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Contact Support',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          // Cancel order logic
                        },
                        child: const Text(
                          'Cancel Order',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    // Bottom indicator
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 120,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  // Status Badge
  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    
    switch (status.toLowerCase()) {
      case 'pending':
      case 'confirmed':
        color = const Color(0xFFBD5B4D);
        label = 'In Transit';
        break;
      case 'picked_up':
        color = Colors.blue;
        label = 'Shipped';
        break;
      case 'delivered':
        color = Colors.green;
        label = 'Delivered';
        break;
      default:
        color = Colors.orange;
        label = 'Processing';
    }
    
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
  
  // Order Progress Bar
  Widget _buildOrderProgressBar(String status) {
    int progress = 0;
    
    if (status == 'pending' || status == 'confirmed') {
      progress = 1;
    } else if (status == 'picked_up') {
      progress = 2;
    } else if (status == 'delivered') {
      progress = 3;
    }
    
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          Expanded(
            flex: progress >= 1 ? 1 : 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFBD5B4D),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            flex: progress < 1 ? 1 : 0,
            child: Container(color: Colors.transparent),
          ),
          Expanded(
            flex: progress >= 2 ? 1 : 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFBD5B4D),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            flex: progress < 2 ? 1 : 0,
            child: Container(color: Colors.transparent),
          ),
          Expanded(
            flex: progress >= 3 ? 1 : 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFBD5B4D),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            flex: progress < 3 ? 1 : 0,
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }
  
  // Order Step
  Widget _buildOrderStep(String label, bool isActive, DateTime date) {
    final formattedDate = '${date.day}/${date.month}/${date.year}';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
        if (isActive)
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }
  
  // Address Card
  Widget _buildAddressCard(dynamic address) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.location_on_outlined,
            color: Colors.grey[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.name,
                  style: context.titleSmall
                ),
                const SizedBox(height: 8),
                Text('${address.address}, ${address.city}, ${address.state}, ${address.country} ${address.postalCode}'.tr(context),
                  style: context.titleSmall!.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      address.phone,
                      style: context.titleSmall!.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Order Item Card
  Widget _buildOrderItemCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: context.titleSmall!.copyWith(fontWeight: FontWeight.w600,color: AppTheme.black),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (item.variation.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('Variation: ${item.variation}'.tr(context),
                      style: context.titleSmall!.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                Text('Quantity: ${item.quantity}'.tr(context),
                  style: context.titleSmall!.copyWith(fontWeight: FontWeight.w600,color: AppTheme.black),
                ),
                const SizedBox(height: 8),
                Text(
                  item.price,
                  style: context.titleSmall!.copyWith(fontWeight: FontWeight.w600,color: AppTheme.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Price Details Card
  Widget _buildPriceDetailsCard(dynamic orderDetails) {
    final items = [
      {'label': 'Subtotal', 'value': orderDetails.subtotal},
      {'label': 'Shipping Fee', 'value': orderDetails.shippingCost},
      {'label': 'Tax', 'value': orderDetails.tax},
    ];
    
    if (orderDetails.couponDiscount.isNotEmpty && orderDetails.couponDiscount != '0' && orderDetails.couponDiscount != '0.00') {
      items.add({'label': 'Coupon Discount', 'value': orderDetails.couponDiscount});
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          ...items.map((item) => _buildPriceRow(item['label']!, item['value']!)),
          const Divider(height: 24),
          _buildPriceRow('Total', orderDetails.grandTotal, isTotal: true),
        ],
      ),
    );
  }
  
  // Price row
  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.black : Colors.grey[700],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? const Color(0xFFBD5B4D) : Colors.black,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
  
  // Payment Information Card
  Widget _buildPaymentInfoCard(dynamic orderDetails) {
    final paymentStatus = orderDetails.paymentStatus.toLowerCase() == 'paid' ? 'Paid' : 'Pending';
    final statusColor = paymentStatus == 'Paid' ? Colors.green[700] : Colors.orange[700];
    final bgColor = paymentStatus == 'Paid' ? Colors.green[50] : Colors.orange[50];
    
    return Container(
            padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            orderDetails.paymentType.toLowerCase().contains('cash') 
                ? Icons.money 
                : Icons.credit_card,
            color: Colors.grey[600],
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderDetails.paymentType,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Date: ${orderDetails.date}'.tr(context),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              paymentStatus,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Order Timeline Card
  Widget _buildOrderTimelineCard(dynamic orderDetails) {
    // Parse the order date
    DateTime orderDate;
    try {
      final parts = orderDetails.date.split('/');
      if (parts.length >= 3) {
        orderDate = DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
      } else {
        orderDate = DateTime.now();
      }
    } catch (e) {
      orderDate = DateTime.now();
    }
    
    // Format dates for display
    String formatDate(DateTime date) {
      return '${date.day}/${date.month}/${date.year}';
    }
    
    final deliveryStatus = orderDetails.deliveryStatus.toLowerCase();
    final confirmedDate = formatDate(orderDate);
    final shippedDate = deliveryStatus == 'picked_up' || deliveryStatus == 'delivered'
        ? formatDate(orderDate.add(const Duration(days: 1)))
        : 'Pending';
    final deliveredDate = deliveryStatus == 'delivered'
        ? formatDate(orderDate.add(const Duration(days: 3)))
        : 'Expected in 3-5 days';
    
    final timelineItems = [
      {
        'icon': Icons.check_circle,
        'color': Colors.green,
        'title': 'Order Delivered',
        'date': deliveredDate,
        'active': deliveryStatus == 'delivered',
      },
      {
        'icon': Icons.local_shipping,
        'color': Colors.blue,
        'title': 'Order Shipped',
        'date': shippedDate,
        'active': deliveryStatus == 'picked_up' || deliveryStatus == 'delivered',
      },
      {
        'icon': Icons.check,
        'color': const Color(0xFFBD5B4D),
        'title': 'Order Confirmed',
        'date': confirmedDate,
        'active': true,
      },
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: timelineItems.map((item) => _buildTimelineItem(
          icon: item['icon'] as IconData,
          color: item['color'] as Color,
          title: item['title'] as String,
          date: item['date'] as String,
          isActive: item['active'] as bool,
          isLast: item == timelineItems.last,
        )).toList(),
      ),
    );
  }
  
  // Timeline Item
  Widget _buildTimelineItem({
    required IconData icon,
    required Color color,
    required String title,
    required String date,
    required bool isActive,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive ? color : Colors.grey[400],
                size: 20,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: isActive ? color.withOpacity(0.5) : Colors.grey[300],
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.black : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Simple Order Step
  Widget _buildSimpleOrderStep(String label, bool isActive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }
}
