import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/models/address.dart';
import 'package:sav_app/models/familly.dart';
import 'package:sav_app/models/sfamilly.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/snack_message.dart';
import 'package:sav_app/widgets/alert.dart';
import 'package:sav_app/widgets/text_field.dart';

class EditAddress extends StatefulWidget {
  final Address address;

  EditAddress({super.key, required this.address});

  @override
  State<EditAddress> createState() => _EditAddressState();
}

class _EditAddressState extends State<EditAddress> {
  LatLng? currentLocation;
  final TextEditingController lat = TextEditingController();
  final TextEditingController lon = TextEditingController();
  final TextEditingController road = TextEditingController();
  final TextEditingController way = TextEditingController();
  final TextEditingController lib = TextEditingController();
  Familly? selectedRegion;
  SFamilly? selectedSector;
  Familly? selectedVille;
  SFamilly? selectedQuartier;
  bool first = true;
  List<SFamilly> sectorsList = [];
  List<SFamilly> quartiersList = [];
  bool isChecked = false;
  final _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    print('hmmmm ${widget.address.res}');
    widget.address.code = widget.address.res['code'];
    if (widget.address.road != null) road.text = widget.address.road!;
    if (widget.address.lib != null) lib.text = widget.address.lib!;
    if (widget.address.location != null) {
      lat.text = widget.address.location!.latitude.toString();
      lon.text = widget.address.location!.longitude.toString();
      currentLocation = widget.address.location;
    }
  }

  Future<void> fetchDataRegion() async {
    first = false;
    AppUrl.tierRegions = [];
    AppUrl.tierSectors = [];
    String url = '${AppUrl.tierRegion}';
    print('url : $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res region code : ${req.statusCode}");
    print("res region body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      print('length ${data.length}');
      data.forEach((element) {
        AppUrl.tierRegions.add(
            Familly(code: element['code'], name: element['nom'], type: ''));
      });
    }
    await fetchDataSector();
    AppUrl.tierRegions.insert(0, Familly(code: '', name: '', type: ''));
    AppUrl.tierSectors.insert(0, SFamilly(code: '', name: '', type: ''));
    selectedRegion = AppUrl.tierRegions.first;
    selectedSector = AppUrl.tierSectors.first;
    sectorsList = AppUrl.tierSectors
        .where((element) => element.type == selectedRegion!.code)
        .toList();
    try {
      selectedSector = sectorsList
          .where((element) => element.code == widget.address.sector!.code)
          .first; //widget.address.quartier
    } catch (_) {}
    try {
      selectedRegion = AppUrl.tierRegions
          .where((element) => element.code == widget.address.region!.code)
          .first; //widget.address.quartier
    } catch (_) {}
    await fetchDataVille();
    await fetchDataQuartier();
    try {
      quartiersList = AppUrl.allQuartiers
          .where((element) => element.type == selectedVille!.code)
          .toList();

      selectedQuartier = quartiersList
          .where((element) => element.code == widget.address.quartier!.code)
          .first; //widget.address.quartier
    } catch (_) {}
  }

  Future<void> fetchDataSector() async {
    String url = '${AppUrl.tierSector}';
    print('url : $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res sector code : ${req.statusCode}");
    print("res sector body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      print('length ${data.length}');
      data.forEach((element) {
        AppUrl.tierSectors.add(SFamilly(
            code: element['code'],
            name: element['nom'],
            type: element['regionId']));
      });
    }
  }

  Future<void> fetchDataVille() async {
    // getOne sector for get villes
    AppUrl.villes = [];
    String url = '${AppUrl.getVilles}';
    print('url : $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res ville code : ${req.statusCode}");
    print("res ville body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      print('length ${data.length}');
      data.forEach((element) {
        try {
          AppUrl.villes.add(Familly(
            code: element['vilCode'],
            name: element['vilNom'],
            type: '',
          ));
        } catch (_) {}
      });
      try {
        print('rfrgr ${AppUrl.villes
            .where((element) => element.code == widget.address.city!.code)
            .length}');
        selectedVille = AppUrl.villes
            .where((element) => element.code == widget.address.city!.code)
            .first; //widget.address.quartier
        print('eee $selectedVille');
      } catch (_) {}
    }
  }

  Future<void> fetchDataQuartier() async {
    AppUrl.allQuartiers = [];
    String url = '${AppUrl.getQuartiers}';
    print('url : $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res quartier code : ${req.statusCode}");
    print("res quartier body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      print('length ${data.length}');
      data.forEach((element) {
        try {
          AppUrl.allQuartiers.add(SFamilly(
            code: element['QRT001'],
            name: element['nom'],
            type: element['villeId'],
          ));
        } catch (_) {}
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        print('latLng: ${position.latitude} ${position.longitude}');
        currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set icon color to white
        ),
        backgroundColor: primaryColor,
        title: Text(
          'Modifier une adresse',
          style: Theme.of(context)
              .textTheme
              .headline2!
              .copyWith(color: Colors.white),
        ),
      ),
      body: FutureBuilder(
          future: (first) ? fetchDataRegion() : null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                content: Container(
                    width: 200,
                    height: 100,
                    child: Image.asset('assets/SAV-Loader.gif')),
              );
            }
            return Form(
              key: _formkey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    customTextField(
                      obscure: false,
                      controller: lib,
                      hint: 'Titre',
                    ),
                    ListTile(
                      title: Text(
                        'Région',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: DropdownButtonFormField<Familly>(
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
                          'Sélectionner la région',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(color: Colors.grey),
                        ),
                        value: selectedRegion,
                        onChanged: (newValue) {
                          selectedRegion = newValue!;
                          print(
                              'fjhbkjbkkrt ${selectedRegion!.code} ${selectedRegion!.name} ${selectedRegion!.type}');
                          print(
                              'fjhbkjbkkrt ${newValue.code} ${newValue.name} ${newValue.type}');
                          if (selectedRegion != null) {
                            sectorsList =
                                List<SFamilly>.from(AppUrl.tierSectors)
                                    .where((element) =>
                                        element.type == selectedRegion!.code)
                                    .toList();
                            sectorsList.insert(
                                0, SFamilly(code: '', name: '', type: ''));
                            selectedSector = sectorsList.first;
                          }
                          setState(() {});
                        },
                        items: AppUrl.tierRegions
                            .map<DropdownMenuItem<Familly>>((Familly value) {
                          return DropdownMenuItem<Familly>(
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
                        'Secteur',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: DropdownButtonFormField<SFamilly>(
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
                          'Sélectionner le secteur',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(color: Colors.grey),
                        ),
                        value: selectedSector,
                        onChanged: (newValue) {
                          setState(() {
                            selectedSector = newValue!;
                            print(
                                'frfrffrfrfrf ${selectedSector!.code} ${selectedSector!.name} ${selectedSector!.type}');
                            print('fjhbkjbkkrt ${sectorsList.length}');
                          });
                        },
                        items: sectorsList
                            .map<DropdownMenuItem<SFamilly>>((SFamilly value) {
                          return DropdownMenuItem<SFamilly>(
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
                        '',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: DropdownSearch<Familly>(
                        items: AppUrl.villes,
                        selectedItem: selectedVille,
                        itemAsString: (Familly f) => "${f.name}",
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "Sélectionner la villle",
                            contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        // onChanged: (Familly? selectedFamilly) {
                        //   // Handle selection
                        //   if (selectedFamilly != null) {
                        //     print("Selected: ${selectedFamilly.name}");
                        //   }
                        // },
                        onChanged: (newValue) {
                          selectedVille = newValue;
                          try {
                            quartiersList = AppUrl.allQuartiers
                                .where((element) =>
                                    element.type == selectedVille!.code)
                                .toList();
                            print('size offf : ${quartiersList.length}');
                            selectedQuartier =
                                quartiersList.first; //widget.address.quartier
                          } catch (_) {}
                          setState(() {});
                        },
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
                              labelText: "",
                            ),
                          ),
                        ),
                      ),
                    ),
                    // customTextFieldEmpty(
                    //   obscure: false,
                    //   controller: way,
                    //   hint: 'Quartier',
                    // ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    ListTile(
                      title: Text(
                        '',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: DropdownSearch<SFamilly>(
                        items: quartiersList,
                        selectedItem: selectedQuartier,
                        itemAsString: (SFamilly f) => "${f.name}",
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "Sélectionner le quartier",
                            contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        // onChanged: (Familly? selectedFamilly) {
                        //   // Handle selection
                        //   if (selectedFamilly != null) {
                        //     print("Selected: ${selectedFamilly.name}");
                        //   }
                        // },
                        onChanged: (newValue) {
                          selectedQuartier = newValue;
                          setState(() {});
                        },
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
                              labelText: "",
                            ),
                          ),
                        ),
                      ),
                    ),
                    customTextFieldEmpty(
                      obscure: false,
                      controller: road,
                      hint: 'Rue',
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Checkbox(
                              activeColor: Theme.of(context).primaryColor,
                              checkColor: Colors.white,
                              value: isChecked,
                              onChanged: (_) {
                                setState(() {
                                  isChecked = !isChecked;
                                  if (isChecked) {
                                    _getCurrentLocation().then((value) {
                                      if (currentLocation != null) {
                                        lat.text = currentLocation!.latitude
                                            .toString();
                                        lon.text = currentLocation!.longitude
                                            .toString();
                                      }
                                    });
                                  }
                                });
                              }),
                        ),
                        Expanded(
                          child: customTextFieldEmpty(
                            obscure: false,
                            controller: lat,
                            hint: 'Latitude',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: customTextFieldEmpty(
                            obscure: false,
                            controller: lon,
                            hint: 'Longitude',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                        width: 200,
                        height: 45,
                        // todo 7
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).primaryColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                          onPressed: () {
                            if (_formkey.currentState != null &&
                                _formkey.currentState!.validate()) {
                              if (selectedVille == null) {
                                showAlertDialog(context,
                                    'Il faut choisir une ville d\'abord');
                                return;
                              }
                              LatLng location;
                              try{
                                location = LatLng(double.parse(lat.text.trim()), double.parse(lon.text.trim()));
                              }catch(_){
                                showAlertDialog(context,
                                    'Il faut choisir une localisation corrèncte !');
                                return;
                              }
                              widget.address.res['title'] = lib.text.trim();
                              Familly? region;
                              Familly? ville;
                              if (selectedRegion!.code != '')
                                widget.address.res['reg'] = selectedRegion!.code;
                              SFamilly? sector;
                              if (selectedSector!.code != '')
                                widget.address.res['secteur'] = selectedSector!.code;
                              if (selectedVille != null)
                                widget.address.res['ville'] = selectedVille!.code;
                              if (selectedQuartier != null)
                                widget.address.res['quartierId'] = selectedVille!.code;

                              widget.address.res['latitude'] = location.latitude;
                              widget.address.res['longitude'] = location.longitude;
                              if(road.text.isNotEmpty){
                                widget.address.res['rue'] = road.text.trim();
                              }
                              showLoaderDialog(context);
                              sendAddress(widget.address).then((value) {
                                Navigator.pop(context);
                                if(value){
                                  showMessage(
                                      message: 'Adresse a été modifiée avec succès',
                                      context: context,
                                      color: primaryColor);
                                  Navigator.pop(context);
                                }else{
                                  showMessage(
                                      message: 'Échec de modification d\'adresse',
                                      context: context,
                                      color: Colors.red);
                                }
                              });
                            }
                          },
                          child: const Text(
                            "Modifier",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        )),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Future<bool> sendAddress(Address address) async {
    String url = AppUrl.editAddress + '/${address.code}';
    print('urlEdit : $url');
    http.Response req =
    await http.put(Uri.parse(url), body: jsonEncode(address.res), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res edit address code : ${req.statusCode}");
    print("res edit address body: ${req.body}");

    if (req.statusCode == 200 || req.statusCode == 201) {
      return true;
    } else {
      print('Failed to load data');
    }
    return false;
  }
}
