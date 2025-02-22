import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/snack_message.dart';

class ImagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Web Image Display'),
      ),
      body: Center(
        child: Image.network(
          'https://media2.ledevoir.com/images_galerie/nwd_1484262_1137769/image.jpg',
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              return CircularProgressIndicator(
                color: primaryColor,
              );
            }
          },
          errorBuilder: (context, error, stackTrace) {
            return Text('Failed to load image');
          },
        ),
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String link;

  const FullScreenImagePage({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              //'https://media2.ledevoir.com/images_galerie/nwd_1484262_1137769/image.jpg',
              '$link',
              fit: BoxFit.cover, // Ensures the image covers the entire screen
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return Center(
                      child: CircularProgressIndicator(
                    color: primaryColor,
                  ));
                }
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(child: Text('Échec du chargement de l\'image'));
              },
            ),
          ),
          AppBar(
            iconTheme: IconThemeData(
              color: Colors.white, // Set icon color to white
            ),
            backgroundColor: Colors.transparent, // Transparent AppBar
            elevation: 0,
          ),
        ],
      ),
    );
  }
}

class FullScreenPdfViewPage extends StatefulWidget {
  final String url;

  FullScreenPdfViewPage({super.key, required this.url});

  @override
  _FullScreenPdfViewPageState createState() => _FullScreenPdfViewPageState();
}

class _FullScreenPdfViewPageState extends State<FullScreenPdfViewPage> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    downloadPdf();
  }

  Future<void> downloadPdf() async {
    try {
      //final url = 'https://pdfobject.com/pdf/sample.pdf';
      final response = await http.get(Uri.parse(widget.url));
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
      Navigator.pop(context);
      showMessage(
          message: 'Échec d\'afficher le PDF !',
          context: context,
          color: Colors.red);
      // setState(() {
      //   isLoading = false;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: primaryColor,
            ))
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
                      isLoading = false;
                    });
                  },
                  onError: (error) {
                    print(error.toString());
                  },
                  onPageError: (page, error) {
                    print('$page: ${error.toString()}');
                  },
                )
              : Center(child: Text('Failed to load PDF')),
    );
  }
}

class PdfViewPage extends StatefulWidget {
  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    downloadPdf();
  }

  Future<void> downloadPdf() async {
    try {
      final url = 'https://pdfobject.com/pdf/sample.pdf';
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: primaryColor,
            ))
          : localPath != null
              ? PDFView(
                  filePath: localPath!,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: false,
                  pageFling: false,
                  onRender: (_pages) {
                    setState(() {
                      isLoading = false;
                    });
                  },
                  onError: (error) {
                    print(error.toString());
                  },
                  onPageError: (page, error) {
                    print('$page: ${error.toString()}');
                  },
                )
              : Center(child: Text('Failed to load PDF')),
    );
  }
}

// class PdfViewPage extends StatefulWidget {
//   @override
//   _PdfViewPageState createState() => _PdfViewPageState();
// }
//
// class _PdfViewPageState extends State<PdfViewPage> {
//   String? localPath;
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     downloadPdf();
//   }
//
//   Future<void> downloadPdf() async {
//     try {
//       final url = 'https://example.com/your-pdf-file.pdf';
//       final response = await http.get(Uri.parse(url));
//       final bytes = response.bodyBytes;
//
//       final dir = await getApplicationDocumentsDirectory();
//       final file = File('${dir.path}/downloaded.pdf');
//       await file.writeAsBytes(bytes, flush: true);
//
//       setState(() {
//         localPath = file.path;
//         isLoading = false;
//       });
//     } catch (e) {
//       print("Error downloading PDF: $e");
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('PDF Viewer'),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : localPath != null
//           ? PDFView(
//         filePath: localPath!,
//         enableSwipe: true,
//         swipeHorizontal: true,
//         autoSpacing: false,
//         pageFling: false,
//         onRender: (_pages) {
//           setState(() {
//             isLoading = false;
//           });
//         },
//         onError: (error) {
//           print(error.toString());
//         },
//         onPageError: (page, error) {
//           print('$page: ${error.toString()}');
//         },
//       )
//           : Center(child: Text('Failed to load PDF')),
//     );
//   }
// }
