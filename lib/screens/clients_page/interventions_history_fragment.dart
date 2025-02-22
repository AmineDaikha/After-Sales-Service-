import 'dart:convert';

import 'package:animate_icons/animate_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/constants/utils.dart';
import 'package:sav_app/models/client.dart';
import 'package:sav_app/models/command.dart';
import 'package:sav_app/models/familly.dart';
import 'package:sav_app/models/product.dart';
import 'package:sav_app/models/sfamilly.dart';
import 'package:sav_app/providers/clients_map_provider.dart';
import 'package:sav_app/screens/home_page/one_intervention_page.dart';
import 'package:sav_app/screens/reclamation_page/one_reclamation_page.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/routers.dart';
import 'package:sav_app/widgets/alert.dart';

class InterventionHistoryFragment extends StatefulWidget {
  Client client;

  InterventionHistoryFragment({super.key, required this.client});

  @override
  State<InterventionHistoryFragment> createState() =>
      _InterventionHistoryFragmentState();
}

class _InterventionHistoryFragmentState
    extends State<InterventionHistoryFragment> {
  AnimateIconController controller = AnimateIconController();
  DateTime dateStart = DateTime.now();
  DateTime dateEnd = DateTime.now();

  // Function to fetch JSON data from an API
  Future<void> fetchData() async {
    String url = AppUrl.intervention +
        '?pcfCode=${widget.client.id}&dateDebut=${DateFormat('yyyy-MM-ddT00:00:00').format(dateStart)}&dateFin=${DateFormat('yyyy-MM-ddT23:59:59').format(dateEnd)}';
    print('urlRec: $url');
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    provider.mapClientsWithCommandsInterventions = [];
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res hisInter code : ${req.statusCode}");
    print("res hisInter body: ${req.body}");
    if (req.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      List<dynamic> data = json.decode(req.body);
      print('size of interventions : ${data.toList().length}');
      for (var element in data.toList()) {
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
          print(
              'size of opp: ${provider.mapClientsWithCommandsInterventions.length}');
        }
      }
      provider.mapClientsWithCommandsInterventions
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

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateStart,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            // Day color
            buttonTheme: ButtonThemeData(
              colorScheme: ColorScheme.light(
                primary: primaryColor, // Change the color here
              ),
            ),
            colorScheme: ColorScheme.light(primary: primaryColor)
                .copyWith(secondary: primaryColor),
            // Button text color
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        dateStart = DateTime(picked.year, picked.month, picked.day, 0, 0, 0);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateEnd,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            // Day color
            buttonTheme: ButtonThemeData(
              colorScheme: ColorScheme.light(
                primary: primaryColor, // Change the color here
              ),
            ),
            colorScheme: ColorScheme.light(primary: primaryColor)
                .copyWith(secondary: primaryColor),
            // Button text color
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        dateEnd =
            DateTime(picked.year, picked.month, picked.day, 23, 59, 59, 999);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    dateStart = DateTime(
      dateStart.year,
      dateStart.month,
      dateStart.day,
      0, // new hour
      0, // new minute
      0, // new second
    );
    dateEnd = DateTime(
        dateEnd.year,
        dateEnd.month,
        dateEnd.day,
        23,
        // new hour
        59,
        // new minute
        59,
        // new second
        999);
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
          } else if (snapshot.hasError) {
            // There was an error in the future, handle it.
            print('Error: ${snapshot.hasError}');
            return Text('Error: ${snapshot.error}');
          } else
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1), // Shadow color
                        offset: Offset(0, 5), // Offset from the object
                      ),
                    ],
                  ),
                  margin: EdgeInsets.all(8),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _selectStartDate(context);
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              color: primaryColor,
                            ),
                            Text(
                              'Du ${DateFormat('yyyy-MM-dd').format(dateStart)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(color: primaryColor),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _selectEndDate(context);
                        },
                        child: Row(
                          children: [
                            Text(
                              'Au ${DateFormat('yyyy-MM-dd').format(dateEnd)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(color: primaryColor),
                            ),
                            Icon(
                              Icons.calendar_month_outlined,
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Consumer<ClientsMapProvider>(
                    builder: (context, clients, child) {
                  print('size:: ${clients.mapClientsWithCommandsInterventions.length}');
                  if (clients.mapClientsWithCommandsInterventions.length == 0)
                    return Expanded(
                      //height: AppUrl.getFullHeight(context) * 0.6,
                      child: Center(
                        child: Text(
                          'Aucune intervention !',
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ),
                    );
                  else
                    return Expanded(
                      child: ListView.builder(
                          padding: EdgeInsets.all(12),
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) => InkWell(
                              onTap: () {
                                // Navigator.pushNamed(
                                //     context, ClientPage.routeName);
                              },
                              child: ClientItem(
                                  client: clients.mapClientsWithCommandsInterventions
                                      .toList()[index])),
                          // separatorBuilder: (BuildContext context, int index) {
                          //   return Divider(
                          //     color: Colors.grey,
                          //   );
                          // },
                          itemCount: clients.mapClientsWithCommandsInterventions.length),
                    );
                }),
              ],
            );
          // return Column(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: [
          //     // Container(
          //     //   margin: EdgeInsets.all(8),
          //     //   child: (AppUrl.filtredCommandsClient.allCollaborators)
          //     //       ? Text(
          //     //           'Collaborateurs: Tout',
          //     //           style: Theme.of(context)
          //     //               .textTheme
          //     //               .headline4!
          //     //               .copyWith(color: primaryColor),
          //     //         )
          //     //       : Text(
          //     //           'Collaborateurs: ${AppUrl.filtredCommandsClient.collaborateur!.userName}',
          //     //           style: Theme.of(context)
          //     //               .textTheme
          //     //               .headline4!
          //     //               .copyWith(color: primaryColor),
          //     //         ),
          //     // ),
          //     // Container(
          //     //   padding: EdgeInsets.symmetric(horizontal: 10),
          //     //   decoration: BoxDecoration(
          //     //     color: Colors.grey[300],
          //     //     boxShadow: [
          //     //       // BoxShadow(
          //     //       //   color: Colors.grey.withOpacity(0.1), // Shadow color
          //     //       //   offset: Offset(0, 5), // Offset from the object
          //     //       // ),
          //     //     ],
          //     //   ),
          //     //   margin: EdgeInsets.all(8),
          //     //   height: 50,
          //     //   child: Stack(
          //     //     children: [
          //     //       Align(
          //     //         alignment: Alignment.centerLeft,
          //     //         child: Row(
          //     //           children: [
          //     //             Icon(
          //     //               Icons.attach_money_outlined,
          //     //               color: primaryColor,
          //     //             ),
          //     //             Text(
          //     //               '${AppUrl.formatter.format(widget.client.totalPay)} DZD',
          //     //               style: Theme.of(context)
          //     //                   .textTheme
          //     //                   .headline3!
          //     //                   .copyWith(color: primaryColor),
          //     //             ),
          //     //           ],
          //     //         ),
          //     //       ),
          //     //       Align(
          //     //         alignment: Alignment.center,
          //     //       ),
          //     //       Align(
          //     //         alignment: Alignment.centerRight,
          //     //         child: Icon(
          //     //           Icons.call_outlined,
          //     //           color: primaryColor,
          //     //         ),
          //     //       ),
          //     //     ],
          //     //   ),
          //     // ),
          //     Container(
          //       padding: EdgeInsets.symmetric(horizontal: 5),
          //       decoration: BoxDecoration(
          //         color: Colors.white,
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.grey.withOpacity(0.1), // Shadow color
          //             offset: Offset(0, 5), // Offset from the object
          //           ),
          //         ],
          //       ),
          //       margin: EdgeInsets.all(8),
          //       height: 50,
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceAround,
          //         children: [
          //           GestureDetector(
          //             onTap: () {
          //               _selectStartDate(context);
          //             },
          //             child: Row(
          //               children: [
          //                 Icon(
          //                   Icons.calendar_month_outlined,
          //                   color: primaryColor,
          //                 ),
          //                 Text(
          //                   'Du ${DateFormat('yyyy-MM-dd').format(dateStart)}',
          //                   style: Theme.of(context)
          //                       .textTheme
          //                       .headline5!
          //                       .copyWith(color: primaryColor),
          //                 ),
          //               ],
          //             ),
          //           ),
          //           GestureDetector(
          //             onTap: () {
          //               _selectEndDate(context);
          //             },
          //             child: Row(
          //               children: [
          //                 Text(
          //                   'Au ${DateFormat('yyyy-MM-dd').format(dateEnd)}',
          //                   style: Theme.of(context)
          //                       .textTheme
          //                       .headline5!
          //                       .copyWith(color: primaryColor),
          //                 ),
          //                 Icon(
          //                   Icons.calendar_month_outlined,
          //                   color: primaryColor,
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //     SizedBox(
          //       height: 20,
          //     ),
          //     Consumer<CommandProvider>(
          //         builder: (context, commands, snapshot) {
          //       return Expanded(
          //         child: (commands.deliverdList.length != 0)
          //             ? ListView.builder(
          //                 physics: BouncingScrollPhysics(),
          //                 itemBuilder: (context, index) {
          //                   widget.client.command =
          //                       commands.deliverdList[index];
          //                   print(
          //                       'size of deliverdList: ${commands.deliverdList.length}');
          //                   return CommandItem(
          //                     client: widget.client,
          //                     command: commands.deliverdList[index],
          //                   );
          //                 },
          //                 itemCount: commands.deliverdList.length)
          //             : Center(
          //                 child: Text(
          //                 'Aucune livraison',
          //                 style: Theme.of(context).textTheme.headline6,
          //               )),
          //       );
          //     }),
          //   ],
          // );
        });
  }
}

class ClientItem extends StatefulWidget {
  final Client client;

  const ClientItem({super.key, required this.client});

  @override
  State<ClientItem> createState() => _ClientItemState();
}

class _ClientItemState extends State<ClientItem> {
  Widget icon = Icon(Icons.shopping_cart_outlined);
  int respone = 200;
  double total = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   showLoaderDialog(context);
    //   fetchData().then((value) {
    //     Navigator.pop(context);
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    double priorityrating = 0;
    double emergencyrating = 0;
    if (widget.client.priority != null)
      priorityrating = widget.client.priority!.toDouble();
    if (widget.client.emergency != null)
      emergencyrating = widget.client.emergency!.toDouble();
    print('lib: ${widget.client.priority}');
    // print('sss: ${widget.client.total}');
    // if (widget.client.total != null){
    //   if (double.parse(widget.client.total.toString()) > 0) {
    //   color = Color(0xff049a9b);
    // } else if (double.parse(widget.client.total.toString()) < 0) {
    //   color = Colors.red;
    // }}
    return FutureBuilder(
      //future: fetchData(widget.client),
        future: null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Future is still running, return a loading indicator or some placeholder.
            return Center(
              child: Row(
                children: [
                  CircularProgressIndicator(
                    color: primaryColor,
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 15, top: 35, bottom: 35),
                      child: Text("Loading...")),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            // There was an error in the future, handle it.
            print('Error: ${snapshot.hasError}');
            return Text('Error: ${snapshot.error}');
          } else {
            print(
                'states is:: ${widget.client.stat} ${AppUrl.filtredOpporunity.pipeline!.steps.length}');
            print(
                'condition: ${(AppUrl.filtredOpporunity.pipeline!.steps.where((element) => element.id == widget.client.stat!).length == 0)}');
            if (AppUrl.filtredOpporunity.pipeline!.steps
                .where((element) => element.id == widget.client.stat!)
                .length ==
                0) return Container();
            print('rjkgergreig ${widget.client.resOppo['etape']}');
            return InkWell(
              onTap: () {
                PageNavigator(ctx: context).nextPage(
                    page: OneInterventionPage(
                      client: widget.client,
                    ));
              },
              child: Column(
                children: [
                  Container(
                    height: 198,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          color: primaryColor,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (widget.client.lib != null)
                                ? Container(
                              width: 240,
                              child: Text(
                                widget.client.lib!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(color: primaryColor),
                              ),
                            )
                                : Text('Nom de l\'Affaire',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(color: Colors.black)),
                            (widget.client.resOppo['etape']['libelle'] != null)
                                ? Text(
                              '(${widget.client.resOppo['etape']['libelle']!})',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(color: Colors.red),
                            )
                                : Text('(Étape)',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(color: Colors.red)),
                            Text('Client : ${widget.client.name!}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(color: Colors.grey)),
                            Text('Adresse : ${widget.client.resOppo['demande']['adress']['title']}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(color: Colors.grey)),
                            Text('Ville : ${widget.client.city}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(color: Colors.grey)),
                            Text('Équipement : ${widget.client.resOppo['demande']['article']['lib']}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(color: Colors.grey)),
                            Text('Nb série : ${widget.client.resOppo['demande']['equipementNumeroSerie']}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(color: Colors.grey)),
                            Row(
                              children: [
                                Icon(Icons.calendar_month_outlined, color: primaryColor, size: 20),
                                SizedBox(width: 7,),
                                Text('${DateFormat('dd-MM-yyyy')
                                    .format(widget.client.dateStart!)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith()),
                                SizedBox(width: 20,),
                                Icon(Icons.access_time, color: primaryColor, size: 20),
                                SizedBox(width: 7,),
                                Text('${DateFormat('HH:mm')
                                    .format(widget.client.dateStart!)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith()),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Priorité: ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                RatingBar.builder(
                                  ignoreGestures: true,
                                  initialRating: priorityrating,
                                  minRating: 1.0,
                                  maxRating: 5.0,
                                  itemCount: 5,
                                  itemSize: 25,
                                  // Number of stars
                                  itemBuilder: (context, index) => Icon(
                                    index >= priorityrating
                                        ? Icons.star_border_outlined
                                        : Icons.star,
                                    color: Colors.yellow,
                                  ),
                                  onRatingUpdate: (rating) {},
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Urgence: ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                RatingBar.builder(
                                  ignoreGestures: true,
                                  initialRating: emergencyrating,
                                  minRating: 1.0,
                                  maxRating: 5.0,
                                  itemCount: 5,
                                  itemSize: 25,
                                  // Number of stars
                                  itemBuilder: (context, index) => Icon(
                                    index >= emergencyrating
                                        ? Icons.star_border_outlined
                                        : Icons.star,
                                    color: Colors.yellow,
                                  ),
                                  onRatingUpdate: (rating) {},
                                ),
                              ],
                            ),
                          ],
                        ),
                        Visibility(
                          visible: true,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    if (widget.client.phone != null)
                                      PhoneUtils()
                                          .makePhoneCall(widget.client.phone!);
                                    else
                                      _showAlertDialog(context,
                                          'Aucune numéro de téléphone pour ce client');
                                  },
                                  icon: Icon(
                                    Icons.call,
                                    color: primaryColor,
                                  )),
                            ],
                          ),
                        ),
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
        });
  }
}
void _showAlertDialog(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.yellow,
              size: 50.0,
            ),
          ],
        ),
        content: Text(
          '$text',
          style: Theme.of(context).textTheme.headline6!,
        ),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(primaryColor)),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Ok',
                style: Theme.of(context)
                    .textTheme
                    .headline3!
                    .copyWith(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

