import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sav_app/utils/snack_message.dart';

class PdfPage extends StatefulWidget {

  final String link;

  const PdfPage({super.key, required this.link});

  @override
  _PdfPageState createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  String? localPath;
  bool isLoading = true;
  int? pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    downloadPdf();
  }

  Future<void> downloadPdf() async {
    try {
      final url = '${widget.link}';
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/downloaded.pdf');
      await file.writeAsBytes(bytes, flush: true);

      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      print("Error downloading PDF: $e");
      setState(() {
        isLoading = false;
        //errorMessage = 'Failed to load PDF';
        Navigator.pop(context);
        showMessage(
            message: 'Échec d\'afficher le PDF !',
            context: context,
            color: Colors.red);
      });
    }
  }

  void _searchInPdf(String query) {
    // This is a placeholder for the search function.
    // PDF search is not natively supported by flutter_pdfview.
    // Implement your own search or use another package if needed.
    print('Searching for: $query');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearchDialog(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          isLoading
              ? Center(child: CircularProgressIndicator())
              : localPath != null
              ? PDFView(
            filePath: localPath!,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: false,
            fitPolicy: FitPolicy.BOTH,
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
              });
            },
            onViewCreated: (PDFViewController pdfViewController) {
              pdfViewController.setPage(currentPage);
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                currentPage = page!;
              });
            },
            onError: (error) {
              print(error.toString());
            },
            onPageError: (page, error) {
              print('$page: ${error.toString()}');
            },
          )
              : Center(child: Text(errorMessage)),
          if (!isReady)
            Center(
              child: CircularProgressIndicator(),
            )
          else
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        currentPage = currentPage > 0 ? currentPage - 1 : 0;
                      });
                    },
                  ),
                  Text(
                    '${currentPage + 1} / $pages',
                    style: TextStyle(color: Colors.white),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () {
                      setState(() {
                        currentPage = currentPage < pages! - 1
                            ? currentPage + 1
                            : pages! - 1;
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search in PDF'),
          content: TextField(
            controller: _searchController,
            decoration: InputDecoration(hintText: 'Enter search query'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _searchInPdf(_searchController.text);
                Navigator.of(context).pop();
              },
              child: Text('Search'),
            ),
          ],
        );
      },
    );
  }
}