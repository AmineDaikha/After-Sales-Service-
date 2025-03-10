import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/constants/utils.dart';
import 'package:sav_app/models/client.dart';
import 'package:sav_app/providers/clients_map_provider.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/routers.dart';
import 'package:sav_app/widgets/add_client_page1.dart';

import 'alert.dart';

class ClientsListForAddClientPage extends StatefulWidget {
  final VoidCallback callback;

  const ClientsListForAddClientPage({
    super.key,
    required this.callback,
  });

  @override
  State<ClientsListForAddClientPage> createState() =>
      _ClientsListForAddClientPageState();
}

class _ClientsListForAddClientPageState
    extends State<ClientsListForAddClientPage> {
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        showLoaderDialog(context);
        fetchData(context).then((value) {
          Navigator.pop(context);
        });
      } on SocketException catch (_) {
        _showAlertDialog(context, 'Pas de connecxion !');
      }
    });
  }

  void _scrollListener() {
    // Check if we've reached the end of the list
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // We're at the end of the list, perform your action here
      print('Reached the end of the list!');
      AppUrl.filtredClient.first = true;
      showLoaderDialog(context);
      fetchData(context).then((value) {
        Navigator.pop(context);
      });
    }
  }

  // Function to fetch JSON data from an API
  int PageNumber = 0;
  Future<void> fetchData(BuildContext context) async {
    PageNumber++;
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    if (PageNumber == 1) provider.clientsList = [];
    final query = '';
    String url =
    '${AppUrl.tiersPage}?etbCode=${AppUrl.user.etblssmnt!.code}&PageNumber=$PageNumber&PageSize=20&type=C';
    print('url getClients: $url');
    http.Response req = await http.get(
        Uri.parse(url),//AppUrl.tiersPage + '?PageNumber=1&Filter=$query&PageSize=30'
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
        });
    print("res client code : ${req.statusCode}");
    print("res client body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      data.toList().forEach((element) async {
        print('code client:  ${element['type']}');
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
            res: element,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          PageNavigator(ctx: context)
              .nextPage(page: AddClientPage1())
              .then((value) {
            print('finish add');
            widget.callback();
            Navigator.pop(context);
          });
        },
        child: Icon(
          Icons.person_add_alt,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set icon color to white
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Prospects / Clients',
          style: Theme.of(context)
              .textTheme
              .headline3!
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
                  delegate: ClientSearchDelegate(
                    callback: widget.callback,
                  ),
                  query: '');
            },
          ),
        ],
      ),
      //drawer: DrawerClientsListPage(),
      body: Consumer<ClientsMapProvider>(builder: (context, clients, child) {
        return (clients.clientsList.isEmpty)
            ? Center(
                child: Text(
                  'Pas de clients !',
                  style: Theme.of(context).textTheme.headline2,
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(12),
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      // Navigator.pushNamed(
                      //     context, ClientPage.routeName);
                    },
                    child: ClientItem(
                      callback: widget.callback,
                      client: clients.clientsList[index],
                    )),
                // separatorBuilder: (BuildContext context, int index) {
                //   return Divider(
                //     color: Colors.grey,
                //   );
                // },
                itemCount: clients.clientsList.length);
      }),
    );
  }
}

class ClientItem extends StatelessWidget {
  final Client client;
  final VoidCallback callback;

  const ClientItem({super.key, required this.client, required this.callback});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    Color txtColor = Color(0xff049a9b);
    if (client.type == 'C') txtColor = Colors.blue;
    if (client.type == 'F') txtColor = Colors.red;
    if (client.total == null) client.total = 0.toString();
    if (client.total == null) client.total = 0.toString();
    if (double.parse(client.total.toString()) > 0) {
      color = Color(0xff049a9b);
    } else if (double.parse(client.total.toString()) < 0) {
      color = Colors.red;
    }
    return InkWell(
      onTap: () {
        AppUrl.selectedClient = client;
        callback();
        Navigator.pop(context);
        // PageNavigator(ctx: context).nextPage(
        //     page: ClientPage(
        //   client: client,
        // ));
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
  final VoidCallback callback;

  ClientSearchDelegate({
    required this.callback,
  });

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
                Text('Pas de connexion'),
              ],
            ),
          );
        } else {
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
                        callback: callback,
                        client: uniqueClientList[index],
                      ),
                  itemCount: uniqueClientList.length),
            );
        }
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
                Text('Pas de connexion'),
              ],
            ),
          );
        } else {
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
                        callback: callback,
                        client: uniqueClientList[index],
                      ),
                  itemCount: uniqueClientList.length),
            );
        }
      },
    );
  }

  // Function to fetch JSON data from an API
  Future<void> fetchData(BuildContext context) async {
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    provider.filtredClients = [];
    http.Response req = await http.get(
        Uri.parse(AppUrl.tiersPage + '?etbCode=${AppUrl.user.etblssmnt!.code}&PageNumber=1&Filter=$query&PageSize=20&type=C'),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
        });
    print("res tier code : ${req.statusCode}");
    print("res tier body: ${req.body}");
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

void _showAlertDialog(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.yellow,
              size: 50.0,
            ),
          ],
        ),
        content: Text(
          '$text',
          style: Theme.of(context).textTheme.headline6!,
        ),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(primaryColor)),
            onPressed: () {
              Navigator.of(context).pop();
              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            },
            child: Text('Ok',
                style: Theme.of(context)
                    .textTheme
                    .headline3!
                    .copyWith(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
