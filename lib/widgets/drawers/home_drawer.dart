import 'package:flutter/material.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/database/db_provider.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/widgets/confirmation_dialog.dart';
import 'package:sav_app/widgets/drawer_notif.dart';


class DrawerHomePage extends StatelessWidget {
  const DrawerHomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        height: double.infinity,
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.9,
              child: ListView(
                padding: EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 0),
                children: [
                  NotificationDrawerHeader(),
                  ListTile(
                      leading: Icon(
                        Icons.volume_up_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        'Réclamations',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/reclamation', (route) => false);
                      }),
                  ListTile(
                      leading: Icon(Icons.map_outlined,
                          color: Theme.of(context).primaryColor),
                      title: Text(
                        'Interventions',
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .copyWith(color: primaryColor),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      }),
                  ListTile(
                      leading: Icon(Icons.local_activity_outlined,
                          color: Theme.of(context).primaryColor),
                      title: Text(
                        'Mes activités',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/activities', (route) => false);
                      }),
                  ListTile(
                      leading: Icon(Icons.note_outlined,
                          color: Theme.of(context).primaryColor),
                      title: Text(
                        'Mes Notes',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/notes', (route) => false);
                      }),
                  ListTile(
                      leading: Icon(Icons.location_on_outlined,
                          color: Theme.of(context).primaryColor),
                      title: Text(
                        'Mes Itinéraires',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/itinerary', (route) => false);
                      }),
                  ListTile(
                      leading: Icon(
                        Icons.groups_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        'Prospects / Clients',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/clients', (route) => false);
                      }),
                  ListTile(
                      leading: Icon(
                        Icons.image_search_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        'Équipements',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/catalog', (route) => false);
                      }),
                  ListTile(
                      leading: Icon(
                        Icons.storefront,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                          'Stock PDR',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                      ),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/stock', (route) => false);
                      }),
                  ListTile(
                      leading: Icon(
                        Icons.shopping_cart_checkout,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                          'Prise de Commande',
                          style: Theme.of(context).textTheme.headline4
                      ),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/command', (route) => false);
                      }),
                  ListTile(
                      leading: Icon(
                        Icons.work_outline,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        'Mes devis / Mes commandes',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/mycommands', (route) => false);
                      }),
                  ListTile(
                      leading: Icon(
                        Icons.delivery_dining_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        'Mes livraisons',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/mydelivery', (route) => false);
                      }),
                  ListTile(
                      leading: Icon(
                        Icons.money_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        'Encaissements',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/payment', (route) => false);
                      }),
                  // ListTile(
                  //     leading: Icon(
                  //       Icons.swap_vert_outlined,
                  //       color: Theme.of(context).primaryColor,
                  //     ),
                  //     title: Text(
                  //       'Chargement / Déchargement',
                  //       style: Theme.of(context).textTheme.headline4,
                  //     ),
                  //     onTap: () {
                  //       Navigator.pushNamedAndRemoveUntil(
                  //           context, '/charg', (route) => false);
                  //     }),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(bottom: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Divider(
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'version 1.0.0',
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: Colors.grey),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(Icons.logout_outlined,
                                  color: Theme.of(context).primaryColor),
                              InkWell(
                                onTap: () async{
                                  ConfirmationDialog confirmationDialog = ConfirmationDialog();
                                  bool confirmed = await confirmationDialog
                                      .showConfirmationDialog(context, 'logout');
                                  if(confirmed){
                                    DatabaseProvider().logOut(context);
                                  }
                                },
                                child: Text(
                                  'Déconnexion',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(
                                          color: Theme.of(context).primaryColor),
                                ),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
