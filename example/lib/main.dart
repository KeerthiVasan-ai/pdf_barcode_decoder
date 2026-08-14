import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_barcode_decoder/pdf_barcode_decoder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<PdfBarcode> _barcodes = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _pickAndScanPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isLoading = true;
          _error = null;
          _barcodes = [];
        });
        
        final path = result.files.single.path!;
        final barcodes = await PdfBarcodeDecoder.decodeFile(
          File(path),
          config: const DecoderConfig(
            dpi: 300,
            formats: [BarcodeFormat.all],
          ),
        );
        debugPrint('Decoded barcodes from file: $barcodes');
        for (var b in barcodes) {
          debugPrint('Barcode: value=${b.value}, type=${b.type.name}, page=${b.page}');
        }
        setState(() {
          _barcodes = barcodes;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _scanAsset() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _barcodes = [];
      });
      
      final barcodes = await PdfBarcodeDecoder.decodeAsset(
        'assets/sample_qr.pdf',
        config: const DecoderConfig(
          dpi: 300,
          formats: [BarcodeFormat.all],
        ),
      );
      debugPrint('Decoded barcodes from asset: $barcodes');
      for (var b in barcodes) {
        debugPrint('Barcode: value=${b.value}, type=${b.type.name}, page=${b.page}');
      }
      setState(() {
        _barcodes = barcodes;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PDF Barcode Decoder'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _pickAndScanPdf,
                      child: const Text('Pick PDF'),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _scanAsset,
                      child: const Text('Scan Asset PDF'),
                    ),
                ],
              ),
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: $_error', style: const TextStyle(color: Colors.red)),
              )
            else if (_barcodes.isEmpty)
              const Expanded(
                child: Center(child: Text('No barcodes found or no PDF selected.')),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _barcodes.length,
                  itemBuilder: (context, index) {
                    final b = _barcodes[index];
                    return ListTile(
                      title: Text(b.value),
                      subtitle: Text('Type: ${b.type.name} | Page: ${b.page}'),
                      trailing: Text('${b.boundingBox.width.toInt()}x${b.boundingBox.height.toInt()}'),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
