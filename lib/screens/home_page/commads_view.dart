import 'dart:convert';

import 'package:animate_icons/animate_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/models/client.dart';
import 'package:sav_app/models/command.dart';
import 'package:sav_app/models/product.dart';
import 'package:sav_app/providers/command_provider.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/routers.dart';
import 'package:provider/provider.dart';

import 'command_page.dart';
import 'deliver_page.dart';
import 'init_store_page.dart';

class CommandsView extends StatefulWidget {
  Client client;

  CommandsView({super.key, required this.client});

  @override
  State<CommandsView> createState() => _CommandsViewState();
}

class _CommandsViewState extends State<CommandsView> {
  AnimateIconController controller = AnimateIconController();
  DateTime dateStart = DateTime.now();
  DateTime dateEnd = DateTime.now();

  Future<void> fetchData() async {
    String url = AppUrl.getDocs +
        '?interNumero=${widget.client.resOppo['numero']}' ;
    print('urlis: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res myCommands code : ${req.statusCode}");
    print("res myCommands body : ${req.body}");
    final provider = Provider.of<CommandProvider>(context, listen: false);
    if (req.statusCode == 200) {
      provider.commandList = [];
      List<dynamic> data = json.decode(req.body);
      print('size commands : ${data.toList().length}');
      //data.toList().forEach((element) async {
      for (int i = 0; i < data.length; i++) {
        var element = data[i];
        // if (AppUrl.isDateBetween(
        //         DateTime.parse(element['date']), dateStart, dateEnd) ==
        //     false) continue;
        // if (AppUrl.filtredCommandsClient.client!.id != '-1') {
        //   if (AppUrl.filtredCommandsClient.client!.id != element['pcfCode'])
        //     continue;
        // }
        print('type is: ${element['type']}');
        if (element['stype'] == 'C' && element['type'] == 'V') {
          String pcfCode = element['pcfCode'];
          http.Response req =
              await http.get(Uri.parse(AppUrl.getOneTier + pcfCode), headers: {
            "Accept": "application/json",
            "content-type": "application/json; charset=UTF-8",
            "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
          });
          print("res oneTier code : ${req.statusCode}");
          print("res oneTier body: ${req.body}");
          if (req.statusCode == 200) {
            var res = json.decode(req.body);
            print('code client:  ${res['code']}');
            print('brut cmd  ${element['brut']}');
            LatLng latLng;
            if (res['longitude'] == null || res['latitude'] == null)
              latLng = LatLng(1.354474457244855, 1.849465150689236);
            else
              latLng = LatLng(res['latitude'], res['longitude']);
            Client client = Client(
                name: res['rs'],
                location: latLng,
                name2: res['rs2'],
                phone: res['tel1'],
                phone2: res['tel2'],
                city: res['ville'],
                id: res['code']);
            provider.commandList.add(Command(
                id: element['numero'],
                date: DateTime.parse(element['date']),
                total: element['brut'],
                deliver: element['codeChauffeur'],
                paid: 0,
                products: [],
                client: client,
                nbProduct: 0));
            provider.notifyListeners();
          }
        }
      }

      // });
    }
  }

  @override
  void initState() {
    super.initState();
    dateStart = DateTime(
      dateStart.year,
      dateStart.month,
      dateStart.day,
      0, // new hour
      0, // new minute
      0, // new second
    );
    dateEnd = DateTime(
        dateEnd.year,
        dateEnd.month,
        dateEnd.day,
        23,
        // new hour
        59,
        // new minute
        59,
        // new second
        999);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Future is still running, return a loading indicator or some placeholder.
            return AlertDialog(
              content: Container(
                  width: 200,
                  height: 100,
                  child: Image.asset('assets/SAV-Loader.gif')),
            );
          } else if (snapshot.hasError) {
            // There was an error in the future, handle it.
            print('Error: ${snapshot.hasError} ${snapshot.error} ');
            return AlertDialog(
              content: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  // Text('Error: ${snapshot.error}')
                  Text(
                      'Nous sommes désolé, la qualité de votre connexion ne vous permet pas de vous connecter à votre serveur.'
                      ' Veuillez réessayer ultérieurement. Merci'),
                ],
              ),
            );
          } else
            return Stack(
              children: [
                Consumer<CommandProvider>(
                    builder: (context, commands, snapshot) {
                  return (commands.commandList.length != 0)
                      ? Container(
                    height:AppUrl.getFullHeight(context)*0.8,
                        child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              print(
                                  'size of commandList: ${commands.commandList.length}');
                              return CommandItem(
                                client: commands.commandList[index].client!,
                                command: commands.commandList[index],
                              );
                            },
                            itemCount: commands.commandList.length),
                      )
                      : Container(
                          height: AppUrl.getFullHeight(context) *0.8,
                          child: Center(
                              child: Text(
                            'Aucune commande',
                            style: Theme.of(context).textTheme.headline6,
                          )),
                        );
                }),
                Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: FloatingActionButton(
                    backgroundColor: primaryColor,
                    onPressed: (){
                      PageNavigator(ctx: context).nextPage(
                          page: StorePage(
                            client: widget.client,
                            type: 'command',
                          ));
                    },
                    tooltip: 'Ajouter commande',
                    child: Icon(Icons.add, color: white,),
                  ),
                ),
              ],
            );
        });
  }
}

class CommandItem extends StatelessWidget {
  final Client client;
  final Command command;

  const CommandItem({super.key, required this.command, required this.client});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        client.command = command;
        PageNavigator(ctx: context).nextPage(
            page: CommandPage(
          client: client,
          //type: 'Commande',
        ));
      },
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 50,
            child: Row(
              children: [
                Icon(
                  Icons.file_copy_outlined,
                  color: primaryColor,
                ),
                SizedBox(
                  width: 20,
                ),
                Center(
                  child: Container(
                    width: 100,
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1, // Limit the number of lines
                      '${command.client!.name} ',
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                            color: black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      child: Text(
                        '${AppUrl.formatter.format(command.total)} DZD',
                        style: Theme.of(context).textTheme.headline4!.copyWith(
                              color: primaryColor,
                            ),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          '${DateFormat('yyyy-MM-dd  HH:mm:ss').format(command.date)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(color: Colors.grey)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.grey,
          )
        ],
      ),
    );
  }
}
