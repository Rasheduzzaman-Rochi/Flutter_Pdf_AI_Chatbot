import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/pdf_chat/presentation/screens/home_screen.dart';

class PdfChatBotApp extends StatelessWidget {
  const PdfChatBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Chatbot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}