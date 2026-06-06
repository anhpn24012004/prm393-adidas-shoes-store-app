import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/product/product_list_screen.dart';
import 'screens/product/product_detail_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/order/checkout_screen.dart';
import 'screens/order/order_history_screen.dart';
import 'screens/order/order_detail_screen.dart';
import 'screens/refund/refund_request_screen.dart';
import 'screens/refund/refund_status_screen.dart';
import 'screens/ai/ai_assistant_screen.dart';
import 'screens/category/category_list_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/admin/admin_product_list_screen.dart';
import 'screens/admin/admin_category_list_screen.dart';
void main() {
  runApp(const AdidasShoesStoreApp());
}

class AdidasShoesStoreApp extends StatelessWidget {
  const AdidasShoesStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adidas Shoes Store',
      debugShowCheckedModeBanner: false,
      initialRoute: '/products',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/categories': (context) => CategoryListScreen(),
        '/products': (context) => const ProductListScreen(),
        '/cart': (context) => const CartScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/orders': (context) => const OrderHistoryScreen(),
        '/order-detail': (context) => const OrderDetailScreen(),
        '/refund-request': (context) => const RefundRequestScreen(),
        '/refund-status': (context) => const RefundStatusScreen(),
        '/ai-assistant': (context) => const AiAssistantScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/admin/products': (context) => const AdminProductListScreen(),
        '/admin/categories': (context) => const AdminCategoryListScreen(),
      },
    );
  }
}