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
import 'package:sav_app/models/step_pip.dart';
import 'package:sav_app/screens/home_page/activities_pages/activity_list_page.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/routers.dart';
import 'package:sav_app/utils/snack_message.dart';
import 'package:sav_app/widgets/confirmation_opportunity_dialog.dart';
import 'package:sav_app/widgets/dialog_lib.dart';

import 'commads_view.dart';
import 'compte_rendus_view.dart';
import 'delivery_view.dart';
import 'devis_view.dart';
import 'notes_page/note_liste_page.dart';

class OneInterventionPage extends StatefulWidget {
  final Client client;

  const OneInterventionPage({super.key, required this.client});

  @override
  State<OneInterventionPage> createState() => _OneInterventionPageState();
}

class _OneInterventionPageState extends State<OneInterventionPage> {
  Widget icon = Icon(Icons.shopping_cart_outlined);
  int respone = 200;
  List<StepPip> steps = [];
  Product? product;

  int selectedItemIndex = 0; // Index of the selected item
  List<String> tabs = [
    'Général',
    'Activités & Notes',
    'Devis',
    'Commandes',
    'Livraisons',
    'Compte rendue',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(
          color: Colors.white, // Set icon color to white
        ),
        title: ListTile(
          title: Text(
            'Intervention pour : ',
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
              //String? s = widget.client.resOppo['etape']['libelle'];
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 50.0, // Adjust the height of the container
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: tabs.length,
                        // Number of items
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              // Handle item tap
                              setState(() {
                                selectedItemIndex = index;
                              });
                            },
                            child: Container(
                              width: 110.0,
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
                                  '${tabs[index]}',
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20.0),
                    processingTabSelected()
                  ],
                ),
              );
            }
          }),
    );
  }

  Widget processingTabSelected() {
    switch (selectedItemIndex) {
      case 0:
        return GeneralView(
          client: widget.client,
        );
      case 1:
        return ActionsAndNotesView(
          client: widget.client,
        );
      case 2:
        return DevisView(client: widget.client);
      case 3:
        return CommandsView(client: widget.client);
      case 4:
        return DelivreyView(
          client: widget.client,
        );
      case 5:
        return CompteRendusView(
          client: widget.client,
        );
    }
    return Container();
  }
}

class ActionsAndNotesView extends StatefulWidget {
  final Client client;

  const ActionsAndNotesView({super.key, required this.client});

  @override
  State<ActionsAndNotesView> createState() => _ActionsAndNotesViewState();
}

class _ActionsAndNotesViewState extends State<ActionsAndNotesView> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Gestion des activités',
                style: Theme.of(context).textTheme.headline4,
              ),
              IconButton(
                  onPressed: () {
                    print('irhgirr');
                    PageNavigator(ctx: context).nextPage(
                        page: ActivityListPage(
                      client: widget.client,
                    ));
                  },
                  icon: Icon(
                    Icons.local_activity_outlined,
                    color: primaryColor,
                  ))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Gestion des notes',
                style: Theme.of(context).textTheme.headline4,
              ),
              IconButton(
                  onPressed: () {
                    print('irhgirr');
                    PageNavigator(ctx: context).nextPage(
                        page: NoteListPage(
                      client: widget.client,
                    ));
                  },
                  icon: Icon(
                    Icons.note_outlined,
                    color: primaryColor,
                  ))
            ],
          ),
        ],
      ),
    );
  }
}

class GeneralView extends StatefulWidget {
  final Client client;

  const GeneralView({
    super.key,
    required this.client,
  });

  @override
  State<GeneralView> createState() => _GeneralViewState();
}

class _GeneralViewState extends State<GeneralView> {
  List<StepPip> steps = [];
  Product? product;

  Future<void> fetchData(Client client) async {
    steps = [];
    String url = AppUrl.getPipelinesSteps +
        client.resOppo['etape']['pipelineId'].toString();
    print('url of CmdOfOpp $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res allSteps code : ${req.statusCode}");
    print("res allSpeps body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      data.forEach((element) {
        steps.add(StepPip(
            id: element['id'],
            name: element['libelle'],
            color: element['couleur']));
      });
    }
    await fetchDataType();
    await fetchDataArticle();
  }

  Future<void> fetchDataType() async {
    String url = AppUrl.getOneTable + '/TPI/${widget.client.resOppo['type']}';
    print('url typeInter: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res interType code : ${req.statusCode}");
    print("res interType body: ${req.body}");
    if (req.statusCode == 200) {
      var res = json.decode(req.body);
      widget.client.resType = res;
    }
  }

  Future<String?> getUrlImage(String artCode) async {
    print('imghhh $artCode');
    var body = jsonEncode({
      'artCode': artCode,
    });
    print('url: ${AppUrl.getUrlImage + '$artCode'}');
    http.Response req =
        await http.get(Uri.parse(AppUrl.getUrlImage + '$artCode'), headers: {
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
        return AppUrl.baseUrl + item['path'];
      }
    }
    return null;
  }

  Future<void> fetchDataArticle() async {
    String url = AppUrl.articlesSuiv +
        '?numSerie=${widget.client.resOppo['demande']['equipementNumeroSerie']}';
    print('url CatInter: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res artSuiv code : ${req.statusCode}");
    print("res artSuiv body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      if (data.length == 0) return;
      Map<String, dynamic> element = data[0];
      await getUrlImage(element['artCode'].toString()).then((value) {
        double price = 0;
        if (element['article']['pVte'] != null)
          price = element['article']['pVte'];
        String? categ;
        try {
          categ = element['article']['marque']['lib'];
        } catch (_) {}
        product = Product(
            name: element['article']['lib'],
            numSerie: element['numSerie'],
            image: value,
            remise: 0,
            adrNumero: element['adrNumero'],
            tva: 0,
            category: categ,
            codeBar: element['article']['cbar'],
            isChosen: false,
            quantity: 0,
            price: price,
            total: 0,
            garanted: element['garantie'],
            dateExpired: DateTime.parse(element['dateFinGarantie']),
            id: element['artCode'].toString());
      });
    }
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

  void confirmationAndChangeState(
      BuildContext context, Client client, int value) {
    _showLoaderDialog(context);
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
    String url = AppUrl.intervention + '/${client.resOppo['numero']}';
    print(' editInter url  $url');
    client.resOppo['objet'] = client.lib;
    client.resOppo['date'] =
        DateFormat('yyyy-MM-ddTHH:mm:ss').format(client.dateStart!);
    client.resOppo['priorite'] = client.priority;
    client.resOppo['urgence'] = client.emergency;

    http.Response req = await http
        .put(Uri.parse(url), body: jsonEncode(client.resOppo), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res editInter code : ${req.statusCode} ");
    print("res editInter body: ${req.body}");
    if (req.statusCode == 200) {
      return true;
    } else {
      print('Failed to load data');
      return false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(
        'zedzedez ${widget.client.resOppo['demande']['equipementNumeroSerie']}');
  }

  @override
  Widget build(BuildContext context) {
    double priorityrating = 0;
    double emergencyrating = 0;
    if (widget.client.priority != null)
      priorityrating = widget.client.priority!.toDouble();
    if (widget.client.emergency != null)
      emergencyrating = widget.client.emergency!.toDouble();
    print('lib: ${widget.client.priority}');
    String? s = widget.client.resOppo['etape']['libelle'];
    return FutureBuilder(
        future: fetchData(widget.client),
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1.0),
            child: SingleChildScrollView(
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
                                  type: 'l\'objet',
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${widget.client.lib!}',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline3!
                                      .copyWith(color: primaryColor),
                                ),
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
                                  type: 'l\'objet',
                                  lib: widget.client.lib,
                                );
                              },
                            ).then((value) {
                              widget.client.lib = value;
                              setState(() {});
                            });
                          },
                          child: Center(
                            child: Text('Intervention',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3!
                                    .copyWith(color: Colors.black)),
                          ),
                        ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      //' (${items[widget.client.stat! - 1]})',
                      ' (${s})',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline3!.copyWith(
                          fontWeight: FontWeight.normal, color: Colors.red),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        //_selectStartDate(context);
                        showDateTimeDialog(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_outlined,
                              color: primaryColor, size: 20),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                              '${DateFormat('dd-MM-yyyy').format(widget.client.dateStart!)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal)),
                          SizedBox(
                            width: 30,
                          ),
                          Icon(Icons.access_time,
                              color: primaryColor, size: 20),
                          SizedBox(
                            width: 7,
                          ),
                          Text(
                              '${DateFormat('HH:mm').format(widget.client.dateStart!)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  (widget.client.resType != null)
                      ? Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                              'Type d\'intervention : ${widget.client.resType['lib']}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline6!),
                        )
                      : Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text('Type d\'intervention : ',
                              style: Theme.of(context).textTheme.headline6!),
                        ),
                  SizedBox(
                    height: 7,
                  ),
                  Divider(color: Colors.grey),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text('Client : ${widget.client.name!}',
                        style: Theme.of(context)
                            .textTheme
                            .headline3!
                            .copyWith(color: primaryColor)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.location_on_rounded,
                              color: primaryColor,
                              size: 20,
                            )),
                        (widget.client.resOppo['demande']['adress'] != null)
                            ? Text(
                                'Adresse : ${widget.client.resOppo['demande']['adress']['title']}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(color: Colors.grey))
                            : Text('Adresse : --',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(color: Colors.grey)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.location_on_rounded,
                              color: primaryColor,
                              size: 20,
                            )),
                        Text('Ville : ${widget.client.city}',
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: Colors.grey)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      (widget.client.phone != null)
                          ? Text(widget.client.phone!,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal))
                          : Container(),
                      IconButton(
                          onPressed: () {
                            if (widget.client.phone != null)
                              PhoneUtils().makePhoneCall(widget.client.phone!);
                            else
                              _showAlertDialog(context,
                                  'Aucune numéro de téléphone pour ce client');
                          },
                          icon: Icon(
                            Icons.call,
                            color: primaryColor,
                            size: 20,
                          )),
                      IconButton(
                          onPressed: () {
                            if (widget.client.phone != null)
                              PhoneUtils().makeSms(widget.client.phone!);
                            else
                              _showAlertDialog(context,
                                  'Aucune numéro de téléphone pour ce client');
                          },
                          icon: Icon(
                            Icons.mail_outline,
                            color: Colors.lightBlue,
                            size: 20,
                          )),
                    ],
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Center(
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       IconButton(
                  //           onPressed: () {},
                  //           icon: Icon(
                  //             Icons.storefront,
                  //             color: primaryColor,
                  //           )),
                  //       Text(
                  //           'Équipement : ${widget.client.resOppo['demande']['article']['lib']}',
                  //           style: Theme.of(context)
                  //               .textTheme
                  //               .headline4!
                  //               .copyWith(color: Colors.grey)),
                  //     ],
                  //   ),
                  // ),
                  Column(
                    children: [
                      Text('Équipement',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 0),
                        width: double.infinity,
                        height: 115,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(4),
                              height: 140,
                              width: 150,
                              child: (product!.image == null)
                                  ? Icon(Icons.image_not_supported_outlined,
                                      size: 150)
                                  : Image.network(
                                      '${product!.image}',
                                      // Replace with your image URL
                                      fit: BoxFit
                                          .cover, // Adjust the fit as needed (cover, contain, etc.)
                                    ),
                              // Image.asset(
                              //   'assets/product.png',
                              //   fit: BoxFit.cover,
                              // )
                            ),
                            // Text('(3)',
                            //     style: Theme
                            //         .of(context)
                            //         .textTheme
                            //         .headline4!
                            //         .copyWith(color: primaryColor)),

                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100,
                                  child: Text(
                                    '${product!.name}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3, // Limit to one line
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .copyWith(color: primaryColor),
                                  ),
                                ),
                                Text('${product!.category}',
                                    style:
                                        Theme.of(context).textTheme.headline6!),
                                Text('${product!.numSerie}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith(color: Colors.grey)),
                              ],
                            ),
                            (product!.dateExpired != null)
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (product!.dateExpired!
                                              .difference(DateTime.now())
                                              .inDays >
                                          0)
                                        Icon(
                                          Icons.gpp_good_outlined,
                                          color: Colors.green,
                                        )
                                      else
                                        Icon(
                                          Icons.gpp_bad_outlined,
                                          color: Colors.red,
                                        ),
                                      if (product!.dateExpired!
                                              .difference(DateTime.now())
                                              .inDays >
                                          0)
                                        Text(
                                          '${DateFormat('yyyy-MM-dd').format(product!.dateExpired!)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .copyWith(
                                                color: Colors.green,
                                              ),
                                        )
                                      else
                                        Text(
                                          '${DateFormat('yyyy-MM-dd').format(product!.dateExpired!)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .copyWith(
                                                color: Colors.red,
                                              ),
                                        )
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.gpp_bad_outlined,
                                        color: Colors.red,
                                      ),
                                      (product!.dateExpired != null)
                                          ? Text(
                                              '${DateFormat('yyyy-MM-dd').format(product!.dateExpired!)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .copyWith(
                                                    color: Colors.red,
                                                  ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      Text('Intervenant',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 0),
                        width: double.infinity,
                        height: 115,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(4),
                              height: 140,
                              width: 150,
                              child: CircleAvatar(
                                foregroundImage: NetworkImage(
                                    '${AppUrl.baseUrl}${widget.client.resOppo['applicationUser']['image']}'),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100,
                                  child: Text(
                                    '${widget.client.resOppo['applicationUser']['lastName']} ${widget.client.resOppo['applicationUser']['firstName']}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3, // Limit to one line
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .copyWith(color: primaryColor),
                                  ),
                                ),
                                Text(
                                    '${widget.client.resOppo['applicationUser']['phoneNumber']}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .copyWith(color: Colors.grey)),
                              ],
                            ),
                            Visibility(
                              visible: true,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        if (widget.client
                                                    .resOppo['applicationUser']
                                                ['phoneNumber'] !=
                                            null)
                                          PhoneUtils().makePhoneCall(widget
                                                  .client
                                                  .resOppo['applicationUser']
                                              ['phoneNumber']);
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
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return LibDialog(
                            type: 'commentaire',
                            lib: widget.client.resOppo['commentaire'],
                          );
                        },
                      ).then((value) {
                        widget.client.resOppo['commentaire'] = value;
                        setState(() {});
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.comment_outlined,
                                color: primaryColor,
                              )),
                          Container(
                            width: 250,
                            child: Text(
                                'Commentaire : ${widget.client.resOppo['commentaire']}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .copyWith(color: Colors.grey)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Priorité: ',
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .copyWith(fontWeight: FontWeight.bold),
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
                              widget.client.priority = rating.toInt();
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
                            .copyWith(fontWeight: FontWeight.bold),
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
                            widget.client.emergency = rating.toInt();
                          });
                        },
                      ),
                    ],
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30))),
                        onPressed: () {
                          showMenu(
                            context: context,
                            position: RelativeRect.fromLTRB(
                                100.0, 100.0, 100.0, 100.0),
                            items: steps.map((StepPip option) {
                              return PopupMenuItem<StepPip>(
                                value: option,
                                child: Text(option.name),
                              );
                            }).toList(),
                          ).then((selectedOption) async {
                            if (selectedOption != null) {
                              ConfirmationOppDialog confirmationOppDialog =
                                  ConfirmationOppDialog();
                              bool confirmed = await confirmationOppDialog
                                  .showConfirmationDialog(context, 'editInter');
                              if (confirmed) {
                                _showLoaderDialog(context);
                                widget.client.resOppo['etat'] =
                                    selectedOption.id;
                                editOpp(widget.client).then((value) {
                                  if (value) {
                                    Navigator.pop(context);
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
                                            page: OneInterventionPage(
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
                            }
                          });
                        },
                        child: Text(
                          "Modifier l'état",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
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
                              .showConfirmationDialog(context, 'editInter');
                          if (confirmed) {
                            _showLoaderDialog(context);
                            editOpp(widget.client).then((value) {
                              if (value) {
                                showMessage(
                                    message:
                                        'Intervention modifiée avec succès',
                                    context: context,
                                    color: primaryColor);
                                Navigator.pushNamedAndRemoveUntil(
                                        context, '/home', (route) => false)
                                    .then((value) => PageNavigator(ctx: context)
                                        .nextPage(
                                            page: OneInterventionPage(
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
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
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

_showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Container(
        width: 200, height: 100, child: Image.asset('assets/SAV-Loader.gif')),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
