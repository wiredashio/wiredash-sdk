import 'package:flutter/material.dart';
import 'package:wiredash/wiredash.dart';

void main() {
  runApp(const WiredashWasmApp());
}

class WiredashWasmApp extends StatelessWidget {
  const WiredashWasmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Wiredash(
      projectId: 'Project ID from console.wiredash.io',
      secret: 'API Key from console.wiredash.io',
      child: MaterialApp(
        title: 'Wiredash Wasm Sample',
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wiredash on Wasm')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Compiled with dart2wasm'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Wiredash.of(context).show(),
              child: const Text('Show Wiredash'),
            ),
          ],
        ),
      ),
    );
  }
}
