import 'package:get/get.dart';
import 'package:treasurehunt/app/bindings/main_nav_binding.dart';
import 'package:treasurehunt/app/routes/app_routes.dart';
import 'package:treasurehunt/app/ui/pages/admin/admin_feedback_page.dart';
import 'package:treasurehunt/app/ui/pages/auth/signin_page.dart';
import 'package:treasurehunt/app/ui/pages/claim/claim_page.dart';
import 'package:treasurehunt/app/ui/pages/feedback_report_page.dart';
import 'package:treasurehunt/app/ui/pages/signup/sign_up_page.dart';
import 'package:treasurehunt/app/ui/pages/splash/splash_page.dart';
import 'package:treasurehunt/app/ui/pages/splash_page.dart';
import 'package:treasurehunt/app/ui/widgets/bottom_nav_bar.dart';

import '../bindings/claim_binding.dart';
import 'package:treasurehunt/app/ui/pages/profile/item_claims_page.dart';
import 'package:treasurehunt/app/ui/pages/signin/sign_in_page.dart';

import '../bindings/chat_binding.dart';
import '../bindings/item_claims_binding.dart';
import '../bindings/my_chats_binding.dart';
import '../ui/pages/chat/chat_page.dart';
import '../ui/pages/profile/my_chats_page.dart';

class AppPages {
  static final initial = Routes.splash;

  static final pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: Routes.signIn,
      page: () => const SignInPage(),
    ),
    GetPage(
      name: Routes.signUp,
      page: () => const SignUpPage(),
    ),
    GetPage(
      name: Routes.mainNav,
      page: () => const MainNavPage(),
      binding: MainNavBinding(),
    ),
    GetPage(
      name: Routes.feedbackReport,
      page: () => FeedbackReportPage(itemId: Get.arguments as String),
    ),
    GetPage(
      name: Routes.adminFeedbacks,
      page: () => const AdminFeedbackPage(),
    ),
    GetPage(
      name: Routes.claim,
      page: () => ClaimPage(),
      binding: ClaimBinding(),
    ),
    GetPage(
      name: Routes.itemClaims,
      page: () => const ItemClaimsPage(),
      binding: ItemClaimsBinding(),
    ),
        GetPage(
      name: Routes.chat,
      page: () => const ChatPage(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: Routes.myChats,
      page: () => const MyChatsPage(),
      binding: MyChatsBinding(),
    ),
    GetPage(
      name: Routes.myChats,
      page: () => const MyChatsPage(),
      binding: MyChatsBinding(),
    ),
  ];
}