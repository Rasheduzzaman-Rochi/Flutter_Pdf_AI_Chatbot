import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PdfChatApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  // 🔹 PDF upload
  Future<String> uploadPdf(File file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload-pdf'),
    );

    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    final data = jsonDecode(body);
    return data['document_id'];
  }

  // 🔹 Ask question
  Future<String> askQuestion({
    required String documentId,
    required String question,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ask'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'document_id': documentId,
        'question': question,
      }),
    );

    final data = jsonDecode(response.body);
    return data['answer'];
  }
}