import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/constants/utils.dart';
import 'package:sav_app/models/client.dart';
import 'package:sav_app/providers/providers.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/routers.dart';
import 'one_intervention_page.dart';

class ClientListFragment extends StatelessWidget {
  const ClientListFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientsMapProvider>(builder: (context, clients, child) {
      print('size:: ${clients.mapClientsWithCommandsInterventions.length}');
      if (clients.mapClientsWithCommandsInterventions.length == 0)
        return Center(
          child: Text(
            'Aucune intervention !',
            style: Theme.of(context).textTheme.headline3,
          ),
        );
      else
        return ListView.builder(
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
            itemCount: clients.mapClientsWithCommandsInterventions.length);
    });
  }
}

// class ClientItem extends StatefulWidget {
//   final Client client;
//
//   const ClientItem({super.key, required this.client});
//
//   @override
//   State<ClientItem> createState() => _ClientItemState();
// }
//
// class _ClientItemState extends State<ClientItem> {
//   Widget icon = Icon(Icons.shopping_cart_outlined);
//   int respone = 200;
//
//   // Function to fetch JSON data from an API
//   Future<void> fetchData(Client client) async {
//     print(
//         'url of CmdOfOpp ${AppUrl.commandsOfOpportunite + AppUrl.user.etblssmnt!.code! + '/' + widget.client.idOpp!}');
//     http.Response req = await http.get(
//         Uri.parse(AppUrl.commandsOfOpportunite +
//             AppUrl.user.etblssmnt!.code! +
//             '/' +
//             widget.client.idOpp!),
//         headers: {
//           "Accept": "application/json",
//           "content-type": "application/json; charset=UTF-8",
//           "Referer": "http://"+AppUrl.user.company!+".localhost:4200/"
//         });
//     print("res cmdOpp code : ${req.statusCode}");
//     print("res cmdOpp body: ${req.body}");
//     if (req.statusCode == 200) {
//       respone = 200;
//
//       icon = Image.asset('assets/caddie_rempli.png');
//
//       var res = json.decode(req.body);
//       List<dynamic> data = res['lignes'];
//       print('sizeof: ${data.length}');
//       try {
//         List<Product> products = [];
//         Future.forEach(data.toList(), (element) async {
//           print('quantité: ${element['qte'].toString()}');
//           double d = element['qte'];
//           int quantity = d.toInt();
//           // double dStock = element['stockDep'];
//           // int quantityStock = dStock.toInt();
//           var artCode = element['artCode'];
//           print('imghhh $artCode');
//           print('url: ${AppUrl.getUrlImage + '$artCode'}');
//           http.Response req = await http
//               .get(Uri.parse(AppUrl.getUrlImage + '$artCode'), headers: {
//             "Accept": "application/json",
//             "content-type": "application/json; charset=UTF-8",
//             "Referer": "http://"+AppUrl.user.company!+".localhost:4200/",
//           });
//           print("res imgArticle code : ${req.statusCode}");
//           print("res imgArticle body: ${req.body}");
//           if (req.statusCode == 200) {
//             List<dynamic> data = json.decode(req.body);
//             if (data.length > 0) {
//               var item = data.first;
//               print('item: ${item['path']}');
//               print('price: ${element['pPrv']} ${element['pBrut']} ');
//               double total = 0;
//               if (element['total'] != null)
//                 total = element['total'];
//               else if(element['cout'] != null)
//                 total = element['cout'];
//               products.add(Product(
//                   quantity: quantity,
//                   price: element['pBrut'],
//                   total: total,
//                   id: element['artCode'],
//                   image: AppUrl.baseUrl + item['path'],
//                   name: element['lib']));
//             }
//           }
//         }).then((value){
//           client.command = Command(
//               id: res['numero'],
//               date: DateTime.parse(res['date']),
//               total: 0,
//               paid: 0,
//               products: products,
//               nbProduct: products.length);
//         });
//
//         // get image
//       } catch (e, stackTrace) {
//         print('Exception: $e');
//         print('Stack trace: $stackTrace');
//       }
//     } else {
//       respone = 404;
//       client.command = null;
//     }
//     print('command of ${client.name } ${client.id} is: ${client.command}');
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     //   showLoaderDialog(context);
//     //   fetchData().then((value) {
//     //     Navigator.pop(context);
//     //   });
//     // });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Color color = Colors.grey;
//     if (double.parse(widget.client.total.toString()) > 0) {
//       color = Color(0xff049a9b);
//     } else if (double.parse(widget.client.total.toString()) < 0) {
//       color = Colors.red;
//     }
//     return FutureBuilder(
//         future: fetchData(widget.client),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             // Future is still running, return a loading indicator or some placeholder.
//             return Center(
//               child: Row(
//                 children: [
//                   CircularProgressIndicator(
//                     color: primaryColor,
//                   ),
//                   Container(
//                       margin: EdgeInsets.only(left: 15, top: 35, bottom: 35),
//                       child: Text("Loading...")),
//                 ],
//               ),
//             );
//           } else if (snapshot.hasError) {
//             // There was an error in the future, handle it.
//             print('Error: ${snapshot.hasError}');
//             return Text('Error: ${snapshot.error}');
//           } else
//             return Column(
//               children: [
//                 Container(
//                   height: 98,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Icon(
//                         Icons.person_pin_rounded,
//                         color: primaryColor,
//                       ),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             widget.client.name!,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .headline5!
//                                 .copyWith(color: primaryColor),
//                           ),
//                           Text(widget.client.city!,
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .bodyText1!
//                                   .copyWith(color: Colors.grey)),
//                         ],
//                       ),
//                       Text(
//                         widget.client.total! + ' DZD',
//                         style: Theme.of(context).textTheme.headline4!.copyWith(
//                             color: color, fontWeight: FontWeight.normal),
//                       ),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           IconButton(
//                             onPressed: () {
//                               print('client; ${widget.client.command}');
//                               if (respone == 200){
//                                 PageNavigator(ctx: context).nextPage(
//                                     page: CommandPage(
//                                       client: widget.client,
//                                     ));
//                               }
//                               else
//                                 PageNavigator(ctx: context).nextPage(
//                                     page: StorePage(
//                                   client: widget.client,
//                                 ));
//                               //Navigator.pushNamed(context, '/home/command', arguments: client);
//                             },
//                             icon: (respone == 200)
//                                 ? Image.asset('assets/caddie_rempli.png')
//                                 : Icon(Icons.shopping_cart_outlined),
//                             color: primaryColor,
//                           ),
//                           IconButton(onPressed: (){
//                             PageNavigator(ctx: context).nextPage(
//                                 page: ActivityListPage(
//                                   client: widget.client,
//                                 ));
//                           }, icon: Icon(Icons.local_activity_outlined, color: primaryColor,))
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Divider(
//                   color: Colors.grey,
//                 )
//               ],
//             );
//         });
//   }
// }

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
