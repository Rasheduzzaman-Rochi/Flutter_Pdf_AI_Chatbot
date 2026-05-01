import 'dart:io';

class ApiConstants {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://127.0.0.1:8000';
  }

  static String get uploadPdf => '$baseUrl/upload-pdf';
  static String get askQuestion => '$baseUrl/ask';
}
