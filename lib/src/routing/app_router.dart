import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/features/auth/presentation/login_screen.dart';
import 'package:store_app/src/features/auth/presentation/register_screen.dart';
import 'package:store_app/src/features/auth/presentation/otp_screen.dart';
import 'package:store_app/src/features/auth/presentation/forgot_password_screen.dart';
import 'package:store_app/src/features/auth/presentation/check_email_screen.dart';
import 'package:store_app/src/features/auth/presentation/reset_password_screen.dart';
import 'package:store_app/src/features/auth/presentation/privacy_policy_screen.dart';
import 'package:store_app/src/features/auth/presentation/terms_of_use_screen.dart';
import 'package:store_app/src/features/auth/presentation/profile_screen.dart';
import 'package:store_app/src/features/auth/presentation/edit_profile_screen.dart';
import 'package:store_app/src/features/product/domain/product.dart';
import 'package:store_app/src/features/address/domain/user_address.dart';
import 'package:store_app/src/features/product/presentation/home_screen.dart';

import 'package:store_app/src/features/product/presentation/discover_screen.dart';
import 'package:store_app/src/features/product/presentation/category_screen.dart';
import 'package:store_app/src/features/product/presentation/product_detail_screen.dart';
import 'package:store_app/src/features/product/presentation/flashsale_screen.dart';
import 'package:store_app/src/features/cart/presentation/cart_screen.dart';
import 'package:store_app/src/features/wallet/presentation/wallet_screen.dart';
import 'package:store_app/src/features/wallet/presentation/topup_screen.dart';
import 'package:store_app/src/features/wallet/presentation/transfer_screen.dart';
import 'package:store_app/src/features/order/presentation/order_list_screen.dart';
import 'package:store_app/src/features/order/presentation/order_detail_screen.dart';
import 'package:store_app/src/features/order/presentation/checkout/checkout_screen.dart';
import 'package:store_app/src/features/order/presentation/order_payment_detail_screen.dart';
import 'package:store_app/src/features/address/presentation/address_list_screen.dart';
import 'package:store_app/src/features/membership/presentation/membership_screen.dart';
import 'package:store_app/src/features/address/presentation/add_address_screen.dart';
import 'package:store_app/src/common_widgets/scaffold_with_navbar.dart';
import 'package:store_app/src/features/auth/presentation/auth_controller.dart';
import 'package:store_app/src/features/voucher/presentation/voucher_offer_screen.dart';
import 'package:store_app/src/features/voucher/presentation/user_voucher_list_screen.dart';
import 'package:store_app/src/features/membership/presentation/membership_reward_list_screen.dart';
import 'package:store_app/src/features/membership/presentation/membership_information_detail_screen.dart';
import 'package:store_app/src/common_widgets/webview_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  
  final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final user = authState.value;
      final isAuthenticated = user != null;
      final isLoggingIn = state.uri.path == '/login' || state.uri.path == '/register' || state.uri.path == '/otp' || state.uri.path.startsWith('/forgot-password') || state.uri.path == '/check-email' || state.uri.path == '/reset-password' || state.uri.path == '/privacy-policy' || state.uri.path == '/terms-of-use';
      
      // Protected Routes
      // /cart, /profile, /wallet, /checkout, /orders
      final isProtectedRoute = 
          state.uri.path.startsWith('/cart') || 
          state.uri.path.startsWith('/profile') || 
          state.uri.path.startsWith('/wallet') || 
          state.uri.path.startsWith('/checkout') || 
          state.uri.path.startsWith('/orders');

      if (!isAuthenticated && isProtectedRoute) {
        return '/login'; // Redirect to login
      }
      
      if (isAuthenticated && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Registration Flow (No Bottom Bar)
      GoRoute(
        path: '/register',
            builder: (context, state) => const RegisterScreen(),
          ),
          GoRoute(
            path: '/otp',
            builder: (context, state) {
              final registrationData = state.extra as Map<String, dynamic>?;
              return OtpScreen(registrationData: registrationData);
            },
          ),
          GoRoute(
            path: '/forgot-password',
            builder: (context, state) => const ForgotPasswordScreen(),
          ),
          GoRoute(
            path: '/check-email',
            builder: (context, state) => const CheckEmailScreen(),
          ),
           GoRoute(
            path: '/reset-password',
            builder: (context, state) => const ResetPasswordScreen(),
          ),
           GoRoute(
            path: '/privacy-policy',
            builder: (context, state) => const PrivacyPolicyScreen(),
          ),
          GoRoute(
            path: '/terms-of-use',
            builder: (context, state) => const TermsOfUseScreen(),
          ),

          // Authenticated Shell (Bottom Nav Bar)
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return ScaffoldWithNavBar(navigationShell: navigationShell);
            },
            branches: [
              // Tab 1: Home
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (context, state) => const HomeScreen(),
                  ),
                ],
              ),
              // Tab 2: Category
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/category',
                    builder: (context, state) => const CategoryScreen(),
                  ),
                ],
              ),
              // Tab 3: Promo (Flashsale)
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/flashsale',
                    builder: (context, state) => const FlashsaleScreen(),
                  ),
                ],
              ),
              // Tab 4: Orders
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/orders',
                    builder: (context, state) {
                       final status = state.uri.queryParameters['status'];
                       return OrderListScreen(initialStatusFilter: status);
                    },
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (context, state) {
                           final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                           return OrderDetailScreen(orderId: id);
                        },
                        routes: [
                          GoRoute(
                            path: 'payment-detail',
                            builder: (context, state) {
                               final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                               return OrderPaymentDetailScreen(orderId: id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Global Routes (Hide Bottom Bar)
          GoRoute(
            path: '/discover',
            builder: (context, state) => const DiscoverScreen(),
          ),
          GoRoute(
            path: '/cart',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: '/checkout',
            builder: (context, state) => const CheckoutScreen(),
          ),
          GoRoute(
            path: '/product/:id',
            builder: (context, state) {
               final product = state.extra as Product; 
               return ProductDetailScreen(product: product);
            },
          ),
          GoRoute(
             path: '/profile',
             builder: (context, state) => const ProfileScreen(),
              routes: [
                 GoRoute(
                   path: 'addresses',
                   builder: (context, state) => const AddressListScreen(),
                   routes: [
                     GoRoute(
                       path: 'add',
                       builder: (context, state) => const AddAddressScreen(),
                     ),
                     GoRoute(
                       path: 'edit',
                       builder: (context, state) {
                          final address = state.extra as UserAddress?;
                          return AddAddressScreen(addressToEdit: address);
                       },
                     ),
                   ],
                 ),
                 GoRoute(
                   path: 'membership',
                   builder: (context, state) => const MembershipScreen(),
                   routes: [
                     GoRoute(
                       path: 'detail',
                       builder: (context, state) {
                          final id = state.uri.queryParameters['id'];
                          return MembershipInformationDetailScreen(
                            initialMembershipId: id != null ? int.tryParse(id) : null,
                          );
                       },
                     ),
                   ],
                 ),
                 GoRoute(
                   path: 'membership-rewards',
                   builder: (context, state) => const MembershipRewardListScreen(),
                 ),
                 GoRoute(
                   path: 'edit',
                   builder: (context, state) => const EditProfileScreen(),
                 ),
                 GoRoute(
                   path: 'vouchers',
                   builder: (context, state) => const UserVoucherListScreen(),
                 ),
              ],
          ),
          GoRoute(
             path: '/wallet',
             builder: (context, state) => const WalletScreen(),
             routes: [
               GoRoute(
                 path: 'topup',
                 builder: (context, state) => const TopupScreen(),
               ),
               GoRoute(
                 path: 'transfer',
                 builder: (context, state) => const TransferScreen(),
               ),
             ],
          ),
      GoRoute(
          path: '/voucher-offers',
          builder: (context, state) => const VoucherOfferScreen(),
      ),
      GoRoute(
          path: '/webview',
          builder: (context, state) {
            final extras = state.extra as Map<String, String>;
            return WebViewScreen(
              url: extras['url']!,
              title: extras['title'] ?? 'Payment',
            );
          },
      ),
    ],
  );

  ref.listen(authControllerProvider, (previous, next) {
    router.refresh();
  });

  return router;
});
