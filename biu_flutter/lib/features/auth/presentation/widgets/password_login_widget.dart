import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/geetest_notifier.dart';
import '../providers/password_login_notifier.dart';

/// Password login widget
///
/// Source: biu/src/layout/navbar/login/password-login.tsx#PasswordLogin
class PasswordLoginWidget extends ConsumerStatefulWidget {

  const PasswordLoginWidget({
    super.key,
    this.onLoginSuccess,
  });
  final VoidCallback? onLoginSuccess;

  @override
  ConsumerState<PasswordLoginWidget> createState() =>
      _PasswordLoginWidgetState();
}

class _PasswordLoginWidgetState extends ConsumerState<PasswordLoginWidget> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto focus username field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _usernameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordLoginNotifierProvider);

    // Handle login success
    ref.listen(passwordLoginNotifierProvider, (previous, next) {
      if (next.status == PasswordLoginStatus.success) {
        widget.onLoginSuccess?.call();
      }
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Username field
        TextField(
          controller: _usernameController,
          focusNode: _usernameFocusNode,
          decoration: InputDecoration(
            labelText: '账号',
            hintText: '请输入手机号或邮箱',
            prefixIcon: const Icon(Icons.person_outline),
            errorText: state.status == PasswordLoginStatus.error
                ? state.errorMessage
                : null,
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _passwordFocusNode.requestFocus(),
        ),
        const SizedBox(height: 16),

        // Password field
        TextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          obscureText: !state.isPasswordVisible,
          decoration: InputDecoration(
            labelText: '密码',
            hintText: '请输入密码',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    state.isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    ref
                        .read(passwordLoginNotifierProvider.notifier)
                        .togglePasswordVisibility();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: _openPasswordRecovery,
                ),
              ],
            ),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleLogin(),
        ),
        const SizedBox(height: 24),

        // Login button
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: state.isLoading ? null : _handleLogin,
            child: state.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('登录'),
          ),
        ),

        const SizedBox(height: 16),

        // Captcha notice
        const Text(
          '密码登录需要完成极验验证',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入账号和密码')),
      );
      return;
    }

    // Perform Geetest verification
    final geetestResult = await ref.read(geetestNotifierProvider.notifier).verify(context);

    if (geetestResult == null || !geetestResult.isValid) {
      // User cancelled or verification failed
      return;
    }

    // Login with Geetest result
    await ref.read(passwordLoginNotifierProvider.notifier).login(
      username: username,
      password: password,
      geetestToken: geetestResult.token,
      geetestChallenge: geetestResult.challenge,
      geetestValidate: geetestResult.validate,
      geetestSeccode: geetestResult.seccode,
    );
  }

  /// Open password recovery page in system browser.
  /// Source: biu/src/layout/navbar/login/password-login.tsx:175-177
  Future<void> _openPasswordRecovery() async {
    final uri =
        Uri.parse('https://passport.bilibili.com/pc/passport/findPassword');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open password recovery page')),
        );
      }
    }
  }
}
