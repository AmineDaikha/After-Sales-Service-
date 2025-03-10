import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/constants/utils.dart';
import 'package:sav_app/models/client.dart';
import 'package:sav_app/providers/clients_map_provider.dart';
import 'package:sav_app/widgets/alert.dart';
import 'package:sav_app/widgets/drawers/command_drawer.dart';
import 'store_page.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/routers.dart';
import 'package:provider/provider.dart';

class CommandListPage extends StatefulWidget {
  const CommandListPage({super.key});

  static const String routeName = '/command';

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => CommandListPage(),
    );
  }

  @override
  State<CommandListPage> createState() => _CommandListPageState();
}

class _CommandListPageState extends State<CommandListPage> {
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLoaderDialog(context);
      fetchData(context).then((value) {
        Navigator.pop(context);
      });
    });
  }
  @override
  void dispose() {
    // Don't forget to dispose the scroll controller
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Check if we've reached the end of the list
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // We're at the end of the list, perform your action here
      print('Reached the end of the list!');
      showLoaderDialog(context);
      fetchData(context).then((value) {
        Navigator.pop(context);
      });
    }
  }
  int PageNumber = 0;
  // Function to fetch JSON data from an API
  Future<void> fetchData(BuildContext context) async {
    PageNumber++;
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    if(PageNumber == 1)provider.clientsList = [];
    final query = '';
    String url =
        '${AppUrl.tiersPage}?etbCode=${AppUrl.user.etblssmnt!.code}&PageNumber=$PageNumber&PageSize=20&type=C';
    http.Response req = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://"+AppUrl.user.company!+".localhost:4200/"
        });
    print("res article code : ${req.statusCode}");
    print("res article body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      data.toList().forEach((element) async {
        print('code client:  ${element['code']}');
        LatLng latLng;
        if (element['longitude'] == null || element['latitude'] == null)
          latLng = LatLng(1.354474457244855, 1.849465150689236);
        else {
          try {
            latLng = LatLng(element['latitude'], element['longitude']);
          } catch (e) {
            print('latlong err: $e');
            latLng = LatLng(1.354474457244855, 1.849465150689236);
          }
        }
        provider.clientsList.add(Client(
            name: element['rs'],
            location: latLng,
            type: element['type'],
            name2: element['rs2'],
            phone: element['tel1'],
            phone2: element['tel2'],
            city: element['ville'],
            id: element['code']));
      });
    }
    print('size is : ${provider.clientsList.length}');
    provider.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set icon color to white
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Prise de commande',
          style: Theme.of(context)
              .textTheme
              .headline2!
              .copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: ClientSearchDelegate(),
                  query: '');
            },
          ),
        ],
      ),
      drawer: DrawerCommandPage(),
      body: Column(
        children: [
          Container(
            height: 50,
            width: double.infinity,
            child: Center(
              child: Text(
                'Sélctionner un Client',
                style: Theme.of(context)
                    .textTheme
                    .headline3!
                    .copyWith(color: primaryColor),
              ),
            ),
          ),
          Consumer<ClientsMapProvider>(builder: (context, clients, child) {
            return Expanded(
              child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  padding: EdgeInsets.all(12),
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) => InkWell(
                      onTap: () {
                        // Navigator.pushNamed(
                        //     context, ClientPage.routeName);
                      },
                      child: ClientItem(
                        client: clients.clientsList[index],
                      )),
                  // separatorBuilder: (BuildContext context, int index) {
                  //   return Divider(
                  //     color: Colors.grey,
                  //   );
                  // },
                  itemCount: clients.clientsList.length),
            );
          }),
        ],
      ),
    );
  }
}

class ClientItem extends StatelessWidget {
  final Client client;

  const ClientItem({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    Color txtColor = primaryColor;
    if (client.type == 'C') txtColor = Colors.blue;
    if (client.type == 'F') txtColor = Colors.red;
    if (client.total == null) client.total = 0.toString();
    if (client.total == null) client.total = 0.toString();
    if (double.parse(client.total.toString()) > 0) {
      color = primaryColor;
    } else if (double.parse(client.total.toString()) < 0) {
      color = Colors.red;
    }
    return InkWell(
      onTap: () {
        PageNavigator(ctx: context).nextPage(
            page: StorePage(
          client: client,
        ));
      },
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.person_pin_rounded,
                  color: primaryColor,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${client.name} ',
                      style: Theme.of(context)
                          .textTheme
                          .headline5!
                          .copyWith(color: txtColor),
                    ),
                    Text('${client.city}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(color: Colors.grey)),
                  ],
                ),
                Text(
                  '',
                  //'${client.total} DZD ',
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(color: color, fontWeight: FontWeight.normal),
                ),
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          onPressed: () {
                            if (client.phone != null)
                              PhoneUtils().makePhoneCall(client.phone!);
                            else
                              showAlertDialog(context,
                                  'Aucune numéro de téléphone pour ce client');
                          },
                          icon: Icon(
                            Icons.call_outlined,
                            color: Colors.grey,
                            size: 20,
                          )),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: IconButton(
                          onPressed: () {
                            if (client.phone != null)
                              PhoneUtils().makeSms(client.phone!);
                            else
                              showAlertDialog(context,
                                  'Aucune numéro de téléphone pour ce client');
                          },
                          icon: Icon(
                            Icons.mail_outline,
                            color: Colors.grey,
                            size: 20,
                          )),
                    )
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

class ClientSearchDelegate extends SearchDelegate {
  // final Client client;
  // final VoidCallback callback;

  ClientSearchDelegate();

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
            onPressed: () {
              if (query.isNotEmpty)
                query = '';
              else
                close(context, null);
            },
            icon: Icon(Icons.clear))
      ];

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    provider.filtredClients = [];
    return FutureBuilder(
      future: fetchData(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Future is still running, return a loading indicator or some placeholder.
          return AlertDialog(
            content: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircularProgressIndicator(
                  color: primaryColor,
                ),
                SizedBox(
                  width: 30,
                ),
                Text("Loading..."),
              ],
            ),
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
                Text('Nous sommes désolé, la qualité de votre connexion ne vous permet pas de vous connecter à votre serveur.'
                      ' Veuillez réessayer ultérieurement. Merci'),
              ],
            ),
          );
        } else{
          List<Client> list = [];
          for (Client client in provider.filtredClients) {
            try {
              if (client.name!.toLowerCase().contains(query.toLowerCase()) ||
                  client.phone!.toLowerCase().contains(query.toLowerCase()) ||
                  client.total!.toLowerCase().contains(query.toLowerCase()) ||
                  client.city!.toLowerCase().contains(query.toLowerCase())) {
                list.add(client);
              }
            } catch (_) {
              continue;
            }
          }
          Set<Client> uniqueClientSet = list.toSet();
          List<Client> uniqueClientList = uniqueClientSet.toList();
          if (uniqueClientList.isEmpty)
            return Center(
              child: Text(
                'Aucune résultat !',
                style: Theme.of(context).textTheme.headline2,
              ),
            );
          else
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) => ClientItem(
                    client: uniqueClientList[index],
                  ),
                  itemCount: uniqueClientList.length),
            );}
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    provider.filtredClients = [];
    return FutureBuilder(
      future: fetchData(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Future is still running, return a loading indicator or some placeholder.
          return AlertDialog(
            content: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircularProgressIndicator(
                  color: primaryColor,
                ),
                SizedBox(
                  width: 30,
                ),
                Text("Loading..."),
              ],
            ),
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
                Text('Nous sommes désolé, la qualité de votre connexion ne vous permet pas de vous connecter à votre serveur.'
                      ' Veuillez réessayer ultérieurement. Merci'),
              ],
            ),
          );
        } else{
        List<Client> list = [];
        for (Client client in provider.filtredClients) {
          try {
            if (client.name!.toLowerCase().contains(query.toLowerCase()) ||
                client.phone!.toLowerCase().contains(query.toLowerCase()) ||
                client.total!.toLowerCase().contains(query.toLowerCase()) ||
                client.city!.toLowerCase().contains(query.toLowerCase())) {
              list.add(client);
            }
          } catch (_) {
            continue;
          }
        }
        Set<Client> uniqueClientSet = list.toSet();
        List<Client> uniqueClientList = uniqueClientSet.toList();
        if (uniqueClientList.isEmpty)
          return Center(
            child: Text(
              'Aucune résultat !',
              style: Theme.of(context).textTheme.headline2,
            ),
          );
        else
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) => ClientItem(
                      client: uniqueClientList[index],
                    ),
                itemCount: uniqueClientList.length),
          );}
      },
    );
  }

  // Function to fetch JSON data from an API
  Future<void> fetchData(BuildContext context) async {
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    provider.filtredClients = [];
    String url = AppUrl.tiersPage + '?etbCode=${AppUrl.user.etblssmnt!.code}&PageNumber=1&Filter=$query&PageSize=20&type=C';
    http.Response req = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://"+AppUrl.user.company!+".localhost:4200/"
        });
    print("res tiers code : ${req.statusCode}");
    print("res tiers body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      data.toList().forEach((element) async {
          print('code client:  ${element['ville']}');
        LatLng latLng;
        if (element['longitude'] == null || element['latitude'] == null)
          latLng = LatLng(1.354474457244855, 1.849465150689236);
        else {
          try {
            latLng = LatLng(element['latitude'], element['longitude']);
          } catch (e) {
            print(
                'latlong : ${element['latitude']}  ${element['longitude']}');
            print('latlong err: $e');
            latLng = LatLng(1.354474457244855, 1.849465150689236);
          }
        }
        provider.filtredClients.add(Client(
            name: element['rs'],
            location: latLng,
            type: element['type'],
            name2: element['rs2'],
            phone: element['tel1'],
            phone2: element['tel2'],
            city: element['ville'],
            id: element['code']));
      });
    }
    print('size is : ${provider.clientsList.length}');
    provider.notifyListeners();
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
