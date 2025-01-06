import 'package:libzt_flutter/libzt_flutter.dart';
import 'package:path_provider/path_provider.dart';

class ZtHttp {
  static final ZeroTierNode _zeroTierNode = ZeroTierNode.instance;
  static BigInt _networkId = BigInt.zero;
  static NetworkStatus get networkStatus =>
      _zeroTierNode.getNetworkStatus(_networkId);

  static Future<void> init({required String networkId}) async {
    _networkId = BigInt.parse(networkId, radix: 16);
    try {
      if (!_zeroTierNode.running) {
        getDownloadsDirectory().then((dir) {
          if (dir?.path != null) {
            _zeroTierNode.initSetPath(dir!.path);
          }
          var result = _zeroTierNode.start();
          if (!result.success) {
            throw Exception('Failed to start ZeroTierNode: $result');
          }
        });
      }
      await _zeroTierNode.waitForOnline();
      _zeroTierNode.join(_networkId);
      await _zeroTierNode.waitForNetworkReady(_networkId);
      await _zeroTierNode.waitForAddressAssignment(_networkId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<ZtHttpResponse> get({
    required String host,
    required int port,
    required String path,
    Map<String, String>? headers,
  }) async {
    return _CURD().get(host: host, port: port, path: path, headers: headers);
  }

  static Future<ZtHttpResponse> post({
    required String host,
    required int port,
    required String path,
    Map<String, String>? headers,
    required String body,
  }) async {
    return _CURD()
        .post(host: host, port: port, path: path, headers: headers, body: body);
  }

  static Future<ZtHttpResponse> update({
    required String host,
    required int port,
    required String path,
    Map<String, String>? headers,
    required String body,
  }) async {
    return _CURD().update(
        host: host, port: port, path: path, headers: headers, body: body);
  }

  static Future<ZtHttpResponse> delete({
    required String host,
    required int port,
    required String path,
    Map<String, String>? headers,
  }) async {
    return _CURD().delete(host: host, port: port, path: path, headers: headers);
  }
}

class _CURD {
  static ZeroTierSocket? zeroTierSocket;
  // General request method
  Future<ZtHttpResponse> _sendRequest({
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
        int bodyStartIndex = response.indexOf('\r\n\r\n') + 4;
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
              200, // Assuming success; this could be parsed from `lines[0]`.
          headers: responseHeaders,
          statusMessage: statusMessage,
        );
      });
    } catch (e) {
      return ZtHttpResponse(
        data: 'Error: $e',
        statusCode: 500,
        headers: {},
        statusMessage: 'Failed to send $method request',
      );
    } finally {
      zeroTierSocket?.close();
      zeroTierSocket?.destroy();
    }
  }

  // CREATE (POST)
  Future<ZtHttpResponse> post({
    required String host,
    required int port,
    required String path,
    Map<String, String>? headers,
    required String body,
  }) {
    return _sendRequest(
      host: host,
      port: port,
      method: 'POST',
      path: path,
      headers: headers,
      body: body,
    );
  }

  // READ (GET)
  Future<ZtHttpResponse> get({
    required String host,
    required int port,
    required String path,
    Map<String, String>? headers,
  }) {
    return _sendRequest(
      host: host,
      port: port,
      method: 'GET',
      path: path,
      headers: headers,
    );
  }

  // UPDATE (PUT)
  Future<ZtHttpResponse> update({
    required String host,
    required int port,
    required String path,
    Map<String, String>? headers,
    required String body,
  }) {
    return _sendRequest(
      host: host,
      port: port,
      method: 'PUT',
      path: path,
      headers: headers,
      body: body,
    );
  }

  Future<ZtHttpResponse> delete({
    required String host,
    required int port,
    required String path,
    Map<String, String>? headers,
  }) {
    return _sendRequest(
      host: host,
      port: port,
      method: 'DELETE',
      path: path,
      headers: headers,
    );
  }
}

class ZtHttpResponse {
  final String data;
  final int statusCode;
  final Map<String, String> headers;
  final String statusMessage;

  ZtHttpResponse({
    required this.data,
    required this.statusCode,
    required this.headers,
    required this.statusMessage,
  });
  @override
  String toString() {
    return 'ZtHttpResponse{data: $data, statusCode: $statusCode, headers: $headers, statusMessage: $statusMessage}';
  }
}
