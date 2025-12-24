import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sms_login_notifier.dart';

/// SMS login widget
class SmsLoginWidget extends ConsumerStatefulWidget {
  final VoidCallback? onLoginSuccess;

  const SmsLoginWidget({
    super.key,
    this.onLoginSuccess,
  });

  @override
  ConsumerState<SmsLoginWidget> createState() => _SmsLoginWidgetState();
}

class _SmsLoginWidgetState extends ConsumerState<SmsLoginWidget> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  final _codeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _phoneFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _phoneFocusNode.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(smsLoginNotifierProvider);

    // Handle login success
    ref.listen(smsLoginNotifierProvider, (previous, next) {
      if (next.status == SmsLoginStatus.success) {
        widget.onLoginSuccess?.call();
      }
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Phone number field
        TextField(
          controller: _phoneController,
          focusNode: _phoneFocusNode,
          decoration: InputDecoration(
            labelText: '手机号',
            hintText: '请输入手机号',
            prefixIcon: const Icon(Icons.phone_outlined),
            prefix: GestureDetector(
              onTap: _showCountryCodePicker,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  '+${state.countryCode}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            errorText: state.status == SmsLoginStatus.error
                ? state.errorMessage
                : null,
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _codeFocusNode.requestFocus(),
        ),
        const SizedBox(height: 16),

        // Verification code field
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codeController,
                focusNode: _codeFocusNode,
                decoration: const InputDecoration(
                  labelText: '验证码',
                  hintText: '请输入验证码',
                  prefixIcon: Icon(Icons.sms_outlined),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleLogin(),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: OutlinedButton(
                onPressed: state.canSendCode ? _showCaptchaInfo : null,
                child: Text(
                  state.countdown > 0
                      ? '${state.countdown}s'
                      : state.isSendingCode
                          ? '发送中...'
                          : '获取验证码',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Login button
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: state.isLoggingIn ? null : _handleLogin,
            child: state.isLoggingIn
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
          '注意：短信登录需要完成极验验证\n当前版本暂不支持，请使用扫码登录',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  void _showCountryCodePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '选择国家/地区',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              title: const Text('中国大陆'),
              trailing: const Text('+86'),
              onTap: () {
                ref.read(smsLoginNotifierProvider.notifier).setCountryCode(86);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('中国香港'),
              trailing: const Text('+852'),
              onTap: () {
                ref.read(smsLoginNotifierProvider.notifier).setCountryCode(852);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('中国台湾'),
              trailing: const Text('+886'),
              onTap: () {
                ref.read(smsLoginNotifierProvider.notifier).setCountryCode(886);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCaptchaInfo() {
    // In a full implementation, this would launch GeeTest captcha
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('极验验证'),
        content: const Text(
          '短信登录需要完成极验(GeeTest)人机验证。\n\n'
          '当前版本暂不支持极验验证，请使用扫码登录。',
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

  void _handleLogin() {
    final notifier = ref.read(smsLoginNotifierProvider.notifier);
    notifier.login(
      phone: _phoneController.text,
      code: _codeController.text,
    );
  }
}
