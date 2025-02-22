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

class AddressListForAddClientPage extends StatefulWidget {
  final VoidCallback callback;
  final Client client;

  const AddressListForAddClientPage({
    super.key,
    required this.callback,
    required this.client,
  });

  @override
  State<AddressListForAddClientPage> createState() =>
      _AddressListForAddClientPageState();
}

class _AddressListForAddClientPageState
    extends State<AddressListForAddClientPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('thisClient: ${widget.client.id}');
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

  // Function to fetch JSON data from an API
  Future<void> fetchData(BuildContext context) async {
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    provider.adressesList = [];
    print('res client : ${widget.client.res}');
    print('res address : ${widget.client.res['adress']}');
    List<dynamic> data = widget.client.res['adress'];
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
      provider.adressesList.add(Client(
          name: element['rs'],
          location: latLng,
          type: element['type'],
          lib: element['title'],
          adress: element['numero'],
          name2: element['rs2'],
          phone: element['tel1'],
          phone2: element['tel2'],
          city: element['ville'],
          id: element['code']));
    });
    print('size is : ${provider.adressesList.length}');
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
          'Adresses de ${widget.client.name}',
          style: Theme.of(context)
              .textTheme
              .headline3!
              .copyWith(color: Colors.white),
        ),
        actions: [
          // IconButton(
          //   icon: Icon(
          //     Icons.search,
          //     color: Colors.white,
          //   ),
          //   onPressed: () {
          //     showSearch(
          //         context: context,
          //         delegate: ClientSearchDelegate(
          //           callback: widget.callback,
          //         ),
          //         query: '');
          //   },
          // ),
        ],
      ),
      body: Consumer<ClientsMapProvider>(builder: (context, clients, child) {
        return (clients.adressesList.isEmpty)
            ? Center(
                child: Text(
                  'Aucune adresse !',
                  style: Theme.of(context).textTheme.headline2,
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(12),
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      // Navigator.pushNamed(
                      //     context, ClientPage.routeName);
                    },
                    child: ClientItem(
                      callback: widget.callback,
                      selectedClient: clients.adressesList[index],
                      client: widget.client,
                    )),
                // separatorBuilder: (BuildContext context, int index) {
                //   return Divider(
                //     color: Colors.grey,
                //   );
                // },
                itemCount: clients.adressesList.length);
      }),
    );
  }
}

class ClientItem extends StatelessWidget {
  final Client selectedClient;
  final Client client;
  final VoidCallback callback;

  const ClientItem(
      {super.key, required this.selectedClient, required this.callback, required this.client});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    Color txtColor = Color(0xff049a9b);
    if (selectedClient.type == 'C') txtColor = Colors.blue;
    if (selectedClient.type == 'F') txtColor = Colors.red;
    if (selectedClient.total == null) selectedClient.total = 0.toString();
    if (selectedClient.total == null) selectedClient.total = 0.toString();
    if (double.parse(selectedClient.total.toString()) > 0) {
      color = Color(0xff049a9b);
    } else if (double.parse(selectedClient.total.toString()) < 0) {
      color = Colors.red;
    }
    return InkWell(
      onTap: () {
        client.lib = selectedClient.lib;
        client.adress = selectedClient.id;
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
                  Icons.location_on_rounded,
                  color: primaryColor,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${selectedClient.lib} ',
                      style: Theme.of(context)
                          .textTheme
                          .headline5!
                          .copyWith(color: txtColor),
                    ),
                    Text('${selectedClient.city}',
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
