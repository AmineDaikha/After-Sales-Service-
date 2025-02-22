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
import 'package:sav_app/widgets/alert.dart';
import 'package:sav_app/widgets/confirmation_dialog.dart';
import 'package:sav_app/widgets/text_field.dart';

import 'clients_list_page.dart';
import 'reclamation_list_page.dart';

class AddInerventionPage extends StatefulWidget {
  const AddInerventionPage({
    super.key,
  });

  @override
  State<AddInerventionPage> createState() => _AddInerventionPageState();
}

class _AddInerventionPageState extends State<AddInerventionPage> {
  late DateTime selectedStartTimeDate = DateTime.now();
  late DateTime selectedEndTimeDate = DateTime.now();
  late Client? client;
  double ratingPriority = 3.0;
  double ratingEmergency = 3.0;
  final formKey = GlobalKey<FormState>();
  final TextEditingController _lib = TextEditingController();
  final TextEditingController _symptome = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _comment = TextEditingController();

  //final TextEditingController _client = TextEditingController();
  final TextEditingController _demande = TextEditingController();
  late Collaborator selectedCollaborator = AppUrl.user.collaborator.first;
  late Team selectedTeam = AppUrl.filtredOpporunity.team!;
  late Pipeline selectedPipeline = AppUrl.filtredOpporunity.pipeline!;

  //late StepPip selectedStepPip = AppUrl.filtredOpporunity.stepPip!;
  StepPip? selectedStepPip;
  List<TypeActivity> interNatures = [];
  List<TypeActivity> interTypes = [];
  List<TypeActivity> recDiagnostic = [];
  TypeActivity? selectedNature;
  TypeActivity? selectedDiagnostic;
  TypeActivity? selectedType;
  bool first = true;

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_client.text = 'Ajouter un Tiers';
    _demande.text = 'Sélectionner une réclamation';
    try {
      selectedStepPip = AppUrl.filtredOpporunity.team!.pipelines!
          .where((element) => element.id == 3)
          .first
          .steps
          .first;
    } catch (_) {}
  }

  void reload() {
    setState(() {
      client = AppUrl.selectedClient;
      //_client.text = client!.name!;
      _demande.text = 'Réclamation de : ' + client!.name!;
      print('id and name client:  ${client!.id!} ${client!.name!}');
    });
  }

  Future<void> fetchDataNature() async {
    first = false;
    String url = AppUrl.getInterNatures;
    print('url CatInter: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res interNature code : ${req.statusCode}");
    print("res interNature body: ${req.body}");
    if (req.statusCode == 200) {
      interNatures.clear();
      List<dynamic> data = json.decode(req.body);
      data.forEach((element) {
        interNatures
            .add(TypeActivity(code: element['code'], name: element['lib']));
      });
      if (interNatures.length > 0) selectedNature = interNatures.first;
    }
    await fetchDataTypes();
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

  Future<void> fetchDataTypes() async {
    first = false;
    String url = AppUrl.getInterTypes;
    print('url CatInter: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res interTypes code : ${req.statusCode}");
    print("res reclmCat body: ${req.body}");
    if (req.statusCode == 200) {
      interTypes.clear();
      List<dynamic> data = json.decode(req.body);
      data.forEach((element) {
        interTypes
            .add(TypeActivity(code: element['code'], name: element['lib']));
      });
      if (interTypes.length > 0) selectedType = interTypes.first;
    }
  }

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
              'Nouvelle intervention',
              style: Theme.of(context)
                  .textTheme
                  .headline3!
                  .copyWith(color: Colors.white),
            ),
          ),
          body: FutureBuilder(
              future: (first) ? fetchDataNature() : null,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return AlertDialog(
                    content: Container(
                        width: 200,
                        height: 100,
                        child: Image.asset('assets/SAV-Loader.gif')),
                  );
                }
                return Center(
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 20,
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
                                  'Authorization':
                                      'Bearer ${AppUrl.user.token}',
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
                                AppUrl.user
                                    .collaborator = List<Collaborator>.from(
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
                                  .headline4!
                                  .copyWith(color: Colors.grey),
                            ),
                            value: selectedPipeline,
                            onChanged: (newValue) {
                              selectedPipeline = newValue!;
                              String collabrator = selectedPipeline.name!;
                              AppUrl.filtredOpporunity.pipeline =
                                  selectedPipeline;
                              AppUrl.filtredOpporunity.stepPip =
                                  selectedPipeline.steps.first;
                              selectedStepPip =
                                  AppUrl.filtredOpporunity.stepPip!;
                              print(
                                  'size of steps: ${AppUrl.filtredOpporunity.pipeline!.steps.length}');
                              print(
                                  'size of steps: ${selectedPipeline.steps.length}');
                              if (collabrator == 'Moi')
                                collabrator = AppUrl.user.userId!;
                              print('collaborator $collabrator');
                              setState(() {});
                            },
                            items: AppUrl.filtredOpporunity.team!.pipelines!
                                .where((element) => element.id == 3)
                                .toList()
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
                      SizedBox(
                        height: 20,
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
                      Visibility(
                        child: ListTile(
                          title: Text(
                            'Nature : ',
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
                              'Selectioner nature',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(color: Colors.grey),
                            ),
                            value: selectedNature,
                            onChanged: (newValue) {
                              selectedNature = newValue!;
                              setState(() {});
                            },
                            items: interNatures
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
                      ),
                      Visibility(
                        child: ListTile(
                          title: Text(
                            'Type : ',
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
                              'Selectioner type',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(color: Colors.grey),
                            ),
                            value: selectedType,
                            onChanged: (newValue) {
                              selectedType = newValue!;
                              setState(() {});
                            },
                            items: interTypes
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
                                        //page: ClientsListForAddClientPage(
                                        page: ReclamationListPage(
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
                                controller: _demande,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 17),
                      //   child: Row(
                      //     //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       IconButton(
                      //         onPressed: () {
                      //           PageNavigator(ctx: context)
                      //               .nextPage(
                      //               page: ClientsListForAddClientPage(
                      //                 callback: reload,
                      //               ))
                      //               .then((value) {
                      //             print('finish');
                      //           });
                      //         },
                      //         icon: Icon(
                      //           Icons.person_add_alt,
                      //           color: primaryColor,
                      //         ),
                      //       ),
                      //       // Your icon
                      //       SizedBox(width: 16.0),
                      //       // Adjust the space between icon and text field
                      //       Expanded(
                      //         child: customTextField(
                      //           obscure: false,
                      //           enable: false,
                      //           controller: _client,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
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
                            'Selectioner l\'étape ',
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
                              .where((element) => element.id == 3)
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
                                  'Début de l\'intervention : ',
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                                //width: 200,
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
                              try {
                                print('client: ${client}');
                              } catch (_) {
                                _showAlertDialog(context,
                                    'Il faut choisir une réclamation d\'abord !');
                                return;
                              }
                              try {
                                print('client: ${selectedStepPip!.id}');
                              } catch (_) {
                                _showAlertDialog(context,
                                    'Il faut choisir l\'étape d\'abord !');
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
                                    'La date début doit être supérieure à la date actuelle !');
                                return;
                              }
                              ConfirmationDialog confirmationDialog =
                                  ConfirmationDialog();
                              bool confirmed = await confirmationDialog
                                  .showConfirmationDialog(
                                      context, 'confirmOpp');
                              if (confirmed) {
                                // confirm
                                showLoaderDialog(context);
                                AppUrl.selectedClient!.lib = _lib.text.trim();
                                AppUrl.selectedClient!.comment =
                                    _comment.text.trim();
                                AppUrl.selectedClient!.dateStart =
                                    selectedStartTimeDate;
                                AppUrl.selectedClient!.priority =
                                    ratingPriority.toInt();
                                AppUrl.selectedClient!.emergency =
                                    ratingEmergency.toInt();
                                sendIntervention(context, client!)
                                    .then((value) {
                                  if (value) {
                                    HttpRequestApp().sendItinerary('INV');
                                    showMessage(
                                        message:
                                            'Intervention créée avec succès',
                                        context: context,
                                        color: primaryColor);
                                    Navigator.pop(context);
                                    Future.delayed(Duration(seconds: 4))
                                        .then((value) {
                                      Navigator.pushNamedAndRemoveUntil(
                                          context, '/home', (route) => false);
                                    });
                                  } else {
                                    showMessage(
                                        message:
                                            'Échec de creation de l\'intervention',
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
                  ),
                );
              })),
    );
  }

  Future<bool> sendIntervention(BuildContext context, Client client) async {
    print('date is: ${client.dateStart}');
    print('userId: ${AppUrl.user.userId}');
    print('selectedStepPip: ${selectedStepPip!.id}');

    String? collabrator = selectedCollaborator.salCode!;
    if (selectedCollaborator.userName == 'Moi')
      collabrator = AppUrl.user.salCode!;
    print('collaborator $collabrator');
    String? valuCat;
    try {
      valuCat = selectedNature!.code;
    } catch (_) {}
    String? valueType;
    try {
      valuCat = selectedType!.code;
    } catch (_) {}
    Map<String, dynamic> jsonObject = {
      "objet": client.lib,
      "categorie": valuCat,
      "type": valueType,
      //"demande": client.resOppo,
      "demNumero": client.resOppo['numero'],
      "dateCreation": DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()),
      "priorite": client.priority,
      "urgence": client.emergency,
      "userCreat": "${AppUrl.user.userId}",
      "etat": selectedStepPip!.id,
      "pcfCode": client.id,
      "etbCode": AppUrl.user.etblssmnt!.code!,
      "date": DateFormat('yyyy-MM-ddTHH:mm:ss').format(client!.dateStart!),
      "dateIntervention":
          DateFormat('yyyy-MM-ddTHH:mm:ss').format(client!.dateStart!),
      "commentaire": "${client.comment}",
      "salCode": "$collabrator",
      "dateCloture": null,
    };

    print('obj json: $jsonObject');
    http.Response req = await http.post(Uri.parse(AppUrl.intervention),
        body: jsonEncode(jsonObject),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
        });
    print("res addInv code : ${req.statusCode}");
    print("res addInv body: ${req.body}");
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
