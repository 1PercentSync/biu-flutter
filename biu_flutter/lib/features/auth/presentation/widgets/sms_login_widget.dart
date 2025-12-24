import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/geetest_notifier.dart';
import '../providers/sms_login_notifier.dart';

/// SMS login widget
class SmsLoginWidget extends ConsumerStatefulWidget {

  const SmsLoginWidget({
    super.key,
    this.onLoginSuccess,
  });
  final VoidCallback? onLoginSuccess;

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
                onPressed: state.canSendCode ? _handleSendCode : null,
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
          '发送验证码需要完成极验验证',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSendCode() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入手机号')),
      );
      return;
    }

    // Perform Geetest verification
    final geetestResult = await ref.read(geetestNotifierProvider.notifier).verify(context);

    if (geetestResult == null || !geetestResult.isValid) {
      // User cancelled or verification failed
      return;
    }

    // Send SMS code with Geetest result
    final success = await ref.read(smsLoginNotifierProvider.notifier).sendCode(
      phone: phone,
      geetestToken: geetestResult.token,
      geetestChallenge: geetestResult.challenge,
      geetestValidate: geetestResult.validate,
      geetestSeccode: geetestResult.seccode,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('验证码已发送')),
      );
      _codeFocusNode.requestFocus();
    }
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

  void _handleLogin() {
    final notifier = ref.read(smsLoginNotifierProvider.notifier);
    notifier.login(
      phone: _phoneController.text,
      code: _codeController.text,
    );
  }
}
