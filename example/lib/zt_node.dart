import 'dart:async';

import 'package:libzt_flutter/libzt_flutter.dart';

class ZtNode {
  ZtNode._();
  static final ZtNode instance = ZtNode._();
  final ZeroTierNode _zeroTierNode = ZeroTierNode.instance;
  Future<ZeroTierNetwork> init(
      {required String networkId, String? path}) async {
    try {
      var nwId = BigInt.parse(networkId, radix: 16);
      if (!_zeroTierNode.running) {
        var appDocPath = path ?? '/storage/emulated/0/Download/net_config';
        _zeroTierNode.initSetPath(appDocPath);
        var result = _zeroTierNode.start();
        if (!result.success) {
          throw Exception('Failed to start ZeroTierNode: $result');
        }
      }
      await _zeroTierNode.waitForOnline();
      _zeroTierNode.join(nwId);
      await _zeroTierNode.waitForNetworkReady(nwId);
      await _zeroTierNode.waitForAddressAssignment(nwId);
      return _zeroTierNode.getNetworkInfo(nwId);
    } catch (e) {
      rethrow;
    }
  }
}
