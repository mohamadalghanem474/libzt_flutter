import 'dart:async';
import 'package:flutter/material.dart';
import 'package:libzt_flutter/libzt_flutter.dart';
import 'zt_http.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ZtHttp.init(networkId: '9f77fc393ec1bb8a');
  runApp(const MyApp());
}

Widget statusNetwork = StreamBuilder<NetworkStatus>(
  initialData: NetworkStatus.unknown,
  stream:
      Stream.periodic(const Duration(seconds: 1), (_) => ZtHttp.networkStatus),
  builder: (context, snapshot) {
    return Text(snapshot.data == NetworkStatus.unknown ? 'Loading' : snapshot.data.toString());
  },
);

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
  final List<ZtHttpResponse> _responses = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: statusNetwork,
      ),
      body: SafeArea(
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _isLoading ? _responses.length + 1 : _responses.length,
          itemBuilder: (context, index) {
            if (index == _responses.length) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_responses[index].data),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            _isLoading = true;
          });

          final response = await ZtHttp.get(
            host: '172.30.224.224',
            port: 3000,
            path: '/',
          );

          setState(() {
            _isLoading = false;
            _responses.add(response);
          });
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        },
        tooltip: 'Send Data',
        child: const Icon(Icons.send),
      ),
    );
  }
}
