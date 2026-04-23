import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import './screen/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const FinanceApp());
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Keuangan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E3D9A),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E3D9A),
          foregroundColor: Colors.white,
        ),
      ),
      builder: (context, child) {
        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 375),
            child: child,
          ),
        );
      },
      home: const HomeScreen(),
    );
  }
}
