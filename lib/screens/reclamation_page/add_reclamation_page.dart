import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/http_requests/http_request.dart';
import 'package:sav_app/models/client.dart';
import 'package:sav_app/models/collaborator.dart';
import 'package:sav_app/models/pipeline.dart';
import 'package:sav_app/models/step_pip.dart';
import 'package:sav_app/models/team.dart';
import 'package:sav_app/models/type_activity.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/routers.dart';
import 'package:sav_app/utils/snack_message.dart';
import 'package:sav_app/widgets/address_list_page.dart';
import 'package:sav_app/widgets/alert.dart';
import 'package:sav_app/widgets/article_list_page.dart';
import 'package:sav_app/widgets/confirmation_dialog.dart';
import 'package:sav_app/widgets/text_field.dart';

import '../../widgets/clients_list_page.dart';

class AddReclamationPage extends StatefulWidget {
  const AddReclamationPage({
    super.key,
  });

  @override
  State<AddReclamationPage> createState() => _AddReclamationPageState();
}

class _AddReclamationPageState extends State<AddReclamationPage> {
  late DateTime selectedStartTimeDate = DateTime.now();
  late DateTime selectedEndTimeDate = DateTime.now();
  late Client? client;
  String selectedStateItem = '';
  double ratingPriority = 3.0;
  double ratingEmergency = 3.0;
  final List<String> options = ['Sur site client', 'Atelier'];
  String currentOption = '';
  final formKey = GlobalKey<FormState>();
  final TextEditingController _lib = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _comment = TextEditingController();
  final TextEditingController _client = TextEditingController();
  final TextEditingController _article = TextEditingController();
  late Collaborator selectedCollaborator = AppUrl.user.collaborator.first;
  late Team selectedTeam = AppUrl.filtredOpporunity.team!;
  TypeActivity? selectedSym;
  List<TypeActivity> syms = [];
  TypeActivity? selectedTypeRec;
  TypeActivity? selectedNatureRec;
  TypeActivity? selectedOriginRec;
  TypeActivity? selectedDiagnostic;
  TypeActivity? selectedCategoryRec;
  List<TypeActivity> typRec = [];
  List<TypeActivity> categoriesRec = [];
  TypeActivity? selectedLevel;
  List<TypeActivity> levels = [];
  List<TypeActivity> recCategories = [];
  List<TypeActivity> recNature = [];
  List<TypeActivity> recOrigin = [];
  List<TypeActivity> recDiagnostic = [];
  Pipeline? selectedPipeline;
  StepPip? selectedStepPip;
  bool first = true;
  bool siteOpt = true;
  bool workshopOpt = false;

  //List<String> typesList = ['Création Devis', 'Qualification Interventions', 'Rdv Client', 'Négociation', 'Réunion de travail'];

  Future<void> showDateTimeDialog(BuildContext context, String type) async {
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
        if (type == 'start')
          selectedStartTimeDate = selectedDateTime;
        else
          selectedEndTimeDate = selectedDateTime;
        print('date:: $type');
        setState(() {});
      }
    }
  }

  void handleCheckbox1(bool? value) {
    setState(() {
      siteOpt = value!;
      workshopOpt = !value;
    });
  }

  void handleCheckbox2(bool? value) {
    setState(() {
      workshopOpt = value!;
      siteOpt = !value;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentOption = options[0];
    //selectedStateItem = states.first;
    _client.text = 'Ajouter un demandeur';
    _address.text = 'Ajouter une adresse';
    _article.text = 'Ajouter un équipement';
    first = true;
    try {
      selectedStepPip = AppUrl.filtredOpporunity.team!.pipelines!
          .where((element) => element.id == 6)
          .first
          .steps
          .first;
    } catch (_) {}
  }

  void reload() {
    setState(() {
      client = AppUrl.selectedClient;
      _client.text = client!.name!;
      print('id and name client:  ${client!.id!} ${client!.name!}');
    });
  }

  void reload2() {
    try {
      print('bfkhbg ${client!.adress}');
      if (client!.lib != null) _address.text = client!.lib!;
      if (client!.city != null)
        _address.text = _address.text.trim() + ' ' + client!.city!;
    } catch (_) {}
  }

  void reload3() {
    try {
      _article.text = AppUrl.selectedProduct!.name!;
    } catch (_) {}
  }

  Future<void> fetchDataSym() async {
    first = false;
    String url = AppUrl.getSymptoms;
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res sym code : ${req.statusCode}");
    print("res sym body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      data.forEach((element) {
        syms.add(TypeActivity(code: element['code'], name: element['lib']));
      });
    }
    await fetchDataTypeRec();
    await fetchDataLevel();
    await fetchDataReclamationCategories();
    await fetchDataOrigin();
    await fetchDataNature();
    await fetchDataDiagnostic();
  }

  Future<void> fetchDataDiagnostic() async {
    first = false;
    String url = AppUrl.getDiagnostic;
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res getNatures code : ${req.statusCode}");
    print("res getNatures body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      data.forEach((element) {
        recDiagnostic
            .add(TypeActivity(code: element['code'], name: element['lib']));
      });
      if (recDiagnostic.length > 0) selectedDiagnostic = recDiagnostic.first;
    }
  }

  Future<void> fetchDataNature() async {
    first = false;
    String url = AppUrl.getNatures;
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res getNatures code : ${req.statusCode}");
    print("res getNatures body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      data.forEach((element) {
        recNature
            .add(TypeActivity(code: element['code'], name: element['lib']));
      });
      if (recNature.length > 0) selectedNatureRec = recNature.first;
    }
  }

  Future<void> fetchDataOrigin() async {
    first = false;
    String url = AppUrl.getOrigin;
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res getOrigin code : ${req.statusCode}");
    print("res getOrigin body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      data.forEach((element) {
        recOrigin
            .add(TypeActivity(code: element['code'], name: element['lib']));
      });
      if (recOrigin.isNotEmpty) selectedOriginRec = recOrigin.first;
    }
  }

  Future<void> fetchDataReclamationCategories() async {
    first = false;
    String url = AppUrl.getCategoriesRec;
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res catRec code : ${req.statusCode}");
    print("res catRec body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      data.forEach((element) {
        categoriesRec
            .add(TypeActivity(code: element['code'], name: element['lib']));
      });
    }
    selectedCategoryRec = categoriesRec.first;
    print(
        'rtth : ${typRec.where((element) => element.divers == selectedCategoryRec!.code).length}');
    selectedTypeRec = typRec
        .where((element) => element.divers == selectedCategoryRec!.code)
        .first;
    print('frrgrr : ${selectedTypeRec!.divers}');
  }

  Future<void> fetchDataTypeRec() async {
    first = false;
    String url = AppUrl.getTypeRec;
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res typeRec code : ${req.statusCode}");
    print("res typeRec body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      data.forEach((element) {
        typRec.add(TypeActivity(
            code: element['code'],
            name: element['lib'],
            divers: element['categCode']));
      });
    }
  }

  Future<void> fetchDataLevel() async {
    first = false;
    String url = AppUrl.getLevels;
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res level code : ${req.statusCode}");
    print("res level body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      data.forEach((element) {
        levels.add(TypeActivity(code: element['code'], name: element['lib']));
      });
    }
  }

  // Future<void> fetchDataSteps() async {
  //   String url = AppUrl.getPipelinesSteps + '6';
  //   print('url: $url');
  //   http.Response req = await http.get(Uri.parse(url), headers: {
  //     "Accept": "application/json",
  //     "content-type": "application/json; charset=UTF-8",
  //     "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
  //   });
  //   print("res sym code : ${req.statusCode}");
  //   print("res sym body: ${req.body}");
  //   if (req.statusCode == 200) {
  //     List<dynamic> steps = json.decode(req.body);
  //     steps.forEach((step) {
  //       allSteps.add(StepPip(
  //           id: step['id'],
  //           name: step['libelle'],
  //           color: element['couleur']));
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white, // Set icon color to white
            ),
            backgroundColor: primaryColor,
            title: Text(
              'Nouvelle réclamation',
              style: Theme.of(context)
                  .textTheme
                  .headline3!
                  .copyWith(color: Colors.white),
            ),
          ),
          body: FutureBuilder(
              future: (first) ? fetchDataSym() : null,
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
                return ListView(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              PageNavigator(ctx: context)
                                  .nextPage(
                                      page: ClientsListForAddClientPage(
                                callback: reload,
                              ))
                                  .then((value) {
                                print('finish');
                              });
                            },
                            icon: Icon(
                              Icons.person_add_alt,
                              color: primaryColor,
                            ),
                          ),
                          // Your icon
                          SizedBox(width: 16.0),
                          // Adjust the space between icon and text field
                          Expanded(
                            child: customTextField(
                              obscure: false,
                              enable: false,
                              controller: _client,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              try {
                                print('client: ${client!.id}');
                              } catch (_) {
                                _showAlertDialog(context,
                                    'Il faut choisir un client d\'abord !');
                                return;
                              }
                              PageNavigator(ctx: context)
                                  .nextPage(
                                      page: ArticlesListPage(
                                callback: reload3,
                                client: client!,
                              ))
                                  .then((value) {
                                print('finish');
                              });
                            },
                            icon: Icon(
                              Icons.storefront,
                              color: primaryColor,
                            ),
                          ),
                          // Your icon
                          SizedBox(width: 16.0),
                          // Adjust the space between icon and text field
                          Expanded(
                            child: customTextField(
                              obscure: false,
                              enable: false,
                              controller: _article,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              try {
                                print('client: ${client}');
                              } catch (_) {
                                _showAlertDialog(context,
                                    'Il faut choisir un client d\'abord !');
                                return;
                              }
                              PageNavigator(ctx: context)
                                  .nextPage(
                                  page: AddressListForAddClientPage(
                                    callback: reload2,
                                    client: client!,
                                  ))
                                  .then((value) {
                                print('finish');
                              });
                            },
                            icon: Icon(
                              Icons.add_location_alt_outlined,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: customTextField(
                              obscure: false,
                              enable: false,
                              controller: _address,
                              //hint: 'Adresse',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      child: customTextField(
                        obscure: false,
                        controller: _lib,
                        hint: 'Objet',
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      title: Text(
                        'Catégorie de réclamation',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: DropdownButtonFormField<TypeActivity>(
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(width: 2, color: primaryColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(width: 2, color: primaryColor),
                            )),
                        hint: Text(
                          'Selectioner catégorie de réclamation',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(color: Colors.grey),
                        ),
                        value: selectedCategoryRec,
                        onChanged: (newValue) async {
                          print('ffffff');
                          selectedCategoryRec = newValue!;
                          selectedTypeRec = typRec
                              .where((element) =>
                                  element.divers == selectedCategoryRec!.code)
                              .first;
                          setState(() {});
                        },
                        items: categoriesRec
                            .map<DropdownMenuItem<TypeActivity>>(
                                (TypeActivity value) {
                          return DropdownMenuItem<TypeActivity>(
                            value: value,
                            child: Text(
                              value.name!,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Type de réclamation',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: DropdownButtonFormField<TypeActivity>(
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(width: 2, color: primaryColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(width: 2, color: primaryColor),
                            )),
                        hint: Text(
                          'Selectioner type de réclamation',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(color: Colors.grey),
                        ),
                        value: selectedTypeRec,
                        onChanged: (newValue) async {
                          print('ffffff');
                          selectedTypeRec = newValue!;
                          setState(() {});
                        },
                        items: typRec
                            .where((element) =>
                                element.divers == selectedCategoryRec!.code)
                            .map<DropdownMenuItem<TypeActivity>>(
                                (TypeActivity value) {
                          return DropdownMenuItem<TypeActivity>(
                            value: value,
                            child: Text(
                              value.name!,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Nature de réclamation',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: DropdownButtonFormField<TypeActivity>(
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(width: 2, color: primaryColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(width: 2, color: primaryColor),
                            )),
                        hint: Text(
                          'Selectioner la nature de réclamation',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(color: Colors.grey),
                        ),
                        value: selectedNatureRec,
                        onChanged: (newValue) async {
                          print('ffffff');
                          selectedNatureRec = newValue!;
                          setState(() {});
                        },
                        items: recNature.map<DropdownMenuItem<TypeActivity>>(
                            (TypeActivity value) {
                          return DropdownMenuItem<TypeActivity>(
                            value: value,
                            child: Text(
                              value.name!,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Origine de réclamation',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: DropdownButtonFormField<TypeActivity>(
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(width: 2, color: primaryColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(width: 2, color: primaryColor),
                            )),
                        hint: Text(
                          'Selectioner l\'origine de réclamation',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(color: Colors.grey),
                        ),
                        value: selectedOriginRec,
                        onChanged: (newValue) async {
                          print('ffffff');
                          selectedOriginRec = newValue!;
                          setState(() {});
                        },
                        items: recOrigin.map<DropdownMenuItem<TypeActivity>>(
                            (TypeActivity value) {
                          return DropdownMenuItem<TypeActivity>(
                            value: value,
                            child: Text(
                              value.name!,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Lieu d\'intervention',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      // subtitle: Expanded(
                      //   child: Column(
                      //     children: [
                      //       ListTile(
                      //         title: Text(
                      //           options[0],
                      //           style: TextStyle(color: primaryColor, fontSize: 11),
                      //         ),
                      //         leading: Radio(
                      //           activeColor: primaryColor,
                      //           value: options[0],
                      //           groupValue: currentOption,
                      //           onChanged: (value) {
                      //             setState(() {
                      //               currentOption = value.toString();
                      //             });
                      //           },
                      //         ),
                      //       ),
                      //       ListTile(
                      //         title: Text(
                      //           options[1],
                      //           style: TextStyle(color: primaryColor, fontSize: 11),
                      //         ),
                      //         leading: Radio(
                      //           value: options[1],
                      //           activeColor: primaryColor,
                      //           groupValue: currentOption,
                      //           onChanged: (value) {
                      //             setState(() {
                      //               currentOption = value.toString();
                      //             });
                      //           },
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                activeColor: primaryColor,
                                value: siteOpt,
                                onChanged: handleCheckbox1,
                              ),
                              Text(
                                '${options[0]}',
                                style: Theme.of(context).textTheme.headline5,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                activeColor: primaryColor,
                                value: workshopOpt,
                                onChanged: handleCheckbox2,
                              ),
                              Text(
                                '${options[1]}',
                                style: Theme.of(context).textTheme.headline5,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Visibility(
                      visible: AppUrl.user.teams.length > 1,
                      child: ListTile(
                        title: Text(
                          'Filtre des équipes',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: DropdownButtonFormField<Team>(
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(width: 2, color: primaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(width: 2, color: primaryColor),
                              )),
                          hint: Text(
                            'Selectioner l\'équipe',
                            style: Theme.of(context)
                                .textTheme
                                .headline4!
                                .copyWith(color: Colors.grey),
                          ),
                          value: selectedTeam,
                          onChanged: (newValue) async {
                            print('ffffff');
                            selectedTeam = newValue!;

                            if (newValue.id != -1) {
                              // get Collaborateurs
                              final Map<String, String> headers = {
                                "Accept": "application/json",
                                "content-type":
                                    "application/json; charset=UTF-8",
                                "Referer": "http://" +
                                    AppUrl.user.company! +
                                    ".localhost:4200/",
                                'Authorization': 'Bearer ${AppUrl.user.token}',
                              };
                              if (newValue.id == AppUrl.user.equipeId) {
                                AppUrl.user.collaborator = [
                                  Collaborator(
                                    id: '-1',
                                    userName: 'Moi',
                                  )
                                ];
                                selectedCollaborator =
                                    AppUrl.user.collaborator.first;
                                AppUrl.filtredOpporunity.collaborateur =
                                    AppUrl.user.collaborator.first;
                              } else {
                                String url = AppUrl.getCollaborateur +
                                    newValue.id.toString();
                                print('url of getCollaborateurs $url');
                                http.Response req = await http
                                    .get(Uri.parse(url), headers: headers);
                                print(
                                    "res Collaborateur code : ${req.statusCode}");
                                print("res Collaborateur body: ${req.body}");
                                if (req.statusCode == 200 ||
                                    req.statusCode == 201) {
                                  List<dynamic> data = json.decode(req.body);
                                  //AppUrl.user.collaborator = [];
                                  print('size from api: ${data.length}');
                                  List<Collaborator> collaborators = [];
                                  data.forEach((element) {
                                    try {
                                      collaborators.add(Collaborator(
                                        id: element['id'],
                                        userName: element['userName'],
                                      ));
                                    } catch (e) {
                                      print('error: $e');
                                    }
                                  });
                                  selectedCollaborator = collaborators.first;
                                  collaborators.insert(
                                      0,
                                      Collaborator(
                                        id: '-1',
                                        userName: 'Moi',
                                      ));
                                  AppUrl.user.collaborator =
                                      List<Collaborator>.from(collaborators)
                                          .where((element) =>
                                              element.userName !=
                                              AppUrl.user.userId)
                                          .toList();
                                  AppUrl.filtredOpporunity.collaborateur =
                                      AppUrl.user.collaborator.first;
                                  print(
                                      'collaborators size: ${AppUrl.user.collaborator.length}');
                                }
                              }
                            } else {
                              selectedCollaborator =
                                  AppUrl.user.allCollaborator.first;
                              AppUrl.filtredOpporunity.collaborateur =
                                  AppUrl.user.collaborator.first;
                              AppUrl
                                  .user.collaborator = List<Collaborator>.from(
                                      AppUrl.user.allCollaborator)
                                  .where((element) =>
                                      element.userName != AppUrl.user.userId)
                                  .toList();
                            }
                            setState(() {});
                          },
                          items: AppUrl.user.teams
                              .map<DropdownMenuItem<Team>>((Team value) {
                            return DropdownMenuItem<Team>(
                              value: value,
                              child: Text(
                                value.lib!,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: AppUrl.user.collaborator.length > 1,
                      child: ListTile(
                        title: Text(
                          'Affecté à ',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: DropdownButtonFormField<Collaborator>(
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(width: 2, color: primaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(width: 2, color: primaryColor),
                              )),
                          hint: Text(
                            'Selectioner le collaborateur',
                            style: Theme.of(context)
                                .textTheme
                                .headline4!
                                .copyWith(color: Colors.grey),
                          ),
                          value: selectedCollaborator,
                          onChanged: (newValue) {
                            setState(() {
                              selectedCollaborator = newValue!;
                              String collabrator =
                                  selectedCollaborator.userName!;
                              if (collabrator == 'Moi')
                                collabrator = AppUrl.user.userId!;
                              print('collaborator $collabrator');
                            });
                          },
                          items: AppUrl.user.collaborator
                              .map<DropdownMenuItem<Collaborator>>(
                                  (Collaborator value) {
                            return DropdownMenuItem<Collaborator>(
                              value: value,
                              child: Text(
                                value.userName!,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: false,
                      child: ListTile(
                        title: Text(
                          'Pipeline ',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: DropdownButtonFormField<Pipeline>(
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(width: 2, color: primaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(width: 2, color: primaryColor),
                              )),
                          hint: Text(
                            'Selectioner pipeline',
                            style: Theme.of(context)
                                .textTheme
                                .headline5!
                                .copyWith(color: Colors.grey),
                          ),
                          value: selectedPipeline,
                          onChanged: (newValue) {
                            selectedPipeline = newValue!;
                            String collabrator = selectedPipeline!.name!;
                            AppUrl.filtredOpporunity.pipeline =
                                selectedPipeline;
                            AppUrl.filtredOpporunity.stepPip =
                                selectedPipeline!.steps.first;
                            selectedStepPip = AppUrl.filtredOpporunity.stepPip!;
                            print(
                                'size of steps: ${AppUrl.filtredOpporunity.pipeline!.steps.length}');
                            print(
                                'size of steps: ${selectedPipeline!.steps.length}');
                            if (collabrator == '${AppUrl.user.userId}')
                              collabrator = AppUrl.user.userId!;
                            print('collaborator $collabrator');
                            setState(() {});
                          },
                          items: AppUrl.filtredOpporunity.team!.pipelines!
                              .where((element) => element.id == 6)
                              .map<DropdownMenuItem<Pipeline>>(
                                  (Pipeline value) {
                            return DropdownMenuItem<Pipeline>(
                              value: value,
                              child: Text(
                                value.name!,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    ListTile(
                      title: Text(
                        'Etat',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: DropdownButtonFormField<StepPip>(
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(width: 2, color: primaryColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(width: 2, color: primaryColor),
                            )),
                        hint: Text(
                          'Selectioner l\'état ',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(color: Colors.grey),
                        ),
                        value: selectedStepPip,
                        onChanged: (newValue) {
                          setState(() {
                            selectedStepPip = newValue!;
                          });
                        },
                        items: AppUrl.filtredOpporunity.team!.pipelines!
                            .where((element) => element.id == 6)
                            .first
                            .steps
                            .map<DropdownMenuItem<StepPip>>((StepPip value) {
                          return DropdownMenuItem<StepPip>(
                            value: value,
                            child: Text(
                              value.name,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Diagnostic client',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: DropdownButtonFormField<TypeActivity>(
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(width: 2, color: primaryColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(width: 2, color: primaryColor),
                            )),
                        hint: Text(
                          'Selectioner le diagnostic client',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(color: Colors.grey),
                        ),
                        value: selectedDiagnostic,
                        onChanged: (newValue) async {
                          print('ffffff');
                          selectedDiagnostic = newValue!;
                          setState(() {});
                        },
                        items: recDiagnostic.map<DropdownMenuItem<TypeActivity>>(
                                (TypeActivity value) {
                              return DropdownMenuItem<TypeActivity>(
                                value: value,
                                child: Text(
                                  value.name!,
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Symptomes',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: DropdownButtonFormField<TypeActivity>(
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(width: 2, color: primaryColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(width: 2, color: primaryColor),
                            )),
                        hint: Text(
                          'Selectioner symptomes',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(color: Colors.grey),
                        ),
                        value: selectedSym,
                        onChanged: (newValue) async {
                          print('ffffff');
                          selectedSym = newValue!;
                          setState(() {});
                        },
                        items: syms.map<DropdownMenuItem<TypeActivity>>(
                            (TypeActivity value) {
                          return DropdownMenuItem<TypeActivity>(
                            value: value,
                            child: Text(
                              value.name!,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Niveau de compétence requis',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: DropdownButtonFormField<TypeActivity>(
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(width: 2, color: primaryColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(width: 2, color: primaryColor),
                            )),
                        hint: Text(
                          'Selectioner niveau de réclamation',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(color: Colors.grey),
                        ),
                        value: selectedLevel,
                        onChanged: (newValue) async {
                          print('ffffff');
                          selectedLevel = newValue!;
                          setState(() {});
                        },
                        items: levels.map<DropdownMenuItem<TypeActivity>>(
                            (TypeActivity value) {
                          return DropdownMenuItem<TypeActivity>(
                            value: value,
                            child: Text(
                              value.name!,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      child: customTextFieldEmpty(
                        obscure: false,
                        controller: _comment,
                        hint: 'Commentaire',
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Priorité',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        RatingBar.builder(
                          initialRating: 3.0,
                          minRating: 1.0,
                          maxRating: 5.0,
                          itemCount: 5,
                          // Number of stars
                          itemBuilder: (context, index) => Icon(
                            index >= ratingPriority
                                ? Icons.star_border_outlined
                                : Icons.star,
                            color: Colors.yellow,
                          ),
                          onRatingUpdate: (rating) {
                            print('New rating: $rating');
                            setState(() {
                              ratingPriority = rating;
                              print('rrrr: $ratingPriority');
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Urgence',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        RatingBar.builder(
                          initialRating: 3.0,
                          minRating: 1.0,
                          maxRating: 5.0,
                          itemCount: 5,
                          // Number of stars
                          itemBuilder: (context, index) => Icon(
                            index >= ratingEmergency
                                ? Icons.star_border_outlined
                                : Icons.star,
                            color: Colors.yellow,
                          ),
                          onRatingUpdate: (rating) {
                            print('New rating: $rating');
                            setState(() {
                              ratingEmergency = rating;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      onTap: () {
                        showDateTimeDialog(context, 'start');
                      },
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(
                                'Début de la réclamation',
                                textAlign: TextAlign.left,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                              width: 200,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                color: primaryColor,
                              ),
                              Text(
                                '${DateFormat('dd-MM-yyyy HH:mm:ss').format(selectedStartTimeDate)}',
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Visibility(
                      visible: false,
                      child: InkWell(
                        onTap: () {
                          showDateTimeDialog(context, 'end');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              color: primaryColor,
                            ),
                            Container(
                              width: 50,
                              child: Text(
                                'Fin  ',
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                            Text(
                              '${DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedEndTimeDate)}',
                              style: Theme.of(context).textTheme.headline3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30))),
                        onPressed: () async {
                          if (formKey.currentState != null &&
                              formKey.currentState!.validate()) {
                            if(_lib.text.trim() == null || _lib.text.trim().isEmpty){
                              _showAlertDialog(context,
                                  'Il faut entrer l\'objet !');
                              return;
                            }
                            try {
                              print('client: ${client}');
                            } catch (_) {
                              _showAlertDialog(context,
                                  'Il faut choisir un client d\'abord !');
                              return;
                            }
                            try {
                              print('client: ${client!.adress!}');
                            } catch (_) {
                              _showAlertDialog(context,
                                  'Il faut choisir une adresse d\'abord !');
                              return;
                            }
                            try {
                              print('article: ${AppUrl.selectedProduct!.name}');
                            } catch (_) {
                              _showAlertDialog(context,
                                  'Il faut choisir un article d\'abord !');
                              return;
                            }
                            try {
                              print('client: ${selectedSym!.code}');
                            } catch (_) {
                              _showAlertDialog(context,
                                  'Il faut choisir une symptome d\'abord !');
                              return;
                            }
                            try {
                              print('client: ${selectedTypeRec!.code}');
                            } catch (_) {
                              _showAlertDialog(context,
                                  'Il faut choisir un type d\'abord !');
                              return;
                            }
                            try {
                              print('client: ${selectedLevel!.code}');
                            } catch (_) {
                              _showAlertDialog(context,
                                  'Il faut choisir un niveau d\'abord !');
                              return;
                            }
                            print('rating;; $ratingPriority');
                            print('rating;; $ratingEmergency');
                            // final provider = Provider.of<ActivityProvider>(context,
                            //     listen: false);
                            // provider.activityList.add(activity);
                            print(
                                'id and name client:  ${client!.id!} ${client!.name!}');
                            if (DateTime.now()
                                    .difference(selectedStartTimeDate)
                                    .inMinutes >
                                0) {
                              showAlertDialog(context,
                                  'Date doit être supérieur à date actuelle !');
                              return;
                            }

                            ConfirmationDialog confirmationDialog =
                                ConfirmationDialog();
                            bool confirmed = await confirmationDialog
                                .showConfirmationDialog(context, 'confirmRec');
                            if (confirmed) {
                              // confirm
                              showLoaderDialog(context);
                              client!.lib = _lib.text.trim();
                              client!.dateStart = selectedStartTimeDate;
                              client!.priority = ratingPriority.toInt();
                              client!.emergency = ratingEmergency.toInt();
                              client!.comment = _comment.text.trim();
                              client!.stat = selectedStepPip!.id;
                              sendReclamation(context, client!).then((value) {
                                if (value) {
                                  HttpRequestApp().sendItinerary('REC');
                                  showMessage(
                                      message:
                                          'Réclation a été créée avec succès',
                                      context: context,
                                      color: primaryColor);
                                  Navigator.pop(context);
                                  Future.delayed(Duration(seconds: 4))
                                      .then((value) {
                                    Navigator.pushNamedAndRemoveUntil(context,
                                        '/reclamation', (route) => false);
                                  });
                                } else {
                                  showMessage(
                                      message:
                                          'Échec de creation de la réclamation',
                                      context: context,
                                      color: Colors.red);
                                  Navigator.pop(context);
                                }
                              });
                            }
                          }
                        },
                        child: const Text(
                          "AJOUTER",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                );
              }),
        ));
  }

  Future<bool> sendReclamation(BuildContext context, Client client) async {
    print('date is: ${client.dateStart}');
    print('userId: ${AppUrl.user.userId}');
    print('selectedStepPip: ${selectedStepPip!.id}');
    if (siteOpt)
      currentOption = options[0];
    else {
      currentOption = options[1];
    }
    String? collabrator = selectedCollaborator.salCode!;
    if (selectedCollaborator.userName == 'Moi')
      collabrator = AppUrl.user.salCode!;
    print('collaborator $collabrator');
    print('hgeorghoe');
    Map<String, dynamic> jsonIntervention = {
      "Numero": "001",
      "objet": "${client.lib}",
      "commentaire": "${client.comment}",
      "symptomes": "${selectedSym!.code}",
      "typeDemande": "${selectedTypeRec!.code}",
      "niveau": "${selectedLevel!.code}",
      "lieuIntervention": "${currentOption}",
      "natureCode": selectedNatureRec!.code,
      "origin": selectedOriginRec!.code,
      //"etat": selectedStepPip.id,
      "salCode": "$collabrator",
      "adrCode": "${client.adress}",
      "adrNum": "${AppUrl.selectedProduct!.adrNumero}",
      "artCode": "${AppUrl.selectedProduct!.id}",
      "equipementNumeroSerie": "${AppUrl.selectedProduct!.numSerie}",
      "etat": '${client.stat}',
      "dateCreation": DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()),
      "dateDemande":
          DateFormat('yyyy-MM-ddTHH:mm:ss').format(client!.dateStart!),
      "date": DateFormat('yyyy-MM-ddTHH:mm:ss').format(client!.dateStart!),
      "dateCloture":
          DateFormat('yyyy-MM-ddTHH:mm:ss').format(client!.dateStart!),
      "priorite": client.priority,
      "urgence": client.emergency,
      "userCreat": "${AppUrl.user.userId}",
      "pcfCode": client.id,
      "etbCode": AppUrl.user.etblssmnt!.code!,
    };
    Map<String, dynamic> jsonObject = {
      "lieuIntervention": "${currentOption}",
      "natureCode": selectedNatureRec!.code,
      "origin": selectedOriginRec!.code,
      "objet": "${client.lib}",
      "commentaire": "${client.comment}",
      "symptomes": "${selectedSym!.code}",
      "typeDemande": "${selectedTypeRec!.code}",
      "type": "${selectedTypeRec!.code}",
      "categ": "${selectedCategoryRec!.code}",
      "niveau": "${selectedLevel!.code}",
      //"etat": selectedStepPip.id,
      "salCode": "${AppUrl.user.salCode}",
      "adrCode": "${client.adress}",
      "adrNum": "${AppUrl.selectedProduct!.adrNumero}",
      "artCode": "${AppUrl.selectedProduct!.id}",
      "equipementNumeroSerie": "${AppUrl.selectedProduct!.numSerie}",
      "etat": '${client.stat}',
      "dateCreation": DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()),
      "dateDemande":
          DateFormat('yyyy-MM-ddTHH:mm:ss').format(client!.dateStart!),
      "date": DateFormat('yyyy-MM-ddTHH:mm:ss').format(client!.dateStart!),
      "priorite": client.priority,
      "urgence": client.emergency,
      "userCreat": "${AppUrl.user.userId}",
      "pcfCode": client.id,
      "etbCode": AppUrl.user.etblssmnt!.code!,
      "interventions": [jsonIntervention],
    };
    print('objet json: ${jsonObject}');

    String url = AppUrl.reclamation;
    print('url: $url');
    http.Response req =
        await http.post(Uri.parse(url), body: jsonEncode(jsonObject), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res addRec code : ${req.statusCode}");
    print("res addRec body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}

showLoaderDialog(BuildContext context) {
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
              Navigator.pop(context);
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
