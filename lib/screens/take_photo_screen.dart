import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../storage/local_document_storage.dart';
import 'camera_capture_screen.dart';
import 'documents_screen.dart';

class TakePhotoScreen extends StatefulWidget {
  const TakePhotoScreen({super.key});

  @override
  State<TakePhotoScreen> createState() => _TakePhotoScreenState();
}

class _TakePhotoScreenState extends State<TakePhotoScreen> {
  final TextEditingController fileNameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  String? _imagePath;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (!mounted) return;

    if (picked != null) {
      dateController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Future<void> _openCamera() async {
    final path = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const CameraCaptureScreen()),
    );

    if (!mounted) return;

    if (path != null && path.isNotEmpty) {
      setState(() => _imagePath = path);
    }
  }

  Future<void> _showUploadedPopup() async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Center(
          child: Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: SvgPicture.asset(
              "assets/images/details_uploaded.svg",
              width: 200,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  Future<void> _onUploadPressed() async {
    final name = fileNameController.text.trim();
    final date = dateController.text.trim();

    if (_imagePath == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please take a photo first")),
        );
      }
      return;
    }

    if (name.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter file name")),
        );
      }
      return;
    }

    if (date.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select date")),
        );
      }
      return;
    }

    final id =
        "${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}";

    final doc = DocumentItem(
      id: id,
      fileName: name,
      date: date,
      imagePath: _imagePath!,
      createdAt: DateTime.now(),
    );

    await LocalDocumentStorage.addDocument(doc);

    if (!mounted) return;

    setState(() {
      _imagePath = null;
      fileNameController.clear();
      dateController.clear();
    });

    await _showUploadedPopup();
  }

  void _openDocuments() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DocumentsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // BOTTOM NAV BAR
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
                // Upload active
                Container(
                  width: 132,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5A78DB),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/upload_arrow_small.svg",
                        width: 34,
                        height: 27,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "Upload",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // File inactive
                GestureDetector(
                  onTap: _openDocuments,
                  child: Container(
                    width: 136,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 6),
                        Text(
                          "File",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // MAIN UI BODY
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 150),
          child: Column(
            children: [
              const SizedBox(height: 16),

              const Text(
                "Tack Photo & Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5A78DB),
                ),
              ),

              const SizedBox(height: 18),

              // IMAGE PREVIEW BOX
              Container(
                width: 323,
                height: 323,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF5A78DB),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _imagePath == null
                      ? Image.asset(
                          "assets/images/illustration.png",
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(_imagePath!),
                          fit: BoxFit.cover,
                        ),
                ),
              ),

              const SizedBox(height: 22),

              // CAMERA BUTTON
              GestureDetector(
                onTap: _openCamera,
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/icons/camera_icon2.svg",
                      width: 34,
                      height: 34,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // FILE NAME LABEL (const)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "File Name",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8C8C8C),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // FILE NAME FIELD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  width: 335,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFDBDBDB),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: fileNameController,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter file name",
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8C8C8C),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // DATE LABEL (fixed const!)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Date",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8C8C8C),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // DATE FIELD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  width: 335,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFDBDBDB),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: TextField(
                            controller: dateController,
                            readOnly: true,
                            onTap: _pickDate,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "DD/MM/YYYY",
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8C8C8C),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: SvgPicture.asset(
                          "assets/icons/calender.svg",
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // MAIN UPLOAD BUTTON
              GestureDetector(
                onTap: _onUploadPressed,
                child: Container(
                  width: 335,
                  height: 47,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5A78DB),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/upload_arrow_upper.svg",
                        width: 34,
                        height: 27,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Upload",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
