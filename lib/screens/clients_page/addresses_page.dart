import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/constants/utils.dart';
import 'package:sav_app/models/address.dart';
import 'package:sav_app/models/client.dart';
import 'package:sav_app/models/concurrent.dart';
import 'package:sav_app/models/contact.dart';
import 'package:sav_app/models/familly.dart';
import 'package:sav_app/models/lot.dart';
import 'package:sav_app/models/salon.dart';
import 'package:sav_app/models/sfamilly.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/routers.dart';
import 'package:sav_app/utils/snack_message.dart';
import 'package:sav_app/widgets/alert.dart';
import 'package:sav_app/widgets/concurrent_list_page.dart';
import 'package:sav_app/widgets/confirmation_dialog.dart';
import 'package:sav_app/widgets/text_field.dart';

import 'add_contact_page.dart';
import 'adresses_page/edit_address.dart';
import 'edit_contact_page.dart';

class AddressesPage extends StatefulWidget {
  final Client client;

  AddressesPage({super.key, required this.client});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  void reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: null,
        //future: fetchDataContacts(),
        builder: (context, snapshot) {
          List<Address> adresses = [];
          List<dynamic> jsonArray = widget.client.res['adress'];
          for (int i = 0; i < jsonArray.length; i++) {
            adresses.add(Address(
                res: jsonArray[i],
                road: jsonArray[i]['rue'],
                lib: jsonArray[i]['title']));
          }
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
              iconTheme: IconThemeData(
                color: Colors.white, // Set icon color to white
              ),
              title: ListTile(
                title: Text(
                  'Liste des adresses : ',
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
            // floatingActionButton: FloatingActionButton(
            //   backgroundColor: primaryColor,
            //   onPressed: () {
            //     PageNavigator(ctx: context)
            //         .nextPage(
            //             page: AddNewContactPage(
            //       client: widget.client,
            //     ))
            //         .then((value) {
            //       setState(() {});
            //     });
            //   },
            //   child: Icon(
            //     Icons.person_add_alt,
            //     color: Colors.white,
            //   ),
            // ),
            body: Container(
              height: AppUrl.getFullHeight(context) * 0.8,
              padding: EdgeInsets.only(top: 20, right: 10, left: 10),
              child: (jsonArray.length > 0)
                  ? ListView.builder(
                      padding: EdgeInsets.all(12),
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) => InkWell(
                          onTap: () {},
                          child: AddressItem(
                              callback: reload,
                              addresses: adresses,
                              address: adresses.toList()[index])),
                      itemCount: adresses.length)
                  : Center(
                      child: Text(
                        'Aucune adresses ajoutées !',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
              // ? ListView.separated(
              //     itemCount: contacts.length,
              //     itemBuilder: (context, index) {
              //       return VisitorItem(
              //         contact: contacts[index],
              //         callback: reload,
              //         contacts: contacts,
              //       );
              //     },
              //     separatorBuilder: (BuildContext context, int index) {
              //       return Container(
              //         height: 5,
              //       );
              //     },
              //   )
              // : Center(
              //     child: Text(
              //       'Aucune adresse !',
              //       style: Theme.of(context).textTheme.headline5!.copyWith(
              //             fontWeight: FontWeight.bold,
              //           ),
              //     ),
              //   ),
            ),
          );
        });
  }
}

class AddressItem extends StatefulWidget {
  final Address address;
  final List<Address> addresses;
  final VoidCallback callback;

  const AddressItem(
      {super.key,
      required this.address,
      required this.addresses,
      required this.callback});

  @override
  State<AddressItem> createState() => _AddressItemState();
}

class _AddressItemState extends State<AddressItem> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchDataRegion() async {
    print('addobj : ${widget.address.res}');
    if (widget.address.res['reg'] != null) {
      String url = AppUrl.getRegion + '${widget.address.res['reg']}';
      print('urlReg: $url');
      http.Response req = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
        "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
      });
      print("res region code : ${req.statusCode}");
      print("res region body: ${req.body}");
      if (req.statusCode == 200) {
        var res = json.decode(req.body);
        widget.address.region =
            Familly(code: res['code'], name: res['nom'], type: '');
      }
    }
    await fetchDataSector();
    await fetchDataQuartier();
  }

  Future<void> fetchDataSector() async {
    if (widget.address.res['secteur'] != null) {
      String url = AppUrl.getSecteur + '${widget.address.res['secteur']}';
      print('urlSec: $url');
      http.Response req = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
        "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
      });
      print("res sec code : ${req.statusCode}");
      print("res sec body: ${req.body}");
      if (req.statusCode == 200) {
        var res = json.decode(req.body);
        widget.address.sector =
            SFamilly(code: res['code'], name: res['nom'], type: 'regionId');
      }
    }
  }

  Future<void> fetchDataQuartier() async {
    if (widget.address.res['quartierId'] != null) {
      String url = AppUrl.getQuartiers + '/${widget.address.res['quartierId']}';
      print('urlQuar: $url');
      http.Response req = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
        "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
      });
      print("res quar code : ${req.statusCode}");
      print("res quar body: ${req.body}");
      if (req.statusCode == 200) {
        var res = json.decode(req.body);
        widget.address.quartier =
            SFamilly(code: res['code'], name: res['nom'], type: 'villeId');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('fefefe ${widget.address.res['villeObj']}');
    try {
      if (widget.address.res['villeObj'] != null) {
        widget.address.city = Familly(
            code: widget.address.res['villeObj']['vilCode'],
            name: widget.address.res['villeObj']['vilNom'],
            type: '');
      }
    } catch (_) {}
    return FutureBuilder(
        future: fetchDataRegion(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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
          }
          widget.address.location =
              LatLng(widget.address.res['latitude'], widget.address.res['longitude']);
          return Column(
            children: [
              Container(
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.share_location,
                      color: primaryColor,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        (widget.address.lib != null)
                            ? Container(
                                width: AppUrl.getFullWidth(context) * 0.6,
                                child: Text(
                                  widget.address.lib!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(color: primaryColor),
                                ),
                              )
                            : Text('Titre',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(color: Colors.black)),
                        (widget.address.road != null)
                            ? Container(
                                width: AppUrl.getFullWidth(context) * 0.6,
                                child: Text(
                                  'Rue : ' + widget.address.road!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(color: Colors.grey),
                                ),
                              )
                            : Text('Rue : --',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal)),
                        (widget.address.quartier != null)
                            ? Container(
                                width: AppUrl.getFullWidth(context) * 0.6,
                                child: Text(
                                  'Quartier : ' + widget.address.quartier!.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(color: Colors.grey),
                                ),
                              )
                            : Text('Quartier : --',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal)),
                        (widget.address.city != null)
                            ? Container(
                                width: AppUrl.getFullWidth(context) * 0.6,
                                child: Text(
                                  'Ville : ' + widget.address.city!.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                ),
                              )
                            : Text('Ville : --',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal)),
                        (widget.address.sector != null)
                            ? Container(
                                width: AppUrl.getFullWidth(context) * 0.6,
                                child: Text(
                                  'Secteur : ' + widget.address.sector!.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(color: Colors.grey),
                                ),
                              )
                            : Text('Secteur : --',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal)),
                        (widget.address.region != null)
                            ? Container(
                                width: AppUrl.getFullWidth(context) * 0.6,
                                child: Text(
                                  'Région : ' + widget.address.region!.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(color: Colors.grey),
                                ),
                              )
                            : Text('Région : --',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal)),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        PageNavigator(ctx: context)
                            .nextPage(
                                page: EditAddress(
                          address: widget.address,
                        ))
                            .then((value) {
                          widget.callback();
                        });
                      },
                      icon: Icon(
                        Icons.edit_square,
                        color: primaryColor,
                      ),
                    )
                  ],
                ),
              ),
              Divider(
                color: Colors.grey,
              )
            ],
          );
        });
  }
}

class VisitorItem extends StatefulWidget {
  final Contact contact;
  final VoidCallback callback;
  final List<Contact> contacts;

  const VisitorItem(
      {super.key,
      required this.contact,
      required this.callback,
      required this.contacts});

  @override
  State<VisitorItem> createState() => _VisitorItemState();
}

class _VisitorItemState extends State<VisitorItem> {
  List<String> options = ['Modifier', 'Supprimer'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: EdgeInsets.all(8.0),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor),
        // Set border color to red
        borderRadius:
            BorderRadius.circular(10.0), // Optional: Set border radius
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 200,
                child: Row(
                  children: [
                    Text(
                      'Contact : ',
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      '${widget.contact.famillyName} ${widget.contact.firstName}',
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                'Entreprise associé : ${widget.contact.origin}',
                style: Theme.of(context).textTheme.headline5!.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
              ),
              Text(
                'Date : ${DateFormat('dd-MM-yyyy').format(widget.contact.date!)}',
                style: Theme.of(context).textTheme.headline4!.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    print('dfkeo ${widget.contact.telMobile}');
                    if (widget.contact.telMobile != null)
                      PhoneUtils().makePhoneCall(widget.contact.telMobile!);
                    else
                      showAlertDialog(context,
                          'pas de numéro de téléphone pour ce contact');
                  },
                  icon: Icon(
                    Icons.call_outlined,
                    color: primaryColor,
                  )),
              IconButton(
                  onPressed: () async {
                    showMenu(
                      context: context,
                      position:
                          RelativeRect.fromLTRB(100.0, 100.0, 100.0, 100.0),
                      items: options.map((String option) {
                        return PopupMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                    ).then((value) async {
                      if (value != null) {
                        if (value == options[0]) {
                          PageNavigator(ctx: context)
                              .nextPage(
                                  page: EditContactPage(
                            contact: widget.contact,
                          ))
                              .then((value) {
                            widget.callback();
                          });
                        } else if (value == options[1]) {
                          ConfirmationDialog confirmationDialog =
                              ConfirmationDialog();
                          bool confirmed = await confirmationDialog
                              .showConfirmationDialog(context, 'deleteCont');
                          if (confirmed) {
                            showLoaderDialog(context);
                            deleteContact(widget.contact).then((value) {
                              if (value) {
                                showMessage(
                                    message:
                                        'Le contact a été supprimé avec succès',
                                    context: context,
                                    color: primaryColor);
                                widget.contacts.remove(widget.contact);
                                widget.callback();
                                Navigator.pop(context);
                              } else {
                                showMessage(
                                    message:
                                        'Échec de la supprission du contact',
                                    context: context,
                                    color: Colors.red);
                                Navigator.pop(context);
                              }
                            });
                          }
                        }
                      }
                    });
                  },
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.black,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> deleteContact(Contact contact) async {
    String url = AppUrl.contacts + '${contact.num}';
    print('url : $url');
    http.Response req = await http
        .delete(Uri.parse(url), body: jsonEncode(contact.res), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res deleteContact code : ${req.statusCode}");
    print("res deleteContact body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}

class AddConcurrentDialog extends StatefulWidget {
  Client client;
  Lot lot;
  String type;
  Concurrent? concurrent;

  AddConcurrentDialog(
      {required this.client,
      required this.lot,
      required this.type,
      this.concurrent});

  @override
  State<AddConcurrentDialog> createState() => _AddConcurrentDialogState();
}

class _AddConcurrentDialogState extends State<AddConcurrentDialog> {
  TextEditingController _client = TextEditingController();
  TextEditingController _total = TextEditingController();

  //TextEditingController _tva = TextEditingController();
  TextEditingController _ttc = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String txtBtn = 'Ajouter';

  void reload() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _client.text = 'Ajouter un Concurrent';
    if (widget.type == 'edit') {
      txtBtn = 'Modifier';
      _client.text = widget.concurrent!.name!;
      _total.text = widget.concurrent!.total.toString();
      //_tva.text = widget.concurrent!.tva.toString();
      _ttc.text = widget.concurrent!.ttc.toString();
      print('jfndk : ${widget.concurrent!.pcfCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Form(
        key: formKey,
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (widget.type == 'edit') return;
                          PageNavigator(ctx: context)
                              .nextPage(
                                  page: ClientsListForAddClientPage(
                            callback: reload,
                          ))
                              .then((value) async {
                            print('finish add ${AppUrl.selectedClient}');
                            if (AppUrl.selectedClient == null) return;
                            if (AppUrl.selectedClient!.id == null) return;
                            widget.client.name = AppUrl.selectedClient!.name;
                            widget.client.id = AppUrl.selectedClient!.id;
                            _client.text = widget.client.name!;
                            reload();
                          });
                        },
                        icon: (widget.type == 'add')
                            ? Icon(
                                Icons.person_add_alt,
                                color: primaryColor,
                              )
                            : Icon(
                                Icons.person,
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
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: customTextField(
                    obscure: false,
                    controller: _total,
                    maxLines: null,
                    hint: 'Écrivez le Total',
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                // Container(
                //   margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                //   child: customTextField(
                //     obscure: false,
                //     controller: _tva,
                //     maxLines: null,
                //     hint: 'Écrivez le TVA',
                //     keyboardType:
                //         TextInputType.numberWithOptions(decimal: true),
                //   ),
                // ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: customTextField(
                    obscure: false,
                    controller: _ttc,
                    maxLines: null,
                    hint: 'Écrivez le TTC',
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                    onPressed: () async {
                      if (widget.type == 'add') {
                        if (widget.client.name == null) {
                          showAlertDialog(context,
                              'Il faut choisir le concurrent d\'abord');
                          return;
                        }
                        if (formKey.currentState != null &&
                            formKey.currentState!.validate()) {
                          // final provider = Provider.of<ActivityProvider>(context,
                          //     listen: false);
                          // provider.activityList.add(activity);
                          ConfirmationDialog confirmationDialog =
                              ConfirmationDialog();
                          bool confirmed = await confirmationDialog
                              .showConfirmationDialog(context, 'confirmChang');
                          if (confirmed) {
                            // confirm
                            showLoaderDialog(context);
                            Concurrent concurrent = Concurrent(
                                numLot: widget.lot.numLot,
                                pcfCode: AppUrl.selectedClient!.id,
                                total: double.parse(_total.text.trim()),
                                ttc: double.parse(_ttc.text.trim()),
                                name: AppUrl.selectedClient!.name);
                            sendProjetLotsConcurrents(concurrent).then((value) {
                              if (value) {
                                widget.lot.concurrent.add(concurrent);
                                showMessage(
                                    message:
                                        'Le concurrent a été ajouté avec succès',
                                    context: context,
                                    color: primaryColor);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              } else {
                                showMessage(
                                    message: 'Échec de l\'ajout du concurrent',
                                    context: context,
                                    color: Colors.red);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            });
                            // Future.delayed(Duration(seconds: 1)).then((value) {

                            // });
                          }
                        }
                      } else {
                        if (formKey.currentState != null &&
                            formKey.currentState!.validate()) {
                          // final provider = Provider.of<ActivityProvider>(context,
                          //     listen: false);
                          // provider.activityList.add(activity);
                          ConfirmationDialog confirmationDialog =
                              ConfirmationDialog();
                          bool confirmed = await confirmationDialog
                              .showConfirmationDialog(context, 'confirmChang');
                          if (confirmed) {
                            // confirm
                            showLoaderDialog(context);
                            widget.concurrent!.total =
                                double.parse(_total.text.trim());
                            widget.concurrent!.ttc =
                                double.parse(_ttc.text.trim());
                            editProjetLotsConcurrents(widget.concurrent!)
                                .then((value) {
                              if (value) {
                                showMessage(
                                    message:
                                        'Le concurrent a été modifié avec succès',
                                    context: context,
                                    color: primaryColor);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              } else {
                                showMessage(
                                    message:
                                        'Échec de la modification du concurrent',
                                    context: context,
                                    color: Colors.red);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            });
                            // Future.delayed(Duration(seconds: 1)).then((value) {

                            // });
                          }
                        }
                      }
                    },
                    child: Text(
                      "$txtBtn",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> sendProjetLotsConcurrents(Concurrent concurrent) async {
    String url = AppUrl.projetLotsConcurrents;
    print('url: $url');
    Map<String, dynamic> jsonObject = {
      "prjCode": "${widget.lot.prjCode}",
      "cdcfCode": "${widget.lot.cdcfCode}",
      "pcfCode": "${concurrent.pcfCode}",
      "numLot": concurrent.numLot,
      "montantLotHt": concurrent.total,
      "montantLotTtc": concurrent.ttc,
      "notes": null,
      "attribue": false,
    };
    print('obj json: $jsonObject');
    http.Response req =
        await http.post(Uri.parse(url), body: jsonEncode(jsonObject), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res addConcurrent code : ${req.statusCode}");
    print("res addConcurrent body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> editProjetLotsConcurrents(Concurrent concurrent) async {
    String url = AppUrl.projetLotsConcurrents +
        '/${widget.lot.prjCode}/${widget.lot.cdcfCode}/${concurrent.pcfCode}/${concurrent.numLot}';
    print('url: $url');
    concurrent.res['montantLotHt'] = concurrent.total;
    concurrent.res['montantLotTtc'] = concurrent.ttc;
    print('obj json: ${concurrent.res}');
    http.Response req = await http
        .put(Uri.parse(url), body: jsonEncode(concurrent.res), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res editConcurrent code : ${req.statusCode}");
    print("res editConcurrent body: ${req.body}");
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
