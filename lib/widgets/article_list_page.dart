import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/models/client.dart';
import 'package:sav_app/models/command.dart';
import 'package:sav_app/models/product.dart';
import 'package:sav_app/providers/product_provider.dart';
import 'package:sav_app/screens/catalog_page/dialog_filtred_catalog.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/routers.dart';
import 'package:sav_app/widgets/clients_list_page.dart';
import 'package:sav_app/widgets/command_dialog.dart';
import 'package:sav_app/widgets/text_field.dart';

class ArticlesListPage extends StatefulWidget {
  final Client client;
  final VoidCallback callback;

  const ArticlesListPage(
      {super.key, required this.client, required this.callback});

  @override
  State<ArticlesListPage> createState() => _ArticlesListPageState();
}

class _ArticlesListPageState extends State<ArticlesListPage> {
  String result = '';
  double total = 0;
  int nbProduct = 0;
  int PageNumber = 1;
  int PageSize = 200;
  String filter = '';
  String _barcodeResult = 'No Barcode Yet';
  final TextEditingController _client = TextEditingController();
  Command currentCommand = new Command(
      date: DateTime.now(), total: 0, paid: 0, products: [], nbProduct: 0);

  @override
  void initState() {
    super.initState();
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

  // Function to fetch JSON data from an API
  Future<void> fetchData() async {
    //await _fetchData();
    final provider = Provider.of<ProductProvider>(context, listen: false);
    provider.allProducts = [];
    String url = '';
    url = AppUrl.articlesSuiv +
        '?PageNumber=$PageNumber&Filter=$filter&PageSize=$PageSize&pcfCode=${widget.client.id!}';

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
        print('code article:  ${element['artCode']}');
        print('price is: ${element['pVte']}');
        double price = 0;
        if (element['article']['pVte'] != null)
          price = element['article']['pVte'];
        getUrlImage(element['artCode'].toString()).then((value) {
          getQuantityMax(element['artCode'].toString()).then((stk) {
            String? categ;
            try {
              categ = element['article']['marque']['lib'];
            } catch (_) {}
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
            provider.allProducts.add(p);
            provider.notifyListeners();
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String nameClient = '';
    if (widget.client.id != null) {
      nameClient = widget.client.name!;
    }
    return Scaffold(
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
              'Choisir l\'équipement',
              style: Theme.of(context)
                  .textTheme
                  .headline5!
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
          // IconButton(
          //     onPressed: () {
          //       //_showDatePicker(context);
          //       showDialog(
          //         context: context,
          //         builder: (BuildContext context) {
          //           return FiltredCatalogDialog();
          //         },
          //       ).then((value) {
          //         setState(() {});
          //       });
          //     },
          //     icon: Icon(
          //       Icons.sort,
          //       color: Colors.white,
          //     ))
        ],
      ),
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
              Consumer<ProductProvider>(builder: (context, products, snapshot) {
                return Container(
                  height: 650,
                  child: (products.allProducts.length != 0)
                      ? ListView.builder(
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
                              callback: widget.callback,
                            );
                          },
                          itemCount: products.allProducts.toList().length)
                      : Center(
                          child: Text(
                            'Aucun équipement !',
                            style: Theme.of(context)
                                .textTheme
                                .headline3!
                                .copyWith(),
                          ),
                        ),
                );
              }),
            ],
          ),
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Container(
          //     width: double.infinity,
          //     height: 80,
          //     color: primaryColor,
          //     child: Center(
          //       child: Container(
          //         child: Center(
          //             child: Text(
          //           '${AppUrl.formatter.format(total)} DZD',
          //           style: Theme.of(context)
          //               .textTheme
          //               .headline3!
          //               .copyWith(color: Colors.white),
          //         )),
          //         width: MediaQuery.of(context).size.width * 0.6,
          //         height: 60,
          //         decoration: BoxDecoration(
          //           color: secondryColor,
          //           borderRadius:
          //               BorderRadius.circular(25), // Set the border radius here
          //         ),
          //       ),
          //     ),
          //   ),
          // )
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
    return InkWell(
      onTap: () {
        AppUrl.selectedProduct = widget.product;
        widget.callback();
        Navigator.pop(context);
      },
      child: Column(
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
                  // Image.asset(
                  //   'assets/product.png',
                  //   fit: BoxFit.cover,
                  // )
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
                    Text('${widget.product.category}',
                        style: Theme.of(context)
                            .textTheme
                            .headline6!),
                    Text('${widget.product.numSerie}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2!
                            .copyWith(color: Colors.grey)),
                  ],
                ),
                (widget.product.garanted!)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.gpp_good_outlined,
                            color: Colors.green,
                          ),
                          (widget.product.dateExpired != null)
                              ? Text(
                                  '${DateFormat('yyyy-MM-dd').format(widget.product.dateExpired!)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(
                                        color: Colors.green,
                                      ),
                                )
                              : Container(),
                        ],
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
          Visibility(
            visible: isVisible,
            child: Container(
              margin: EdgeInsets.all(8),
              width: double.infinity,
              height: 160,
              color: backgroundColor,
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(8),
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    child: (widget.product.image == null)
                        ? Icon(Icons.image_not_supported_outlined)
                        : Image.network(
                            '${widget.product.image}', // Replace with your image URL
                            fit: BoxFit
                                .cover, // Adjust the fit as needed (cover, contain, etc.)
                          ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    padding:
                        EdgeInsets.only(left: 8, right: 0, top: 8, bottom: 8),
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          child: Text(
                            '${widget.product.name}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: primaryColor),
                          ),
                        ),
                        Text('${widget.product.category}',
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: Colors.grey)),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 2),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: primaryColor,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CommandDialog(widget.product);
                                },
                              ).then((value) {
                                setState(() {
                                  widget.product.calculateTotal();
                                  widget.callback();
                                });
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Quantité sotck ',
                                    style:
                                        Theme.of(context).textTheme.bodyText1),
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 4),
                                    child: Center(
                                        child: Text(
                                      '${widget.product.quantityStock}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor),
                                    )),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 2),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: primaryColor,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CommandDialog(widget.product);
                                },
                              ).then((value) {
                                setState(() {
                                  widget.product.calculateTotal();
                                  widget.callback();
                                });
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Remise ',
                                    style:
                                        Theme.of(context).textTheme.bodyText1),
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 4),
                                    child: Center(
                                        child: Text(
                                      '${widget.product.remise} %',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor),
                                    )),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 2),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: primaryColor,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CommandDialog(widget.product);
                                },
                              ).then((value) {
                                setState(() {
                                  widget.product.calculateTotal();
                                  widget.callback();
                                });
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('TVA',
                                    style:
                                        Theme.of(context).textTheme.bodyText1),
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 4),
                                    child: Center(
                                        child: Text(
                                      '${widget.product.tva} %',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor),
                                    )),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            color: Colors.grey,
          ),
        ],
      ),
    );
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
        print('code article:  ${element['artCode']}');
        String? img;
        int? stock;
        double price = 0;
        if (element['article']['pVte'] != null)
          price = element['article']['pVte'];
        await getUrlImage(element['artCode']).then((value) {
          getQuantityMax(element['artCode']).then((stk) {
            stock = stk;
          });
          img = value;
        });
        String? categ;
        try {
          categ = element['article']['marque']['lib'];
        } catch (_) {}
        provider.filtredProducts.add(Product(
            name: element['article']['lib'],
            numSerie: element['numSerie'],
            image: img,
            remise: 0,
            tva: 0,
            category: categ,
            codeBar: element['article']['cbar'],
            isChosen: false,
            quantity: 0,
            quantityStock: stock,
            price: price,
            total: 0,
            garanted: element['garantie'],
            dateExpired: DateTime.parse(element['dateFinGarantie']),
            id: element['artCode']));
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
      print('item: ${item['path']}');
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
