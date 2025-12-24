import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../data/models/captcha_response.dart';

/// Dialog that displays Geetest captcha verification
class GeetestDialog extends StatefulWidget {
  /// Geetest token from captcha API
  final String token;

  /// Geetest gt parameter
  final String gt;

  /// Geetest challenge parameter
  final String challenge;

  const GeetestDialog({
    super.key,
    required this.token,
    required this.gt,
    required this.challenge,
  });

  /// Show Geetest dialog and return verification result
  static Future<GeetestResult?> show(
    BuildContext context, {
    required String token,
    required String gt,
    required String challenge,
  }) async {
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

  @override
  State<GeetestDialog> createState() => _GeetestDialogState();
}

class _GeetestDialogState extends State<GeetestDialog> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  String? _error;

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
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(null),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // WebView
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    initialData: InAppWebViewInitialData(
                      data: _buildHtml(),
                      mimeType: 'text/html',
                      encoding: 'utf-8',
                    ),
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      transparentBackground: true,
                      useShouldOverrideUrlLoading: true,
                      mediaPlaybackRequiresUserGesture: false,
                    ),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                      _addJavaScriptHandler(controller);
                    },
                    onLoadStop: (controller, url) {
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    onReceivedError: (controller, request, error) {
                      setState(() {
                        _error = error.description;
                        _isLoading = false;
                      });
                    },
                  ),
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
                              Icons.error_outline,
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
                                _webViewController?.reload();
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

  void _addJavaScriptHandler(InAppWebViewController controller) {
    // Handler for successful verification
    controller.addJavaScriptHandler(
      handlerName: 'onGeetestSuccess',
      callback: (args) {
        if (args.isNotEmpty && args[0] is Map) {
          final result = args[0] as Map;
          final geetestResult = GeetestResult(
            token: widget.token,
            gt: widget.gt,
            challenge: result['geetest_challenge'] as String? ?? widget.challenge,
            validate: result['geetest_validate'] as String? ?? '',
            seccode: result['geetest_seccode'] as String? ?? '',
          );
          Navigator.of(context).pop(geetestResult);
        }
      },
    );

    // Handler for error
    controller.addJavaScriptHandler(
      handlerName: 'onGeetestError',
      callback: (args) {
        setState(() {
          _error = args.isNotEmpty ? args[0].toString() : '验证出错';
        });
      },
    );

    // Handler for close/cancel
    controller.addJavaScriptHandler(
      handlerName: 'onGeetestClose',
      callback: (args) {
        Navigator.of(context).pop(null);
      },
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
      background: transparent;
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
        window.flutter_inappwebview.callHandler('onGeetestError', '极验组件加载失败');
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
            window.flutter_inappwebview.callHandler('onGeetestSuccess', result);
          } else {
            window.flutter_inappwebview.callHandler('onGeetestError', '验证结果无效');
          }
        });

        captchaObj.onError(function(e) {
          var msg = e && e.error_code ? ('错误代码: ' + e.error_code) : '验证出错';
          window.flutter_inappwebview.callHandler('onGeetestError', msg);
        });

        captchaObj.onClose(function() {
          window.flutter_inappwebview.callHandler('onGeetestClose');
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
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r');
  }
}
