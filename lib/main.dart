import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://zgymrqnfdcjrrewjphbh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpneW1ycW5mZGNqcnJld2pwaGJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI4NzUzODQsImV4cCI6MjA0ODQ1MTM4NH0.a5ovquvlexvLkY3r6gvTn24vEHO-9_1DA9O95-b0bR8',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
