import 'dart:ffi';
import 'dart:io';

import 'libzt_flutter_bindings_generated.dart';


abstract class ZeroTierNativeLoader {
  static LibztFlutterBindings load() {
    DynamicLibrary? lib;

    if (Platform.isAndroid) {
      lib = DynamicLibrary.open('libzt.so');
    }

    if (lib == null) {
      throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
    }

    return LibztFlutterBindings(lib);
  }
}
