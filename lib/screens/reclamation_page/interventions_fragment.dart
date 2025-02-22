import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sav_app/providers/clients_map_provider.dart';

class InterventionsFragment extends StatefulWidget {
  const InterventionsFragment({super.key});

  @override
  State<InterventionsFragment> createState() => _InterventionsFragmentState();
}

class _InterventionsFragmentState extends State<InterventionsFragment> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ClientsMapProvider>(builder: (context, clients, child) {
      print('size:: ${clients.mapClientsWithCommands.length}');
      return Center(
        child: Text(
          'Aucune intervention !',
          style: Theme.of(context).textTheme.headline3,
        ),
      );
      if (clients.mapClientsWithCommands.length == 0)
        return Center(
          child: Text(
            'Aucune intervention !',
            style: Theme.of(context).textTheme.headline3,
          ),
        );
      else
        return ListView.builder(
            padding: EdgeInsets.all(12),
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) => InkWell(
                onTap: () {
                  // Navigator.pushNamed(
                  //     context, ClientPage.routeName);
                },
                child: Text('')),
            // separatorBuilder: (BuildContext context, int index) {
            //   return Divider(
            //     color: Colors.grey,
            //   );
            // },
            itemCount: clients.mapClientsWithCommands.length);
    });
  }
}
