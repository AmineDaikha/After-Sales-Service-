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
import 'package:sav_app/screens/home_page/clients_list_fragment.dart';
import 'package:sav_app/screens/home_page/itineraire_fragment.dart';
import 'package:sav_app/screens/home_page/pipline_fragment.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/widgets/drawers/home_drawer.dart';

import 'tournees_appbar.dart';

class HomePage extends StatefulWidget {
  final Client? client;

  const HomePage({super.key, this.client});

  static const String routeName = '/home';

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => HomePage(),
    );
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    //     print('size of list: ${provider.mapClientsWithCommandsInterventions}');
    //     Navigator.pop(context);
    //   });} on SocketException catch (_) {
    //     _showAlertDialog(context,
    //         'Pas de connecxion !');
    //   }
    // });
  }

  // Function to fetch JSON data from an API
  // Future<void> fetchData() async {
  //   print('debuginggg');
  //   final provider = Provider.of<ClientsMapProvider>(context, listen: false);
  //   provider.mapClientsWithCommandsInterventions = [];
  //
  //   try {
  //     print('frr : ${widget.client!.resOppo['interventions'].toString()}');
  //     List<dynamic> data =
  //         json.decode(widget.client!.resOppo['interventions'].toString());
  //     print('size of interventions : ${data.toList().length}');
  //     for (var element in data.toList()) {
  //       print('id client:  ${element['tiersId']}');
  //       print('id opp:  ${element['code']}');
  //       print('etapeId: ${element['etapeId']}');
  //       String pcfCode = element['demande']['pcfCode'];
  //       var res = json.decode(element['tiers']);
  //       LatLng latLng;
  //       if (res['longitude'] == null || res['latitude'] == null)
  //         latLng = LatLng(1.354474457244855, 1.849465150689236);
  //       else {
  //         try {
  //           latLng = LatLng(res['latitude'], res['longitude']);
  //         } catch (e) {
  //           latLng = LatLng(1.354474457244855, 1.849465150689236);
  //         }
  //       }
  //       Client client = new Client(
  //         idOpp: element['INT001'].toString(),
  //         id: res['code'],
  //         type: res['type'],
  //         name: res['rs'],
  //         name2: res['rs2'],
  //         phone2: res['tel2'],
  //         total: element['montant'].toString(),
  //         phone: res['tel1'],
  //         city: res['ville'],
  //         location: latLng,
  //         stat: element['etat'],
  //         priority: element['priorite'],
  //         emergency: element['urgence'],
  //         lib: element['objet'],
  //         resOppo: element,
  //         dateStart: DateTime.parse(element['date']),
  //         //dateCreation: DateTime.parse(element['dateCreation']),
  //       );
  //       //if(element['etapeId'] == 1 || element['etapeId'] == 2)
  //       provider.mapClientsWithCommandsInterventions.add(client);
  //       print(
  //           'size of opp: ${provider.mapClientsWithCommandsInterventions.length}');
  //     }
  //     provider.mapClientsWithCommandsInterventions
  //         .sort((a, b) => a.dateStart!.compareTo(b.dateStart!));
  //   } catch (e) {
  //     print('Failed to load data $e');
  //   }
  //   provider.updateList();
  //   _fetchDataCatalog();
  // }
  //
  // Future<void> _fetchDataCatalog() async {
  //   String url = AppUrl.getArticlesFamilly;
  //   AppUrl.user.famillies = [];
  //   http.Response req = await http.get(Uri.parse(url), headers: {
  //     "Accept": "application/json",
  //     "content-type": "application/json; charset=UTF-8",
  //     "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
  //   });
  //   print("res familly code : ${req.statusCode}");
  //   print("res familly body: ${req.body}");
  //   if (req.statusCode == 200) {
  //     List<dynamic> data = json.decode(req.body);
  //     data.forEach((element) {
  //       AppUrl.user.famillies.add(Familly(
  //           code: element['code'],
  //           name: element['lib'],
  //           type: element['type']));
  //     });
  //     AppUrl.user.famillies
  //         .insert(0, Familly(code: '-1', name: 'Tout', type: ''));
  //     AppUrl.user.sFamillies = [SFamilly(code: '-1', name: 'Tout', type: '')];
  //     AppUrl.filtredCatalog.selectedFamilly = AppUrl.user.famillies.first;
  //     AppUrl.filtredCatalog.selectedSFamilly = AppUrl.user.sFamillies.first;
  //   }
  // }


  Future<void> fetchData() async {
    print('debuginggg');
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    provider.mapClientsWithCommandsInterventions = [];
    int? equipe;
    String collaborator = AppUrl.user.userId!;
    print('ss: ${AppUrl.filtredOpporunity.collaborateur!.id}');
    if (AppUrl.filtredOpporunity.collaborateur!.id != null) {
      if (AppUrl.filtredOpporunity.collaborateur!.id! != -1) {
        collaborator = AppUrl.filtredOpporunity.collaborateur!.salCode!;
      }
    } else {
      collaborator = AppUrl.filtredOpporunity.collaborateur!.salCode!;
    }

    if (AppUrl.filtredOpporunity.team!.id! != -1)
      equipe = AppUrl.filtredOpporunity.team!.id!;

    if (collaborator == 'Moi') collaborator = AppUrl.user.salCode!;
    print('debuginggg222 $collaborator');
    for (Client rec in provider.recList) {
      print('tuhgtuhgt : ${rec.resOppo['numero']}');
    String url = AppUrl.intervention +
        '?demNumero=${rec.resOppo['numero']}';

    print('url interEq : $url');
    http.Response req = await http
        .get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res interv code : ${req.statusCode}");
    print("res interv body: ${req.body}");
    if (req.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      List<dynamic> data = json.decode(req.body);
      print('size of interventions : ${data
          .toList()
          .length}');
      for (var element in data.toList()) {
        print('id client:  ${element['tiersId']}');
        print('id opp:  ${element['code']}');
        print('etapeId: ${element['etapeId']}');
        String pcfCode = element['demande']['pcfCode'];
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
            idOpp: element['INT001'].toString(),
            id: res['code'],
            type: res['type'],
            name: res['rs'],
            name2: res['rs2'],
            phone2: res['tel2'],
            total: element['montant'].toString(),
            phone: res['tel1'],
            city: res['ville'],
            location: latLng,
            stat: element['etat'],
            priority: element['priorite'],
            emergency: element['urgence'],
            lib: element['objet'],
            resOppo: element,
            dateStart: DateTime.parse(element['date']),
            //dateCreation: DateTime.parse(element['dateCreation']),
          );
          //if(element['etapeId'] == 1 || element['etapeId'] == 2)
          provider.mapClientsWithCommandsInterventions.add(client);
          print('size of opp: ${provider.mapClientsWithCommandsInterventions
              .length}');
        }
      }
      provider.mapClientsWithCommandsInterventions
          .sort((a, b) => a.dateStart!.compareTo(b.dateStart!));
    } else {
      print('Failed to load data');
    }
    provider.updateList();
  }
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
            return DefaultTabController(
              length: 3,
              child: Scaffold(
                  appBar: TourneesAppBar(type: 'intervention'),
                  //drawer: DrawerHomePage(),
                  body: TabBarView(
                    children: [
                      PiplineFragment(),
                      ClientListFragment(),
                      ItineraireFragment(),
                      //CalanderFragment(),
                    ],
                  )),
            );
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
