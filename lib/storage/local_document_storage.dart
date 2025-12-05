import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class DocumentItem {
  final String id;
  final String fileName;
  final String date;      // DD/MM/YYYY
  final String imagePath; // local file path
  final DateTime createdAt;

  DocumentItem({
    required this.id,
    required this.fileName,
    required this.date,
    required this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'date': date,
        'imagePath': imagePath,
        'createdAt': createdAt.toIso8601String(),
      };

  factory DocumentItem.fromJson(Map<String, dynamic> json) => DocumentItem(
        id: json['id'] as String,
        fileName: json['fileName'] as String,
        date: json['date'] as String,
        imagePath: json['imagePath'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class LocalDocumentStorage {
  static const _fileName = 'documents.json';

  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/$_fileName';
    return File(path);
  }

  static Future<List<DocumentItem>> loadDocuments() async {
    final file = await _getFile();
    if (!await file.exists()) return [];

    final content = await file.readAsString();
    if (content.trim().isEmpty) return [];

    final List<dynamic> list = jsonDecode(content) as List<dynamic>;
    return list
        .map((e) => DocumentItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> addDocument(DocumentItem doc) async {
    final docs = await loadDocuments();
    docs.add(doc);
    final file = await _getFile();
    final encoded = jsonEncode(docs.map((d) => d.toJson()).toList());
    await file.writeAsString(encoded);
  }
}
