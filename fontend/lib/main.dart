import 'package:flutter/material.dart';

import 'localization/app_localization.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
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
import 'screens/admin/admin_category_list_screen.dart';
import 'screens/review/create_review_screen.dart';
import 'screens/admin/admin_shipment_list_screen.dart';
import 'screens/admin/admin_shipment_detail_screen.dart';
import 'screens/admin/admin_shipment_form_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_order_list_screen.dart';
import 'screens/admin/admin_returns_refunds_screen.dart';
import 'screens/admin/admin_user_list_screen.dart';
import 'theme/app_theme.dart';
import 'config/app_config.dart';
import 'services/auth_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.currentUserId = await AuthStorage().getUserId() ?? 0;
  await AppLocaleController.instance.load();
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
            final orderId = argument is int ? argument : 0;

            return PaymentResultScreen(orderId: orderId);
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
          '/admin/products': (context) => const AdminProductListScreen(),
          '/admin/dashboard': (context) => const AdminDashboardScreen(),
          '/admin/users': (context) => const AdminUserListScreen(),
          '/admin/orders': (context) => const AdminOrderListScreen(),
          '/admin/returns-refunds': (context) =>
              const AdminReturnsRefundsScreen(),
          '/admin/categories': (context) => const AdminCategoryListScreen(),
          '/create-review': (context) => const CreateReviewScreen(),
          '/admin/shipments': (context) => const AdminShipmentListScreen(),
          '/admin/shipments/detail': (context) =>
              const AdminShipmentDetailScreen(),
          '/admin/shipments/create': (context) =>
              const AdminShipmentFormScreen(createMode: true),
        },
      ),
    );
  }
}
