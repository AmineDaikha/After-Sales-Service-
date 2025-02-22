import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/constants/utils.dart';
import 'package:sav_app/models/client.dart';
import 'package:sav_app/models/command.dart';
import 'package:sav_app/models/product.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/routers.dart';
import 'package:sav_app/utils/snack_message.dart';
import 'package:sav_app/widgets/confirmation_opportunity_dialog.dart';
import 'package:sav_app/widgets/dialog_lib.dart';
import 'package:sav_app/widgets/dialog_opp_state.dart';
import 'package:sav_app/widgets/payment_page.dart';

import 'activities_pages/activity_list_page.dart';
import 'command_delivred_page.dart';
import 'command_page.dart';
import 'init_store_page.dart';
import 'notes_page/note_liste_page.dart';

class OpportunityPage extends StatefulWidget {
  final Client client;

  const OpportunityPage({super.key, required this.client});

  @override
  State<OpportunityPage> createState() => _OpportunityPageState();
}

class _OpportunityPageState extends State<OpportunityPage> {
  Widget icon = Icon(Icons.shopping_cart_outlined);
  int respone = 200;

  List<String> items = [
    'A visité',
    'Visité',
    'Livré',
    'Encaissé',
    'Livré & encaissé',
    'Annulée'
  ];

  Future<void> fetchData(Client client) async {
    print('stat: ${client.stat}');
    String url = AppUrl.commandsOfOpportunite +
        AppUrl.user.etblssmnt!.code! +
        '/' +
        widget.client.idOpp!;
    if (client.stat == 3 || client.stat == 5) {
      url = AppUrl.deliveryOfOpportunite +
          AppUrl.user.etblssmnt!.code! +
          '/' +
          widget.client.idOpp!;
      widget.client.typeCommand = 'liv';
    }
    print('url of CmdOfOpp $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res cmdOpp code : ${req.statusCode}");
    print("res cmdOpp body: ${req.body}");
    if (req.statusCode == 200) {
      respone = 200;

      icon = Image.asset('assets/caddie_rempli.png');

      var res = json.decode(req.body);
      List<dynamic> data = res['lignes'];
      print('sizeof: ${data.length}');
      try {
        List<Product> products = [];
        Future.forEach(data.toList(), (element) async {
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
            if (data.length > 0) {
              var item = data.first;
              print('item: ${item['path']}');
              print('price: ${element['pPrv']} ${element['pBrut']} ');
              double total = 0;
              if (element['total'] != null)
                total = element['total'];
              else if (element['cout'] != null) total = element['cout'];
              products.add(Product(
                  quantity: quantity,
                  price: element['pBrut'],
                  total: total,
                  id: element['artCode'],
                  image: AppUrl.baseUrl + item['path'],
                  name: element['lib']));
            }
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
    print('command of ${client.name} ${client.id} is: ${client.command}');
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
    if (double.parse(widget.client.total.toString()) > 0) {
      color = Color(0xff049a9b);
    } else if (double.parse(widget.client.total.toString()) < 0) {
      color = Colors.red;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(
          color: Colors.white, // Set icon color to white
        ),
        title: ListTile(
          title: Text(
            'Intervention de : ',
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
      body: FutureBuilder(
          future: fetchData(widget.client),
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
              String? s = AppUrl.filtredOpporunity.pipeline!.steps
                  .where((element) => element.id == widget.client.stat!)
                  .first
                  .name;
              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 1.0),
                          child: Container(
                            height: 600,
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (widget.client.lib != null)
                                    ? GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return LibDialog(
                                                type: 'objet',
                                                lib: widget.client.lib,
                                              );
                                            },
                                          ).then((value) {
                                            widget.client.lib = value;
                                            setState(() {});
                                          });
                                        },
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${widget.client.lib!}',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline3!
                                                    .copyWith(
                                                        color: primaryColor),
                                              ),
                                              (widget.client.stat! > 0)
                                                  ? Text(
                                                      //' (${items[widget.client.stat! - 1]})',
                                                      ' (${s})',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline3!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  primaryColor),
                                                    )
                                                  : Text(''),
                                            ],
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return LibDialog(
                                                type: 'objet',
                                                lib: widget.client.lib,
                                              );
                                            },
                                          ).then((value) {
                                            widget.client.lib = value;
                                            setState(() {});
                                          });
                                        },
                                        child: Center(
                                          child: Text('Nom de l\'Affaire',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline2!
                                                  .copyWith(
                                                      color: Colors.black)),
                                        ),
                                      ),
                                SizedBox(
                                  height: 15,
                                ),
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      //_selectStartDate(context);
                                      showDateTimeDialog(context);
                                    },
                                    child: Text(
                                        '${DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.client.dateStart!)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2!
                                            .copyWith(
                                                fontStyle: FontStyle.italic,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.normal)),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Center(
                                  child: Text('client : ${widget.client.name!}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline2!
                                          .copyWith(color: Colors.black)),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                (widget.client.name2 != null)
                                    ? Center(
                                        child: Text(widget.client.name2!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4!
                                                .copyWith(color: Colors.black)),
                                      )
                                    : Container(),
                                SizedBox(
                                  height: 15,
                                ),
                                Center(
                                  child: Text('ville : ${widget.client.city!}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4!
                                          .copyWith(color: Colors.grey)),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    (widget.client.phone != null)
                                        ? Text(widget.client.phone!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline3!
                                                .copyWith(
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.normal))
                                        : Container(),
                                    IconButton(
                                        onPressed: () {
                                          if (widget.client.phone != null)
                                            PhoneUtils().makePhoneCall(
                                                widget.client.phone!);
                                          else
                                            _showAlertDialog(context,
                                                'Aucune numéro de téléphone pour ce client');
                                        },
                                        icon: Icon(
                                          Icons.call,
                                          color: primaryColor,
                                        )),
                                    IconButton(
                                        onPressed: () {
                                          if (widget.client.phone != null)
                                            PhoneUtils()
                                                .makeSms(widget.client.phone!);
                                          else
                                            _showAlertDialog(context,
                                                'Aucune numéro de téléphone pour ce client');
                                        },
                                        icon: Icon(
                                          Icons.mail_outline,
                                          color: Colors.lightBlue,
                                        )),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Center(
                                  child: Text(
                                    '${AppUrl.formatter.format(double.parse(widget.client.total!))} DZD',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline1!
                                        .copyWith(
                                            color: color,
                                            fontWeight: FontWeight.normal),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Priorité: ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    Align(
                                      child: RatingBar.builder(
                                        //ignoreGestures: true,
                                        initialRating: priorityrating,
                                        minRating: 1.0,
                                        maxRating: 5.0,
                                        itemCount: 5,
                                        itemSize: 35,
                                        // Number of stars
                                        itemBuilder: (context, index) => Icon(
                                          index >= priorityrating
                                              ? Icons.star_border_outlined
                                              : Icons.star,
                                          color: Colors.yellow,
                                        ),
                                        onRatingUpdate: (rating) {
                                          setState(() {
                                            widget.client.priority =
                                                rating.toInt();
                                          });
                                        },
                                      ),
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
                                          .headline4!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    RatingBar.builder(
                                      //ignoreGestures: true,
                                      initialRating: emergencyrating,
                                      minRating: 1.0,
                                      maxRating: 5.0,
                                      itemCount: 5,
                                      itemSize: 35,
                                      // Number of stars
                                      itemBuilder: (context, index) => Icon(
                                        index >= emergencyrating
                                            ? Icons.star_border_outlined
                                            : Icons.star,
                                        color: Colors.yellow,
                                      ),
                                      onRatingUpdate: (rating) {
                                        setState(() {
                                          widget.client.emergency =
                                              rating.toInt();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Gestion de la commande ',
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        print(
                                            'client; ${widget.client.command}');
                                        if (respone == 200) {
                                          if (widget.client.stat == 3 ||
                                              widget.client.stat == 5)
                                            PageNavigator(ctx: context)
                                                .nextPage(
                                                    page: CommandDelivredPage(
                                              client: widget.client,
                                            ));
                                          else
                                            PageNavigator(ctx: context)
                                                .nextPage(
                                                    page: CommandPage(
                                              client: widget.client,
                                            ));
                                        } else
                                          PageNavigator(ctx: context).nextPage(
                                              page: StorePage(
                                            client: widget.client,
                                                type: '',
                                          ));
                                        //Navigator.pushNamed(context, '/home/command', arguments: client);
                                      },
                                      icon: (respone == 200)
                                          ? Image.asset(
                                              'assets/caddie_rempli.png')
                                          : Icon(Icons.shopping_cart_outlined),
                                      color: primaryColor,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Gestion des activités ',
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          PageNavigator(ctx: context).nextPage(
                                              page: ActivityListPage(
                                            client: widget.client,
                                          ));
                                        },
                                        icon: Icon(
                                          Icons.local_activity_outlined,
                                          color: primaryColor,
                                        )),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Gestion des notes ',
                                      style:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          PageNavigator(ctx: context).nextPage(
                                              page: NoteListPage(
                                                  client: widget.client));
                                        },
                                        icon: Icon(
                                          Icons.note_outlined,
                                          color: primaryColor,
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ChoiceDialog();
                                },
                              ).then((value) {
                                PageNavigator page =
                                    PageNavigator(ctx: context);
                                print('value of result choice: $value');
                                if (value == 4) {
                                  page.nextPage(
                                      page: PaymentPage(
                                          client: widget.client, toStat: 4));
                                } else if (value == 5) {
                                  if (widget.client.command == null) {
                                    showMessage(
                                        message: 'Pas de commande',
                                        context: context,
                                        color: Colors.red);
                                  } else {
                                    if (widget.client.typeCommand == 'cmd') {
                                      page.nextPage(
                                          page: CommandPage(
                                              client: widget.client));
                                    } else {
                                      page.nextPage(
                                          page: PaymentPage(
                                              client: widget.client,
                                              toStat: 5));
                                    }
                                  }
                                } else if (value == 3) {
                                  if (widget.client.command == null) {
                                    showMessage(
                                        message: 'Pas de commande',
                                        context: context,
                                        color: Colors.red);
                                  } else {
                                    if (widget.client.typeCommand == 'cmd') {
                                      page.nextPage(
                                          page: CommandPage(
                                              client: widget.client));
                                    } else {
                                      showMessage(
                                          message: 'Commande déjà livré !',
                                          context: context,
                                          color: Colors.red);
                                    }
                                  }
                                } else
                                  confirmationAndChangeState(
                                      context, widget.client, value);
                              });
                            },
                            child: Text(
                              "Modifier l'état",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            onPressed: () async {
                              ConfirmationOppDialog confirmationOppDialog =
                                  ConfirmationOppDialog();
                              bool confirmed = await confirmationOppDialog
                                  .showConfirmationDialog(context, 'editOpp');
                              if (confirmed) {
                                showLoaderDialog(context);
                                editOpp(widget.client).then((value) {
                                  if (value) {
                                    showMessage(
                                        message:
                                            'Intervention modifiée avec succès',
                                        context: context,
                                        color: primaryColor);
                                    Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/home',
                                        (route) =>
                                            false).then((value) =>
                                        PageNavigator(ctx: context).nextPage(
                                            page: OpportunityPage(
                                                client: widget.client)));
                                  } else {
                                    Navigator.pop(context);
                                    showMessage(
                                        message:
                                            'Échec de modification de l\'intervention',
                                        context: context,
                                        color: Colors.red);
                                  }
                                });
                              }
                            },
                            child: Text(
                              "Modifier l'intervention",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          }),
    );
  }

  Future<void> showDateTimeDialog(BuildContext context) async {
    // Initialize result variables
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    // Show date picker
    selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
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

    // Check if date was selected
    if (selectedDate != null) {
      // Show time picker
      selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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

      // Handle both date and time selection
      if (selectedTime != null) {
        // Combine date and time and show final result
        DateTime selectedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        widget.client.dateStart = selectedDateTime;
        setState(() {});
      }
    }
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(
            color: primaryColor,
          ),
          Container(
              margin: EdgeInsets.only(left: 15), child: Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void confirmationAndChangeState(
      BuildContext context, Client client, int value) {
    showLoaderDialog(context);
    try {
      changeOppState(client, value).then((value) {
        Navigator.pop(context);
        if (value) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else {
          showMessage(
              message: 'Échec de modification de l\'état d\'intervention',
              context: context,
              color: Colors.red);
        }
      });
    } on SocketException catch (_) {
      print(":::: Internet connection is not available ");
      _showAlertDialog(context, 'Pas de connecxion !');
    }
  }

  Future<bool> changeOppState(Client client, int state) async {
    String url = AppUrl.opportunitiesChangeState + '${client.idOpp}/$state';
    print('res url $url');
    http.Response req = await http.put(Uri.parse(url),
        //body: body,
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
        });
    print("res state code : ${req.statusCode} ");
    print("res state body: ${req.body}");
    if (req.statusCode == 200) {
      return true;
    } else {
      print('Failed to load data');
      return false;
    }
  }

  Future<bool> editOpp(Client client) async {
    String url = AppUrl.editOpportunities + '${client.idOpp}';
    print('res url $url');
    client.resOppo['libelle'] = client.lib;
    client.resOppo['dateDebut'] =
        DateFormat('yyyy-MM-ddTHH:mm:ss').format(client.dateStart!);
    client.resOppo['priorite'] = client.priority;
    client.resOppo['urgence'] = client.emergency;

    http.Response req = await http
        .put(Uri.parse(url), body: jsonEncode(client.resOppo), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res editOpp code : ${req.statusCode} ");
    print("res editOpp body: ${req.body}");
    if (req.statusCode == 200) {
      return true;
    } else {
      print('Failed to load data');
      return false;
    }
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
