import 'package:flutter/material.dart';

import 'localization/app_localization.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forbidden_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/change_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/product/product_list_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/wishlist/wishlist_screen.dart';
import 'screens/order/checkout_screen.dart';
import 'screens/order/order_history_screen.dart';
import 'screens/order/order_detail_screen.dart';
import 'screens/order/payment_result_screen.dart';
import 'screens/order/sepay_payment_screen.dart';
import 'screens/order/user_shipment_tracking_screen.dart';
import 'screens/refund/refund_request_screen.dart';
import 'screens/refund/refund_status_screen.dart';
import 'screens/ai/ai_assistant_screen.dart';
import 'screens/category/category_list_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/help_support_screen.dart';
import 'screens/profile/payment_methods_screen.dart';
import 'screens/profile/address_list_screen.dart';
import 'screens/profile/address_form_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/admin/admin_product_list_screen.dart';
import 'screens/admin/admin_product_form_screen.dart';
import 'screens/admin/admin_product_image_list_screen.dart';
import 'screens/admin/admin_category_list_screen.dart';
import 'screens/review/create_review_screen.dart';
import 'screens/admin/admin_shipment_list_screen.dart';
import 'screens/admin/admin_shipment_detail_screen.dart';
import 'screens/admin/admin_shipment_form_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_order_list_screen.dart';
import 'screens/admin/admin_refund_requests_screen.dart';
import 'screens/admin/admin_returns_refunds_screen.dart';
import 'screens/admin/admin_user_list_screen.dart';
import 'screens/admin/admin_marketing_notification_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'theme/app_theme.dart';
import 'config/app_config.dart';
import 'models/product_model.dart';
import 'models/order_model.dart';
import 'services/auth_storage.dart';
import 'services/inventory_realtime_service.dart';
import 'services/notification_realtime_service.dart';
import 'widgets/admin_route_guard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.currentUserId = await AuthStorage().getUserId() ?? 0;
  await AppLocaleController.instance.load();
  await InventoryRealtimeService.instance.initialize();
  await NotificationRealtimeService.instance.initialize();
  runApp(const AdidasShoesStoreApp());
}

class AdidasShoesStoreApp extends StatelessWidget {
  const AdidasShoesStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLanguageScope(
      child: MaterialApp(
        title: 'Adidas Shoes Store',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: '/home',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forbidden': (context) => const ForbiddenScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/reset-password': (context) => const ResetPasswordScreen(),
          '/change-password': (context) => const ChangePasswordScreen(),
          '/home': (context) => const HomeScreen(),
          '/categories': (context) => CategoryListScreen(),
          '/products': (context) => const ProductListScreen(),
          '/cart': (context) => const CartScreen(),
          '/wishlist': (context) => const WishlistScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/orders': (context) => const OrderHistoryScreen(),
          '/order-detail': (context) => const OrderDetailScreen(),
          '/shipment-tracking': (context) => const UserShipmentTrackingScreen(),
          '/payment-result': (context) {
            final argument = ModalRoute.of(context)?.settings.arguments;
            final queryOrderId = int.tryParse(
              Uri.base.queryParameters['orderId'] ?? '',
            );
            final queryStatus = Uri.base.queryParameters['status'];

            int orderId = queryOrderId ?? 0;
            String? statusHint = queryStatus;

            if (argument is int) {
              orderId = argument;
            } else if (argument is Map) {
              orderId = argument['orderId'] as int? ?? orderId;
              statusHint = argument['status'] as String? ?? statusHint;
            }

            return PaymentResultScreen(
              orderId: orderId,
              statusHint: statusHint,
            );
          },
          '/sepay-payment': (context) {
            final argument = ModalRoute.of(context)?.settings.arguments;
            if (argument is SePayPaymentResponse) {
              return SePayPaymentScreen(payment: argument);
            }
            throw ArgumentError('SePayPaymentResponse required');
          },
          '/refund-request': (context) => const RefundRequestScreen(),
          '/refund-status': (context) => const RefundStatusScreen(),
          '/ai-assistant': (context) => const AiAssistantScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/edit-profile': (context) => const EditProfileScreen(),
          '/help-support': (context) => const HelpSupportScreen(),
          '/payment-methods': (context) => const PaymentMethodsScreen(),
          '/addresses': (context) => const AddressListScreen(),
          '/address-form': (context) => const AddressFormScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/admin/products': (context) => AdminRouteGuard(
                builder: (_) => AdminProductListScreen(),
              ),
          '/admin/dashboard': (context) => AdminRouteGuard(
                builder: (_) => AdminDashboardScreen(),
              ),
          '/admin/products/create': (context) =>
              AdminRouteGuard(
                builder: (_) => AdminProductFormScreen(createMode: true),
              ),
          '/admin/products/edit': (context) {
            return AdminRouteGuard(
              builder: (guardContext) {
                final argument = ModalRoute.of(guardContext)?.settings.arguments;
                if (argument is ProductRouteArgs) {
                  return AdminProductFormScreen(product: argument.product);
                }
                throw ArgumentError('ProductRouteArgs required for edit product');
              },
            );
          },
          '/admin/products/images': (context) {
            return AdminRouteGuard(
              builder: (guardContext) {
                final argument = ModalRoute.of(guardContext)?.settings.arguments;
                if (argument is ProductRouteArgs) {
                  return AdminProductImageListScreen(
                    product: argument.product,
                    fromCreateFlow: argument.fromCreateFlow,
                  );
                }
                throw ArgumentError('ProductRouteArgs required for product images');
              },
            );
          },
          '/admin/products/variants': (context) {
            return AdminRouteGuard(
              builder: (guardContext) {
                final argument = ModalRoute.of(guardContext)?.settings.arguments;
                if (argument is ProductRouteArgs) {
                  return AdminProductFormScreen(product: argument.product);
                }
                throw ArgumentError(
                  'ProductRouteArgs required for product variants',
                );
              },
            );
          },
          '/admin/users': (context) => AdminRouteGuard(
                builder: (_) => AdminUserListScreen(),
              ),
          '/admin/orders': (context) => AdminRouteGuard(
                builder: (_) => AdminOrderListScreen(),
              ),
          '/admin/refund-requests': (context) =>
              AdminRouteGuard(
                builder: (_) => AdminRefundRequestsScreen(),
              ),
          '/admin/returns-refunds': (context) =>
              AdminRouteGuard(
                builder: (_) => AdminReturnsRefundsScreen(),
              ),
          '/admin/categories': (context) => AdminRouteGuard(
                builder: (_) => AdminCategoryListScreen(),
              ),
          '/create-review': (context) => const CreateReviewScreen(),
          '/admin/shipments': (context) => AdminRouteGuard(
                builder: (_) => AdminShipmentListScreen(),
              ),
          '/admin/shipments/detail': (context) =>
              AdminRouteGuard(
                builder: (_) => AdminShipmentDetailScreen(),
              ),
          '/admin/shipments/create': (context) =>
              AdminRouteGuard(
                builder: (_) => AdminShipmentFormScreen(createMode: true),
              ),
          '/admin/marketing-notifications': (context) =>
              AdminRouteGuard(
                builder: (_) => AdminMarketingNotificationScreen(),
              ),
        },
      ),
    );
  }
}
