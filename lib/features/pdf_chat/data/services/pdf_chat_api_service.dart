import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../../../../../core/constants/api_constants.dart';

class PdfChatApiService {
  Future<String> uploadPdf(File file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstants.uploadPdf),
    );

    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('PDF upload failed');
    }

    final data = jsonDecode(body);
    return data['document_id'];
  }

  Future<String> askQuestion({
    required String documentId,
    required String question,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.askQuestion),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'document_id': documentId,
        'question': question,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get answer');
    }

    final data = jsonDecode(response.body);
    return data['answer'];
  }
}