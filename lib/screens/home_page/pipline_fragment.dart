import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/constants/utils.dart';
import 'package:sav_app/models/client.dart';
import 'package:sav_app/models/command.dart';
import 'package:sav_app/models/pipeline.dart';
import 'package:sav_app/models/product.dart';
import 'package:sav_app/providers/clients_map_provider.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/routers.dart';

import 'activities_pages/activity_list_page.dart';
import 'command_delivred_page.dart';
import 'command_page.dart';
import 'init_store_page.dart';
import 'one_intervention_page.dart';
import 'opportunity_page.dart';

class PiplineFragment extends StatefulWidget {
  const PiplineFragment({super.key});

  @override
  State<PiplineFragment> createState() => _PiplineFragmentState();
}

class _PiplineFragmentState extends State<PiplineFragment> {
  int selectedItemIndex = 0; // Index of the selected item
  // List<String> items = [
  //   'A visité',
  //   'Visité',
  //   'Livré',
  //   'Encaissé',
  //   'Livré & encaissé',
  //   'Annulée'
  // ];

  @override
  void initState() {
    super.initState();
    print('uyuyuy : ${AppUrl.filtredOpporunity.team!.lib}');

    AppUrl.filtredOpporunity.pipeline = AppUrl.filtredOpporunity.team!.pipelines
        .where((element) => element.id == 3)
        .first;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    print('hkjjj: ${AppUrl.user.userId}');
    print('first stat: ${AppUrl.filtredOpporunity.pipeline!.steps.first.name}');
    print(
        'date: ${DateFormat('yyyy-MM-ddT00:00:00').format(AppUrl.selectedDate)}}');
    return Column(
      children: [
        // Visibility(
        //   visible: false,
        //   child: ListTile(
        //     title: Text(
        //       'Filtre des équipes',
        //       style: Theme.of(context).textTheme.headline6,
        //     ),
        //     subtitle: DropdownButtonFormField<Team>(
        //       decoration: InputDecoration(
        //           fillColor: Colors.white,
        //           filled: true,
        //           focusedBorder: OutlineInputBorder(
        //             borderRadius: BorderRadius.circular(12),
        //             borderSide: BorderSide(width: 2, color: primaryColor),
        //           ),
        //           enabledBorder: OutlineInputBorder(
        //             borderRadius: BorderRadius.circular(12),
        //             borderSide: BorderSide(width: 2, color: primaryColor),
        //           )),
        //       hint: Text(
        //         'Selectioner l\'équipe',
        //         style: Theme.of(context)
        //             .textTheme
        //             .headline4!
        //             .copyWith(color: Colors.grey),
        //       ),
        //       value: AppUrl.selectedTeam,
        //       onChanged: (newValue) {
        //         setState(() {
        //           AppUrl.selectedTeam = newValue!;
        //         });
        //       },
        //       items:
        //       AppUrl.user.teams.map<DropdownMenuItem<Team>>((Team value) {
        //         return DropdownMenuItem<Team>(
        //           value: value,
        //           child: Text(
        //             value.lib!,
        //             style: Theme.of(context).textTheme.headline4,
        //           ),
        //         );
        //       }).toList(),
        //     ),
        //   ),
        // ),
        Container(
          height: 50.0, // Adjust the height of the container
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppUrl.filtredOpporunity.pipeline!.steps.length,
            // Number of items
            itemBuilder: (context, index) {
              return Consumer<ClientsMapProvider>(
                  builder: (context, clients, snapshot) {
                List<Client> clientList = [];
                if (clients.mapClientsWithCommandsInterventions.length > 0) {
                  print(
                      'zzzzzzz: ${clients.mapClientsWithCommandsInterventions.first.stat} index: ${index + 1}');
                }
                clientList = provider.getOppoByStat(
                    index + AppUrl.filtredOpporunity.pipeline!.steps.first.id);
                // switch (index) {
                //   case 0:
                //     clientList = provider.toVisitedClients.toList();
                //     break;
                //   case 1:
                //     clientList = provider.visitedClients.toList();
                //     break;
                //   case 2:
                //     clientList = provider.delivredClients.toList();
                //     break;
                //   case 3:
                //     clientList = provider.paymentedClients.toList();
                //     break;
                //   case 4:
                //     clientList = provider.delivredAndPaymentedClients.toList();
                //     break;
                //   case 5:
                //     clientList = provider.canceledClients.toList();
                //     break;
                //   default:
                //     clientList = [];
                // }
                return GestureDetector(
                  onTap: () {
                    // Handle item tap
                    setState(() {
                      selectedItemIndex = index;
                    });
                  },
                  child: Container(
                    width: 120.0,
                    // Adjust the width of each item
                    margin: EdgeInsets.all(8.0),
                    decoration: selectedItemIndex == index
                        ? BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                            width: 2.5,
                            color: Theme.of(context).primaryColor,
                          )))
                        : BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                            width: 2.5,
                            color: Colors.transparent,
                          ))),
                    // color: selectedItemIndex == index
                    //     ? Colors.blue // Color when item is selected
                    //     : Colors.grey,
                    // Default color
                    child: Center(
                      child: Text(
                        '${AppUrl.filtredOpporunity.pipeline!.steps[index].name} (${clientList.length})',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
        SizedBox(height: 20.0),
        selectedItemIndex != -1
            ? Consumer<ClientsMapProvider>(
                builder: (context, clients, snapshot) {
                List<Client> clientList;
                switch (selectedItemIndex) {
                  case 0:
                    clientList = provider.toVisitedClients.toList();
                    break;
                  case 1:
                    clientList = provider.visitedClients.toList();
                    break;
                  case 2:
                    clientList = provider.delivredClients.toList();
                    break;
                  case 3:
                    clientList = provider.paymentedClients.toList();
                    break;
                  case 4:
                    clientList = provider.delivredAndPaymentedClients.toList();
                    break;
                  case 5:
                    clientList = provider.canceledClients.toList();
                    break;
                  default:
                    clientList = [];
                }
                clientList = provider.getOppoByStat(selectedItemIndex +
                    AppUrl.filtredOpporunity.pipeline!.steps.first.id);
                //clientList = provider.getOppoByStat(selectedItemIndex + 16);
                print(
                    'hhhhh: ${clientList.length} gjrier : ${AppUrl.filtredOpporunity.pipeline!.steps.first.id}');
                return Expanded(
                    child: (clientList.isEmpty)
                        ? Center(
                            child: Text(
                            'Aucune intervention !',
                            style: Theme.of(context).textTheme.headline3,
                          ))
                        : ListView.builder(
                            padding: EdgeInsets.all(12),
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) => InkWell(
                                onTap: () {
                                  // Navigator.pushNamed(
                                  //     context, ClientPage.routeName);
                                },
                                child: ClientItem(client: clientList[index])),
                            // separatorBuilder: (BuildContext context, int index) {
                            //   return Divider(
                            //     color: Colors.grey,
                            //   );
                            // },
                            itemCount: clientList.length));
              })
            // Container(
            //         height: 100.0, // Adjust the height of the container
            //         width: 100.0, // Adjust the width of the container
            //         color: Colors.purple, // Color of the container
            //         child: Center(
            //           child: Text(
            //             'Selected: $selectedItemIndex',
            //             style: TextStyle(color: Colors.white),
            //           ),
            //         ),
            //       )
            : Container(),
      ],
    );
    // return Consumer<ClientsMapProvider>(builder: (context, clients, child) {
    //   return ListView.builder(
    //       padding: EdgeInsets.all(12),
    //       physics: BouncingScrollPhysics(),
    //       itemBuilder: (context, index) => InkWell(
    //           onTap: () {
    //             // Navigator.pushNamed(
    //             //     context, ClientPage.routeName);
    //           },
    //           child: ClientItem(
    //               client: clients.mapClientsWithCommandsInterventions.toList()[index])),
    //       // separatorBuilder: (BuildContext context, int index) {
    //       //   return Divider(
    //       //     color: Colors.grey,
    //       //   );
    //       // },
    //       itemCount: clients.mapClientsWithCommandsInterventions.length);
    // });
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
