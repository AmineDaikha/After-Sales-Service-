import 'package:flutter/material.dart';
import 'package:sav_app/styles/colors.dart';

import '../screens/notes_page/title_note_dialog.dart';

class ConfirmationOppDialog {
  Future<bool> showConfirmationDialog(
      BuildContext context, String type) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        String content = '';
        String confirm = 'Oui';
        String cancel = 'Non';
        TextStyle style = Theme.of(context)
            .textTheme
            .headline5!
            .copyWith(color: primaryColor);
        if (type == 'cancelOpp') {
          content = 'Êtes-vous sûr d\'annuler l\'intervention ?';
        }
        if (type == 'editOpp') {
          content = 'Êtes-vous sûr de modifier l\'intervention ?';
        }
        if (type == 'editRec') {
          content = 'Être sûr de modifier la réclamation ?';
        }
        if (type == 'editInter') {
          content = 'Être sûr de modifier l\'intervention ?';
        }
        if (type == 'visitedOpp') {
          content = 'Êtes-vous sûr de marquer cette intervention comme visité ?';
        }
        if (type == 'paymentOpp') {
          content = 'Êtes-vous sûr de marquer cette intervention comme Encaissé ?';
        }
        if (type == 'delivredOpp') {
          content = 'Êtes-vous sûr de marquer cette intervention comme Livré ?';
        }
        if (type == 'delivredAndPaymentOpp') {
          content = 'Êtes-vous sûr de marquer cette intervention comme Livré et Encaissé ?';
        }

        return AlertDialog(
          title: Text(
            'Confirmation',
            style: Theme.of(context).textTheme.headline3,
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false when canceled
              },
              child: Text(
                '$cancel',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true when confirmed
              },
              child: Text(
                '$confirm',
                style: style,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != null && confirmed) {
      print('User confirmed.');
      return true;
    } else {
      // User canceled, take appropriate action
      print('User canceled.');
      return false;
    }
  }
}
