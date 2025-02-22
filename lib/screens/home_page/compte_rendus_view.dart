import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/models/client.dart';
import 'package:sav_app/widgets/confirmation_dialog.dart';
import 'package:sav_app/widgets/text_field.dart';

import '../../widgets/clients_list_page.dart';

class CompteRendusView extends StatelessWidget {
  final TextEditingController _lib = TextEditingController();

  CompteRendusView({super.key, required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    try{
    if (client.res['cdcf']['synthese'] != null) {
      _lib.text = client.res['cdcf']['synthese'];
    }}catch(_){

    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17),
          child: customTextFieldEmptyMulti(
            obscure: false,
            controller: _lib,
            hint: 'Compte rendus',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            onPressed: () async {
              ConfirmationDialog confirmationDialog = ConfirmationDialog();
              bool confirmed = await confirmationDialog.showConfirmationDialog(
                  context, 'confirmChang');
              if (confirmed) {
                showLoaderDialog(context);
                client.res['cdcf']['synthese'] = _lib.text.trim();
                editSynthese(client).then((value) {
                  Navigator.pop(context);
                });
                // Future.delayed(Duration(seconds: 1)).then((value) {
                // showMessage(
                //     message:
                //     'Échec ...',
                //     context: context,
                //     color: Colors.red);
                //   Navigator.pop(context);
                // });
              }
            },
            child: Text(
              "        Valider        ",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> editSynthese(Client client) async {
    String url = AppUrl.intervention + '/${client.code}';
    print('url: $url');
    print('obj json: ${client.res['users']}');
    print('sal: ${AppUrl.user.salCode}');
    http.Response req =
        await http.put(Uri.parse(url), body: jsonEncode(client.res), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res editProject code : ${req.statusCode}");
    print("res editProject body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}
