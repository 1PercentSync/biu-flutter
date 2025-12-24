import 'dart:developer' as developer;
import 'package:dio/dio.dart';

/// Interceptor for logging HTTP requests and responses in debug mode
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({this.logPrint});

  /// Custom log function, defaults to developer.log
  final void Function(String message)? logPrint;

  void _log(String message) {
    if (logPrint != null) {
      logPrint!(message);
    } else {
      developer.log(message, name: 'HTTP');
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('╔══════════════════════════════════════════════════════════')
      ..writeln('║ REQUEST')
      ..writeln('╟──────────────────────────────────────────────────────────')
      ..writeln('║ ${options.method} ${options.uri}');

    if (options.headers.isNotEmpty) {
      buffer.writeln('║ Headers:');
      options.headers.forEach((key, value) {
        // Don't log sensitive headers
        if (key.toLowerCase() == 'cookie') {
          buffer.writeln('║   $key: [REDACTED]');
        } else {
          buffer.writeln('║   $key: $value');
        }
      });
    }

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('║ Query Parameters:');
      options.queryParameters.forEach((key, value) {
        buffer.writeln('║   $key: $value');
      });
    }

    if (options.data != null) {
      buffer.writeln('║ Body: ${_truncate(options.data.toString(), 500)}');
    }

    buffer.writeln('╚══════════════════════════════════════════════════════════');
    _log(buffer.toString());

    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('╔══════════════════════════════════════════════════════════')
      ..writeln('║ RESPONSE')
      ..writeln('╟──────────────────────────────────────────────────────────')
      ..writeln('║ ${response.statusCode} ${response.requestOptions.uri}')
      ..writeln('║ Data: ${_truncate(response.data.toString(), 500)}')
      ..writeln('╚══════════════════════════════════════════════════════════');
    _log(buffer.toString());

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('╔══════════════════════════════════════════════════════════')
      ..writeln('║ ERROR')
      ..writeln('╟──────────────────────────────────────────────────────────')
      ..writeln('║ ${err.type} ${err.requestOptions.uri}')
      ..writeln('║ Message: ${err.message}');
    if (err.response != null) {
      buffer
        ..writeln('║ Status: ${err.response?.statusCode}')
        ..writeln('║ Data: ${_truncate(err.response?.data?.toString() ?? '', 500)}');
    }
    buffer.writeln('╚══════════════════════════════════════════════════════════');
    _log(buffer.toString());

    handler.next(err);
  }

  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}... [truncated]';
  }
}
