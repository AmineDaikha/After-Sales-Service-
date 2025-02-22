class Product {
  String id;
  String? codeBar;
  String? name;
  String? category;
  int quantity;
  int? quantityOfColis = 12;
  int? quantityStock = 0;
  String? typeStock;
  double price;
  String? image;
  double total;
  double? remise = 0;
  double? tva = 0;
  double? priceNet;
  double? totalWitoutTaxes;
  double? priceTVA;
  String? numSerie;
  bool? isChosen = false;
  bool? garanted = false;
  DateTime? dateExpired;
  String? adrNumero;
  var res = null;

  Product(
      {this.remise,
      this.adrNumero,
      this.codeBar,
      this.name,
      this.quantityOfColis,
      this.category,
      required this.quantity,
      this.quantityStock,
      required this.price,
      required this.total,
      this.image,
      this.isChosen,
      required this.id,
      this.numSerie,
      this.priceNet,
      this.priceTVA,
      this.dateExpired,
      this.tva,
      this.garanted,
      this.totalWitoutTaxes}) {
    if (total == 0) total = price * quantity;
    priceNet = price * (1 - remise! / 100);
    totalWitoutTaxes = priceNet! * quantity;
    priceTVA = totalWitoutTaxes! * (tva! / 100);
    total = totalWitoutTaxes! + priceTVA!;
  }

  double getPrice(){
    if(tva != null)
      return price + (price*tva!/100);
    else
      return price;
  }

  void calculateTotal() {
    priceNet = price * (1 - remise! / 100);
    print('net: $priceNet and : $remise');
    totalWitoutTaxes = priceNet! * quantity;
    print('without tax : $totalWitoutTaxes');
    priceTVA = totalWitoutTaxes! * (tva! / 100);
    total = totalWitoutTaxes! + priceTVA!;
  }
}
