import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/models/client.dart';
import 'package:sav_app/models/depot.dart';
import 'package:sav_app/models/familly.dart';
import 'package:sav_app/models/sfamilly.dart';
import 'package:sav_app/providers/clients_map_provider.dart';
import 'package:sav_app/screens/reclamation_page/demands_fragment.dart';
import 'package:sav_app/screens/reclamation_page/interventions_fragment.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/widgets/appbars/reclamation_appbar.dart';
import 'package:sav_app/widgets/drawers/reclamation_drawer.dart';

import 'attachments_fragment.dart';
import 'proc_fragment.dart';

class ReclamationPage extends StatefulWidget {

  final String? numSerie;
  const ReclamationPage({super.key, this.numSerie});

  static const String routeName = '/reclamation';

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => ReclamationPage(),
    );
  }

  @override
  State<ReclamationPage> createState() => _ReclamationPageState();
}

class _ReclamationPageState extends State<ReclamationPage> {
  @override
  void initState() {
    super.initState();
    print('equipe size: ${AppUrl.user.teams.length}');
    print('salCode: ${AppUrl.user.salCode}');
    print('collaborators size: ${AppUrl.user.collaborator.length}');
    if (AppUrl.user.collaborator.length > 0)
      print('coll salCode : ${AppUrl.user.collaborator.last.salCode}');
    print('dateSelected: ${AppUrl.filtredOpporunity.date}');
    print('etbl: ${AppUrl.user.etblssmnt!.code}');
    print('startEnd ! ${AppUrl.startTime} ');
    if (AppUrl.user.localDepot != null) {
      print('depStock: ${AppUrl.user.localDepot!.id}');
    } else {
      AppUrl.user.localDepot = Depot(id: '001', name: 'name');
    }

    print('company: ${AppUrl.user.company}');
    print('salCode: ${AppUrl.user.salCode}');
    print('repCode: ${AppUrl.user.repCode}');
    print('image: ${AppUrl.user.image}');
    print('equipeId: ${AppUrl.user.equipeId}');
    print('image: ${AppUrl.baseUrl}');
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   try{
    //   showLoaderDialog(context);
    //   await fetchData().then((value) {
    //     final provider =
    //         Provider.of<ClientsMapProvider>(context, listen: false);
    //     print('size of list: ${provider.mapClientsWithCommands}');
    //     Navigator.pop(context);
    //   });} on SocketException catch (_) {
    //     _showAlertDialog(context,
    //         'Pas de connecxion !');
    //   }
    // });
  }

  // Function to fetch JSON data from an API
  Future<void> fetchData() async {
    print('debuginggg');
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    provider.mapClientsWithCommands = [];
    int? equipe;
    String collaborator = AppUrl.user.userId!;
    print('ss: ${AppUrl.filtredOpporunity.collaborateur!.id}');
    if (AppUrl.filtredOpporunity.collaborateur!.id != null) {
      if (AppUrl.filtredOpporunity.collaborateur!.id! != -1) {
        collaborator = AppUrl.filtredOpporunity.collaborateur!.userName!;
      }
    } else {
      collaborator = AppUrl.filtredOpporunity.collaborateur!.userName!;
    }

    if (AppUrl.filtredOpporunity.team!.id! != -1)
      equipe = AppUrl.filtredOpporunity.team!.id!;

    if (collaborator == 'Moi') collaborator = AppUrl.user.userId!;
    print('debuginggg222 $collaborator');
    var body = jsonEncode({
      "filter": null,
      "equipe": equipe,
      "tiers": null,
      "priorite": null,
      "urgence": null,
      "collaborateur": collaborator,
      "collaborateurs": [],
      "dateDebut": DateFormat('yyyy-MM-ddT00:00:00')
          .format(AppUrl.filtredOpporunity.date),
      "dateFin": DateFormat('yyyy-MM-ddT23:59:59')
          .format(AppUrl.filtredOpporunity.dateEnd)
    });
    http.Response req = await http
        .post(Uri.parse(AppUrl.opportunitiesFiltred), body: body, headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res opp code : ${req.statusCode}");
    print("res opp body: ${req.body}");
    if (req.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      List<dynamic> data = json.decode(req.body);
      print('size of opportunities : ${data.toList().length}');
      //addOppurtonities(data);
      //data.toList().forEach((element) async {
      for (var element in data.toList()) {
        print('id client:  ${element['tiersId']}');
        print('id opp:  ${element['code']}');
        print('etapeId: ${element['etapeId']}');
        String pcfCode = element['tiersId'];
        req = await http.get(Uri.parse(AppUrl.getOneTiers + pcfCode), headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
        });
        print("res tier code: ${req.statusCode}");
        print("res tier body: ${req.body}");
        if (req.statusCode == 200) {
          var res = json.decode(req.body);
          LatLng latLng;
          if (res['longitude'] == null || res['latitude'] == null)
            latLng = LatLng(1.354474457244855, 1.849465150689236);
          else {
            try {
              latLng = LatLng(res['latitude'], res['longitude']);
            } catch (e) {
              latLng = LatLng(1.354474457244855, 1.849465150689236);
            }
          }
          Client client = new Client(
            idOpp: element['numero'].toString(),
            id: res['code'],
            type: res['type'],
            name: res['rs'],
            name2: res['rs2'],
            phone2: res['tel2'],
            total: element['montant'].toString(),
            phone: res['tel1'],
            city: res['ville'],
            location: latLng,
            stat: element['etapeId'],
            priority: element['priorite'],
            emergency: element['urgence'],
            lib: element['libelle'],
            resOppo: element,
            dateStart: DateTime.parse(element['dateDebut']),
            dateCreation: DateTime.parse(element['dateCreation']),
          );
          //if(element['etapeId'] == 1 || element['etapeId'] == 2)
          provider.mapClientsWithCommands.add(client);
          print('size of opp: ${provider.mapClientsWithCommands.length}');
        }
      }
      provider.mapClientsWithCommands
          .sort((a, b) => a.dateStart!.compareTo(b.dateStart!));
    } else {
      print('Failed to load data');
    }
    provider.updateList();
    _fetchDataCatalog();
  }

  Future<void> _fetchDataCatalog() async {
    String url = AppUrl.getArticlesFamilly;
    AppUrl.user.famillies = [];
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res familly code : ${req.statusCode}");
    print("res familly body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      data.forEach((element) {
        AppUrl.user.famillies.add(Familly(
            code: element['code'],
            name: element['lib'],
            type: element['type']));
      });
      AppUrl.user.famillies
          .insert(0, Familly(code: '-1', name: 'Tout', type: ''));
      AppUrl.user.sFamillies = [SFamilly(code: '-1', name: 'Tout', type: '')];
      AppUrl.filtredCatalog.selectedFamilly = AppUrl.user.famillies.first;
      AppUrl.filtredCatalog.selectedSFamilly = AppUrl.user.sFamillies.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: null,
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
          // else if (snapshot.hasError) {
          //   // There was an error in the future, handle it.
          //   print('Error: ${snapshot.hasError} ${snapshot.error} ');
          //   return AlertDialog(
          //     content: Row(
          //       //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Icon(
          //           Icons.error_outline,
          //           color: Colors.red,
          //         ),
          //         SizedBox(
          //           width: 30,
          //         ),
          //         // Text('Error: ${snapshot.error}')
          //         Text('Pas de connexion'),
          //       ],
          //     ),
          //   );
          // }
          else
            return Scaffold(
                appBar: ReclamationsAppBar(),
                drawer: (widget.numSerie == null) ? DrawerReclamationPage() : null,
                // body: TabBarView(
                //   children: [
                //     DemandsFragment(numSerie: widget.numSerie),
                //     //InterventionsFragment(),
                //     AttachmentsFragment(),
                //     ProcFragment(),
                //   ],
                // )
              body: DemandsFragment(),
            );
            // return DefaultTabController(
            //   length: 3,
            //   child: Scaffold(
            //       appBar: ReclamationsAppBar(),
            //       drawer: (widget.numSerie == null) ? DrawerReclamationPage() : null,
            //       body: TabBarView(
            //         children: [
            //           DemandsFragment(numSerie: widget.numSerie),
            //           //InterventionsFragment(),
            //           AttachmentsFragment(),
            //           ProcFragment(),
            //         ],
            //       )),
            // );
        });
  }

  void addOppurtonities(List<dynamic> data) {
    if (data.toList().length == 0) {
      Map<String, dynamic> jsonObject = {
        "code": 0,
        "libelle": "string",
        "proprio": "string",
        "statut": "string",
        "montant": 0,
        "contact": "string",
        "dateCreation": "2023-09-15T19:00:29.434Z",
        "dateDebut": "2023-09-15T19:00:29.434Z",
        "priorite": 0,
        "urgence": 0,
        "description": "string",
        "motifSupp": "string",
        "userSupp": "string",
        "deleted": true,
        "dateSupp": "2023-09-15T19:00:29.434Z",
        "dateMaj": "2023-09-15T19:00:29.434Z",
        "userCreat": "string",
        "userMaj": "string",
        "etapeId": 1,
        "tiersId": "aaa001",
      };

      List<Map<String, dynamic>> jsonArray = [jsonObject];
      String jsonString = jsonEncode(jsonArray);
      print(' the array is: $jsonString');
      data = json.decode(jsonString);
    }
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
