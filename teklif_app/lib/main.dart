import 'package:flutter/material.dart';
import 'screens/giris_ekrani.dart';
import 'utils/constants.dart';

void main() {
  runApp(const TeklifApp());
}

class TeklifApp extends StatelessWidget {
  const TeklifApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teklif Sistemi',
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
