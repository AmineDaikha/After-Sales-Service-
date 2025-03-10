import 'dart:convert';

import 'package:animate_icons/animate_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/models/client.dart';
import 'package:sav_app/models/command.dart';
import 'package:sav_app/providers/command_provider.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/routers.dart';

import 'deliver_page.dart';

class DelivredHistoryFragment extends StatefulWidget {
  Client client;

  DelivredHistoryFragment({super.key, required this.client});

  @override
  State<DelivredHistoryFragment> createState() =>
      _DelivredHistoryFragmentState();
}

class _DelivredHistoryFragmentState extends State<DelivredHistoryFragment> {
  AnimateIconController controller = AnimateIconController();
  DateTime dateStart = DateTime.now();
  DateTime dateEnd = DateTime.now();

  // Function to fetch JSON data from an API
  Future<void> fetchData() async {
    String url = AppUrl.livraison +
        AppUrl.user.etblssmnt!.code! +
        '/' +
        widget.client.id!;
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res liv code : ${req.statusCode}");
    print("res liv body: ${req.body}");
    final provider = Provider.of<CommandProvider>(context, listen: false);
    if (req.statusCode == 200) {
      // add commands
      provider.deliverdList = [];
      List<dynamic> data = json.decode(req.body);
      //data.toList().forEach((element) {
      for (int i = 0; i < data.length; i++) {
        var element = data[i];
        if (AppUrl.isDateBetween(
                DateTime.parse(element['date']), dateStart, dateEnd) ==
            false) continue;
        print('salCode coll : ${AppUrl.filtredCommandsClient.collaborateur!.salCode},, ${element['salCode']}');
        if (AppUrl.filtredCommandsClient.allCollaborators == false) {
          if (AppUrl.filtredCommandsClient.collaborateur!.salCode !=
              element['salCode']) continue;
        }
        provider.deliverdList.add(Command(
            id: element['numero'],
            date: DateTime.parse(element['date']),
            total: element['brut'],
            deliver: element['codeChauffeur'],
            paid: 0,
            products: [],
            nbProduct: 0));
        provider.notifyListeners();
      }
      //});
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateStart,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            // Day color
            buttonTheme: ButtonThemeData(
              colorScheme: ColorScheme.light(
                primary: primaryColor, // Change the color here
              ),
            ),
            colorScheme: ColorScheme.light(primary: primaryColor)
                .copyWith(secondary: primaryColor),
            // Button text color
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        dateStart = DateTime(picked.year, picked.month, picked.day, 0, 0, 0);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateEnd,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            // Day color
            buttonTheme: ButtonThemeData(
              colorScheme: ColorScheme.light(
                primary: primaryColor, // Change the color here
              ),
            ),
            colorScheme: ColorScheme.light(primary: primaryColor)
                .copyWith(secondary: primaryColor),
            // Button text color
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        dateEnd =
            DateTime(picked.year, picked.month, picked.day, 23, 59, 59, 999);
      });
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
            return Center(
              child: Row(
                children: [
                  CircularProgressIndicator(
                    color: primaryColor,
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 15, top: 35, bottom: 35),
                      child: Text("Loading...")),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            // There was an error in the future, handle it.
            print('Error: ${snapshot.hasError}');
            return Text('Error: ${snapshot.error}');
          } else
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Container(
                //   margin: EdgeInsets.all(8),
                //   child: (AppUrl.filtredCommandsClient.allCollaborators)
                //       ? Text(
                //           'Collaborateurs: Tout',
                //           style: Theme.of(context)
                //               .textTheme
                //               .headline4!
                //               .copyWith(color: primaryColor),
                //         )
                //       : Text(
                //           'Collaborateurs: ${AppUrl.filtredCommandsClient.collaborateur!.userName}',
                //           style: Theme.of(context)
                //               .textTheme
                //               .headline4!
                //               .copyWith(color: primaryColor),
                //         ),
                // ),
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 10),
                //   decoration: BoxDecoration(
                //     color: Colors.grey[300],
                //     boxShadow: [
                //       // BoxShadow(
                //       //   color: Colors.grey.withOpacity(0.1), // Shadow color
                //       //   offset: Offset(0, 5), // Offset from the object
                //       // ),
                //     ],
                //   ),
                //   margin: EdgeInsets.all(8),
                //   height: 50,
                //   child: Stack(
                //     children: [
                //       Align(
                //         alignment: Alignment.centerLeft,
                //         child: Row(
                //           children: [
                //             Icon(
                //               Icons.attach_money_outlined,
                //               color: primaryColor,
                //             ),
                //             Text(
                //               '${AppUrl.formatter.format(widget.client.totalPay)} DZD',
                //               style: Theme.of(context)
                //                   .textTheme
                //                   .headline3!
                //                   .copyWith(color: primaryColor),
                //             ),
                //           ],
                //         ),
                //       ),
                //       Align(
                //         alignment: Alignment.center,
                //       ),
                //       Align(
                //         alignment: Alignment.centerRight,
                //         child: Icon(
                //           Icons.call_outlined,
                //           color: primaryColor,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1), // Shadow color
                        offset: Offset(0, 5), // Offset from the object
                      ),
                    ],
                  ),
                  margin: EdgeInsets.all(8),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _selectStartDate(context);
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              color: primaryColor,
                            ),
                            Text(
                              'Du ${DateFormat('yyyy-MM-dd').format(dateStart)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(color: primaryColor),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _selectEndDate(context);
                        },
                        child: Row(
                          children: [
                            Text(
                              'Au ${DateFormat('yyyy-MM-dd').format(dateEnd)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(color: primaryColor),
                            ),
                            Icon(
                              Icons.calendar_month_outlined,
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Consumer<CommandProvider>(
                    builder: (context, commands, snapshot) {
                  return Expanded(
                    child: (commands.deliverdList.length != 0)
                        ? ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              widget.client.command =
                                  commands.deliverdList[index];
                              print(
                                  'size of deliverdList: ${commands.deliverdList.length}');
                              return CommandItem(
                                client: widget.client,
                                command: commands.deliverdList[index],
                              );
                            },
                            itemCount: commands.deliverdList.length)
                        : Center(
                            child: Text(
                            'Aucune livraison',
                            style: Theme.of(context).textTheme.headline6,
                          )),
                  );
                }),
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
            page: DeliverdPage(
          client: client,
          type: 'Livraison',
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
                  Icons.delivery_dining_outlined,
                  color: primaryColor,
                ),
                SizedBox(
                  width: 20,
                ),
                Center(
                    child: (command.deliver != null)
                        ? Text(
                            '${command.deliver} ',
                            style:
                                Theme.of(context).textTheme.headline4!.copyWith(
                                      color: black,
                                      fontWeight: FontWeight.normal,
                                    ),
                          )
                        : Container()),
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
                      child: Text('${command.date}',
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
