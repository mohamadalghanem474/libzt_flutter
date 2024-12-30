# libzt_flutter

[![pub package](https://img.shields.io/pub/v/libzt_flutter.svg)](https://pub.dartlang.org/packages/libzt_flutter)

Flutter plugin providing bindings for the [libzt](https://github.com/zerotier/libzt) library. Uses `dart:ffi`.

This package has been updated to the latest versions of the `libzt` library and Flutter libraries. Support for iOS is currently being worked on.

## Supported platforms

- **Android** (fully supported)
- **iOS** (work in progress)

To support additional platforms:
* A platform-specific folder must be created with default contents.
* A library file built from [libzt](https://github.com/zerotier/libzt) must be included in the corresponding platform build process inside the platform folder.
* `loader.dart` must be updated to include the new platform.

Also see [libzt_flutter GitHub Issues](https://github.com/nuc134r/libzt_flutter/issues).

## Usage

For more detailed usage, see the `example` folder. Also refer to the [ZeroTier Sockets tutorial](https://docs.zerotier.com/sockets/tutorial.html).

Currently, only client TCP sockets are implemented.

```dart
import 'package:libzt_flutter/libzt_flutter.dart';
import 'package:path_provider/path_provider.dart';

Future<void> startNodeAndConnectToNetwork(String networkId) async {
  // obtain node instance
  var node = ZeroTierNode.instance;

  // set persistent storage path to have identity and network configuration cached
  // you can also use initSetIdentity to set identity from memory but network configs won't be cached
  var appDocPath = (await getApplicationDocumentsDirectory()).path + '/zerotier_node';
  node.initSetPath(appDocPath);
  
  // try to start
  var result = node.start();
  if (!result.success) {
    throw Exception('Failed to start node: $result');
  } 
  
  await node.waitForOnline();

  // parse network id from hex string
  var nwId = BigInt.parse(networkId, radix: 16);
  
  // join network
  result = node.join(nwId);
  if (!result.success) {
    throw Exception('Failed to join network: $result');
  }
  
  await node.waitForNetworkReady(nwId);
  await node.waitForAddressAssignment(nwId);
 
  // get network info
  var networkInfo = node.getNetworkInfo(nwId);
  print(networkInfo.name);
  print(networkInfo.address);
  print(networkInfo.id);

  ZeroTierSocket socket;
  try {
    // connect socket
    socket = await ZeroTierSocket.connect('10.144.242.244', 22);
  } catch (e) {
    print('Failed to connect socket: $e');
    socket.close();
    return;
  }
  
  // send data
  socket.sink.add([1, 2, 3, 4, 5]);

  // listen for data
  socket.stream.listen((data) => print('received ${data.length} byte(s)'));

  // detect socket close
  socket.done.then((_) => print('socket closed'));
  
  // don't forget to close sockets
  socket.close();
}
