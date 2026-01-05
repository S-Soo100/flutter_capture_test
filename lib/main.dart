import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screen Capture Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CapturePage(),
    );
  }
}

class CapturePage extends StatefulWidget {
  const CapturePage({super.key});

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  final GlobalKey _captureKey = GlobalKey();

  Future<Uint8List?> _captureWidget() async {
    try {
      print('캡처 시작');

      RenderRepaintBoundary boundary =
          _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      print('RenderRepaintBoundary 획득 성공');

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      print('이미지 변환 성공');

      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      print('PNG 데이터 변환 성공: ${pngBytes.length} bytes');

      return pngBytes;
    } catch (e, stackTrace) {
      print('캡처 실패 - 에러: $e');
      print('스택 트레이스:\n$stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('캡처 실패: $e')),
        );
      }
      return null;
    }
  }

  Future<void> _captureAndShare() async {
    final pngBytes = await _captureWidget();
    if (pngBytes == null) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/capture.png');
      await file.writeAsBytes(pngBytes);
      print('파일 저장 성공: ${file.path}');

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '캡처된 이미지',
      );
      print('공유 완료');
    } catch (e, stackTrace) {
      print('공유 실패 - 에러: $e');
      print('스택 트레이스:\n$stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('공유 실패: $e')),
        );
      }
    }
  }

  Future<void> _saveToGallery() async {
    final pngBytes = await _captureWidget();
    if (pngBytes == null) return;

    try {
      final result = await ImageGallerySaver.saveImage(
        pngBytes,
        quality: 100,
        name: 'capture_${DateTime.now().millisecondsSinceEpoch}',
      );
      print('갤러리 저장 결과: $result');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진 라이브러리에 저장되었습니다!')),
        );
      }
    } catch (e, stackTrace) {
      print('갤러리 저장 실패 - 에러: $e');
      print('스택 트레이스:\n$stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('갤러리 저장 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('화면 캡처 데모'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RepaintBoundary(
              key: _captureKey,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade400,
                      Colors.purple.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '캡처할 영역',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '이 위젯이 캡처됩니다',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _saveToGallery,
                  icon: const Icon(Icons.save),
                  label: const Text('사진에 저장'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _captureAndShare,
                  icon: const Icon(Icons.share),
                  label: const Text('공유'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
