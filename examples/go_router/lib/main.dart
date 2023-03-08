import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wiredash/wiredash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Wiredash(
      projectId: '',
      secret: '',
      child: MaterialApp.router(
        color: Colors.white,
        routerConfig: router,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0000FF),
        title: const Text('WidgetsApp'),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(32),
              child: TextField(),
            ),
            ElevatedButton(
              onPressed: () {
                Wiredash.of(context).show();
              },
              child: const Text('Open Wiredash'),
            ),
          ],
        ),
      ),
    );
  }
}
