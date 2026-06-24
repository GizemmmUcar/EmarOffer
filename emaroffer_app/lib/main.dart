import 'package:flutter/material.dart';
import 'screens/giris_ekrani.dart';
import 'utils/constants.dart';

void main() {
  runApp(const emarofferApp());
}

class emarofferApp extends StatelessWidget {
  const emarofferApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emar Offer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppConstants.anaRenk,
        scaffoldBackgroundColor: AppConstants.arkaplanRengi,
      ),
      home: const GirisEkrani(),
    );
  }
}
