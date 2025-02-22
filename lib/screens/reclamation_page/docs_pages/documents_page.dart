import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/models/Document.dart';
import 'package:sav_app/models/client.dart';
import 'package:sav_app/screens/reclamation_page/docs_pages/image_page.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/routers.dart';
import 'package:sav_app/utils/snack_message.dart';

import 'add_doc_page.dart';
import 'pdf_page.dart';

class DocsPage extends StatefulWidget {
  final Client client;

  DocsPage({super.key, required this.client});

  @override
  State<DocsPage> createState() => _DocsPageState();
}

class _DocsPageState extends State<DocsPage> {
  List<Document> docs = [];

  void reload() {
    setState(() {});
  }

  Future<void> fetchDataDocs() async {
    docs = [];
    String url = AppUrl.docs + '?demNumero=${widget.client.resOppo['numero']}';
    //String url = AppUrl.docs + '?demNumero=DEM021';
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res docs code : ${req.statusCode}");
    print("res docs body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      //activitiesProcesses[process] = types;
      print('efrfr : ${data.length}');
      //data.toList().forEach((element) {
      for (int i = 0; i < data.length; i++) {
        var element = data[i];
        try {
          print('elemnt : $element');
          Document document = Document(
            type: element['categ'],
            path: element['path'],
            name: element['nom'],
            dateCreate: DateTime.parse(element['dateCreation']),
          );
          document.res = element;
          docs.add(document);
        } catch (e) {
          print('errrrrr $e');
          continue;
        }
      }
      //});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchDataDocs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Future is still running, return a loading indicator or some placeholder.
            return AlertDialog(
              content: Container(
                  width: 200,
                  height: 100,
                  child: Image.asset('assets/SAV-Loader.gif')),
            );
          }
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
              iconTheme: IconThemeData(
                color: Colors.white, // Set icon color to white
              ),
              title: ListTile(
                title: Text(
                  'Liste des documents : ',
                  style: Theme.of(context)
                      .textTheme
                      .headline3!
                      .copyWith(color: Colors.white),
                ),
                subtitle: Text(
                  '${widget.client.name}',
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: primaryColor,
              onPressed: () {
                PageNavigator(ctx: context)
                    .nextPage(
                        page: FileUploadPage(
                  client: widget.client,
                ))
                    .then((value) {
                  setState(() {});
                });
              },
              child: Icon(Icons.add, color: Colors.white,), // Add icon
            ),
            body: Container(
              height: AppUrl.getFullHeight(context) * 0.8,
              padding: EdgeInsets.only(top: 20, right: 10, left: 10),
              child: (docs.length > 0)
                  ? ListView.builder(
                      padding: EdgeInsets.all(12),
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) => DocumentItem(
                          callback: reload,
                          docs: docs,
                          document: docs.toList()[index]),
                      itemCount: docs.length)
                  : Center(
                      child: Text(
                        'Aucun document !',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
              // ? ListView.separated(
              //     itemCount: contacts.length,
              //     itemBuilder: (context, index) {
              //       return VisitorItem(
              //         contact: contacts[index],
              //         callback: reload,
              //         contacts: contacts,
              //       );
              //     },
              //     separatorBuilder: (BuildContext context, int index) {
              //       return Container(
              //         height: 5,
              //       );
              //     },
              //   )
              // : Center(
              //     child: Text(
              //       'Aucune adresse !',
              //       style: Theme.of(context).textTheme.headline5!.copyWith(
              //             fontWeight: FontWeight.bold,
              //           ),
              //     ),
              //   ),
            ),
          );
        });
  }
}

class DocumentItem extends StatefulWidget {
  final Document document;
  final List<Document> docs;
  final VoidCallback callback;

  const DocumentItem(
      {super.key,
      required this.document,
      required this.docs,
      required this.callback});

  @override
  State<DocumentItem> createState() => _DocumentItemState();
}

class _DocumentItemState extends State<DocumentItem> {
  Icon icon = Icon(
    Icons.file_present_outlined,
    color: primaryColor,
  );

  @override
  void initState() {
    super.initState();
    if (widget.document.type.toLowerCase() == 'jpg' ||
        widget.document.type.toLowerCase() == 'png') {
      icon = Icon(
        Icons.image_outlined,
        color: primaryColor,
      );
    } else if (widget.document.type.toLowerCase() == 'pdf') {
      icon = Icon(
        Icons.picture_as_pdf_outlined,
        color: primaryColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        print('path:: ${AppUrl.baseUrl}${widget.document.path}');
        if (widget.document.type.toLowerCase() == 'jpg' ||
            widget.document.type.toLowerCase() == 'png') {
         PageNavigator(ctx: context).nextPage(page: FullScreenImagePage(link: '${AppUrl.baseUrl}${widget.document.path}',));
        } else if (widget.document.type.toLowerCase() == 'pdf') {
          PageNavigator(ctx: context).nextPage(page: FullScreenPdfViewPage(url: '${AppUrl.baseUrl}${widget.document.path}',));
        }else{
          showMessage(
              message: 'Ce type de fichier n\'est pas supporté !',
              context: context,
              color: Colors.red);
        }
      },
      child: Column(
        children: [
          Container(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                icon,
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (widget.document.name != null)
                        ? Container(
                            width: AppUrl.getFullWidth(context) * 0.6,
                            child: Text(
                              widget.document.name!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(color: primaryColor),
                            ),
                          )
                        : Text('Nom de document',
                            style: Theme.of(context)
                                .textTheme
                                .headline5!
                                .copyWith(color: Colors.black)),
                    Row(
                      children: [
                        Icon(Icons.calendar_month_outlined,
                            color: primaryColor, size: 20),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                            '${DateFormat('dd-MM-yyyy').format(widget.document.dateCreate)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith()),
                        SizedBox(
                          width: 20,
                        ),
                        Icon(Icons.access_time, color: primaryColor, size: 20),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                            '${DateFormat('HH:mm').format(widget.document.dateCreate)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith()),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          Divider(
            color: Colors.grey,
          )
        ],
      ),
    );
  }
}
