import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/models/Itinerary.dart';
import 'package:sav_app/providers/itinerary_provider.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/widgets/drawers/itinerary_drawer.dart';

import 'dialog_filtred_itinerary.dart';

class ItineraryPage extends StatefulWidget {
  const ItineraryPage({super.key});

  static const String routeName = '/itinerary';

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => ItineraryPage(),
    );
  }

  @override
  State<ItineraryPage> createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  bool isMap = false;

  Future<void> fetchData() async {
    //print('image: ${AppUrl.baseUrl}${AppUrl.user.image}');
    final provider = Provider.of<ItineraryProvider>(context, listen: false);
    provider.itineraryList.clear();
    String url = AppUrl.itinerary +
        '?salCode=${AppUrl.filtredOpporunity.collaborateur!.salCode!}&date=${DateFormat('yyyy-MM-dd').format(AppUrl.filtredOpporunity.date!)}';
    print('url : $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res UserItineraires code : ${req.statusCode}");
    print("res UserItineraires body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      List<dynamic> data = json.decode(req.body);
      for (int i = 0; i < data.length; i++) {
        try {
          var element = data[i];
          LatLng location;
          try {
            location = LatLng(element['latitude'], element['longitude']);
          } catch (e) {
            continue;
          }
          String? s = element['type'];
          if (s == null || s == 'null') s = 'CPT';
          Itinerary itinerary = Itinerary(
              salCode: AppUrl.filtredOpporunity.collaborateur!.salCode!,
              etbCode: AppUrl.user.etblssmnt!.code!,
              position: location,
              type: element['type'],
              codeLie: element['codeLie'],
              date: DateTime.parse(element['date']));
          provider.itineraryList.add(itinerary);
        } catch (_) {}
      }
    }
    print('sizeIS: ${provider.itineraryList.length}');
    provider.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Future is still running, return a loading indicator or some placeholder.
            return AlertDialog(
              content: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      width: 200,
                      height: 100,
                      child: Image.asset('assets/SAV-Loader.gif')),
                  // CircularProgressIndicator(
                  //   color: primaryColor,
                  // ),
                  // SizedBox(
                  //   width: 30,
                  // ),
                  // Text("Loading..."),
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
          } else
            return Scaffold(
              appBar: AppBar(
                iconTheme: IconThemeData(
                  color: Colors.white, // Set icon color to white
                ),
                backgroundColor: Theme.of(context).primaryColor,
                actions: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          isMap = !isMap;
                        });
                      },
                      icon: (isMap)
                          ? Icon(
                              Icons.list_alt_outlined,
                              color: Colors.white,
                            )
                          : Icon(
                              Icons.location_on_outlined,
                              color: Colors.white,
                            )),
                  IconButton(
                      onPressed: () {
                        //_showDatePicker(context);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return FiltredItineraryDialog();
                          },
                        ).then((value) {
                          setState(() {});
                        });
                      },
                      icon: Icon(
                        Icons.sort,
                        color: Colors.white,
                      ))
                ],
                title: Container(
                  width: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mes Itinérairess',
                        style: Theme.of(context).textTheme.headline3!.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'du : ${DateFormat('yyyy-MM-dd').format(AppUrl.selectedDate)}, de : ${AppUrl.filtredOpporunity.collaborateur!.userName}',
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              drawer: DrawerItineraryPage(),
              body: (isMap) ? ViewMap() : ViewList(),
            );
        });
  }
}

class ViewMap extends StatelessWidget {
  const ViewMap({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ItineraryProvider>(builder: (context, provider, child) {
      return FlutterMap(
        options: MapOptions(
          center: (provider.itineraryList.length > 0)
              ? LatLng(provider.itineraryList.first.position!.latitude,
                  provider.itineraryList.first.position!.longitude)
              : LatLng(1.354474457244855, 1.849465150689236),
          zoom: 5.0,
        ),
        children: [
          TileLayer(
            tileProvider: NetworkTileProvider(),
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          MarkerLayer(
            markers: [
              // Markers for waypoints
              for (int i = 0; i < provider.itineraryList.length; i++)
                Marker(
                    point: provider.itineraryList[i].position,
                    child: (provider.itineraryList[i].type != 'CPT')
                        ? ListTile(
                            title: Text(
                              '${provider.itineraryList[i].type}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .copyWith(color: Colors.black),
                            ),
                            subtitle: Text(
                              '${DateFormat('HH:mm:ss').format(provider.itineraryList[i].date)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(color: Colors.grey),
                            ),
                            trailing: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.place_outlined,
                                    color: Colors.red)),
                          )
                        : ListTile(
                            title: Text(
                              '${provider.itineraryList[i].type}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(color: Colors.black),
                            ),
                            subtitle: Text(
                              '${DateFormat('HH:mm:ss').format(provider.itineraryList[i].date)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(color: Colors.grey),
                            ),
                            trailing: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.place_outlined,
                                    color: primaryColor)),
                          )),
            ],
          ),
        ],
      );
    });
  }
}

class ViewList extends StatelessWidget {
  const ViewList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ItineraryProvider>(builder: (context, provider, child) {
      return (provider.itineraryList.isEmpty)
          ? Center(
              child: Text(
                'Pas d\'itinéraires !',
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
                  child: ItineraryItem(
                    itinerary: provider.itineraryList[index],
                  )),
              // separatorBuilder: (BuildContext context, int index) {
              //   return Divider(
              //     color: Colors.grey,
              //   );
              // },
              itemCount: provider.itineraryList.length);
    });
  }
}

class ItineraryItem extends StatelessWidget {
  final Itinerary itinerary;

  const ItineraryItem({super.key, required this.itinerary});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.red;
    if (itinerary.type == 'CPT') color = Color(0xff049a9b);
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: color,
                ),
                //SizedBox(width: 20,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${itinerary.type}',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(color: Colors.black),
                    ),
                    Text(
                        '${DateFormat('yyyy-MM-dd HH:mm:ss').format(itinerary.date)}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(color: Colors.grey)),
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
