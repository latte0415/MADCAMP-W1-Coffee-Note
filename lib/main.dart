import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dev/seed_test_data.dart';
import 'main_page.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await seedTestData(); // 한 번 호출 후 테스트 끝나면 제거
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Note',
      theme: AppTheme.lightTheme,
      home: const MainPage(),
    );
  }
}
