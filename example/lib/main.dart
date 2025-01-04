import 'package:flutter/material.dart';
import 'package:libzt_flutter/libzt_flutter.dart';

import 'zt_http.dart';
import 'zt_node.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZeroTier Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  ZeroTierNetwork? _networkInfo;
  String _response = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    ZtNode.instance.init(networkId: '9f77fc393ec1bb8a').then((network) {
      setState(() {
        _networkInfo = network;
      });
    }).catchError((e) {
      debugPrint('Error: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZeroTier Flutter App'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            if (_networkInfo != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Network Info: ${_networkInfo.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            if (_networkInfo == null)
              const Text(
                'Loading network information...',
                style: TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator(),
            if (!_isLoading && _response.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Response: $_response',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            if (!_isLoading && _response.isEmpty)
              const Text(
                'No response yet...',
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            _isLoading = true;
          });

          final response = await ZtHttp().request(
            host: '172.30.224.224',
            port: 3000,
            method: 'GET',
            path: '/',
          );

          setState(() {
            _isLoading = false;
            _response =
                response?.toString() ?? 'No response';
          });
        },
        tooltip: 'Send Data',
        child: const Icon(Icons.add),
      ),
    );
  }
}
