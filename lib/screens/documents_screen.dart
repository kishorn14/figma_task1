import 'dart:io';

import 'package:flutter/material.dart';
import '../storage/local_document_storage.dart';
import 'document_details_screen.dart';
import 'take_photo_screen.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  bool _loading = true;
  List<DocumentItem> _docs = [];

  @override
  void initState() {
    super.initState();
    _loadDocs();
  }

  Future<void> _loadDocs() async {
    final docs = await LocalDocumentStorage.loadDocuments();
    docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    setState(() {
      _docs = docs;
      _loading = false;
    });
  }

  void _goToUpload() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TakePhotoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: SafeArea(
        child: Container(
          height: 96,
          alignment: Alignment.center,
          child: Container(
            width: 304,
            height: 74,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(40),
            ),
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Upload inactive
                GestureDetector(
                  onTap: _goToUpload,
                  child: Container(
                    width: 132,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload, size: 22),
                        SizedBox(width: 6),
                        Text(
                          "Upload",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // File active
                Container(
                  width: 136,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5A78DB),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description,
                          size: 22, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        "File",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      appBar: AppBar(
        title: const Text(
          'Documents',
          style: TextStyle(
            color: Color(0xFF5A78DB),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF5A78DB)),
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _docs.isEmpty
              ? const Center(
                  child: Text(
                    'No documents yet',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  itemCount: _docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = _docs[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DocumentDetailsScreen(document: doc),
                          ),
                        );
                      },
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFDBDBDB),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            // Image
                            Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.75),
                                color: const Color(0xFFEFEFEF),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6.75),
                                child: File(doc.imagePath).existsSync()
                                    ? Image.file(
                                        File(doc.imagePath),
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        "assets/images/illustration.png",
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Texts
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    doc.fileName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    doc.date,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF8C8C8C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
