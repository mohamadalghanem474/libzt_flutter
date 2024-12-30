import 'package:flutter/widgets.dart';
import 'package:libzt_flutter/libzt_flutter.dart';

class SocketModel extends ChangeNotifier {
  SocketModel(this.address, this.port);

  final String address;
  final int port;

  Future<void> reconnect() async {
    _socket?.close();
    _status = 'connecting...';
    notifyListeners();

    ZeroTierSocket.connect(address, port).then(
      (s) {
        _socket = s;
        _status = 'connected';
        notifyListeners();
        s.done.then((v) {
          _status = 'connection lost';
          notifyListeners();
        });
      },
      onError: (e) {
        _status = e.toString();
        notifyListeners();
      },
    );
  }

  void disconnect() {
    _socket?.close();
  }

  ZeroTierSocket? _socket;

  String get status => _status;
  String _status = 'not connected';
}
