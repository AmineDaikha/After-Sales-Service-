import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/models/activity.dart';
import 'package:sav_app/models/client.dart';
import 'package:sav_app/models/file_note.dart';
import 'package:sav_app/models/note.dart';
import 'package:sav_app/providers/clients_map_provider.dart';
import 'package:sav_app/providers/note_provider.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/routers.dart';
import 'package:provider/provider.dart';
import 'package:sav_app/widgets/drawers/my_notes_drawer.dart';

import 'dialog_filtred_notes.dart';
import 'add_text_note_page.dart';
import 'text_note_page.dart';

class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});

  static const String routeName = '/notes';

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => NoteListPage(),
    );
  }

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  @override
  initState() {
    super.initState();
    AppUrl.filtredCommandsClient.clients = [Client(id: '-1', name: 'Tout')];
    AppUrl.filtredCommandsClient.client =
        AppUrl.filtredCommandsClient.clients.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLoaderDialog(context);
      _fetchData(context).then((value) {
        Navigator.pop(context);
      });
    });
  }

  Future<void> fetchData() async {
    //print('image: ${AppUrl.baseUrl}${AppUrl.user.image}');
    final provider = Provider.of<NoteProvider>(context, listen: false);
    provider.noteList.clear();
    String url = AppUrl.getAllNotes +
        '?userName=${AppUrl.user.userId}&dateDebut=${DateFormat('yyyy-MM-ddT00:00:00').format(AppUrl.filtredCommandsClient.date)}&dateFin=${DateFormat('yyyy-MM-ddT23:59:59').format(AppUrl.filtredCommandsClient.dateEnd)}';
    print('url : $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res allNote code : ${req.statusCode}");
    print("res allNote body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      List<dynamic> data = json.decode(req.body);
      //data.forEach((element) {
      for (int i = 0; i < data.length; i++) {
        var element = data[i];

        if (DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(element['dateCreation'])) !=
            DateFormat('yyyy-MM-dd')
                .format(AppUrl.filtredCommandsClient.date)) {
          continue;
        }
        //if (element['usersNotes'] == null) continue;
        // List<Collaborator> collaborators = [];
        // List<dynamic> users = element['usersNotes'];
        // bool notExist = false;
        // String collaboratorsTxt = '';
        // users.forEach((user) {
        //   // collaboratorsTxt = collaboratorsTxt + '${user['salCode']} | ';
        //   print('salCodeISS ${user['salCode']}');
        //   if (user['salCode'] ==
        //       AppUrl.filtredCommandsClient.collaborateur!.salCode)
        //     notExist = true;
        // });
        // print(
        //     'notExist $notExist ${AppUrl.filtredCommandsClient.collaborateur!.salCode}');
        // if (notExist == false) continue;
        // print('pcfCode: ${AppUrl.filtredCommandsClient.client!.id}');
        if (AppUrl.filtredCommandsClient.client!.id != '-1') {
          if (AppUrl.filtredCommandsClient.client!.id != element['pcfCode'])
            continue;
        }
        Client client = Client(id: element['pcfCode']);
        url = AppUrl.getFileNote + element['id'].toString();
        print('url : $url');
        req = await http.get(Uri.parse(url), headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
        });
        print("res allDocNote code : ${req.statusCode}");
        print("res allDocNote body: ${req.body}");
        List<FileNote> images = [];
        if (req.statusCode == 200) {
          List<dynamic> docs = json.decode(req.body);
          if (docs.length > 0) {
            for (int j = 0; j < docs.length; j++) {
              try {
                images.add(
                    FileNote(type: docs[j]['type'], path: docs[j]['path']));
              } catch (_) {}
            }
          }
        }
        if (element['type'] == 'txt') {
          print('');
          Note note = Note(
              type: element['type'],
              title: element['nom'],
              text: element['description'],
              client: client,
              collaboratorsTxt: element['userName']);
          //note.collaborators = collaborators;
          print('sizeDocs : ${note.files.length}');
          note.files = images.toList();
          provider.noteList.add(note);
        }

        //});}
      }
      print('sizeIS: ${provider.noteList.length}');
      provider.notifyListeners();
    }
  }

  Future<void> _fetchData(BuildContext context) async {
    print('hhhhhh');
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    provider.filtredClients = [];
    String url = '${AppUrl.tiersPage}?PageNumber=1&PageSize=20';
    print('url : $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res tiers code : ${req.statusCode}");
    print("res tiers body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      for (int i = 0; i < data.toList().length; i++) {
        var element = data.toList()[i];
        print('code client:  ${element['code']}');
        req = await http.get(
            Uri.parse(AppUrl.tiersEcheance +
                '${AppUrl.user.etblssmnt!.code}/${element['code']}'),
            headers: {
              "Accept": "application/json",
              "content-type": "application/json; charset=UTF-8",
              "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
            });
        print("res total code : ${req.statusCode}");
        print("res total body: ${req.body}");
        if (req.statusCode == 200) {
          // double total = 0;
          // List<dynamic> echeances = json.decode(req.body);
          // echeances.toList().forEach((ech) {
          //   total = total + ech['echArecev'] - ech['echRecu'];
          //   print('ech: ${ech['echArecev']}');
          // });
          // LatLng latLng;
          // if (element['longitude'] == null || element['latitude'] == null) {
          //   latLng = LatLng(1.354474457244855, 1.849465150689236);
          // } else {
          //   try {
          //     latLng = LatLng(element['latitude'], element['longitude']);
          //   } catch (e) {
          //     print('latlong err: $e');
          //     latLng = LatLng(1.354474457244855, 1.849465150689236);
          //   }
          // }
          // String? familleId = element['familleId'];
          // String? sFamilleId = element['sFamilleId'];
          // print('TiersFams: ${element['familleId']} ${element['sFamilleId']}');
          // if (familleId != null) {
          //   req = await http
          //       .get(Uri.parse(AppUrl.getFamilly + '$familleId'), headers: {
          //     "Accept": "application/json",
          //     "content-type": "application/json; charset=UTF-8",
          //     "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
          //   });
          //   print("res familleId code : ${req.statusCode}");
          //   print("res familleId body: ${req.body}");
          //   if (req.statusCode == 200) {
          //     print('ddd: ${json.decode(req.body)['lib']}');
          //     familleId = json.decode(req.body)['lib'];
          //   }
          // }
          //
          // if (sFamilleId != null) {
          //   req = await http
          //       .get(Uri.parse(AppUrl.getSFamilly + '$sFamilleId'), headers: {
          //     "Accept": "application/json",
          //     "content-type": "application/json; charset=UTF-8",
          //     "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
          //   });
          //   print("res sfamilleId code : ${req.statusCode}");
          //   print("res sfamilleId body: ${req.body}");
          //   if (req.statusCode == 200) {
          //     sFamilleId = json.decode(req.body)['lib'];
          //   }
          // }
          // print('TiersFams!!: $familleId $sFamilleId');
          AppUrl.filtredCommandsClient.clients.add(Client(
              name: element['rs'],
              type: element['type'],
              name2: element['rs2'],
              phone: element['tel1'],
              phone2: element['tel2'],
              city: element['ville'],
              id: element['code']));
          //provider.notifyListeners();
        }
      }
    }
    provider.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    PageNavigator page = PageNavigator(ctx: context);
    return FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Future is still running, return a loading indicator or some placeholder.
            return AlertDialog(
              content: Container(
                  width: 200,
                  height: 100,
                  child: Image.asset('assets/SAV-Loader.gif')),
            );
          } else if (snapshot.hasError) {
            // There was an error in the future, handle it.
            print('Error: ${snapshot.hasError} ${snapshot.error} ');
            return AlertDialog(
              content: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  // Text('Error: ${snapshot.error}')
                  Text(
                      'Nous sommes désolé, la qualité de votre connexion ne vous permet pas de vous connecter à votre serveur.'
                      ' Veuillez réessayer ultérieurement. Merci'),
                ],
              ),
            );
          } else
            return Scaffold(
                drawer: DrawerNotesPage(),
                appBar: AppBar(
                  iconTheme: IconThemeData(
                    color: Colors.white, // Set icon color to white
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mes notes ',
                        style: Theme.of(context).textTheme.headline3!.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'au : ${DateFormat('yyyy-MM-dd').format(AppUrl.filtredCommandsClient.date)}',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'du : ${DateFormat('yyyy-MM-dd').format(AppUrl.filtredCommandsClient.dateEnd)}, de : ${AppUrl.filtredCommandsClient.collaborateur!.userName}',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      // Text(
                      //   'Clients : ${AppUrl.filtredCommandsClient.client!.name}',
                      //   style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      //       color: Colors.white, fontWeight: FontWeight.bold),
                      // ),
                    ],
                  ),
                  backgroundColor: primaryColor,
                  actions: [
                    IconButton(
                        onPressed: () {
                          //_showDatePicker(context);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return FiltredNotesDialog();
                            },
                          ).then((value) {
                            setState(() {});
                          });
                        },
                        icon: Icon(
                          Icons.sort,
                          color: Colors.white,
                        ))
                  ],
                ),
                floatingActionButton:
                FloatingActionButton(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(50.0), // Set FAB shape to circle
                  ),
                  backgroundColor: primaryColor,
                  onPressed: () {
                    page
                        .nextPage(
                        page: AddTextNotePage(
                            visible: true,
                            client: Client(),
                            note: Note(
                              type: Note.TEXT,
                            )))
                        .then((value) {
                      setState(() {});
                    });
                  },
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
                body:
                    Consumer<NoteProvider>(builder: (context, notes, snapshot) {
                  if (notes.noteList.length == 0)
                    return Center(
                        child: Text(
                      'Aucune note !',
                      style: Theme.of(context).textTheme.headline3,
                    ));
                  else
                    return ListView.builder(
                        padding: EdgeInsets.all(12),
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) =>
                            NoteItem(note: notes.noteList.toList()[index]),
                        // separatorBuilder: (BuildContext context, int index) {
                        //   return Divider(
                        //     color: Colors.grey,
                        //   );
                        // },
                        itemCount: notes.noteList.length);
                }));
        });
  }
}

class NoteItem extends StatefulWidget {
  const NoteItem({super.key, required this.note});

  final Note note;

  @override
  State<NoteItem> createState() => _NoteItemState();
}

class _NoteItemState extends State<NoteItem> {
  late Icon icon;

  @override
  void initState() {
    super.initState();
    print('sizeeee: ${widget.note.client!.id}');
    if (widget.note.type == 'vocal') {
      icon = Icon(
        Icons.mic_none_outlined,
        color: primaryColor,
      );
    } else if (widget.note.type == 'photo') {
      icon = Icon(
        Icons.image_outlined,
        color: primaryColor,
      );
    } else if (widget.note.type == 'video') {
      icon = Icon(
        Icons.video_camera_back_outlined,
        color: primaryColor,
      );
    } else if (widget.note.type == Note.TEXT) {
      icon = Icon(
        Icons.text_snippet_outlined,
        color: primaryColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('path: ${widget.note.files}');
    PageNavigator page = PageNavigator(ctx: context);
    return GestureDetector(
      onTap: () {
        if (widget.note.type == Note.TEXT) {
          page.nextPage(
              page: TextNotePage(
            note: widget.note,
            visible: false,
          ));
        }
      },
      child: Column(
        children: [
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.note.title!,
                    style: Theme.of(context)
                        .textTheme
                        .headline4!
                        .copyWith(fontWeight: FontWeight.bold)),
                Text('${widget.note.text}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.headline6),
              ],
            ),
            leading: icon,
          ),
          Divider(
            color: Colors.grey,
          )
        ],
      ),
    );
    // return Column(
    //   children: [
    //     Container(
    //       height: 70,
    //       child: Row(
    //         //mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [
    //           icon,
    //           Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text('${widget.note.type}'),
    //             ],
    //           ),
    //         ],
    //       ),
    //     ),
    //     Divider(
    //       color: Colors.grey,
    //     )
    //   ],
    // );
    ;
  }
}

showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Container(
        width: 200,
        height: 100,
        child: Image.asset('assets/SAV-Loader.gif')),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
