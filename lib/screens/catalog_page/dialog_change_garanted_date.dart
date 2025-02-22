import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/models/client.dart';
import 'package:sav_app/models/collaborator.dart';
import 'package:sav_app/models/pipeline.dart';
import 'package:sav_app/models/product.dart';
import 'package:sav_app/models/team.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/routers.dart';
import 'package:sav_app/utils/snack_message.dart';
import 'package:sav_app/widgets/alert.dart';
import 'package:sav_app/widgets/clients_list_page.dart';
import 'package:sav_app/widgets/confirmation_dialog.dart';

class ChangeGarantedDateDialog extends StatefulWidget {
  final String? type;
  final Product product;

  const ChangeGarantedDateDialog({super.key, this.type, required this.product});

  @override
  State<ChangeGarantedDateDialog> createState() =>
      _ChangeGarantedDateDialogState();
}

class _ChangeGarantedDateDialogState extends State<ChangeGarantedDateDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //selectedDate = AppUrl.filtredOpporunity.date!;
    //selectedStateItem = states.first;
    return SimpleDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Date de garantie de ${widget.product.name}',
        style: Theme.of(context).textTheme.headline3,
      ),
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            // Set desired border radius
            color: Colors.white,
          ),
          width: 150,
          height: 110,
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    _selectDate(context).then((value) => print(
                        'Selected Month222: ${DateFormat('yyyy-MM-dd').format(widget.product.dateExpired!)}'));
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
                          'Date ',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      Text(
                        '${DateFormat('yyyy-MM-dd').format(widget.product.dateExpired!)}',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  onPressed: () async {
                    ConfirmationDialog confirmationDialog =
                        ConfirmationDialog();
                    bool confirmed = await confirmationDialog
                        .showConfirmationDialog(context, 'confirmEditGar');
                    if (confirmed) {
                      showLoaderDialog(context);
                      ChangeGarantedDate(context, widget.product).then((value) {
                        if (value) {
                          showMessage(
                              message: 'Date de garantie a été modifiée avec succès',
                              context: context,
                              color: primaryColor);
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/catalog', (route) => false);
                        } else {
                          showMessage(
                              message: 'Échec de modification de l\'activité',
                              context: context,
                              color: Colors.red);
                          Navigator.pop(context);
                        }
                      });
                    }

                  },
                  child: const Text(
                    "Confirmer",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Future<bool> ChangeGarantedDate(BuildContext context, Product product) async {

    product.res['dateFinGarantie'] = DateFormat('yyyy-MM-ddT23:59:59').format(product.dateExpired!);
    print('obj: ${product.res['dateFinGarantie']}');
    String url = AppUrl.articlesSuiv + '/${product.res['numSerie']}';
    http.Response req =
        await http.put(Uri.parse(url), body: jsonEncode(product.res), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res actProduct code : ${req.statusCode}");
    print("res acProduct body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: widget.product.dateExpired,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
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
        });
    print('date is : ${DateFormat('yyyy-MM-dd').format(picked!)}');
    if (picked != null && picked != widget.product.dateExpired) {
      setState(() {
        widget.product.dateExpired = picked;
        print('date is : ${DateFormat('yyyy-MM-dd').format(widget.product.dateExpired!)}');
      });
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
