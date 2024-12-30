import 'loader.dart';
import 'libzt_flutter_bindings_generated.dart';

/// Top level declaration so that it can be accessed in another isolate
final LibztFlutterBindings zts = ZeroTierNativeLoader.load();
