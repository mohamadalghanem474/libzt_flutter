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
