import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:sav_app/models/client.dart';
import 'package:sav_app/models/command.dart';
import 'package:sav_app/models/familly.dart';
import 'package:sav_app/models/product.dart';
import 'package:sav_app/models/sfamilly.dart';
import 'package:sav_app/providers/clients_map_provider.dart';
import 'package:sav_app/providers/product_provider.dart';
import 'package:sav_app/screens/home_page/clients_list_page.dart';

//import 'package:sav_app/screens/home_page/home_page.dart';
import 'package:sav_app/screens/reclamation_page/reclamation_page.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/routers.dart';
import 'package:sav_app/utils/snack_message.dart';
import 'package:sav_app/widgets/command_dialog.dart';
import 'package:sav_app/widgets/drawers/catalog_drawer.dart';
import 'package:sav_app/widgets/text_field.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:sav_app/constants/urls.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import 'dialog_change_garanted_date.dart';
import 'dialog_filtred_catalog.dart';
import 'interventions_page.dart';
import 'new_command_page.dart';

class StorePage extends StatefulWidget {
  final Client client;

  static const String routeName = '/catalog';

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => StorePage(client: Client()),
    );
  }

  const StorePage({super.key, required this.client});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  String result = '';
  double total = 0;
  int nbProduct = 0;
  int PageNumber = 0;
  int PageSize = 10;
  String filter = '';
  String _barcodeResult = 'No Barcode Yet';
  final TextEditingController _client = TextEditingController();
  Command currentCommand = new Command(
      date: DateTime.now(), total: 0, paid: 0, products: [], nbProduct: 0);
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    widget.client.command = Command(
        date: DateTime.now(), total: 0, paid: 0, products: [], nbProduct: 0);
    final provider = Provider.of<ProductProvider>(context, listen: false);
    provider.allProducts = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLoaderDialog(context);
      fetchData().then((value) {
        Navigator.pop(context);
        reload();
      });
      //reload();
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
      fetchData().then((value) {
        Navigator.pop(context);
      });
    }
  }

  Future<void> fetchData() async {
    //await _fetchData();
    final provider = Provider.of<ProductProvider>(context, listen: false);
    provider.allProducts = [];
    String url = '';
    url = AppUrl.articlesSuiv +
        '?PageNumber=$PageNumber&Filter=$filter&PageSize=$PageSize';

    print('url catalog: ${url}');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res articlelist code : ${req.statusCode}");
    print("res articlelist body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      data.toList().forEach((element) {
        print(
            'code article:  ${element['artCode']} jijiji ${element['article']['marque']} ${element['tiers']}');
        //print('price is: ${element['pVte']}');
        String? categ;
        double price = 0;
        try {
          categ = element['article']['marque']['lib'];
        } catch (_) {}
        if (element['article']['pVte'] != null)
          price = element['article']['pVte'];
        getUrlImage(element['artCode'].toString()).then((value) {
          getQuantityMax(element['artCode'].toString()).then((stk) {
            Product p = Product(
                name: element['article']['lib'],
                numSerie: element['numSerie'],
                image: value,
                remise: 0,
                adrNumero: element['adrNumero'],
                tva: 0,
                quantityStock: stk,
                category: categ,
                codeBar: element['article']['cbar'],
                isChosen: false,
                quantity: 0,
                price: price,
                total: 0,
                garanted: element['garantie'],
                dateExpired: DateTime.parse(element['dateFinGarantie']),
                id: element['artCode'].toString());
            p.res = element;
            provider.allProducts.add(p);
            provider.notifyListeners();
          });
        });
      });
    }
  }

  // Function to fetch JSON data from an API
  // Future<void> fetchData() async {
  //   //await _fetchData();
  //   final provider = Provider.of<ProductProvider>(context, listen: false);
  //   PageNumber++;
  //   if (PageNumber == 1) provider.allProducts = [];
  //   String url = '';
  //   if (AppUrl.filtredCatalog.selectedFamilly!.code == '-1') {
  //     url = AppUrl.articles +
  //         '?PageNumber=$PageNumber&Filter=$filter&PageSize=$PageSize';
  //   } else {
  //     if (AppUrl.filtredCatalog.selectedSFamilly!.code == '-1')
  //       url = AppUrl.articlesOfFamilly +
  //           AppUrl.filtredCatalog.selectedFamilly!.code +
  //           '?PageNumber=$PageNumber&Filter=$filter&PageSize=$PageSize';
  //     else
  //       url = AppUrl.articlesOfFamilly +
  //           AppUrl.filtredCatalog.selectedSFamilly!.code +
  //           '?PageNumber=$PageNumber&Filter=$filter&PageSize=$PageSize';
  //   }
  //
  //   print('url catalog: ${url}');
  //   http.Response req = await http.get(Uri.parse(url), headers: {
  //     "Accept": "application/json",
  //     "content-type": "application/json; charset=UTF-8",
  //     "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
  //   });
  //   print("res articlelist code : ${req.statusCode}");
  //   print("res articlelist body: ${req.body}");
  //   if (req.statusCode == 200) {
  //     List<dynamic> data = json.decode(req.body);
  //     print('size catlogList : ${data.length}');
  //     data.toList().forEach((element) {
  //       print('code article:  ${element['code']}');
  //       print('price is: ${element['pVte']}');
  //       double price = 0;
  //       if (element['pVte'] != null) price = element['pVte'];
  //       getUrlImage(element['code']).then((value) {
  //         getQuantityMax(element['code']).then((stk) {
  //           Product p = Product(
  //               name: element['lib'],
  //               image: value,
  //               remise: 0,
  //               tva: 0,
  //               quantityStock: stk,
  //               category: element['categ'],
  //               codeBar: element['cbar'],
  //               isChosen: false,
  //               quantity: 0,
  //               price: price,
  //               total: 0,
  //               id: element['code']);
  //           provider.allProducts.add(p);
  //           provider.notifyListeners();
  //         });
  //       });
  //     });
  //   }
  //   print('size is: ${provider.allProducts.length}');
  // }

  @override
  Widget build(BuildContext context) {
    String nameClient = '';
    if (widget.client.id != null) {
      nameClient = widget.client.name!;
    }
    return Scaffold(
      drawer: DrawerCatalogPage(),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set icon color to white
        ),
        backgroundColor: primaryColor,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Équipements',
              style: Theme.of(context)
                  .textTheme
                  .headline3!
                  .copyWith(color: Colors.white),
            ),
            Text(
              'Famille : ${AppUrl.filtredCatalog.selectedFamilly!.name}',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(color: Colors.white),
            ),
            Text(
              'Sous famille : ${AppUrl.filtredCatalog.selectedSFamilly!.name}',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              final provider =
                  Provider.of<ProductProvider>(context, listen: false);
              provider.filtredProducts = [];
              showSearch(
                  context: context,
                  delegate:
                      StoreSearchDelegate(widget.client.command!, reload, ''),
                  query: '');
            },
          ),
          IconButton(
              onPressed: () {
                _scanBarcode();
              },
              icon: Icon(Icons.document_scanner_outlined)),
          IconButton(
              onPressed: () {
                //_showDatePicker(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FiltredCatalogDialog();
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
      ),
      // floatingActionButton: Container(
      //   margin: EdgeInsets.only(bottom: 30),
      //   child: FloatingActionButton(
      //     onPressed: () {
      //       if (widget.client.id == null) {
      //         _showAlertDialog(context, 'Il faut choisir un client d\'abord !');
      //         return;
      //       }
      //       if (widget.client.command!.nbProduct > 0) {
      //         showDialog(
      //           context: context,
      //           builder: (BuildContext context) {
      //             return AlertDialog(
      //               title: Center(child: Text('Veuillez choisir une option')),
      //               content: Row(
      //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                 children: [
      //                   ElevatedButton(
      //                     style: ElevatedButton.styleFrom(
      //                       primary: primaryColor,
      //                       // Change the button color here
      //                       onPrimary:
      //                           Colors.white, // Change the text color here
      //                     ),
      //                     onPressed: () {
      //                       Navigator.of(context).pop('Devis');
      //                     },
      //                     child: Text('Devis',
      //                         style: Theme.of(context)
      //                             .textTheme
      //                             .headline6!
      //                             .copyWith(color: Colors.white)),
      //                   ),
      //                   SizedBox(height: 8),
      //                   ElevatedButton(
      //                     style: ElevatedButton.styleFrom(
      //                       primary: Colors.blue,
      //                       // Change the button color here
      //                       onPrimary:
      //                           Colors.white, // Change the text color here
      //                     ),
      //                     onPressed: () {
      //                       Navigator.of(context).pop('Commande');
      //                     },
      //                     child: Text('Commande',
      //                         style: Theme.of(context)
      //                             .textTheme
      //                             .headline6!
      //                             .copyWith(color: Colors.white)),
      //                   ),
      //                 ],
      //               ),
      //             );
      //           },
      //         ).then((value) {
      //           if (value != null) {
      //             // Handle the selected option here
      //             print('Selected Option: $value');
      //             widget.client.command!.type = value;
      //             PageNavigator(ctx: context).nextPage(
      //                 page: NewCommandPage(
      //               client: widget.client,
      //               callback: reload,
      //             ));
      //           }
      //         });
      //       }
      //     },
      //     backgroundColor: Colors.white,
      //     child: Stack(
      //       children: [
      //         Center(
      //           child: Icon(
      //             Icons.shopping_cart_checkout_outlined,
      //             color: primaryColor,
      //           ),
      //         ),
      //         Positioned(
      //           top: -4,
      //           child: Align(
      //             alignment: Alignment.topLeft,
      //             child: Container(
      //               padding: EdgeInsets.all(4),
      //               decoration: BoxDecoration(
      //                   shape: BoxShape.circle, color: Colors.red),
      //               child: Text(
      //                 '${nbProduct}',
      //                 style: TextStyle(fontSize: 16, color: Colors.white),
      //               ),
      //             ),
      //           ),
      //         )
      //       ],
      //     ),
      //   ),
      // ),
      body: Stack(
        children: [
          Column(
            children: [
              Visibility(
                visible: false,
                child: Container(
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
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            color: primaryColor,
                          ),
                          Text(
                            'Sélctionner une date de livraison',
                            style: Theme.of(context)
                                .textTheme
                                .headline5!
                                .copyWith(color: primaryColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          currentCommand = widget.client.command!;
                          PageNavigator(ctx: context)
                              .nextPage(
                                  page: ClientsListForAddClientPage(
                            callback: reload,
                          ))
                              .then((value) {
                            print('finish add ${AppUrl.selectedClient}');
                            widget.client.name = AppUrl.selectedClient!.name;
                            widget.client.id = AppUrl.selectedClient!.id;
                            _client.text = widget.client.name!;
                            reload();
                          });
                        },
                        icon: Icon(
                          Icons.person_add_alt,
                          color: primaryColor,
                        ),
                      ),
                      // Your icon
                      SizedBox(width: 16.0),
                      // Adjust the space between icon and text field
                      Expanded(
                        child: customTextField(
                          obscure: false,
                          enable: false,
                          controller: _client,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Consumer<ProductProvider>(builder: (context, products, snapshot) {
                return Container(
                  height: 700,
                  child: (products.allProducts.length != 0)
                      ? ListView.builder(
                          controller: _scrollController,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (widget.client.command == null) {
                              widget.client.command = Command(
                                  date: DateTime.now(),
                                  total: 0,
                                  paid: 0,
                                  products: [],
                                  nbProduct: 0);
                            }
                            return CommandItem(
                              product: products.allProducts.toList()[index],
                              command: widget.client.command!,
                              callback: reload,
                            );
                          },
                          itemCount: products.allProducts.toList().length)
                      : Text(
                          'Aucun équipement !',
                          style: Theme.of(context)
                              .textTheme
                              .headline3!
                              .copyWith(color: Colors.white),
                        ),
                );
              }),
            ],
          ),
          Visibility(
            visible: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 80,
                color: primaryColor,
                child: Center(
                  child: Container(
                    child: Center(
                        child: Text(
                      '${AppUrl.formatter.format(total)} DZD',
                      style: Theme.of(context)
                          .textTheme
                          .headline3!
                          .copyWith(color: Colors.white),
                    )),
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 60,
                    decoration: BoxDecoration(
                      color: secondryColor,
                      borderRadius: BorderRadius.circular(
                          25), // Set the border radius here
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void reload() {
    setState(() {
      total = widget.client.command!.total;
      nbProduct = widget.client.command!.nbProduct;
      //widget.callback();
    });
  }

  Future<void> _scanBarcode() async {
    String barcodeResult = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666', // Color for the background of the scan view
      'Cancel', // Cancel button text
      true, // Show flash icon
      ScanMode.DEFAULT, // Scan mode: QR code, barcode, or both
    );
    setState(() {
      print('scan = ${barcodeResult}');
      _barcodeResult = barcodeResult;
      if (barcodeResult != '-1') {
        showSearch(
            context: context,
            delegate:
                StoreSearchDelegate(widget.client.command!, reload, 'barCode'),
            query: barcodeResult);
      }
    });
  }
}

class CommandItem extends StatefulWidget {
  Product product;
  final Command command;
  final VoidCallback callback;

  CommandItem(
      {super.key,
      required this.product,
      required this.command,
      required this.callback});

  @override
  State<CommandItem> createState() => _CommandItemState();
}

class _CommandItemState extends State<CommandItem> {
  bool isVisible = false;
  var provider = null;

  Future<void> _selectDate(BuildContext context, Product product) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.product.dateExpired,
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
        widget.product.dateExpired =
            DateTime(picked.year, picked.month, picked.day, 23, 59, 59, 999);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.command.products.any((product) {
      if (product.id == widget.product.id) {
        widget.product = product;
        return true;
      }
      return false;
    });
    provider = Provider.of<ProductProvider>(context, listen: false);
    //print('choose: ${widget.product.isChosen}');
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          height: 115,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(4),
                height: 140,
                width: 150,
                child: (widget.product.image == null)
                    ? Icon(Icons.image_not_supported_outlined, size: 150)
                    : Image.network(
                        '${widget.product.image}', // Replace with your image URL
                        fit: BoxFit
                            .cover, // Adjust the fit as needed (cover, contain, etc.)
                      ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    child: Text(
                      '${widget.product.name}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3, // Limit to one line
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(color: primaryColor),
                    ),
                  ),
                  (widget.product.category != null) ?Text('${widget.product.category}',
                      style: Theme.of(context).textTheme.headline6!): Container(),
                  Text('${widget.product.numSerie}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2!
                          .copyWith(color: Colors.grey)),
                ],
              ),
              (widget.product.garanted == null)
                  ? Container()
                  : (widget.product.garanted!)
                      ? InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ChangeGarantedDateDialog(
                                    type: '', product: widget.product);
                              },
                            ).then((value) {
                              setState(() {});
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.product.dateExpired!
                                      .difference(DateTime.now())
                                      .inDays >
                                  0)
                                Icon(
                                  Icons.gpp_good_outlined,
                                  color: Colors.green,
                                )
                              else
                                Icon(
                                  Icons.gpp_bad_outlined,
                                  color: Colors.red,
                                ),
                              (widget.product.dateExpired != null)
                                  ? (widget.product.dateExpired!
                                              .difference(DateTime.now())
                                              .inDays >
                                          0)
                                      ? Text(
                                          '${DateFormat('yyyy-MM-dd').format(widget.product.dateExpired!)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .copyWith(
                                                color: Colors.green,
                                              ),
                                        )
                                      : Text(
                                          '${DateFormat('yyyy-MM-dd').format(widget.product.dateExpired!)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .copyWith(
                                                color: Colors.red,
                                              ),
                                        )
                                  : Container(),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.gpp_bad_outlined,
                              color: Colors.red,
                            ),
                            (widget.product.dateExpired != null)
                                ? Text(
                                    '${DateFormat('yyyy-MM-dd').format(widget.product.dateExpired!)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith(
                                          color: Colors.red,
                                        ),
                                  )
                                : Container(),
                          ],
                        ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Client : ${widget.product.res['tiers']['rs']}',
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              style: Theme.of(context)
                  .textTheme
                  .headline5!
                  .copyWith(color: primaryColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          onTap: () {
            print('figf : ${widget.product.numSerie}');
            PageNavigator(ctx: context).nextPage(
                page: ReclamationPage(
              numSerie: '${widget.product.numSerie}',
            ));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Les réclamations liées',
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                style: Theme.of(context)
                    .textTheme
                    .headline5!
                    .copyWith( fontWeight: FontWeight.bold),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: primaryColor,
                size: 20,
              )
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          onTap: () {
            print('figf : ${widget.product.numSerie}');
            showLoaderDialog(context);
            if (widget.product.numSerie != null)
              fetchDataRec(widget.product.numSerie!).then((value) {
                print('fefeeeee');
                Navigator.pop(context);
                PageNavigator(ctx: context).nextPage(page: HomePage());
              });
            // PageNavigator(ctx: context).nextPage(
            //     page: ReclamationPage(
            //   numSerie: '${widget.product.numSerie}',
            // ));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Les interventions liées',
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                style: Theme.of(context)
                    .textTheme
                    .headline5!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: primaryColor,
                size: 20,
              )
            ],
          ),
        ),
        Divider(
          color: Colors.grey,
        ),
      ],
    );
  }

  Future<void> fetchDataRec(String numSerie) async {
    print('debuginggg');
    final provider = Provider.of<ClientsMapProvider>(context, listen: false);
    provider.recList = [];
    int? equipe;
    String collaborator = AppUrl.user.salCode!;
    print('ss: ${AppUrl.filtredOpporunity.collaborateur!.id}');
    if (AppUrl.filtredOpporunity.collaborateur!.id != null) {
      if (AppUrl.filtredOpporunity.collaborateur!.id! != -1) {
        collaborator = AppUrl.filtredOpporunity.collaborateur!.salCode!;
      }
    } else {
      collaborator = AppUrl.filtredOpporunity.collaborateur!.salCode!;
    }

    if (AppUrl.filtredOpporunity.team!.id! != -1)
      equipe = AppUrl.filtredOpporunity.team!.id!;

    if (collaborator == 'Moi') collaborator = AppUrl.user.salCode!;
    print('debuginggg222 $collaborator');
    String url = '';
    url = AppUrl.reclamation + '?numSerie=${numSerie}';
    // String url = AppUrl.reclamation +
    //     '?dateDebut=${DateFormat('yyyy-MM-ddT00:00:00').format(AppUrl.filtredOpporunity.date)}&dateFin=${DateFormat('yyyy-MM-ddT23:59:59').format(AppUrl.filtredOpporunity.dateEnd)}';
    print('url: $url');
    http.Response req = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "content-type": "application/json; charset=UTF-8",
      "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
    });
    print("res rec code : ${req.statusCode}");
    print("res rec body: ${req.body}");
    if (req.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      List<dynamic> data = json.decode(req.body);
      print('size of reclamations : ${data.toList().length}');
      //addOppurtonities(data);
      //data.toList().forEach((element) async {
      for (var element in data.toList()) {
        try {
          print('id client:  ${element['pcfCode']}');
          print('id opp:  ${element['code']}');
          print('etapeId: ${element['etapeId']}');
          String pcfCode = element['pcfCode'];
          String urlClient = AppUrl.getOneTier + pcfCode;
          print('urlClient: $urlClient');
          req = await http.get(Uri.parse(urlClient), headers: {
            "Accept": "application/json",
            "content-type": "application/json; charset=UTF-8",
            "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
          });
          print("res tier code: ${req.statusCode}");
          print("res tier body: ${req.body}");
          if (req.statusCode == 200) {
            print('element iss: $element');
            //   var res = json.decode(req.body);
            Client client = new Client(
              idOpp: element['demNumero'],
              id: element['pcfCode'],
              name: element['tiers']['rs'],
              phone: element['tiers']['tel1'],
              adress: element['adress']['title'],
              artCode: element['artCode'],
              //stat: element['etapeId'],
              priority: element['priorite'],
              emergency: element['urgence'],
              lib: element['objet'],
              resOppo: element,
              symptome: element['symptomes'],
              dateStart: DateTime.parse(element['date']),
            );
            //if(element['etapeId'] == 1 || element['etapeId'] == 2)
            provider.recList.add(client);
            print('size of rec: ${provider.recList.length}');
          } else {
            print('grjtorotor');
            Client client = new Client(
              idOpp: element['demNumero'],
              id: element['pcfCode'],
              adress: element['adrCode'],
              artCode: element['artCode'],
              //stat: element['etapeId'],
              priority: element['priorite'],
              emergency: element['urgence'],
              lib: element['objet'],
              resOppo: element,
              symptome: element['symptomes'],
              dateStart: DateTime.parse(element['date']),
              //dateCreation: DateTime.parse(element['dateCreation'])
            );
            provider.mapClientsWithCommands.add(client);
            print('size of rec: ${provider.mapClientsWithCommands.length}');
          }
        } catch (e) {
          print('err : $e');
        }
      }
      provider.recList.sort((a, b) => a.dateStart!.compareTo(b.dateStart!));
    } else {
      print('Failed to load data');
    }
    provider.updateList();
  }
}

class StoreSearchDelegate extends SearchDelegate {
  final Command command;
  final VoidCallback callback;
  late String barCode;

  StoreSearchDelegate(this.command, this.callback, this.barCode);

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
    throw UnimplementedError();
  }

  // Function to fetch JSON data from an API
  Future<void> fetchData(BuildContext context) async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    provider.filtredProducts = [];
    http.Response req = await http.get(
        Uri.parse(
            AppUrl.articlesSuiv + '?PageNumber=1&Filter=$query&PageSize=20'),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
        });
    print("res article code : ${req.statusCode}");
    print("res article body: ${req.body}");
    if (req.statusCode == 200) {
      List<dynamic> data = json.decode(req.body);
      data.toList().forEach((element) async {
        print('code article:  ${element['artCode']} ');
        String? img;
        int? stock;
        double price = 0;
        if (element['article']['pVte'] != null)
          price = element['article']['pVte'];
        getUrlImage(element['artCode']).then((value) {
          getQuantityMax(element['artCode']).then((stk) {
            stock = stk;
          });
          img = value;
        });
        Product p = Product(
            name: element['article']['lib'],
            numSerie: element['numSerie'],
            image: img,
            remise: 0,
            tva: 0,
            category: element['article']['categ'],
            codeBar: element['article']['cbar'],
            isChosen: false,
            quantity: 0,
            quantityStock: stock,
            price: price,
            total: 0,
            garanted: element['garantie'],
            dateExpired: DateTime.parse(element['dateFinGarantie']),
            id: element['artCode']);
        p.res = element;
        provider.filtredProducts.add(p);
        provider.notifyListeners();
      });
    }
    print('size is : ${provider.filtredProducts.length}');
    provider.notifyListeners();
  }

  Future<void> fetchDataBarCode(BuildContext context) async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    provider.filtredProducts = [];

    print('hhh $query id=${AppUrl.user.userId}');
    print('url is : ' +
        AppUrl.articlesSuiv +
        '/cbar/${AppUrl.user.userId}?cBar=$query');
    http.Response req = await http.get(
        Uri.parse(
            AppUrl.articlesSuiv + '/cbar/${AppUrl.user.userId}?cBar=$query'),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/"
        });
    print("res bqrcode code : ${req.statusCode}");
    print("res bqrcode body: ${req.body}");
    if (req.statusCode == 200) {
      final data = json.decode(req.body);
      print('code article:  ${data['artCode']}');
      int? stock;
      getUrlImage(data['artCode']).then((value) {
        getQuantityMax(data['artCode']).then((stk) {
          stock = stk;
          provider.filtredProducts.add(Product(
              name: data['lib'],
              image: value,
              remise: 0,
              tva: 0,
              category: data['categ'],
              codeBar: data['cbar'],
              isChosen: false,
              quantity: 0,
              quantityStock: stock,
              price: data['Pvte'],
              total: 0,
              id: data['artCode']));
          provider.notifyListeners();
        });
      });
    }
    print('size is : ${provider.filtredProducts.length}');
    provider.notifyListeners();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    // fetchData(context).then((value) {
    //   final list = provider.filtredProducts
    //       .toList()
    //       .where((product) =>
    //           product.name!.toLowerCase().contains(query.toLowerCase()) ||
    //           product.category!.toLowerCase().contains(query.toLowerCase()))
    //       .toList();
    //   provider.notifyListeners();
    //   buildResults(context);
    //   //return resultFilter(list, context);
    //  return FutureBuilder(future: fetchData(context), builder: (context, snapshot){
    //    return resultFilter(list, context);
    //  });
    // });
    return FutureBuilder(
        future:
            (barCode == '') ? fetchData(context) : fetchDataBarCode(context),
        builder: (context, snapshot) {
          final list = provider.filtredProducts
              .toList()
              .where((product) =>
                  product.name!.toLowerCase().contains(query.toLowerCase()) ||
                  product.codeBar!
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  product.price
                      .toString()!
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  product.category!.toLowerCase().contains(query.toLowerCase()))
              .toList();
          return resultFilter(list, context);
        });
  }

  Widget resultFilter(List<Product> list, BuildContext context) {
    if (list.isEmpty)
      return Center(
        child: Text(
          'Aucune résultat !',
          style: Theme.of(context).textTheme.headline2,
        ),
      );
    else
      return Consumer<ProductProvider>(builder: (context, products, snapshot) {
        products.notifyListeners();
        return ListView.builder(
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) => CommandItem(
                  product: list[index],
                  command: command,
                  callback: callback,
                ),
            itemCount: list.length);
      });
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

Future<String?> getUrlImage(String artCode) async {
  print('imghhh $artCode');
  var body = jsonEncode({
    'artCode': artCode,
  });
  print('url: ${AppUrl.getUrlImage + '$artCode'}');
  http.Response req =
      await http.get(Uri.parse(AppUrl.getUrlImage + '$artCode'), headers: {
    "Accept": "application/json",
    "content-type": "application/json; charset=UTF-8",
    "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/",
  });
  print("res imgArticle code : ${req.statusCode}");
  print("res imgArticle body: ${req.body}");
  if (req.statusCode == 200) {
    List<dynamic> data = json.decode(req.body);
    if (data.length > 0) {
      var item = data.first;
      print('item: ${AppUrl.baseUrl + item['path']}');
      return AppUrl.baseUrl + item['path'];
    }
  }
  return null;
}

Future<int?> getQuantityMax(String artCode) async {
  print(
      'url: ${AppUrl.getQuantityMax + '${AppUrl.user.etblssmnt!.code}/$artCode'}');
  http.Response req = await http.get(
      Uri.parse(
          AppUrl.getQuantityMax + '${AppUrl.user.etblssmnt!.code}/$artCode'),
      headers: {
        "Accept": "application/json",
        "content-type": "application/json; charset=UTF-8",
        "Referer": "http://" + AppUrl.user.company! + ".localhost:4200/",
      });
  print("res maxQuantity code : ${req.statusCode}");
  print("res maxQuantity body: ${req.body}");
  if (req.statusCode == 200) {
    List<dynamic> data = json.decode(req.body);
    int somme = 0;
    data.toList().forEach((element) {
      double qt = element['stkReel'];
      int max = qt.toInt();
      somme = somme + max;
    });
    return somme;
  }
  return null;
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
              Navigator.pop(context);
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
