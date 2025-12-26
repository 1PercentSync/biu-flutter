import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/geetest_notifier.dart';
import '../providers/sms_login_notifier.dart';

/// SMS login widget
///
/// Source: biu/src/layout/navbar/login/code-login.tsx#CodeLogin
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
            prefixIcon: const Icon(CupertinoIcons.phone_fill),
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
                  prefixIcon: Icon(CupertinoIcons.chat_bubble_fill),
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
    final state = ref.read(smsLoginNotifierProvider);
    final countryList = state.countryList;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SafeArea(
          child: Column(
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
              Expanded(
                child: countryList.isEmpty
                    ? _buildFallbackCountryList()
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: countryList.length,
                        itemBuilder: (context, index) {
                          final country = countryList[index];
                          final code = int.tryParse(country.countryCode) ?? 0;
                          return ListTile(
                            title: Text(country.name),
                            trailing: Text(country.displayCode),
                            selected: code == state.countryCode,
                            onTap: () {
                              ref
                                  .read(smsLoginNotifierProvider.notifier)
                                  .setCountryCode(code);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fallback display when API fails - only show default country code 86.
  /// This aligns with source project (biu/src/layout/navbar/login/code-login.tsx)
  /// which only uses default "86" when country list is unavailable.
  Widget _buildFallbackCountryList() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.info_circle_fill,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              '无法加载国家列表',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '当前使用默认国家/地区代码 +86',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() {
    ref.read(smsLoginNotifierProvider.notifier).login(
      phone: _phoneController.text,
      code: _codeController.text,
    );
  }
}
