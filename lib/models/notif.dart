import 'client.dart';

class Notif {
  int? code;
  Client? client;
  String type;
  String? sType;
  String? lib;
  String? codeLie;
  DateTime? date;
  bool? seen = false;
  String? desc;
  var res;

  Notif(
      {required this.code,
      required this.type,
      this.sType,
      this.lib,
      this.codeLie,
      this.seen,
      this.client,
      this.date,
      this.desc});
}
