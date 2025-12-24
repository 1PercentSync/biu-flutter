import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/password_login_widget.dart';
import '../widgets/qr_login_widget.dart';
import '../widgets/sms_login_widget.dart';

/// Login screen with tabbed login methods
///
/// Source: biu/src/layout/navbar/login/index.tsx#Login
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onLoginSuccess() {
    // Navigate back or to home
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '扫码登录'),
            Tab(text: '密码登录'),
            Tab(text: '短信登录'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // QR Code Login
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: QrLoginWidget(
                  onLoginSuccess: _onLoginSuccess,
                ),
              ),
            ),

            // Password Login
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: PasswordLoginWidget(
                    onLoginSuccess: _onLoginSuccess,
                  ),
                ),
              ),
            ),

            // SMS Login
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: SmsLoginWidget(
                    onLoginSuccess: _onLoginSuccess,
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
