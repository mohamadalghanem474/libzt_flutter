enum NetworkStatus { waitingForConfig, ok, accessDenied, notFound, portError, clientTooOld, unknown }

enum NetworkType { private, public }

class ZeroTierNetwork {
  ZeroTierNetwork(
    this.id,
    this.transportIsReady,
    this.mac,
    this.macString,
    this.broadcastEnabled,
    this.mtu,
    this.name,
    this.type,
    this.routeAssigned,
    this.address,
  );

  final BigInt id;
  String get idString => id.toRadixString(16);
  final bool transportIsReady;
  final BigInt mac;
  final String macString;
  final bool broadcastEnabled;
  final int mtu;
  final String name;
  final NetworkType type;
  final bool routeAssigned;
  final String address;

  // Override the toString method
  @override
  String toString() {
    return 'ZeroTierNetwork { '
      'ID: $idString, '
      'Name: $name, '
      'Type: ${type.name}, '
      'Transport Ready: $transportIsReady, '
      'MAC: $macString, '
      'Broadcast Enabled: $broadcastEnabled, '
      'MTU: $mtu, '
      'Route Assigned: $routeAssigned, '
      'Address: $address '
      '}';
  }
}
