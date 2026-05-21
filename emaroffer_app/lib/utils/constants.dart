import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  static String get apiUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else {
      return 'http://localhost:3000';
    }
  }

  static const Color arkaplanRengi = Color(0xFFF3F4F6);
  static const Color anaRenk = Colors.indigo;
}
