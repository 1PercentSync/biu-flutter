import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../data/models/captcha_response.dart';

/// Check if current platform supports WebView
bool get _isWebViewSupported =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);

/// Dialog that displays Geetest captcha verification
class GeetestDialog extends StatefulWidget {

  const GeetestDialog({
    required this.token, required this.gt, required this.challenge, super.key,
  });
  /// Geetest token from captcha API
  final String token;

  /// Geetest gt parameter
  final String gt;

  /// Geetest challenge parameter
  final String challenge;

  /// Show Geetest dialog and return verification result
  static Future<GeetestResult?> show(
    BuildContext context, {
    required String token,
    required String gt,
    required String challenge,
  }) async {
    // On unsupported platforms (Windows, Linux, Web), show alternative dialog
    if (!_isWebViewSupported) {
      return _showUnsupportedPlatformDialog(context);
    }

    return showDialog<GeetestResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => GeetestDialog(
        token: token,
        gt: gt,
        challenge: challenge,
      ),
    );
  }

  /// Show dialog for unsupported platforms (Windows, Linux, Web).
  /// Source: This login method requires WebView which is only available on mobile.
  static Future<GeetestResult?> _showUnsupportedPlatformDialog(
    BuildContext context,
  ) async {
    return showDialog<GeetestResult>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('桌面端不可用'),
        content: const Text(
          '此登录方式需要验证码功能，在桌面端不可用。\n\n'
          '请使用以下方式登录：\n'
          '• 扫码登录（推荐）\n'
          '• 在手机或平板上使用短信登录',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  State<GeetestDialog> createState() => _GeetestDialogState();
}

class _GeetestDialogState extends State<GeetestDialog> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            setState(() {
              _error = error.description;
              _isLoading = false;
            });
          },
        ),
      )
      ..addJavaScriptChannel(
        'GeetestBridge',
        onMessageReceived: _handleJavaScriptMessage,
      )
      ..loadHtmlString(_buildHtml());
  }

  void _handleJavaScriptMessage(JavaScriptMessage message) {
    final data = message.message;

    if (data.startsWith('success:')) {
      // Parse success result: success:challenge|validate|seccode
      final parts = data.substring(8).split('|');
      if (parts.length >= 3) {
        final result = GeetestResult(
          token: widget.token,
          gt: widget.gt,
          challenge: parts[0],
          validate: parts[1],
          seccode: parts[2],
        );
        Navigator.of(context).pop(result);
      }
    } else if (data.startsWith('error:')) {
      setState(() {
        _error = data.substring(6);
      });
    } else if (data == 'close') {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '安全验证',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // WebView
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  if (_error != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.exclamationmark_circle_fill,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '加载失败: $_error',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _error = null;
                                  _isLoading = true;
                                });
                                _controller.reload();
                              },
                              child: const Text('重试'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildHtml() {
    final gt = _escapeJs(widget.gt);
    final challenge = _escapeJs(widget.challenge);

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>Geetest</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    html, body {
      width: 100%;
      height: 100%;
      background: #fff;
    }
    body {
      display: flex;
      justify-content: center;
      align-items: center;
      padding: 16px;
    }
    #captcha-container {
      width: 100%;
      max-width: 340px;
    }
    .loading {
      text-align: center;
      color: #666;
      padding: 20px;
    }
    .error {
      text-align: center;
      color: #e53935;
      padding: 20px;
    }
  </style>
</head>
<body>
  <div id="captcha-container">
    <div class="loading" id="loading">正在加载验证码...</div>
  </div>

  <script src="https://static.geetest.com/static/tools/gt.js"></script>
  <script>
    (function() {
      var loadingEl = document.getElementById('loading');

      if (typeof initGeetest !== 'function') {
        loadingEl.className = 'error';
        loadingEl.textContent = '极验组件加载失败';
        GeetestBridge.postMessage('error:极验组件加载失败');
        return;
      }

      initGeetest({
        gt: '$gt',
        challenge: '$challenge',
        offline: false,
        new_captcha: true,
        product: 'bind',
        https: true
      }, function(captchaObj) {
        loadingEl.style.display = 'none';

        captchaObj.onReady(function() {
          captchaObj.verify();
        });

        captchaObj.onSuccess(function() {
          var result = captchaObj.getValidate();
          if (result && typeof result !== 'boolean') {
            var msg = 'success:' + result.geetest_challenge + '|' + result.geetest_validate + '|' + result.geetest_seccode;
            GeetestBridge.postMessage(msg);
          } else {
            GeetestBridge.postMessage('error:验证结果无效');
          }
        });

        captchaObj.onError(function(e) {
          var msg = e && e.error_code ? ('错误代码: ' + e.error_code) : '验证出错';
          GeetestBridge.postMessage('error:' + msg);
        });

        captchaObj.onClose(function() {
          GeetestBridge.postMessage('close');
        });
      });
    })();
  </script>
</body>
</html>
''';
  }

  String _escapeJs(String input) {
    return input
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll('"', r'\"')
        .replaceAll('\n', r'\n')
        .replaceAll('\r', r'\r');
  }
}
