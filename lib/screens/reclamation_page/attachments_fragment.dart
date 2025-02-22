import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sav_app/providers/clients_map_provider.dart';

class AttachmentsFragment extends StatefulWidget {
  const AttachmentsFragment({super.key});

  @override
  State<AttachmentsFragment> createState() => _AttachmentsFragmentState();
}

class _AttachmentsFragmentState extends State<AttachmentsFragment> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ClientsMapProvider>(builder: (context, clients, child) {
      print('size:: ${clients.mapClientsWithCommands.length}');
      return Center(
        child: Text(
          'Aucun document !',
          style: Theme.of(context).textTheme.headline3,
        ),
      );
      if (clients.mapClientsWithCommands.length == 0)
        return Center(
          child: Text(
            'Aucun document !',
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
