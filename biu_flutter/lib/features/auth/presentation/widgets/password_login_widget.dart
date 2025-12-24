import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/password_login_notifier.dart';

/// Password login widget
class PasswordLoginWidget extends ConsumerStatefulWidget {
  final VoidCallback? onLoginSuccess;

  const PasswordLoginWidget({
    super.key,
    this.onLoginSuccess,
  });

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
                  onPressed: _showForgotPasswordHint,
                ),
              ],
            ),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _showCaptchaInfo(),
        ),
        const SizedBox(height: 24),

        // Login button
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: state.isLoading ? null : _showCaptchaInfo,
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
          '注意：密码登录需要完成极验验证\n当前版本暂不支持，请使用扫码登录',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  void _showCaptchaInfo() {
    // In a full implementation, this would launch GeeTest captcha
    // For now, show an info dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('极验验证'),
        content: const Text(
          '密码登录需要完成极验(GeeTest)人机验证。\n\n'
          '当前版本暂不支持极验验证，请使用扫码登录或短信登录。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('我知道了'),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordHint() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('找回密码'),
        content: const Text(
          '请访问 bilibili 官网找回密码：\n'
          'https://passport.bilibili.com/pc/passport/findPassword',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('我知道了'),
          ),
        ],
      ),
    );
  }
}
