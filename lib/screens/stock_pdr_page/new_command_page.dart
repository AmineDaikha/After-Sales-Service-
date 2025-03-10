import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:sav_app/constants/http_request.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/models/client.dart';
import 'package:sav_app/models/command.dart';
import 'package:sav_app/models/product.dart';
import 'package:sav_app/providers/command_provider.dart';
import 'package:sav_app/providers/product_provider.dart';
import 'package:sav_app/styles/colors.dart';
import 'package:sav_app/utils/routers.dart';
import 'package:sav_app/utils/snack_message.dart';
import 'package:sav_app/widgets/add_payment_dialog.dart';
import 'package:sav_app/widgets/command_dialog.dart';
import 'package:sav_app/widgets/confirmation_dialog.dart';
import 'package:provider/provider.dart';

import 'add_opportunity_page.dart';

class NewCommandPage extends StatefulWidget {
  final Client client;
  final VoidCallback callback;

  const NewCommandPage({
    super.key,
    required this.client,
    required this.callback,
  });

  //static const String routeName = '/home/command';

  // static Route route() {
  //   return MaterialPageRoute(
  //     settings: RouteSettings(name: routeName),
  //     builder: (_) {
  //       return CommandPage();
  //     },
  //   );
  // }

  @override
  State<NewCommandPage> createState() => _NewCommandPageState();
}

class _NewCommandPageState extends State<NewCommandPage> {
  double total = 0;
  late DateTime selectedDate = DateTime.now();
  LatLng? currentLocation;
  //late IconButton validateIcon;
  //late Command oldCommand;

  @override
  void initState() {
    // WidgetsBinding.instance!.addPostFrameCallback((_) {
    //   // Access BuildContext or dependent widgets here

    // });
    super.initState();
    total = widget.client.command!.total;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      reload();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor, // Day color
            buttonTheme: ButtonThemeData(colorScheme: ColorScheme.light(
              primary: primaryColor, // Change the color here
            ),), colorScheme: ColorScheme.light(primary:primaryColor).copyWith(secondary: primaryColor),
            // Button text color
          ),
          child: child!,);
      },
    );
    if (picked != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: primaryColor,
                // change the text color
                onSurface: grey,
              ),
              indicatorColor: primaryColor,
              primaryColor: primaryColor,
              backgroundColor: primaryColor,
              buttonTheme: ButtonTheme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  background: primaryColor,
                  secondary: primaryColor,
                ),
              ),
            ),
            child: child!,
          );
        },
      );
      print('time is: ${selectedTime!.hour}');
      if (selectedTime != null) {
        setState(() {
          selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  void reload() {
    setState(() {
      widget.client.command!.calculateTotal();
      total = widget.client.command!.total;
      widget.callback();
      print('total is: ${total}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(builder: (context, products, snapshot) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white, // Set icon color to white
          ),
          backgroundColor: Theme.of(context).primaryColor,
          title: ListTile(
            title: Text(
              "${widget.client.command!.type}",
              style: Theme.of(context)
                  .textTheme
                  .headline2!
                  .copyWith(color: Colors.white),
            ),
            subtitle: Text(
              '${widget.client.name}',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.white),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () async{
                ConfirmationDialog confirmationDialog = ConfirmationDialog();
                String typeConf = '';
                if (widget.client.command!.type == 'Devis') {
                  typeConf = 'confirmDevis';
                } else {
                  typeConf = 'confirmCommand';
                }
                bool confirmed = await confirmationDialog
                    .showConfirmationDialog(context, typeConf);
                if(confirmed){
                  // confirm
                  _getCurrentLocation().then((value){
                    if(value){
                      widget.client.dateStart = selectedDate;
                      if (widget.client.command!.type == 'Devis')
                        widget.client.lib = 'Etablissement de devis';
                      else if (widget.client.command!.type == 'Command')
                        widget.client.lib = 'Prise de commande';
                      print('type is : ${widget.client.type}');
                      PageNavigator(ctx: context).nextPage(page: AddOpportunityPage(client: widget.client,)).then((value){
                        print('value is: $value');
                        if(value!= null){
                          widget.client.idOpp = value;
                          sendDocument(context);
                        }
                      });
                    }
                  });
                }
              },
              icon: Icon(
                Icons.check_box_outlined,
                color: Colors.white,
              ),
            ),
            // IconButton(
            //     onPressed: () {},
            //     icon: Icon(
            //       Icons.check_box_outlined,
            //       color: Colors.white,
            //     )),,
          ],
        ),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                                onPressed: () {
                                  _selectDate(context);
                                },
                                icon: Icon(
                                  Icons.calendar_month_outlined,
                                  color: primaryColor,
                                )),
                          ),
                          Container(
                            width: 120,
                            child: Text(
                              'Date et heur de livraison souhaitée',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          // todo must change
                          '${DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate)}',
                          style: Theme.of(context)
                              .textTheme
                              .headline5!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
                Consumer<CommandProvider>(
                  builder: (context, commands,snapshot) {
                    return Container(
                      height: 550,
                      child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            //print('nullable ??? ${widget.client.command!.products}');
                            final provider = Provider.of<ProductProvider>(context,
                                listen: false);
                            provider.products = widget.client.command!.products;
                            return CommandItem(
                              //product: widget.client.command!.products![index],
                              product: provider.products![index],
                              command: widget.client.command!,
                              callback: reload,
                            );
                          },
                          itemCount: widget.client.command?.products!.length),
                    );
                  }
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 100,
                color: primaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.client.command!.nbProduct!}',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Articles',
                          style:
                          Theme.of(context).textTheme.headline4!.copyWith(
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                    Container(
                      width: 2,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date : ${DateFormat('dd-MM-yyyy HH:mm:ss').format(selectedDate)}',
                          style: Theme.of(context)
                              .textTheme
                              .headline5!
                              .copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.normal),
                        ),
                        Text(
                          'Total : ${AppUrl.formatter.format(widget.client.command!.totalWitoutTaxes)} DZD',
                          style:
                          Theme.of(context).textTheme.headline5!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          'TVA : ${AppUrl.formatter.format(widget.client.command!.totalTVA)} DZD',
                          style:
                          Theme.of(context).textTheme.headline5!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          'TTC : ${AppUrl.formatter.format(total)} DZD',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: false,
                      child: IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AddPaymentDialog(client: widget.client,);
                              });
                        },
                        icon: Ink(
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.add_shopping_cart_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // Function to fetch JSON data from an API
  Future<void> sendDocument(BuildContext context) async {
    print('salcode is: ${AppUrl.user.salCode}');
    List<Map<String, dynamic>> products = [];
    List<Map<String, dynamic>> produitDtos = [];
    for (Product product in widget.client.command!.products) {
      Map<String, dynamic> jsonProduct = {
        "artCode": product.id,
        "lib": product.name,
        "artCbar": product.codeBar,
        "qte": product.quantity,
        "pBrut": product.price,
        "Qcmde": product.quantity,
        "PNet": product.priceNet,
        "repCode": AppUrl.user.repCode,
        "remise": product.remise,
        "NatTvaTx": product.tva,
      };
      products.add(jsonProduct);
      Map<String, dynamic> jsonProduct2 = {
        "codeProduit": product.id,
        "lib": product.name,
        "cBar": product.codeBar,
        "tva": product.tva,
        "prixVente": product.price,
        "prixVenteRemise": product.priceNet,
        "remise": product.remise,
        "qts": product.quantity,
        "DepStock": product.quantityStock,
      };
      produitDtos.add(jsonProduct2);
    }
    Map<String, dynamic> jsonObject = {
      "etbCode": AppUrl.user.etblssmnt!.code,
      "date": DateTime.now().toString(),
      "pcfCode": widget.client.id, // tier
      "repCode": AppUrl.user.repCode,
      "salCode": AppUrl.user.salCode,
      "depCode": AppUrl.user.localDepot!.id!,
      "oppoCode": widget.client.idOpp,
      "longitude": currentLocation!.longitude,
      "latitude": currentLocation!.latitude,
      "signature": null,
      "lignes": products,
      "produitDtos": produitDtos
    };
    String url = '';
    if (widget.client.command!.type == 'Commande') {
      url = AppUrl.commands;
    } else if(widget.client.command!.type == 'Devis'){
      url = AppUrl.devis;
    }
    print('url : $url');
    http.Response req = await http.post(Uri.parse(url),
        body: jsonEncode(jsonObject),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json; charset=UTF-8",
          "Referer": "http://"+AppUrl.user.company!+".localhost:4200/"
        });
    print("res cmd code : ${req.statusCode}");
    print("res cmd body: ${req.body}");
    if (req.statusCode == 200 || req.statusCode == 201) {
      HttpRequestApp httpRequestApp = HttpRequestApp();
      await httpRequestApp.sendItinerary('COM');
      var res = json.decode(req.body);
      if (widget.client.email != null)
        await httpRequestApp.sendEmail(res['numero'],
            widget.client.command!.type!, '${widget.client.email}');
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }else{
      showMessage(
          message: 'Échec de creation de la commande',
          context: context,
          color: Colors.red);
    }
  }

  Future<bool> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('latLng: ${position.latitude} ${position.longitude}');
      currentLocation = LatLng(position.latitude, position.longitude);
      return true;
    } catch (e) {
      print('Error getting current location: $e');
    }
    return false;
  }
}
class CommandItem extends StatefulWidget {
  final Product product;
  final Command command;
  final VoidCallback callback;

  const CommandItem(
      {super.key,
        required this.product,
        required this.command,
        required this.callback});

  @override
  State<CommandItem> createState() => _CommandItemState();
}

class _CommandItemState extends State<CommandItem> {
  bool isVisible = false;
  @override
  Widget build(BuildContext context) {

    ConfirmationDialog confirmationDialog = ConfirmationDialog();
    return GestureDetector(onTap: (){
      setState(() {
        isVisible = !isVisible;
      });
    },

      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Slidable(
              startActionPane: ActionPane(motion: ScrollMotion(), children: [
                SlidableAction(
                  flex: 5,
                  onPressed: (_) async {
                    bool confirmed = await confirmationDialog
                        .showConfirmationDialog(context, 'deleteProduct');
                    if (confirmed) {
                      setState(() {
                        final provider =
                        Provider.of<ProductProvider>(context, listen: false);
                        provider.removeProduct(widget.product, widget.command);
                        widget.callback();
                      });
                    }
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline,
                  label: 'Supprimer',
                ),
              ]),
              child: Container(
                width: double.infinity,
                height: 115,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        height: 60,
                        width: 70,
                        child: (widget.product.image == null)
                            ? Icon(
                          Icons.image_not_supported_outlined,
                        )
                            : Image.network(
                          '${widget.product.image}',
                          // Replace with your image URL
                          fit: BoxFit
                              .cover, // Adjust the fit as needed (cover, contain, etc.)
                        )),
                    // Text('(${widget.product.quantity})',
                    //     style: Theme.of(context)
                    //         .textTheme
                    //         .headline4!
                    //         .copyWith(color: primaryColor)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                        Text('${widget.product.category} ',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(color: Colors.grey)),
                        SizedBox(height: 10,),
                        Text(
                          'Prix unitaire :',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(),
                        ),
                        Text(
                          '${AppUrl.formatter.format(widget.product.price)} DZD',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(color: primaryColor),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total ${AppUrl.formatter.format(widget.product.totalWitoutTaxes)} DZD ',
                          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          'TVA ${AppUrl.formatter.format(widget.product.priceTVA)} DZD ',
                          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          'TTC ${AppUrl.formatter.format(widget.product.total)} DZD',
                          style: Theme.of(context).textTheme.headline5!.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          // to increment
                          onPressed: () {
                            setState(() {
                              final provider = Provider.of<ProductProvider>(
                                  context,
                                  listen: false);
                              provider.incrementQuantity(
                                  widget.product, widget.command);
                              widget.callback();
                            });
                          },
                          icon: Container(
                            height: 23,
                            width: 23,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        Text(
                          '${widget.product.quantity}',
                          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          // to decrement
                          onPressed: () {
                            setState(() async {
                              final provider = Provider.of<ProductProvider>(
                                  context,
                                  listen: false);
                              bool confirmed;
                              if (widget.product.quantity == 1) {
                                if (widget.command.nbProduct == 1) {
                                  // remove command
                                  confirmed = await confirmationDialog
                                      .showConfirmationDialog(
                                      context, 'deleteCommand');
                                } else {
                                  // remove product
                                  confirmed = await confirmationDialog
                                      .showConfirmationDialog(
                                      context, 'deleteProduct');
                                  if (confirmed) {
                                    provider.removeProduct(
                                        widget.product, widget.command);
                                    widget.callback();
                                  }
                                }
                              } else {
                                provider.decrementQuantity(
                                    widget.product, widget.command);
                                widget.callback();
                              }
                            });
                          },
                          icon: Container(
                            height: 23,
                            width: 23,
                            decoration: BoxDecoration(
                              border: Border.all(color: grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Icon(
                              Icons.remove_outlined,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: isVisible,
            child: Container(
              margin: EdgeInsets.all(8),
              width: double.infinity,
              height: 180,
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
                                .copyWith(fontWeight: FontWeight.bold,color: primaryColor),
                          ),
                        ),
                        Text('${widget.product.category} ',
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Quantité stock',
                                  style: Theme.of(context).textTheme.bodyText1),
                              GestureDetector(
                                onTap: (){
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CommandDialog(widget.product);
                                    },
                                  ).then((value){
                                    setState(() {
                                      widget.product.calculateTotal();
                                      widget.callback();
                                    });
                                  });
                                },
                                child: Container(
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
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        GestureDetector(
                          onTap: (){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CommandDialog(widget.product);
                              },
                            ).then((value){
                              setState(() {
                                widget.product.calculateTotal();
                                widget.callback();
                              });
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(bottom: 2),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: primaryColor,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Remise',
                                    style: Theme.of(context).textTheme.bodyText1),
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
                        GestureDetector(
                          onTap: (){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CommandDialog(widget.product);
                              },
                            ).then((value){
                              setState(() {
                                widget.product.calculateTotal();
                                widget.callback();
                              });
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(bottom: 2),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: primaryColor,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('TVA',
                                    style: Theme.of(context).textTheme.bodyText1),
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
          )
        ],
      ),
    );
  }
}
