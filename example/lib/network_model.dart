import 'package:libzt_flutter/libzt_flutter.dart';

class NetworkModel {
  NetworkModel.fromId(this.id)
      : name = id.toRadixString(16),
        type = 'type unknown',
        address = 'no address',
        status = 'error';

  NetworkModel.fromInfo(ZeroTierNetwork info)
      : id = info.id,
        type = info.type == NetworkType.private ? 'private' : 'public',
        name = info.name == '' ? info.id.toRadixString(16) : info.name,
        address = info.address == '' ? 'no address yet' : info.address,
        status = _getStatus(info.status);

  static String _getStatus(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.waitingForConfig:
        return 'waiting for config';
      case NetworkStatus.ok:
        return 'online';
      case NetworkStatus.accessDenied:
        return 'access denied';
      case NetworkStatus.notFound:
        return 'not found';
      case NetworkStatus.portError:
        return 'port error';
      case NetworkStatus.clientTooOld:
        return 'client too old';
    }
  }

  final BigInt id;
  final String name;
  final String type;
  final String address;
  final String status;

  bool equals(NetworkModel other) {
    return id == other.id && name == other.name && address == other.address && status == other.status;
  }
}
