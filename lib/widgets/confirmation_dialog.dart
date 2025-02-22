import 'package:flutter/material.dart';
import 'package:sav_app/styles/colors.dart';

class ConfirmationDialog {
  Future<bool> showConfirmationDialog(
      BuildContext context, String type) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        String content = '';
        String confirm = 'Confirmer';
        TextStyle style = TextStyle();
        if (type == 'deleteProduct') {
          content = 'Êtes-vous sûr de supprimer ce produit de la commande ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: Colors.red);
        }
        if (type == 'logout') {
          confirm = 'Déconnecter';
          content = 'Êtes-vous sûr de déconnecter ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }
        if (type == 'deleteCommand') {
          content = 'Êtes-vous sûr de supprimer cette commande ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: Colors.red);
        }
        if (type == 'transToCommand') {
          content = 'Vous êtes sûr de transférer ce devis à une commande ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }
        if (type == 'confirmDevis') {
          content = 'Vous êtes sûr de confirmer ce devis ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }
        if (type == 'confirmCommand') {
          content = 'Êtes-vous sûr de confirmer cette commande ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }

        if (type == 'confirmDelivr') {
          content = 'Êtes-vous sûr de confirmer cette livraison ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }

        if (type == 'confirmChang') {
          content = 'Êtes-vous sûr de confirmer ces changement ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }

        if (type == 'confirmCharg') {
          content = 'Êtes-vous sûr de confirmer ce chargement ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }

        if (type == 'confirmDecharg') {
          content = 'Êtes-vous sûr de confirmer ce déchargement ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }

        if (type == 'confirmPayment') {
          content = 'Êtes-vous sûr de confirmer ce règlement ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }

        if (type == 'confirmReturn') {
          content = 'Êtes-vous sûr de confirmer ce bon de retour ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }

        if (type == 'confirmEditAct') {
          content = 'Êtes-vous sûr de modifier cette activité ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }
        if (type == 'confirmEditGar') {
          content = 'Êtes-vous sûr de modifier la date de garantie ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }
        if (type == 'confirmDupAct') {
          content = 'Êtes-vous sûr de dupliquer cette activité ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }
        if (type == 'confirmAct') {
          content = 'Êtes-vous sûr d\'ajouter cette activité ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }
        if (type == 'confirmOpp') {
          content = 'Êtes-vous sûr d\'ajouter cette intervention ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
        }
        if (type == 'confirmRec') {
          content = 'Êtes-vous sûr d\'ajouter cette réclamation ?';
          style = Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor);
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
                'Annuler',
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
