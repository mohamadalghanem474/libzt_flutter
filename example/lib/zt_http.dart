import 'package:flutter/foundation.dart';
import 'package:libzt_flutter/libzt_flutter.dart';

import 'zt_http_response.dart';

class ZtHttp {
  ZeroTierSocket? zeroTierSocket;

  Future<ZtHttpResponse?> request({
    required String host,
    required int port,
    required String method,
    required String path,
    Map<String, String>? headers,
    String? body,
  }) async {
    try {
      String request = '$method $path HTTP/1.1\r\n'
          'Host: $host\r\n'
          'Connection: close\r\n'
          'User-Agent: Dart/2.0\r\n'
          'Accept: */*\r\n';

      if (headers != null) {
        headers.forEach((key, value) {
          request += '$key: $value\r\n';
        });
      }

      if (body != null) {
        request += 'Content-Length: ${body.length}\r\n\r\n';
        request += body;
      } else {
        request += '\r\n';
      }
      zeroTierSocket = await ZeroTierSocket.connect(host, port);

      zeroTierSocket!.sink.add(request.codeUnits);

      return await zeroTierSocket!.stream.first.then((data) {
        String response = String.fromCharCodes(data);
        int bodyStartIndex =
            response.indexOf('\r\n\r\n') + 4;
        String body = response.substring(bodyStartIndex);
        Map<String, String> responseHeaders = {};
        List<String> lines = response.split('\r\n');
        for (var line in lines.skip(1)) {
          if (line.isEmpty) continue;
          var parts = line.split(':');
          if (parts.length == 2) {
            responseHeaders[parts[0].trim()] = parts[1].trim();
          }
        }
        String statusMessage = lines.isNotEmpty ? lines[0] : '';

        return ZtHttpResponse(
          data: body,
          statusCode:
              200,
          headers: responseHeaders,
          statusMessage: statusMessage,
        );
      });
    } catch (e) {
      debugPrint('Failed to send $method request: $e');
      return null;
    } finally {
      zeroTierSocket?.close();
      zeroTierSocket?.destroy();
    }
  }
}
