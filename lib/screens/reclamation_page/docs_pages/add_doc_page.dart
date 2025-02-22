import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/models/client.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/snack_message.dart';
import 'package:path/path.dart' as p;

class FileUploadPage extends StatefulWidget {
  Client client;

  FileUploadPage({super.key, required this.client});

  @override
  _FileUploadPageState createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  File? selectedFile;
  bool isLoading = false;
  String uploadMessage = '';

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        print('type isss: ${selectedFile!.path.split('.').last}');
      });
    } else {
      setState(() {
        uploadMessage = 'File selection canceled';
      });
    }
  }

  Future<void> _uploadFile() async {
    if (selectedFile == null) return;

    setState(() {
      isLoading = true;
      uploadMessage = '';
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse('${AppUrl.docs}'));
      request.headers['Accept'] = 'application/json';
      request.headers['content-type'] = 'application/json; charset=UTF-8';
      request.headers['Referer'] =
          "http://" + AppUrl.user.company! + ".localhost:4200/";
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        // The name attribute from the server-side that represents the file
        selectedFile!.path,
      ));
      Map<String, dynamic> jsonDoc = {
        "nom": '${p.basename(selectedFile!.path)}',
        "categ": '${selectedFile!.path.split('.').last}',
        "demNumero": '${'${widget.client.resOppo['numero']}'}',
        "dateCreation": DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()).toString()
      };
      request.fields['document'] = jsonEncode(jsonDoc);
      print('obj json: ${request.fields}');
      print('url: ${request.url}');
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print("res doc code : ${response.statusCode}");
      print("res doc body: ${responseBody}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          showMessage(
              message: 'Le document a été chargé avec succès !',
              context: context,
              color: primaryColor);
          uploadMessage = 'Le document a été chargé avec succès !';
          Navigator.pop(context);
        }); // show message
      } else {
        // sow message
        setState(() {
          uploadMessage = 'Le chargement du document a échoué !';
        });
      }
    } catch (e, stackTrace) {
      setState(() {
        uploadMessage = 'Le chargement du document a échoué !';
        print('${e}');
        print('Stack Trace: $stackTrace');
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set icon color to white
        ),
        title: Text(
          'Chargement de document',
          style: Theme.of(context)
              .textTheme
              .headline3!
              .copyWith(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _pickFile,
                child: Text(
                  'Choisissez un document',
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(color: primaryColor),
                ),
              ),
              SizedBox(height: 16),
              selectedFile != null
                  ? Text(
                      'Document sélectionné : ${selectedFile!.path.split('/').last}',
                      style: Theme.of(context).textTheme.headline5!.copyWith(),
                    )
                  : Text(
                      'Aucun document sélectionné',
                      style: Theme.of(context).textTheme.headline5!.copyWith(),
                    ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : _uploadFile,
                child: isLoading
                    ? CircularProgressIndicator(
                        color: primaryColor,
                      )
                    : Text(
                        'Charger le document',
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .copyWith(color: primaryColor),
                      ),
              ),
              SizedBox(height: 16),
              Text(
                uploadMessage,
                style: Theme.of(context)
                    .textTheme
                    .headline4!
                    .copyWith(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
