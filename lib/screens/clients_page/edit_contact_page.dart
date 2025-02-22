import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/models/client.dart';
import 'package:sav_app/models/contact.dart';
import 'package:sav_app/models/salon.dart';
import 'package:sav_app/models/type_activity.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/routers.dart';
import 'package:sav_app/utils/snack_message.dart';
import 'package:sav_app/widgets/alert.dart';
import 'package:sav_app/widgets/text_field.dart';
import 'package:sav_app/models/contact.dart';

import '../activities_pages/activity_list_page.dart';

class EditContactPage extends StatefulWidget {
  final Contact contact;


  const EditContactPage({
    super.key,
    required this.contact,
  });

  @override
  State<EditContactPage> createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> {
  final TextEditingController nameRs = TextEditingController();
  final TextEditingController namRS2 = TextEditingController();
  final TextEditingController tel1 = TextEditingController();
  final TextEditingController tel2 = TextEditingController();
  final TextEditingController email = TextEditingController();
  final _formkey = GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();
    if(widget.contact.res['nom'] != null)
    nameRs.text = widget.contact.res['nom'];
    if(widget.contact.res['prenom'] != null)
      namRS2.text = widget.contact.res['prenom'];
    if(widget.contact.res['teld'] != null )// dsl, on pas suup le cont, car il ya des action ratachées (opp, act.. )
      tel2.text = widget.contact.res['teld'];
    if(widget.contact.res['telm'] != null)
      tel1.text = widget.contact.res['telm'];
    if(widget.contact.res['email'] != null)
      email.text = widget.contact.res['email'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        //future: (civilit.isEmpty) ? getCivilite() : null,
      future: null,
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
          return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: Colors.white, // Set icon color to white
              ),
              backgroundColor: primaryColor,
              title: Text(
                'Modifier le contact',
                style: Theme.of(context)
                    .textTheme
                    .headline2!
                    .copyWith(color: Colors.white),
              ),
            ),
            body: Form(
              key: _formkey,
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/addclient.png',
                        fit: BoxFit.cover,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: customTextField(
                              obscure: false,
                              controller: nameRs,
                              hint: 'Nom',
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: customTextField(
                              obscure: false,
                              controller: namRS2,
                              hint: 'Prénom',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: customTextField(
                              keyboardType: TextInputType.phone,
                              obscure: false,
                              controller: tel1,
                              hint: 'Téléphone mobile',
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: customTextFieldEmpty(
                              keyboardType: TextInputType.phone,
                              obscure: false,
                              controller: tel2,
                              hint: 'Téléphone direct',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      customTextField(
                        keyboardType: TextInputType.emailAddress,
                        obscure: false,
                        controller: email,
                        hint: 'Adresse e-mail ',
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

                                widget.contact.res['nom'] = nameRs.text.trim();
                                widget.contact.res['prenom'] = namRS2.text.trim();
                                widget.contact.res['telm'] = tel1.text.trim();
                                widget.contact.res['teld'] = tel2.text.trim();
                                widget.contact.res['email'] = email.text.trim();
                                showLoaderDialog(context);
                                sendContact(widget.contact).then((value) {
                                  if (value != null) {
                                    showMessage(
                                        message:
                                            'Contact a été modifié avec succès',
                                        context: context,
                                        color: primaryColor);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  } else {
                                    Navigator.pop(context);
                                    showMessage(
                                        message: 'Échec de la modification du contact',
                                        context: context,
                                        color: Colors.red);
                                  }
                                });
                              }
                            },
                            child: const Text(
                              "Valider",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Future<Contact?> sendContact(Contact contact) async {
    // var body = jsonEncode({
    //   "table": "CCT",
    //   "origin": '${contact.origin}',
    //   "civile": contact.civilte,
    //   "nom": contact.famillyName,
    //   "prenom": contact.firstName,
    //   "teld": contact.telDirect,
    //   "telm": contact.telMobile,
    //   "email": contact.email,
    //   "etbCode": AppUrl.user.etblssmnt!.code,
    // });
    String url = AppUrl.contact + '/${contact.num}';
    print('urlEdit : $url');
    http.Response req =
        await http.put(Uri.parse(url), body: jsonEncode(contact.res), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res add contact code : ${req.statusCode}");
    print("res add contact body: ${req.body}");

    if (req.statusCode == 200 || req.statusCode == 201) {
      var res = json.decode(req.body);

      contact.code = res['numero'];
      return contact;
    } else {
      print('Failed to load data');
    }
    return null;
  }
}
showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Container(
        width: 200,
        height: 100,
        child: Image.asset('assets/SAV-Loader.gif')),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}