import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../providers/qr_login_notifier.dart';

/// QR code login widget
///
/// Source: biu/src/layout/navbar/login/qrcode-login.tsx#QrcodeLogin
class QrLoginWidget extends ConsumerWidget {

  const QrLoginWidget({
    super.key,
    this.onLoginSuccess,
  });
  final VoidCallback? onLoginSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(qrLoginNotifierProvider);
    final notifier = ref.read(qrLoginNotifierProvider.notifier);

    // Handle login success
    ref.listen(qrLoginNotifierProvider, (previous, next) {
      if (next.status == QrLoginStatus.success) {
        onLoginSuccess?.call();
      }
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '扫码登录',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        _buildQrCodeContainer(context, state, notifier),
        const SizedBox(height: 16),
        _buildStatusText(state),
      ],
    );
  }

  Widget _buildQrCodeContainer(
    BuildContext context,
    QrLoginState state,
    QrLoginNotifier notifier,
  ) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildQrContent(state),
            if (state.status == QrLoginStatus.expired)
              _buildExpiredOverlay(notifier),
            if (state.status == QrLoginStatus.scanned) _buildScannedOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildQrContent(QrLoginState state) {
    if (state.status == QrLoginStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.status == QrLoginStatus.error) {
      return Center(
        child: Icon(
          Icons.error_outline,
          size: 48,
          color: Colors.red[300],
        ),
      );
    }

    final url = state.qrCodeUrl;
    if (url == null || url.isEmpty) {
      return const Center(
        child: Icon(
          Icons.qr_code,
          size: 48,
          color: Colors.grey,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: QrImageView(
        data: url,
        size: 164,
        backgroundColor: Colors.white,
        errorStateBuilder: (context, error) {
          return Center(
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[300],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpiredOverlay(QrLoginNotifier notifier) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: notifier.refreshQrCode,
            icon: const Icon(
              Icons.refresh,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '二维码已失效\n点击刷新',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannedOverlay() {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.7),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 36,
            color: Colors.green,
          ),
          SizedBox(height: 8),
          Text(
            '扫描成功\n请在手机上确认',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText(QrLoginState state) {
    String text;
    Color color = Colors.grey;

    switch (state.status) {
      case QrLoginStatus.loading:
        text = '正在加载二维码...';
        break;
      case QrLoginStatus.ready:
        text = '请使用bilibili手机客户端扫码登录';
        break;
      case QrLoginStatus.scanned:
        text = '扫描成功，请在手机上确认登录';
        color = Colors.green;
        break;
      case QrLoginStatus.success:
        text = '登录成功';
        color = Colors.green;
        break;
      case QrLoginStatus.expired:
        text = '二维码已失效，请刷新';
        color = Colors.orange;
        break;
      case QrLoginStatus.error:
        text = state.errorMessage ?? '发生错误';
        color = Colors.red;
        break;
    }

    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13,
        color: color,
      ),
    );
  }
}
