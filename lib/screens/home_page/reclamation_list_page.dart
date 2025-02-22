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
import 'package:sav_app/models/product.dart';
import 'package:sav_app/providers/providers.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/routers.dart';
import 'package:sav_app/widgets/alert.dart';
import 'package:sav_app/widgets/dialog_filtred_opportunities.dart';

class ReclamationListPage extends StatefulWidget {
  final VoidCallback callback;

  const ReclamationListPage({super.key, required this.callback});

  @override
  State<ReclamationListPage> createState() => _ReclamationListPageState();
}

class _ReclamationListPageState extends State<ReclamationListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set icon color to white
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: ListTile(
          title: Text(
            'Sélectionner la réclamation ',
            style: Theme.of(context)
                .textTheme
                .headline4!
                .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                //_showDatePicker(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FiltredOpportunitiesDialog(
                      type: 'addInter',
                    );
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
      body: FutureBuilder(
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
            return Consumer<ClientsMapProvider>(
                builder: (context, clients, child) {
              print(
                  'size:: ${clients.mapClientsWithCommandsInterventions.length}');
              if (clients.mapClientsWithCommandsInterventions.length == 0)
                return Center(
                  child: Text(
                    'Aucune réclamation !',
                    style: Theme.of(context).textTheme.headline3,
                  ),
                );
              else
                return ListView.builder(
                    padding: EdgeInsets.all(12),
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) => InkWell(
                        onTap: () {
                          AppUrl.selectedClient = clients
                              .mapClientsWithCommandsInterventions
                              .toList()[index];
                          widget.callback();
                          Navigator.pop(context);
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
                    itemCount:
                        clients.mapClientsWithCommandsInterventions.length);
            });
          }),
    );
  }

  Future<void> fetchData() async {
    print('debuginggg');
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    provider.mapClientsWithCommandsInterventions = [];
    int? equipe;
    String collaborator = AppUrl.user.salCode!;
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
    String url = AppUrl.reclamation +
        '?dateDebut=${DateFormat('yyyy-MM-ddT00:00:00').format(AppUrl.filtredOpporunity.date)}&dateFin=${DateFormat('yyyy-MM-ddT23:59:59').format(AppUrl.filtredOpporunity.dateEnd)}&salCode=${collaborator}';

    if (AppUrl.filtredOpporunity.clinet != null &&
        AppUrl.filtredOpporunity.article == null) {
      url = AppUrl.reclamation +
          '?dateDebut=${DateFormat('yyyy-MM-ddT00:00:00').format(AppUrl.filtredOpporunity.date)}&dateFin=${DateFormat('yyyy-MM-ddT23:59:59').format(AppUrl.filtredOpporunity.dateEnd)}&salCode=${collaborator}&pcfCode=${AppUrl.filtredOpporunity.clinet!.id}';
    }
    if (AppUrl.filtredOpporunity.clinet != null &&
        AppUrl.filtredOpporunity.article != null) {
      url = AppUrl.reclamation +
          '?dateDebut=${DateFormat('yyyy-MM-ddT00:00:00').format(AppUrl.filtredOpporunity.date)}&dateFin=${DateFormat('yyyy-MM-ddT23:59:59').format(AppUrl.filtredOpporunity.dateEnd)}&salCode=${collaborator}&pcfCode=${AppUrl.filtredOpporunity.clinet!.id}&numSerie=${AppUrl.filtredOpporunity.article!.numSerie}';
    }
    // String url = AppUrl.reclamation +
    //     '?dateDebut=${DateFormat('yyyy-MM-ddT00:00:00').format(AppUrl.filtredOpporunity.date)}&dateFin=${DateFormat('yyyy-MM-ddT23:59:59').format(AppUrl.filtredOpporunity.dateEnd)}';
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res rec code : ${req.statusCode}");
    print("res rec body: ${req.body}");
    if (req.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      List<dynamic> data = json.decode(req.body);
      print('size of reclamations : ${data.toList().length}');
      //addOppurtonities(data);
      //data.toList().forEach((element) async {
      for (var element in data.toList()) {
        try {
          print('id client:  ${element['pcfCode']}');
          print('id opp:  ${element['code']}');
          print('etapeId: ${element['etapeId']}');
          String pcfCode = element['pcfCode'];
          String urlClient = AppUrl.getOneTier + pcfCode;
          print('urlClient: $urlClient');
          req = await http.get(Uri.parse(urlClient), headers: {
            "Accept": "application/json",
            "content-type": "application/json; charset=UTF-8",
            "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
          });
          print("res tier code: ${req.statusCode}");
          print("res tier body: ${req.body}");
          if (req.statusCode == 200) {
            print('element iss: $element');
            //   var res = json.decode(req.body);
            Client client = new Client(
              idOpp: element['demNumero'],
              id: element['pcfCode'],
              name: element['tiers']['rs'],
              phone: element['tiers']['tel1'],
              adress: element['adress']['title'],
              artCode: element['artCode'],
              //stat: element['etapeId'],
              priority: element['priorite'],
              emergency: element['urgence'],
              lib: element['objet'],
              resOppo: element,
              symptome: element['symptomes'],
              dateStart: DateTime.parse(element['date']),
            );
            //if(element['etapeId'] == 1 || element['etapeId'] == 2)
            provider.mapClientsWithCommandsInterventions.add(client);
            print(
                'size of rec: ${provider.mapClientsWithCommandsInterventions.length}');
          } else {
            print('grjtorotor');
            Client client = new Client(
              idOpp: element['demNumero'],
              id: element['pcfCode'],
              adress: element['adrCode'],
              artCode: element['artCode'],
              //stat: element['etapeId'],
              priority: element['priorite'],
              emergency: element['urgence'],
              lib: element['objet'],
              resOppo: element,
              symptome: element['symptomes'],
              dateStart: DateTime.parse(element['date']),
              //dateCreation: DateTime.parse(element['dateCreation'])
            );
            provider.mapClientsWithCommandsInterventions.add(client);
            print(
                'size of rec: ${provider.mapClientsWithCommandsInterventions.length}');
          }
        } catch (e) {
          print('err : $e');
        }
      }
      provider.mapClientsWithCommandsInterventions
          .sort((a, b) => a.dateStart!.compareTo(b.dateStart!));
    } else {
      print('Failed to load data');
    }
    provider.updateList();
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

  // Function to fetch JSON data from an API
  Future<void> fetchData(Client client) async {
    // print('stat: ${client.stat}');
    // String url = AppUrl.commandsOfOpportunite +
    //     AppUrl.user.etblssmnt!.code! +
    //     '/' +
    //     widget.client.idOpp!;
    // if (client.stat == 3 || client.stat == 5)
    //   url = AppUrl.deliveryOfOpportunite +
    //       AppUrl.user.etblssmnt!.code! +
    //       '/' +
    //       widget.client.idOpp!;
    // print('url of CmdOfOpp $url');
    String url = AppUrl.reclamation;
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res reclamation code : ${req.statusCode}");
    print("res reclamation body: ${req.body}");
    if (req.statusCode == 200) {
      var res = json.decode(req.body);
      widget.client.res = res;
      total = res['brut'];
      List<dynamic> data = res['lignes'];
      print('sizeof: ${data.length}');
      try {
        List<Product> products = [];
        await Future.forEach(data.toList(), (element) async {
          double remise = 0;
          double tva = 0;
          if (element['natTvatx'] != null) tva = element['natTvatx'];
          if (element['remise'] != null) remise = element['remise'];
          print('quantité: ${element['qte'].toString()}');
          double d = element['qte'];
          int quantity = d.toInt();
          // double dStock = element['stockDep'];
          // int quantityStock = dStock.toInt();
          var artCode = element['artCode'];
          print('imghhh $artCode');
          print('url: ${AppUrl.getUrlImage + '$artCode'}');
          http.Response req = await http
              .get(Uri.parse(AppUrl.getUrlImage + '$artCode'), headers: {
            "Accept": "application/json",
            "content-type": "application/json; charset=UTF-8",
            "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/",
          });
          print("res imgArticle code : ${req.statusCode}");
          print("res imgArticle body: ${req.body}");
          if (req.statusCode == 200) {
            List<dynamic> data = json.decode(req.body);
            var path = null;
            if (data.length > 0) {
              var item = data.first;
              print('item: ${item['path']}');
              path = AppUrl.baseUrl + item['path'];
              print('price: ${element['pPrv']} ${element['pBrut']} ');
              double total = 0;
              if (element['total'] != null)
                total = element['total'];
              else if (element['cout'] != null) total = element['cout'];
            }
            products.add(Product(
                quantity: quantity,
                price: element['pBrut'],
                total: total,
                remise: remise,
                tva: tva,
                id: element['artCode'],
                image: path,
                name: element['lib']));
          }
        }).then((value) {
          client.command = Command(
              res: res,
              id: res['numero'],
              date: DateTime.parse(res['date']),
              total: 0,
              paid: 0,
              products: products,
              nbProduct: products.length);
          print('size of products: ${products.length}');
        });

        // get image
      } catch (e, stackTrace) {
        print('Exception: $e');
        print('Stack trace: $stackTrace');
      }
    } else {
      url = AppUrl.devisOfOpportunite +
          AppUrl.user.etblssmnt!.code! +
          '/' +
          widget.client.idOpp!;
      print('url of devisOfOpp $url');
      req = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
        "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
      });
      print("res devisOpp code : ${req.statusCode}");
      print("res devisOpp body: ${req.body}");
      if (req.statusCode == 200) {
        respone = 200;
        icon = Icon(
          Icons.shopping_cart_checkout_sharp,
          color: Colors.orange,
        );
        print('rfrrfrfr: orange!');
        var res = json.decode(req.body);
        widget.client.res = res;
        total = res['brut'];
        List<dynamic> data = res['lignes'];
        print('sizeof: ${data.length}');
        try {
          List<Product> products = [];
          await Future.forEach(data.toList(), (element) async {
            double remise = 0;
            double tva = 0;
            if (element['natTvatx'] != null) tva = element['natTvatx'];
            if (element['remise'] != null) remise = element['remise'];
            print('quantité: ${element['qte'].toString()}');
            double d = element['qte'];
            int quantity = d.toInt();
            // double dStock = element['stockDep'];
            // int quantityStock = dStock.toInt();
            var artCode = element['artCode'];
            print('imghhh $artCode');
            print('url: ${AppUrl.getUrlImage + '$artCode'}');
            http.Response req = await http
                .get(Uri.parse(AppUrl.getUrlImage + '$artCode'), headers: {
              "Accept": "application/json",
              "content-type": "application/json; charset=UTF-8",
              "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/",
            });
            print("res imgArticle code : ${req.statusCode}");
            print("res imgArticle body: ${req.body}");
            if (req.statusCode == 200) {
              List<dynamic> data = json.decode(req.body);
              var path = null;
              if (data.length > 0) {
                var item = data.first;
                print('item: ${item['path']}');
                path = AppUrl.baseUrl + item['path'];
                print('price: ${element['pPrv']} ${element['pBrut']} ');
                double total = 0;
                if (element['total'] != null)
                  total = element['total'];
                else if (element['cout'] != null) total = element['cout'];
              }
              products.add(Product(
                  quantity: quantity,
                  price: element['pBrut'],
                  total: total,
                  remise: remise,
                  tva: tva,
                  id: element['artCode'],
                  image: path,
                  name: element['lib']));
            }
          }).then((value) {
            client.command = Command(
                res: res,
                id: res['numero'],
                date: DateTime.parse(res['date']),
                total: 0,
                paid: 0,
                products: products,
                nbProduct: products.length);
            print('size of products: ${products.length}');
            widget.client.command!.type = 'Devis';
          });

          // get image
        } catch (e, stackTrace) {
          print('Exception: $e');
          print('Stack trace: $stackTrace');
        }
      } else {
        respone = 404;
        client.command = null;
      }
    }
    print('command of ${client.name} ${client.id} is: ${client.command}');
    client.total = total.toString();
  }

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
            print('Error: ${snapshot.hasError} ');
            return Text('Error: ${snapshot.error}');
          } else {
            // print(
            //     'states is:: ${widget.client.stat} ${AppUrl.filtredOpporunity.pipeline!.steps.length}');
            // print(
            //     'condition: ${(AppUrl.filtredOpporunity.pipeline!.steps.where((element) => element.id == widget.client.stat!).length == 0)}');
            // if (AppUrl.filtredOpporunity.pipeline!.steps
            //         .where((element) => element.id == widget.client.stat!)
            //         .length ==
            //     0) return Container();
            return Column(
              children: [
                Container(
                  height: 170,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.person_pin_rounded,
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
                              : Text('Réclamation',
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
                              : Text('(étape)',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(color: Colors.red)),
                          (widget.client.resOppo['tiers']['rs'] != null)
                              ?Text('Client : ${widget.client.resOppo['tiers']['rs']}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(color: Colors.grey))
                              :Text('Client : ${widget.client.id}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(color: Colors.grey)),
                          Text('Adresse : ${widget.client.adress}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(color: Colors.grey)),
                          Text('Article : ${widget.client.artCode}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(color: Colors.grey)),
                          // (widget.client.command != null)
                          //     ? Text(
                          //         '${AppUrl.formatter.format(widget.client.command!.total)} DZD',
                          //         style: Theme.of(context)
                          //             .textTheme
                          //             .headline4!
                          //             .copyWith(
                          //                 color: color,
                          //                 fontWeight: FontWeight.normal),
                          //       )
                          //     : Text(
                          //         '${AppUrl.formatter.format(0)} DZD',
                          //         style: Theme.of(context)
                          //             .textTheme
                          //             .headline4!
                          //             .copyWith(
                          //                 color: color,
                          //                 fontWeight: FontWeight.normal),
                          //       ),

                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.date_range_outlined,
                                  color: primaryColor,
                                ),
                                Text(
                                  '${DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.client.dateStart!)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ]),
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
                                    showAlertDialog(context,
                                        'Aucune numéro de téléphone pour ce client');
                                },
                                icon: Icon(
                                  Icons.call,
                                  color: primaryColor,
                                )),
                            // IconButton(
                            //   onPressed: () {
                            //     print('client; ${widget.client.command}');
                            //     if (respone == 200) {
                            //       if (widget.client.command!.type ==
                            //           'Devis') {
                            //         PageNavigator(ctx: context).nextPage(
                            //             page: DevisPage(
                            //           client: widget.client,
                            //         ));
                            //       } else if (widget.client.stat == 3 ||
                            //           widget.client.stat == 5)
                            //         PageNavigator(ctx: context).nextPage(
                            //             page: CommandDelivredPage(
                            //           client: widget.client,
                            //         ));
                            //       else
                            //         PageNavigator(ctx: context).nextPage(
                            //             page: CommandPage(
                            //           client: widget.client,
                            //         ));
                            //     } else
                            //       PageNavigator(ctx: context).nextPage(
                            //           page: StorePage(
                            //         client: widget.client,
                            //       ));
                            //     //Navigator.pushNamed(context, '/home/command', arguments: client);
                            //   },
                            //   icon: (respone == 200)
                            //       ? icon //Image.asset('assets/caddie_rempli.png')
                            //       : icon,
                            //   //Icon(Icons.shopping_cart_outlined),
                            //   color: primaryColor,
                            // ),
                            // IconButton(
                            //     onPressed: () {
                            //       PageNavigator(ctx: context).nextPage(
                            //           page: ActivityListPage(
                            //         client: widget.client,
                            //       ));
                            //     },
                            //     icon: Icon(
                            //       Icons.local_activity_outlined,
                            //       color: primaryColor,
                            //     ))
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
            );
          }
        });
  }
}
